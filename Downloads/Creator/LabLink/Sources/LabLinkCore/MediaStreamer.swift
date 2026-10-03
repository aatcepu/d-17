import Foundation
import VideoToolbox
import CoreMedia
import Network
import CHandshake

/// Hardware-accelerated HEVC 4:4:4 encoding and UDP streaming.
/// Supports ProRes 422 Proxy "Ultra" mode for M5 (near-zero encoding latency).
/// Monitors thermal state and halves bitrate on .serious.
/// Zero-Retransmission UDP: lost packets are skipped.
public final class MediaStreamer: @unchecked Sendable {

    // MARK: - Types

    public enum CodecMode: Sendable {
        case hevc444          // Default: HEVC 10-bit 4:4:4, CBR 50 Mbps
        case prores422proxy   // M5 Ultra: ProRes 422 Proxy (near-zero encode latency)
        case prores4444xq     // Lossless: ProRes 4444 XQ
    }

    // MARK: - Properties

    private var compressionSession: VTCompressionSession?
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "com.lablink.streamer", qos: .userInteractive)
    private let codecMode: CodecMode
    private var baseBitrate: Int32 = 50_000_000  // 50 Mbps
    private var currentBitrate: Int32 = 50_000_000
    private var frameID: UInt32 = 0
    private var sequenceNumber: UInt32 = 0
    private var thermalObserver: NSObjectProtocol?
    private var isStreaming = false

    /// Maximum payload per UDP packet (Cat 6 max MTU: 1472 bytes)
    private let maxPayloadSize = Int(LABLINK_MAX_PAYLOAD) - MemoryLayout<LabLinkPacketHeader>.size - MemoryLayout<LabLinkStreamDataHeader>.size

    // MARK: - Init

    public init(codecMode: CodecMode = .hevc444) {
        self.codecMode = codecMode
        setupThermalObserver()
    }

    deinit {
        if let observer = thermalObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Thermal Observer

    private func setupThermalObserver() {
        thermalObserver = NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            let state = ProcessInfo.processInfo.thermalState
            LabLinkLog.encoder.info("Thermal state: \(state.rawValue)")

            if state == .serious || state == .critical {
                self.currentBitrate = self.baseBitrate / 2
                LabLinkLog.encoder.warning("Thermal throttle: bitrate halved to \(self.currentBitrate)")
                self.updateBitrate(self.currentBitrate)
            } else {
                self.currentBitrate = self.baseBitrate
                self.updateBitrate(self.currentBitrate)
            }
        }
    }

    // MARK: - Setup

    /// Initialize the encoder and connect to the Student endpoint.
    public func start(endpoint: NWEndpoint, width: Int32, height: Int32) throws {
        // Create UDP connection to Student
        let params = NWParameters.udp
        params.requiredInterfaceType = .wiredEthernet

        let conn = NWConnection(to: endpoint, using: params)
        conn.start(queue: queue)
        self.connection = conn

        // Create VTCompressionSession
        let codecType: CMVideoCodecType
        switch codecMode {
        case .hevc444:
            codecType = kCMVideoCodecType_HEVC
        case .prores422proxy:
            codecType = kCMVideoCodecType_AppleProRes422Proxy
        case .prores4444xq:
            codecType = kCMVideoCodecType_AppleProRes4444XQ
        }

        var session: VTCompressionSession?

        // Use callback-based API for VTCompressionSession
        let callbackPointer = Unmanaged.passUnretained(self).toOpaque()

        let outputCallback: VTCompressionOutputCallback = { refcon, _, status, _, sampleBuffer in
            guard status == noErr, let sampleBuffer, let refcon else { return }
            let streamer = Unmanaged<MediaStreamer>.fromOpaque(refcon).takeUnretainedValue()
            streamer.handleEncodedFrame(sampleBuffer)
        }

        let status = VTCompressionSessionCreate(
            allocator: kCFAllocatorDefault,
            width: width,
            height: height,
            codecType: codecType,
            encoderSpecification: nil,
            imageBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA,
                kCVPixelBufferIOSurfacePropertiesKey: [:],
            ] as CFDictionary,
            compressedDataAllocator: nil,
            outputCallback: outputCallback,
            refcon: callbackPointer,
            compressionSessionOut: &session
        )

        guard status == noErr, let session else {
            throw StreamerError.encoderCreationFailed(status)
        }

        // Configure encoder properties
        if codecMode == .hevc444 {
            // HEVC 4:4:4 for pixel-perfect text
            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ProfileLevel,
                                 value: kVTProfileLevel_HEVC_Main10_AutoLevel)

            // CBR at target bitrate
            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AverageBitRate,
                                 value: currentBitrate as CFNumber)

            // Byte limit for CBR behavior
            let byteLimit = Int(currentBitrate / 8)
            let byteLimitDuration: Double = 1.0
            let dataRateLimits = [byteLimit, Int(byteLimitDuration)] as CFArray
            VTSessionSetProperty(session, key: kVTCompressionPropertyKey_DataRateLimits,
                                 value: dataRateLimits)
        }

        // RealTime: prioritize latency over file size
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_RealTime,
                             value: kCFBooleanTrue)

        // Target 60 FPS
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_ExpectedFrameRate,
                             value: 60.0 as CFNumber)

        // Max keyframe interval for seeking
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_MaxKeyFrameInterval,
                             value: 60 as CFNumber)

        VTCompressionSessionPrepareToEncodeFrames(session)
        self.compressionSession = session
        self.isStreaming = true

        // Send stream metadata to Student
        sendStreamMetadata(width: width, height: height)

        LabLinkLog.encoder.info("MediaStreamer started: \(String(describing: self.codecMode)), \(width)x\(height)")
    }

    // MARK: - Encode Frame

    /// Feed an IOSurface frame to the encoder.
    public func encodeFrame(_ surface: IOSurface, presentationTime: CMTime) {
        guard let session = compressionSession, isStreaming else { return }

        var pixelBuffer: Unmanaged<CVPixelBuffer>?
        let status = CVPixelBufferCreateWithIOSurface(
            kCFAllocatorDefault,
            surface,
            nil,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let unmanagedBuffer = pixelBuffer else {
            LabLinkLog.encoder.error("Failed to create pixel buffer from IOSurface")
            return
        }
        let buffer = unmanagedBuffer.takeRetainedValue()

        VTCompressionSessionEncodeFrame(
            session,
            imageBuffer: buffer,
            presentationTimeStamp: presentationTime,
            duration: CMTime(value: 1, timescale: 60),
            frameProperties: nil,
            sourceFrameRefcon: nil,
            infoFlagsOut: nil
        )
    }

    // MARK: - Handle Encoded Output

    private func handleEncodedFrame(_ sampleBuffer: CMSampleBuffer) {
        guard let dataBuffer = sampleBuffer.dataBuffer else { return }

        var totalLength: Int = 0
        var dataPointer: UnsafeMutablePointer<Int8>?
        CMBlockBufferGetDataPointer(dataBuffer, atOffset: 0, lengthAtOffsetOut: nil,
                                    totalLengthOut: &totalLength, dataPointerOut: &dataPointer)

        guard let pointer = dataPointer, totalLength > 0 else { return }

        let encodedData = Data(bytes: pointer, count: totalLength)
        let currentFrameID = frameID
        frameID += 1

        // Chunk the encoded data into MTU-safe UDP packets
        sendChunkedFrame(frameID: currentFrameID, data: encodedData)
    }

    // MARK: - UDP Chunked Transmission

    private func sendChunkedFrame(frameID: UInt32, data: Data) {
        let chunkCount = (data.count + maxPayloadSize - 1) / maxPayloadSize

        for i in 0..<chunkCount {
            let start = i * maxPayloadSize
            let end = min(start + maxPayloadSize, data.count)
            let chunk = data.subdata(in: start..<end)

            // Build packet header
            let streamDataHeader = LabLinkStreamDataHeader(
                frame_id: frameID,
                chunk_index: UInt16(i),
                chunk_total: UInt16(chunkCount),
                data_length: UInt32(chunk.count)
            )

            var header = LabLinkPacketHeader(
                magic: UInt32(LABLINK_MAGIC),
                version: UInt8(LABLINK_PROTOCOL_VERSION),
                opcode: UInt8(LABLINK_OP_STREAM_DATA.rawValue),
                payload_length: UInt16(MemoryLayout<LabLinkStreamDataHeader>.size + chunk.count),
                sequence: nextSequence()
            )

            var packet = Data()
            withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }
            var sdh = streamDataHeader
            withUnsafeBytes(of: &sdh) { packet.append(contentsOf: $0) }
            packet.append(chunk)

            // Zero-Retransmission: fire-and-forget UDP
            connection?.send(content: packet, completion: .idempotent)
        }
    }

    // MARK: - Stream Metadata

    private func sendStreamMetadata(width: Int32, height: Int32) {
        let codec: UInt8
        switch codecMode {
        case .hevc444:
            codec = UInt8(LABLINK_CODEC_HEVC_444.rawValue)
        case .prores422proxy:
            codec = UInt8(LABLINK_CODEC_PRORES_422_PROXY.rawValue)
        case .prores4444xq:
            codec = UInt8(LABLINK_CODEC_PRORES_4444XQ.rawValue)
        }

        var metadata = LabLinkStreamMetadata(
            codec: codec,
            width: UInt16(width),
            height: UInt16(height),
            fps: 60,
            bitrate_kbps: UInt32(currentBitrate / 1000),
            cursor_visible: true
        )

        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_STREAM_START.rawValue),
            payload_length: UInt16(MemoryLayout<LabLinkStreamMetadata>.size),
            sequence: nextSequence()
        )

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }
        withUnsafeBytes(of: &metadata) { packet.append(contentsOf: $0) }

        connection?.send(content: packet, completion: .contentProcessed { error in
            if let error {
                LabLinkLog.encoder.error("Failed to send stream metadata: \(error)")
            }
        })
    }

    // MARK: - Bitrate Update

    private func updateBitrate(_ newBitrate: Int32) {
        guard let session = compressionSession else { return }
        VTSessionSetProperty(session, key: kVTCompressionPropertyKey_AverageBitRate,
                             value: newBitrate as CFNumber)
    }

    // MARK: - Stop

    public func stop() {
        isStreaming = false

        // Send stream end
        var header = LabLinkPacketHeader(
            magic: UInt32(LABLINK_MAGIC),
            version: UInt8(LABLINK_PROTOCOL_VERSION),
            opcode: UInt8(LABLINK_OP_STREAM_END.rawValue),
            payload_length: 0,
            sequence: nextSequence()
        )

        var packet = Data()
        withUnsafeBytes(of: &header) { packet.append(contentsOf: $0) }
        connection?.send(content: packet, completion: .idempotent)

        if let session = compressionSession {
            VTCompressionSessionCompleteFrames(session, untilPresentationTimeStamp: .invalid)
            VTCompressionSessionInvalidate(session)
        }
        compressionSession = nil
        connection?.cancel()
        connection = nil

        LabLinkLog.encoder.info("MediaStreamer stopped")
    }

    // MARK: - Helpers

    private func nextSequence() -> UInt32 {
        sequenceNumber += 1
        return sequenceNumber
    }

    public enum StreamerError: Error {
        case encoderCreationFailed(OSStatus)
    }
}
