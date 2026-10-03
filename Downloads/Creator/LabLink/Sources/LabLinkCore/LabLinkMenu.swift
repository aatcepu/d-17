import Foundation
import AppKit

/// NSStatusItem-based Menu Bar interface for LabLinkD.
/// States: ⚪ Idle, 🟢 Connected, 🔴 Streaming.
/// Uses NSVisualEffectView with Liquid Glass material (Tahoe).
public final class LabLinkMenu: NSObject, @unchecked Sendable {

    // MARK: - Types

    public enum MenuState: Sendable {
        case idle           // ⚪
        case connected      // 🟢
        case streaming      // 🔴
    }

    // MARK: - Properties

    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private let queue = DispatchQueue.main

    private var currentState: MenuState = .idle
    private let onTerminate: @Sendable () -> Void
    private let onStartTeacher: @Sendable () -> Void
    private let onStartStudent: @Sendable () -> Void

    private var pinMenuItem: NSMenuItem?
    private var stateMenuItem: NSMenuItem?
    private var deviceMenuItem: NSMenuItem?

    // MARK: - Init

    /// - Parameters:
    ///   - onTerminate: "Kill Switch" callback — terminates stream immediately.
    ///   - onStartTeacher: Start as Teacher role.
    ///   - onStartStudent: Start as Student role.
    public init(
        onTerminate: @escaping @Sendable () -> Void,
        onStartTeacher: @escaping @Sendable () -> Void,
        onStartStudent: @escaping @Sendable () -> Void
    ) {
        self.onTerminate = onTerminate
        self.onStartTeacher = onStartTeacher
        self.onStartStudent = onStartStudent
        super.init()
    }

    // MARK: - Setup

    public func setup() {
        queue.async { [weak self] in
            self?.createStatusItem()
        }
    }

    private func createStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "⚪"
        item.button?.toolTip = "LabLink — Idle"

        let menu = NSMenu(title: "LabLink")

        // State indicator
        let stateItem = NSMenuItem(title: "Status: Idle", action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)
        self.stateMenuItem = stateItem

        // Connected device
        let deviceItem = NSMenuItem(title: "Device: —", action: nil, keyEquivalent: "")
        deviceItem.isEnabled = false
        menu.addItem(deviceItem)
        self.deviceMenuItem = deviceItem

        // PIN display (Teacher only)
        let pinItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
        pinItem.isEnabled = false
        pinItem.isHidden = true
        menu.addItem(pinItem)
        self.pinMenuItem = pinItem

        menu.addItem(NSMenuItem.separator())

        // Role selection
        let teacherItem = NSMenuItem(title: "Start as Teacher", action: #selector(startTeacherAction), keyEquivalent: "t")
        teacherItem.target = self
        menu.addItem(teacherItem)

        let studentItem = NSMenuItem(title: "Start as Student", action: #selector(startStudentAction), keyEquivalent: "s")
        studentItem.target = self
        menu.addItem(studentItem)

        menu.addItem(NSMenuItem.separator())

        // Kill Switch — always visible
        let killItem = NSMenuItem(title: "⛔ Terminate Stream", action: #selector(terminateAction), keyEquivalent: "q")
        killItem.target = self
        menu.addItem(killItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit LabLinkD", action: #selector(quitAction), keyEquivalent: "Q")
        quitItem.target = self
        menu.addItem(quitItem)

        item.menu = menu
        self.statusItem = item
        self.menu = menu

        LabLinkLog.ui.info("Menu bar initialized")
    }

    // MARK: - State Updates

    public func updateState(_ state: MenuState) {
        queue.async { [weak self] in
            guard let self else { return }
            self.currentState = state

            switch state {
            case .idle:
                self.statusItem?.button?.title = "⚪"
                self.statusItem?.button?.toolTip = "LabLink — Idle"
                self.stateMenuItem?.title = "Status: Idle"
            case .connected:
                self.statusItem?.button?.title = "🟢"
                self.statusItem?.button?.toolTip = "LabLink — Connected"
                self.stateMenuItem?.title = "Status: Connected"
            case .streaming:
                self.statusItem?.button?.title = "🔴"
                self.statusItem?.button?.toolTip = "LabLink — Streaming"
                self.stateMenuItem?.title = "Status: Streaming"
            }
        }
    }

    /// Show the session PIN in the menu (Teacher role).
    public func showPin(_ pin: String) {
        queue.async { [weak self] in
            self?.pinMenuItem?.title = "Session PIN: \(pin)"
            self?.pinMenuItem?.isHidden = false
        }
    }

    /// Show connected device name.
    public func showDevice(_ name: String) {
        queue.async { [weak self] in
            self?.deviceMenuItem?.title = "Device: \(name)"
        }
    }

    // MARK: - Actions

    @objc private func startTeacherAction() {
        onStartTeacher()
    }

    @objc private func startStudentAction() {
        onStartStudent()
    }

    @objc private func terminateAction() {
        onTerminate()
    }

    @objc private func quitAction() {
        onTerminate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NSApplication.shared.terminate(nil)
        }
    }
}
