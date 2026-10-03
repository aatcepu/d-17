import Foundation
import VideoToolbox
import CoreMedia
import CoreVideo
import Network
import QuartzCore
import CHandshake

/// Receives UDP stream data, decodes HEVC/ProRes via VTDecompressionSession,
/// and renders frames to a CALayer for direct GPU display.
/// Zero-Retransmission tolerant: displays the latest complete frame only.
public final class MediaReceiver: @unchecked Sendable {

    // MARK: - Types

    public typealias FrameReadyHandler = @Sendable (CVPixelBuffer) -> Void

    // MARK: - Properties

    private var decompressionSession: VTDecompressionSession?
    private var formatDescription: CMVideoFormatDescription?
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.lablink.receiver", qos: .userInteractive)

    private var frameAssembler: [UInt32: FrameAssembly] = [:]
    private var latestFrameID: UInt32 = 0
    private var streamMetadata: LabLinkStreamMetadata?
    private var isReceiving = false

    private let frameReadyHandler: FrameReadyHandler

    /// Tracks chunks for a single frame.
    private struct FrameAssembly {
        let totalChunks: Int
        var chunks: [UInt16: Data] = [:]
        var isComplete: Bool { chunks.count == totalChunks }

        var assembledData: Data {
            var data = Data()
            for i in 0..<UInt16(totalChunks) {
                if let chunk = chunks[i] {
                    data.append(chunk)
                }
            }
            return data
        }
    }

    // MARK: - Init

    /// - Parameter frameReadyHandler: Called with decoded CVPixelBuffer for display.
    public init(frameReadyHandler: @escaping FrameReadyHandler) {
        self.frameReadyHandler = frameReadyHandler
    }

    // MARK: - Start Listening

