import SwiftUI

@MainActor
struct Theme {
    // AMOLED-friendly color palette
    static let primary = Color(red: 0.29, green: 0.55, blue: 1.0)
    static let secondary = Color(red: 0.37, green: 0.83, blue: 0.78)
    static let accent = Color(red: 1.0, green: 0.68, blue: 0.26)
    static let tertiary = Color(red: 0.55, green: 0.62, blue: 0.78)
    static let warmGlow = Color(red: 1.0, green: 0.55, blue: 0.2)
    static let deepBlack = Color.black
    
    // Feature Colors
    static let health = Color(red: 1.0, green: 0.36, blue: 0.36)
    static let fitness = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let games = Color(red: 0.55, green: 0.35, blue: 0.95)
    static let music = Color(red: 1.0, green: 0.6, blue: 0.2)
    static let puzzles = Color(red: 0.3, green: 0.7, blue: 1.0)
    static let wellness = Color(red: 0.4, green: 0.85, blue: 0.65)
    static let discover = Color(red: 0.75, green: 0.45, blue: 1.0)
    
    // MARK: - Dynamic Background Colors
    static let background = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .black : UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    })
    
    static let cardBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.08, alpha: 1.0) : UIColor.white
    })
    
    static let elevatedCardBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.12, alpha: 1.0) : UIColor.white
    })
    
    static let textPrimary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    })
    
    static let textSecondary = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 0.75, alpha: 1.0) : UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
    })
    
    static let divider = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.1) : UIColor(white: 0.0, alpha: 0.08)
    })
    
    static let glassBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.05) : UIColor(white: 1.0, alpha: 0.7)
    })

    static let overlayBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? UIColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 0.85) : UIColor(white: 1.0, alpha: 0.9)
    })
    
    static let overlayText = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark ? .white : UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
    })

    // MARK: - Dynamic Gradients
    static var navyGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(red: 0.03, green: 0.03, blue: 0.08, alpha: 1.0) : UIColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0) }),
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? .black : UIColor(white: 0.9, alpha: 1.0) }),
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? .black : UIColor(white: 0.92, alpha: 1.0) })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.06) : UIColor.white }),
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.02) : UIColor(white: 0.98, alpha: 1.0) })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var elevatedCard: LinearGradient {
        LinearGradient(
            colors: [
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.1) : UIColor.white }),
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(white: 1.0, alpha: 0.03) : UIColor(white: 0.97, alpha: 1.0) })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static var headerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(red: 0.08, green: 0.05, blue: 0.15, alpha: 1.0) : .white }),
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? UIColor(red: 0.02, green: 0.03, blue: 0.08, alpha: 1.0) : UIColor(white: 0.98, alpha: 1.0) }),
                Color(UIColor { trait in trait.userInterfaceStyle == .dark ? .black : UIColor(white: 0.97, alpha: 1.0) })
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static let titleFont = Font.system(.title, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .rounded)
    
    // MARK: - Navigation & Layout
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }
    
    static var headerHeight: CGFloat { screenHeight * 0.1 } // Responsive header
    static let cornerRadiusLarge: CGFloat = 24
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusSmall: CGFloat = 12
    static var paddingStandard: CGFloat { screenWidth * 0.05 } // 5% of screen width
    
    static var springDuration: Double { CognitiveInsightAgent.shared.emotionalTempoDuration }
    static let springDamping: Double = 0.7
    
    static func moodGradient(for emoji: String) -> LinearGradient {
        switch emoji {
        case "🌟": return LinearGradient(colors: [Color.yellow.opacity(0.08), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "😊": return LinearGradient(colors: [Color.green.opacity(0.06), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "😌": return LinearGradient(colors: [secondary.opacity(0.06), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "😕": return LinearGradient(colors: [Color.orange.opacity(0.05), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "😔": return LinearGradient(colors: [Color.blue.opacity(0.05), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Glowing Card Modifier
struct GlowingCardModifier: ViewModifier {
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        let isDark = colorScheme == .dark
        content
            .padding(20)
            .background(
                ZStack {
                    isDark ? Color.white.opacity(0.03) : Color.white
                    RadialGradient(
                        colors: [color.opacity(isDark ? 0.08 : 0.04), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 250
                    )
                }
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [color.opacity(isDark ? 0.3 : 0.5), color.opacity(isDark ? 0.03 : 0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isDark ? 0.5 : 1.0
                    )
            )
            .shadow(color: color.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Progress Ring
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    var size: CGFloat = 60
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.1), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    LinearGradient(colors: [color, color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.3), radius: 3)
        }
        .frame(width: size, height: size)
    }
}

extension View {
    func glowingCard(_ color: Color) -> some View {
        self.modifier(GlowingCardModifier(color: color))
    }
}

// MARK: - Tap Gesture Feedback
struct SubtleTapModifier: ViewModifier {
    @State private var isPressed = false
    let action: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {
                // If there's an action to perform on tap, do it here, but often we just want the visual press
                action?()
            })
    }
}

extension View {
    func withSubtleTap(action: (() -> Void)? = nil) -> some View {
        self.modifier(SubtleTapModifier(action: action))
    }
}

// Global button style for cards
struct SubtleTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - NightToneAgent
/// Detects time-of-day and provides adaptive warm tone overlay for evening use.
@MainActor
final class NightToneAgent: ObservableObject {
    static let shared = NightToneAgent()
    
    @Published var isNightMode: Bool = false
    @Published var warmthIntensity: Double = 0
    
    private init() {
        updateTone()
    }
    
    func updateTone() {
        let hour = Calendar.current.component(.hour, from: Date())
        // Gradual warmth: 8PM = 0.03, 9PM = 0.05, 10PM+ = 0.07, 5-7AM = 0.03
        if hour >= 22 || hour < 5 {
            isNightMode = true
            warmthIntensity = 0.07
        } else if hour >= 21 {
            isNightMode = true
            warmthIntensity = 0.05
        } else if hour >= 20 {
            isNightMode = true
            warmthIntensity = 0.03
        } else if hour < 7 {
            isNightMode = true
            warmthIntensity = 0.03
        } else {
            isNightMode = false
            warmthIntensity = 0
        }
    }
}

// MARK: - Night Tone Overlay
struct NightToneOverlay: ViewModifier {
    @StateObject private var agent = NightToneAgent.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if agent.isNightMode {
                    Color(red: 1.0, green: 0.7, blue: 0.3)
                        .opacity(agent.warmthIntensity)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 2.0), value: agent.warmthIntensity)
                }
            }
        )
    }
}

extension View {
    func nightToneOverlay() -> some View {
        self.modifier(NightToneOverlay())
    }
}

// MARK: - Glassmorphic Card Modifier
struct GlassmorphicCardModifier: ViewModifier {
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(colorScheme == .dark ? 0.08 : 0.05),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            )
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(colorScheme == .dark ? 0.15 : 0.5),
                                Color.white.opacity(colorScheme == .dark ? 0.02 : 0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: color.opacity(0.1), radius: 15, y: 8)
    }
}

extension View {
    func glassmorphicCard(_ color: Color = .white) -> some View {
        self.modifier(GlassmorphicCardModifier(color: color))
    }
}

