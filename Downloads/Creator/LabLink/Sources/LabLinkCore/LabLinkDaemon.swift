import Foundation
import AppKit
import Network

/// The central orchestrator for LabLinkD.
/// Coordinates all subsystems: NetworkMonitor, DiscoveryService,
/// HandshakeManager, CaptureSession, MediaStreamer/Receiver, and LabLinkMenu.
@available(macOS 14.0, *)
public final class LabLinkDaemon: @unchecked Sendable {

    // MARK: - Types

    public enum Role: Sendable {
        case undecided
        case teacher
        case student
    }

    // MARK: - Properties

    private var role: Role = .undecided
    private var networkMonitor: NetworkMonitor?
    private var discoveryService: DiscoveryService?
    private var handshakeManager: HandshakeManager?
    private var captureSession: CaptureSession?
    private var mediaStreamer: MediaStreamer?
    private var mediaReceiver: MediaReceiver?
    private var menu: LabLinkMenu?

    private let queue = DispatchQueue(label: "com.lablink.daemon", qos: .userInteractive)

    // MARK: - Init & Start

    public init() {}

    public func start() {
        LabLinkLog.system.info("LabLinkD starting…")

        // TCC Preflight — check screen capture permission
        if !CaptureSession.preflightScreenCaptureAccess() {
            LabLinkLog.system.warning("Screen capture permission not granted")
            _ = CaptureSession.requestScreenCaptureAccess()
        }

        // Setup Menu Bar
        menu = LabLinkMenu(
            onTerminate: { [weak self] in self?.terminateStream() },
            onStartTeacher: { [weak self] in self?.startAsTeacher() },
            onStartStudent: { [weak self] in self?.startAsStudent() }
        )
        menu?.setup()

        // Start network monitoring — stay dormant until link-local detected
        networkMonitor = NetworkMonitor { [weak self] state in
            self?.handleNetworkState(state)
        }
        networkMonitor?.start()

        LabLinkLog.system.info("LabLinkD initialized — dormant, waiting for Ethernet")
    }

    // MARK: - Network State

    private func handleNetworkState(_ state: NetworkMonitor.LinkState) {
        switch state {
        case .dormant:
            LabLinkLog.system.info("Ethernet dormant — daemon idle")
            menu?.updateState(.idle)

        case .linkDetected:
            LabLinkLog.system.info("Ethernet link-local detected — ready")
            menu?.updateState(.connected)

        case .disconnected:
            LabLinkLog.system.warning("Ethernet disconnected — entering low-power poll")
            terminateStream()
            menu?.updateState(.idle)
        }
    }

    // MARK: - Role Selection

    private func startAsTeacher() {
        role = .teacher
        LabLinkLog.system.info("Role: Teacher")

        // Start mDNS publishing
        discoveryService = DiscoveryService(
            role: .teacher,
            onStudentConnected: { [weak self] connection in
                self?.handleStudentConnection(connection)
            }
        )
        discoveryService?.start()

        // Setup handshake
        handshakeManager = HandshakeManager(
            onStateChange: { [weak self] state in
                self?.handleHandshakeState(state)
            },
            onPermissionRequest: { [weak self] deviceName, callback in
                self?.showPermissionPrompt(deviceName: deviceName, callback: callback)
            },
            onSessionEstablished: { [weak self] sessionInfo in
                self?.startTeacherStream(sessionInfo: sessionInfo)
            }
        )

        // Generate and display PIN
        let pin = handshakeManager?.generatePin() ?? "000000"
        menu?.showPin(pin)

        LabLinkLog.system.info("Teacher ready — broadcasting on mDNS")
    }

    private func startAsStudent() {
        role = .student
        LabLinkLog.system.info("Role: Student")

        // Browse for Teacher
        discoveryService = DiscoveryService(
            role: .student,
            onTeacherFound: { [weak self] endpoint in
                self?.handleTeacherDiscovered(endpoint)
            }
        )
        discoveryService?.start()

        LabLinkLog.system.info("Student searching for Teacher…")
    }

    // MARK: - Teacher: Handle Student Connection

    private func handleStudentConnection(_ connection: NWConnection) {
        LabLinkLog.system.info("Student connection received")
        handshakeManager?.handleIncomingConnection(connection)
    }

    // MARK: - Student: Handle Teacher Discovery

