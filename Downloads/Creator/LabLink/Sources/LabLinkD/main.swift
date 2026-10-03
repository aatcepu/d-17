import Foundation
import AppKit
import LabLinkCore

/// LabLinkD — Intrinsic System Daemon Entry Point
/// Runs as an NSApplication agent (menu bar only, no dock icon).
@available(macOS 14.0, *)
@main
struct LabLinkDApp {
    static func main() {
        let app = NSApplication.shared
        app.setActivationPolicy(.accessory)  // Menu bar only — no dock icon

        let daemon = LabLinkDaemon()
        daemon.start()

        // Run the event loop
        app.run()
    }
}
