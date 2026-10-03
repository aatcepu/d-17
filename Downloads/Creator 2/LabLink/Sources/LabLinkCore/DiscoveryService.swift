import Foundation
import Network

/// Handles mDNS service publishing (Teacher) and browsing (Student).
/// Teacher publishes `_lablink._udp` as `LabLink-Teacher.local`.
/// Student uses NWBrowser to discover the Teacher service.
public final class DiscoveryService: @unchecked Sendable {

    // MARK: - Types

    public enum Role: Sendable {
        case teacher
        case student
    }

    // MARK: - Constants

    public static let serviceType = "_lablink._udp"
    public static let serviceDomain = "local"
    public static let teacherName = "LabLink-Teacher"
    public static let servicePort: NWEndpoint.Port = 41700

    // MARK: - Properties

    private let role: Role
    private let queue = DispatchQueue(label: "com.lablink.discovery", qos: .userInitiated)
    private var listener: NWListener?
    private var browser: NWBrowser?
    private let onTeacherFound: (@Sendable (NWEndpoint) -> Void)?
    private let onStudentConnected: (@Sendable (NWConnection) -> Void)?

    // MARK: - Init

    /// - Parameters:
    ///   - role: Whether this instance is Teacher (publisher) or Student (browser).
    ///   - onTeacherFound: Called when Student discovers a Teacher endpoint.
    ///   - onStudentConnected: Called when Teacher receives a Student connection.
    public init(
        role: Role,
        onTeacherFound: (@Sendable (NWEndpoint) -> Void)? = nil,
        onStudentConnected: (@Sendable (NWConnection) -> Void)? = nil
    ) {
        self.role = role
        self.onTeacherFound = onTeacherFound
        self.onStudentConnected = onStudentConnected
    }

    // MARK: - Lifecycle

    public func start() {
        switch role {
        case .teacher:
            startPublishing()
        case .student:
            startBrowsing()
        }
    }

    public func stop() {
        listener?.cancel()
        listener = nil
        browser?.cancel()
        browser = nil
        LabLinkLog.discovery.info("DiscoveryService stopped")
    }

    // MARK: - Teacher: Publish

    private func startPublishing() {
        do {
            // Use UDP for the listener
            let params = NWParameters.udp
            params.requiredInterfaceType = .wiredEthernet

            let nwListener = try NWListener(using: params, on: Self.servicePort)

            // Advertise via Bonjour
            nwListener.service = NWListener.Service(
                name: Self.teacherName,
                type: Self.serviceType,
                domain: Self.serviceDomain
            )

            nwListener.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    LabLinkLog.discovery.info("Teacher publishing on \(Self.serviceType)")
                case .failed(let error):
                    LabLinkLog.discovery.error("Teacher listener failed: \(error)")
                default:
                    break
                }
            }

            nwListener.newConnectionHandler = { [weak self] connection in
                LabLinkLog.discovery.info("Student connected: \(String(describing: connection.endpoint))")
                self?.onStudentConnected?(connection)
            }

            nwListener.start(queue: queue)
            self.listener = nwListener

        } catch {
            LabLinkLog.discovery.error("Failed to create listener: \(error)")
        }
    }

    // MARK: - Student: Browse

    private func startBrowsing() {
        let descriptor = NWBrowser.Descriptor.bonjour(
            type: Self.serviceType,
            domain: Self.serviceDomain
        )
        let params = NWParameters()
        params.requiredInterfaceType = .wiredEthernet

        let nwBrowser = NWBrowser(for: descriptor, using: params)

        nwBrowser.stateUpdateHandler = { state in
            switch state {
            case .ready:
                LabLinkLog.discovery.info("Student browsing for \(Self.serviceType)")
            case .failed(let error):
                LabLinkLog.discovery.error("Student browser failed: \(error)")
            default:
                break
            }
        }

        nwBrowser.browseResultsChangedHandler = { [weak self] results, _ in
            for result in results {
                if case .service(let name, _, _, _) = result.endpoint {
                    if name == Self.teacherName {
                        LabLinkLog.discovery.info("Found Teacher: \(String(describing: result.endpoint))")
                        self?.onTeacherFound?(result.endpoint)
                    }
                }
            }
        }

        nwBrowser.start(queue: queue)
        self.browser = nwBrowser
    }
}
