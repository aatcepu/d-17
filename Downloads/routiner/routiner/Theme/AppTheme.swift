import SwiftUI

// MARK: - What is this file?
// A single place that holds the app's DESIGN TOKENS — colors, spacing,
// corner radii and shadows. Pulled straight from the Figma design
// (Routiner - Habit Tracker App).
//
// Why bother with a "theme" file instead of typing values everywhere?
// If the designer changes the brand purple next month, you edit ONE line
// here instead of hunting through every screen. It also means every screen
// automatically stays visually consistent — which is most of what "pixel
// perfect" actually means in practice: the same 16pt gap and the same 16pt
// corner radius everywhere, not a 15 here and a 17 there.

enum AppTheme {

    // MARK: Brand colors
    // These are the same in light and dark mode — a brand color shouldn't
    // change identity just because the user flipped a switch.

    /// The deep indigo/purple used for the primary button, progress rings,
    /// and the onboarding background gradient.
    static let primary = Color(hex: "4F46E5")

    /// The two ends of the diagonal gradient behind the onboarding screens.
    static let gradientTop = Color(hex: "7B7FF6")
    static let gradientBottom = Color(hex: "4338CA")

    // MARK: Surfaces & text
    // These DO change between light and dark mode. Each one is declared with
    // both values up front (see `Color(light:dark:)` at the bottom of this
    // file), so a screen never has to ask "am I in dark mode?" — it just uses
    // the token and gets the right value automatically.

    /// The page background sitting behind the cards on Home and Profile.
    static let groupedBackground = Color(light: "F5F6FA", dark: "0F1017")

    /// The background of a single card (a habit row, an activity row...).
    static let cardBackground = Color(light: "FFFFFF", dark: "1B1D29")

    /// Muted text — subtitles, captions, placeholder copy.
    static let secondaryText = Color(light: "8B8D97", dark: "9BA0AE")

    /// Hairline borders and dividers.
    static let separator = Color(light: "E9EAF0", dark: "2A2D3B")

    // MARK: Spacing
    // A fixed scale instead of hand-picked numbers. Sticking to a scale is
    // what stops a layout from looking subtly "off" — every gap in the app
    // is one of these six values, nothing in between.
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }

    // MARK: Corner radii
    enum Radius {
        /// Small chips and calendar day boxes.
        static let small: CGFloat = 12
        /// The standard card radius used across Home and Profile.
        static let card: CGFloat = 16
        /// Large hero surfaces, e.g. the daily-progress banner.
        static let large: CGFloat = 20
    }

    // MARK: Elevation
    // One shared shadow recipe. Defining it once means every card in the app
    // catches the light from the same angle — copy-pasted shadows are one of
    // the most common ways a design drifts out of spec.
    enum Elevation {
        static let color = Color.black.opacity(0.06)
        static let radius: CGFloat = 10
        static let y: CGFloat = 4
    }

    // MARK: Layout constants
    /// Standard screen edge inset. Every screen uses this so headlines on
    /// different tabs line up perfectly when you flip between them.
    static let screenPadding: CGFloat = 20

    /// Diameter of the icon bubble on a habit row.
    static let iconBubbleSize: CGFloat = 44
}

// MARK: - Color(hex:)
// SwiftUI's `Color` only ships initializers for named colors (.blue, .red)
// or RGB values from 0...1 (Color(red: 0.3, green: 0.5, blue: 0.9)).
// Designers hand us hex codes instead (like "4F46E5"), so this extension
// teaches `Color` a new initializer that understands hex strings.
extension Color {

    /// Creates a color from a hex string such as `"4F46E5"`, `"#4F46E5"`, or
    /// `"4F46E5FF"` (with alpha). Falls back to magenta on malformed input so
    /// a typo is loud and obvious on screen instead of silently drawing black.
    init(hex: String) {
        // Keep only real hex digits, wherever they appear. (The old version
        // used `trimmingCharacters`, which only strips from the two ENDS of
        // the string — so a stray character in the middle sailed through.)
        let digits = hex.filter(\.isHexDigit)

        // Scanner reads the hex string as one big integer, e.g. "4F46E5" -> 0x4F46E5.
        var value: UInt64 = 0
        guard Scanner(string: digits).scanHexInt64(&value) else {
            self = .magenta_invalidHex
            return
        }

        // Bit-shifting pulls out each color channel from that single integer.
        // Example: 0x4F46E5 -> red = 0x4F, green = 0x46, blue = 0xE5.
        switch digits.count {
        case 6: // RRGGBB
            self.init(
                .sRGB,
                red: Double((value >> 16) & 0xFF) / 255,
                green: Double((value >> 8) & 0xFF) / 255,
                blue: Double(value & 0xFF) / 255,
                opacity: 1
            )
        case 8: // RRGGBBAA
            self.init(
                .sRGB,
                red: Double((value >> 24) & 0xFF) / 255,
                green: Double((value >> 16) & 0xFF) / 255,
                blue: Double((value >> 8) & 0xFF) / 255,
                opacity: Double(value & 0xFF) / 255
            )
        default:
            // Not 6 or 8 digits — someone mistyped the token.
            self = .magenta_invalidHex
        }
    }

    /// Deliberately hideous, so a bad hex code gets noticed during development
    /// rather than shipping as an invisible black rectangle.
    fileprivate static let magenta_invalidHex = Color(.sRGB, red: 1, green: 0, blue: 1, opacity: 1)

    /// Builds a color that automatically swaps value when the system flips
    /// between light and dark mode.
    ///
    /// `UIColor` has supported this for years via its trait-based initializer;
    /// SwiftUI's `Color` can simply wrap one. That's why the theme above can
    /// declare both appearances in a single line.
    init(light: String, dark: String) {
        self.init(UIColor { traits in
            UIColor(Color(hex: traits.userInterfaceStyle == .dark ? dark : light))
        })
    }
}
