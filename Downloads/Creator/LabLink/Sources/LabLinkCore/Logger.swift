import Foundation
import os.log

/// Centralized OSLog-based logging for LabLinkD.
/// Zero print() statements — all logging goes through unified logging.
public enum LabLinkLog {
    private static let subsystem = "com.lablink.daemon"

    public static let network   = Logger(subsystem: subsystem, category: "Network")
    public static let discovery = Logger(subsystem: subsystem, category: "Discovery")
    public static let handshake = Logger(subsystem: subsystem, category: "Handshake")
    public static let capture   = Logger(subsystem: subsystem, category: "Capture")
    public static let encoder   = Logger(subsystem: subsystem, category: "Encoder")
    public static let decoder   = Logger(subsystem: subsystem, category: "Decoder")
    public static let ui        = Logger(subsystem: subsystem, category: "UI")
    public static let system    = Logger(subsystem: subsystem, category: "System")
}
