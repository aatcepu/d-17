import Foundation
import Network

/// Monitors the `en0` Ethernet interface for 169.254.x.x Link-Local addresses.
/// Stays dormant until a wired Ethernet link with a link-local IP is detected.
/// Enters "Low Power/Poll" state (0.1% CPU) on cable unplug.
public final class NetworkMonitor: @unchecked Sendable {

    // MARK: - Types

    public enum LinkState: Sendable {
        case dormant            // No cable / no link-local IP
        case linkDetected       // Cable plugged, link-local IP found
        case disconnected       // Cable was unplugged mid-session
    }

    // MARK: - Properties

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.lablink.network-monitor", qos: .utility)
    private var currentState: LinkState = .dormant
    private let onStateChange: @Sendable (LinkState) -> Void

    // MARK: - Init

    /// - Parameter onStateChange: Callback fired when link state transitions.
    public init(onStateChange: @escaping @Sendable (LinkState) -> Void) {
        self.onStateChange = onStateChange
        self.monitor = NWPathMonitor(requiredInterfaceType: .wiredEthernet)
    }

    // MARK: - Lifecycle

    public func start() {
        LabLinkLog.network.info("NetworkMonitor starting — watching en0 for link-local")

        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            self.evaluatePath(path)
        }
        monitor.start(queue: queue)
    }

    public func stop() {
        monitor.cancel()
        LabLinkLog.network.info("NetworkMonitor stopped")
    }

    // MARK: - Evaluation

    private func evaluatePath(_ path: NWPath) {
        // Check for wired Ethernet availability
        let hasWired = path.usesInterfaceType(.wiredEthernet)
        let isSatisfied = path.status == .satisfied

        if hasWired && isSatisfied {
            // Check for link-local IP on en0
            if Self.hasLinkLocalAddress() {
                transition(to: .linkDetected)
            } else {
                LabLinkLog.network.debug("Wired link up but no 169.254.x.x yet")
                transition(to: .dormant)
            }
        } else {
            if currentState == .linkDetected {
                transition(to: .disconnected)
            } else {
                transition(to: .dormant)
            }
        }
    }

    private func transition(to newState: LinkState) {
        guard newState != currentState else { return }
        let oldState = currentState
        currentState = newState
        LabLinkLog.network.info("Link state: \(String(describing: oldState)) → \(String(describing: newState))")
        onStateChange(newState)
    }

    // MARK: - Link-Local Detection

    /// Checks if any network interface has a 169.254.x.x address.
    public static func hasLinkLocalAddress() -> Bool {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let firstAddr = ifaddr else { return false }
        defer { freeifaddrs(ifaddr) }

        for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let addr = ptr.pointee
            let name = String(cString: addr.ifa_name)

            // Only check en0 (primary Ethernet)
            guard name == "en0" else { continue }
            guard addr.ifa_addr.pointee.sa_family == UInt8(AF_INET) else { continue }

            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            if getnameinfo(addr.ifa_addr, socklen_t(addr.ifa_addr.pointee.sa_len),
                           &hostname, socklen_t(hostname.count),
                           nil, 0, NI_NUMERICHOST) == 0 {
                let ip = String(decoding: hostname.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, as: UTF8.self)
                if ip.hasPrefix("169.254.") {
                    return true
                }
            }
        }
        return false
    }
}
