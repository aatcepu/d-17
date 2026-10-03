import Foundation
import ScreenCaptureKit
import CoreGraphics

/// ScreenCaptureKit-based screen capture for the Teacher role.
/// Captures IOSurface frames with BGRA pixel format, cursor visible,
/// and optional app-only SCContentFilter.
@available(macOS 14.0, *)
public final class CaptureSession: NSObject, @unchecked Sendable, SCStreamDelegate, SCStreamOutput {

    // MARK: - Types

    public typealias FrameHandler = @Sendable (IOSurface, CMTime) -> Void

    // MARK: - Properties

    private var stream: SCStream?
    private var filter: SCContentFilter?
    private let frameHandler: FrameHandler
    private let queue = DispatchQueue(label: "com.lablink.capture", qos: .userInteractive)
    private var isCapturing = false

    // MARK: - Init

    /// - Parameter frameHandler: Called for each captured frame's IOSurface.
    public init(frameHandler: @escaping FrameHandler) {
        self.frameHandler = frameHandler
        super.init()
    }

    // MARK: - TCC Preflight

    /// Check Screen Recording permission. Returns false if not granted.
    public static func preflightScreenCaptureAccess() -> Bool {
        return CGPreflightScreenCaptureAccess()
    }

    /// Request Screen Recording permission (triggers system alert).
    public static func requestScreenCaptureAccess() -> Bool {
        return CGRequestScreenCaptureAccess()
    }

    // MARK: - Start Capture

    /// Start capturing the entire screen or a specific app.
    /// - Parameter bundleIdentifier: If provided, captures only this app (App-Only Mode).
    /// Zero-Copy: Frames flow directly into Unified Memory via IOSurface — no CPU copy.
    public func startCapture(appBundleIdentifier: String? = nil) async throws {
        // Exclude desktop windows by default to skip Liquid Glass shadows/blur layers
        let content = try await SCShareableContent.excludingDesktopWindows(true, onScreenWindowsOnly: true)

        // Build filter
        if let bundleID = appBundleIdentifier,
           let app = content.applications.first(where: { $0.bundleIdentifier == bundleID }),
           let display = content.displays.first {
            // App-Only Mode: share only the specified workspace/IDE
            // Automatically excludes Tahoe Liquid Glass drop shadows of non-shared windows
            filter = SCContentFilter(display: display, including: [app], exceptingWindows: [])
            LabLinkLog.capture.info("Capture filter: App-Only (\(bundleID))")
        } else {
            // Full screen capture — exclude desktop-only windows (shadows, blur layers)
            guard let display = content.displays.first else {
                throw CaptureError.noDisplay
            }
            filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
            LabLinkLog.capture.info("Capture filter: Full Screen (desktop shadows excluded)")
        }

        guard let filter else {
            throw CaptureError.noFilter
        }

        // Configure stream
        let config = SCStreamConfiguration()
        config.pixelFormat = kCVPixelFormatType_32BGRA
        config.showsCursor = true

        // Target 60 FPS
        config.minimumFrameInterval = CMTime(value: 1, timescale: 60)

        // Match display resolution
        if let display = content.displays.first {
            config.width = display.width
            config.height = display.height
        }

        // Zero-Copy IOSurface: data stays in GPU/Unified Memory fabric
        // queueDepth of 3 ensures pipeline doesn't stall while encoding
        config.queueDepth = 3


        let scStream = SCStream(filter: filter, configuration: config, delegate: self)
        try scStream.addStreamOutput(self, type: .screen, sampleHandlerQueue: queue)

        try await scStream.startCapture()
        self.stream = scStream
        self.isCapturing = true

        LabLinkLog.capture.info("Screen capture started at 60 FPS (zero-copy IOSurface path)")
    }

    // MARK: - Stop

    public func stopCapture() async throws {
        guard let stream, isCapturing else { return }
        try await stream.stopCapture()
        self.stream = nil
        self.isCapturing = false
        LabLinkLog.capture.info("Screen capture stopped")
    }

    // MARK: - SCStreamOutput

    public func stream(_ stream: SCStream,
                       didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
                       of type: SCStreamOutputType) {
        guard type == .screen else { return }
        guard let surface = sampleBuffer.imageBuffer.flatMap({ CVPixelBufferGetIOSurface($0)?.takeUnretainedValue() }) else {
            return
        }

        let pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        frameHandler(surface, pts)
    }

    // MARK: - SCStreamDelegate

    public func stream(_ stream: SCStream, didStopWithError error: any Error) {
        LabLinkLog.capture.error("Capture stream error: \(error)")
        self.isCapturing = false
    }

    // MARK: - Errors

    public enum CaptureError: Error {
        case noDisplay
        case noFilter
        case permissionDenied
    }
}