    private func handleTeacherDiscovered(_ endpoint: NWEndpoint) {
        LabLinkLog.system.info("Teacher discovered — prompting for PIN")

        // Prompt user for PIN via alert on main thread
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "LabLink Teacher Found"
            alert.informativeText = "Enter the 6-digit PIN shown on the Teacher's screen:"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Connect")
            alert.addButton(withTitle: "Cancel")

            let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
            input.placeholderString = "000000"
            alert.accessoryView = input

            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                let pin = input.stringValue
                let deviceName = Host.current().localizedName ?? "Student Mac"
                self?.handshakeManager = HandshakeManager(
                    onStateChange: { [weak self] state in
                        self?.handleHandshakeState(state)
                    },
                    onPermissionRequest: { _, callback in callback(true) },
                    onSessionEstablished: { [weak self] sessionInfo in
                        self?.startStudentStream(sessionInfo: sessionInfo)
                    }
                )
                self?.handshakeManager?.initiateHandshake(to: endpoint, pin: pin, deviceName: deviceName)
            }
        }
    }

    // MARK: - Handshake State

    private func handleHandshakeState(_ state: HandshakeManager.HandshakeState) {
        switch state {
        case .authenticated:
            LabLinkLog.system.info("Handshake authenticated")
            menu?.updateState(.connected)
        case .denied:
            LabLinkLog.system.info("Handshake denied")
            menu?.updateState(.idle)
        case .failed(let reason):
            LabLinkLog.system.error("Handshake failed: \(reason)")
            menu?.updateState(.idle)
        default:
            break
        }
    }

    // MARK: - Permission Prompt (Teacher)

    private func showPermissionPrompt(deviceName: String, callback: @escaping (Bool) -> Void) {
        nonisolated(unsafe) let safeCallback = callback
        DispatchQueue.main.async { [weak self] in
            let alert = NSAlert()
            alert.messageText = "LabLink Connection Request"
            alert.informativeText = "\"\(deviceName)\" wants to view your screen."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Grant")
            alert.addButton(withTitle: "Deny")

            let response = alert.runModal()
            let granted = response == .alertFirstButtonReturn
            safeCallback(granted)

            if granted {
                self?.menu?.showDevice(deviceName)
            }
        }
    }

    // MARK: - Teacher: Start Streaming

    private func startTeacherStream(sessionInfo: HandshakeManager.SessionInfo) {
        guard let endpoint = sessionInfo.endpoint else { return }

        menu?.updateState(.streaming)
        menu?.showDevice(sessionInfo.deviceName)

        // Initialize capture
        captureSession = CaptureSession { [weak self] surface, pts in
            self?.mediaStreamer?.encodeFrame(surface, presentationTime: pts)
        }

        // Initialize streamer — auto-detect M5 for ProRes 422 Proxy Ultra mode
        let codec = ChipDetector.recommendedCodec
        mediaStreamer = MediaStreamer(codecMode: codec)

        Task {
            do {
                // Start capture
                try await captureSession?.startCapture()

                // Start streamer (uses display dimensions)
                let screen = NSScreen.main
                let width = Int32(screen?.frame.width ?? 1920)
                let height = Int32(screen?.frame.height ?? 1080)
                try mediaStreamer?.start(endpoint: endpoint, width: width, height: height)

                LabLinkLog.system.info("Teacher streaming at \(width)x\(height)")
            } catch {
                LabLinkLog.system.error("Failed to start teacher stream: \(error)")
                menu?.updateState(.idle)
            }
        }
    }

    // MARK: - Student: Start Receiving

    private func startStudentStream(sessionInfo: HandshakeManager.SessionInfo) {
        menu?.updateState(.streaming)
        menu?.showDevice(sessionInfo.deviceName)

        // Create a window for display
        DispatchQueue.main.async { [weak self] in
            self?.createViewerWindow()
        }
    }

    @MainActor
    private func createViewerWindow() {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.backgroundColor = .black
        window.title = "LabLink Viewer"

        // CALayer for GPU rendering
        let layerView = NSView(frame: window.contentView!.bounds)
        layerView.wantsLayer = true
        layerView.layer = CALayer()
        window.contentView?.addSubview(layerView)

        // Start receiver
        mediaReceiver = MediaReceiver { pixelBuffer in
            nonisolated(unsafe) let safeBuffer = pixelBuffer
            DispatchQueue.main.async {
                // Create CIImage from pixel buffer and render to layer
                let ciImage = CIImage(cvPixelBuffer: safeBuffer)
                let context = CIContext()
                if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                    layerView.layer?.contents = cgImage
                }
            }
        }

        do {
            try mediaReceiver?.startListening()
            window.makeKeyAndOrderFront(nil)
            LabLinkLog.system.info("Student viewer window created")
        } catch {
            LabLinkLog.system.error("Failed to start receiver: \(error)")
        }
    }

    // MARK: - Kill Switch

    private func terminateStream() {
        LabLinkLog.system.info("Terminating stream (Kill Switch)")

        Task {
            try? await captureSession?.stopCapture()
        }
        mediaStreamer?.stop()
        mediaReceiver?.stop()
        handshakeManager?.terminate()
        discoveryService?.stop()

        captureSession = nil
        mediaStreamer = nil
        mediaReceiver = nil
        handshakeManager = nil
        discoveryService = nil

        role = .undecided
        menu?.updateState(.idle)

        LabLinkLog.system.info("All streams terminated — daemon idle")
    }
}