    /// Start receiving stream on the LabLink service port.
    public func startListening() throws {
        let params = NWParameters.udp
        params.requiredInterfaceType = .wiredEthernet

        let nwListener = try NWListener(using: params, on: DiscoveryService.servicePort)

        nwListener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                LabLinkLog.decoder.info("MediaReceiver listening on port \(String(describing: DiscoveryService.servicePort))")
            case .failed(let error):
                LabLinkLog.decoder.error("Listener failed: \(error)")
            default:
                break
            }
        }

        nwListener.newConnectionHandler = { [weak self] connection in
            self?.handleConnection(connection)
        }

        nwListener.start(queue: queue)
        self.listener = nwListener
        self.isReceiving = true
    }

    // MARK: - Connection Handling

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        receivePackets(on: connection)
    }

    private func receivePackets(on connection: NWConnection) {
        connection.receiveMessage { [weak self] content, _, _, error in
            guard let self, self.isReceiving else { return }

            if let data = content {
                self.processPacket(data)
            }

            if let error {
                LabLinkLog.decoder.error("Receive error: \(error)")
            }

            // Continue receiving
            self.receivePackets(on: connection)
        }
    }

    // MARK: - Packet Processing

    private func processPacket(_ data: Data) {
        guard data.count >= MemoryLayout<LabLinkPacketHeader>.size else { return }

        let header = data.withUnsafeBytes { $0.load(as: LabLinkPacketHeader.self) }
        guard header.magic == LABLINK_MAGIC else { return }

        let payloadStart = MemoryLayout<LabLinkPacketHeader>.size
        let payload = data.subdata(in: payloadStart..<data.count)

        let opcode = LabLinkOpcode(rawValue: header.opcode)

        switch opcode {
        case LABLINK_OP_STREAM_START:
            handleStreamMetadata(payload)

        case LABLINK_OP_STREAM_DATA:
            handleStreamData(payload)

        case LABLINK_OP_STREAM_END:
            LabLinkLog.decoder.info("Stream ended by Teacher")
            stop()

        default:
            break
        }
    }

    // MARK: - Stream Metadata

    private func handleStreamMetadata(_ payload: Data) {
        guard payload.count >= MemoryLayout<LabLinkStreamMetadata>.size else { return }

        let metadata = payload.withUnsafeBytes { $0.load(as: LabLinkStreamMetadata.self) }
        self.streamMetadata = metadata

        LabLinkLog.decoder.info("Stream metadata: \(metadata.width)x\(metadata.height) @ \(metadata.fps)fps, codec=\(metadata.codec)")

        // Create format description and decompression session
        setupDecoder(metadata: metadata)
    }

    // MARK: - Decoder Setup

    private func setupDecoder(metadata: LabLinkStreamMetadata) {
        let codecType: CMVideoCodecType
        if metadata.codec == UInt8(LABLINK_CODEC_HEVC_444.rawValue) {
            codecType = kCMVideoCodecType_HEVC
        } else {
            codecType = kCMVideoCodecType_AppleProRes4444XQ
        }

        // Create a basic format description
        var description: CMVideoFormatDescription?
        let dimensionsDict: [String: Any] = [
            kCVPixelBufferWidthKey as String: Int(metadata.width),
            kCVPixelBufferHeightKey as String: Int(metadata.height),
        ]

        let status = CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: codecType,
            width: Int32(metadata.width),
            height: Int32(metadata.height),
            extensions: dimensionsDict as CFDictionary,
            formatDescriptionOut: &description
        )

        guard status == noErr, let desc = description else {
            LabLinkLog.decoder.error("Failed to create format description: \(status)")
            return
        }
        self.formatDescription = desc

        // Output buffer attributes
        let destAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferIOSurfacePropertiesKey as String: [:],
        ]

        var decompSession: VTDecompressionSession?
        let decompStatus = VTDecompressionSessionCreate(
            allocator: kCFAllocatorDefault,
            formatDescription: desc,
            decoderSpecification: nil,
            imageBufferAttributes: destAttributes as CFDictionary,
            outputCallback: nil,
            decompressionSessionOut: &decompSession
        )

        guard decompStatus == noErr, let session = decompSession else {
            LabLinkLog.decoder.error("Failed to create decompression session: \(decompStatus)")
            return
        }

        // RealTime decoding
        VTSessionSetProperty(session, key: kVTDecompressionPropertyKey_RealTime, value: kCFBooleanTrue)

        self.decompressionSession = session
        LabLinkLog.decoder.info("Decoder initialized: \(metadata.width)x\(metadata.height)")
    }

    // MARK: - Stream Data

    private func handleStreamData(_ payload: Data) {
        guard payload.count >= MemoryLayout<LabLinkStreamDataHeader>.size else { return }

        let sdh = payload.withUnsafeBytes { $0.load(as: LabLinkStreamDataHeader.self) }
        let dataStart = MemoryLayout<LabLinkStreamDataHeader>.size
        let chunkData = payload.subdata(in: dataStart..<dataStart + Int(sdh.data_length))

        // Drop old frames (zero-retransmission: move forward)
        guard sdh.frame_id >= latestFrameID else { return }

        // Assemble chunks
        if frameAssembler[sdh.frame_id] == nil {
            frameAssembler[sdh.frame_id] = FrameAssembly(totalChunks: Int(sdh.chunk_total))
        }
        frameAssembler[sdh.frame_id]?.chunks[sdh.chunk_index] = chunkData

        // Check if frame is complete
        if let assembly = frameAssembler[sdh.frame_id], assembly.isComplete {
            let frameData = assembly.assembledData
            latestFrameID = sdh.frame_id + 1

            // Clean up old assemblies
            frameAssembler = frameAssembler.filter { $0.key >= latestFrameID }

            // Decode
            decodeFrame(frameData)
        }
    }

    // MARK: - Decode

    private func decodeFrame(_ data: Data) {
        guard let session = decompressionSession, let formatDesc = formatDescription else { return }

        // Create CMBlockBuffer from data
        var blockBuffer: CMBlockBuffer?
        data.withUnsafeBytes { rawBuffer in
            guard let baseAddress = rawBuffer.baseAddress else { return }
            CMBlockBufferCreateWithMemoryBlock(
                allocator: kCFAllocatorDefault,
                memoryBlock: UnsafeMutableRawPointer(mutating: baseAddress),
                blockLength: data.count,
                blockAllocator: kCFAllocatorNull,
                customBlockSource: nil,
                offsetToData: 0,
                dataLength: data.count,
                flags: 0,
                blockBufferOut: &blockBuffer
            )
        }

        guard let block = blockBuffer else { return }

        // Create CMSampleBuffer
        var sampleBuffer: CMSampleBuffer?
        var sampleSize = data.count
        CMSampleBufferCreateReady(
            allocator: kCFAllocatorDefault,
            dataBuffer: block,
            formatDescription: formatDesc,
            sampleCount: 1,
            sampleTimingEntryCount: 0,
            sampleTimingArray: nil,
            sampleSizeEntryCount: 1,
            sampleSizeArray: &sampleSize,
            sampleBufferOut: &sampleBuffer
        )

        guard let sample = sampleBuffer else { return }

        // Decode
        var flagsOut: VTDecodeInfoFlags = []
        let decodeStatus = VTDecompressionSessionDecodeFrame(
            session,
            sampleBuffer: sample,
            flags: [._EnableAsynchronousDecompression],
            infoFlagsOut: &flagsOut
        ) { [weak self] status, _, imageBuffer, _, _ in
            guard status == noErr, let pixelBuffer = imageBuffer else { return }
            self?.frameReadyHandler(pixelBuffer)
        }

        if decodeStatus != noErr {
            LabLinkLog.decoder.debug("Decode error: \(decodeStatus) — skipping frame")
        }
    }

    // MARK: - Stop

    public func stop() {
        isReceiving = false
        listener?.cancel()
        listener = nil

        if let session = decompressionSession {
            VTDecompressionSessionWaitForAsynchronousFrames(session)
            VTDecompressionSessionInvalidate(session)
        }
        decompressionSession = nil
        formatDescription = nil
        frameAssembler.removeAll()

        LabLinkLog.decoder.info("MediaReceiver stopped")
    }
}
