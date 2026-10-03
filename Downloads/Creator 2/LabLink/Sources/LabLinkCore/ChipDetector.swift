import Foundation

/// Detects Apple Silicon chip generation and capabilities.
/// Used to select optimal codec path (HEVC vs ProRes 422 Proxy on M5).
public enum ChipDetector {

    /// Apple Silicon chip generation.
    public enum ChipGeneration: Sendable, Comparable {
        case m1
        case m2
        case m3
        case m4
        case m5
        case unknown(String)

        public static func < (lhs: ChipGeneration, rhs: ChipGeneration) -> Bool {
            return lhs.ordinal < rhs.ordinal
        }

        fileprivate var ordinal: Int {
            switch self {
            case .m1: return 1
            case .m2: return 2
            case .m3: return 3
            case .m4: return 4
            case .m5: return 5
            case .unknown: return 0
            }
        }
    }

    /// Detect the current chip generation via sysctl.
    public static func detect() -> ChipGeneration {
        let chipName = sysctlString("machdep.cpu.brand_string").lowercased()

        if chipName.contains("m5") { return .m5 }
        if chipName.contains("m4") { return .m4 }
        if chipName.contains("m3") { return .m3 }
        if chipName.contains("m2") { return .m2 }
        if chipName.contains("m1") { return .m1 }

        return .unknown(chipName)
    }

    /// Returns true if the chip is M5 or later (has hardware ProRes accelerator).
    public static var isM5OrLater: Bool {
        return detect() >= .m5
    }

    /// Returns the recommended codec mode based on detected hardware.
    public static var recommendedCodec: MediaStreamer.CodecMode {
        if isM5OrLater {
            LabLinkLog.system.info("M5 detected — enabling ProRes 422 Proxy Ultra mode")
            return .prores422proxy
        } else {
            LabLinkLog.system.info("M1–M4 detected — using HEVC 4:4:4")
            return .hevc444
        }
    }

    // MARK: - sysctl Helper

    private static func sysctlString(_ name: String) -> String {
        var size: Int = 0
        sysctlbyname(name, nil, &size, nil, 0)
        guard size > 0 else { return "" }

        var result = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &result, &size, nil, 0)
        return String(decoding: result.prefix(while: { $0 != 0 }).map { UInt8(bitPattern: $0) }, as: UTF8.self)
    }
}
