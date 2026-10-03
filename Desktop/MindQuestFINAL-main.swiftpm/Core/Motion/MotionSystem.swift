import SwiftUI

// MARK: - MotionAgent
/// Coordinates micro-animations, transition timing, and spring configurations
/// across the app without modifying underlying view layouts.
@MainActor
final class MotionAgent {
    static let shared = MotionAgent()
    private init() {}
    
    // Standard spring configs
    static let snappy = Animation.spring(response: 0.3, dampingFraction: 0.6)
    static let gentle = Animation.spring(response: 0.5, dampingFraction: 0.7)
    static let bouncy = Animation.spring(response: 0.35, dampingFraction: 0.5)
    static let micro = Animation.spring(response: 0.2, dampingFraction: 0.7)
}

// MARK: - Emoji Bounce Confirmation
/// Emoji tap → scale 1→1.25→1 with expanding glow ring
struct EmojiBounceModifier: ViewModifier {
    @Binding var trigger: Bool
    var color: Color = .yellow
    
    @State private var scale: CGFloat = 1.0
    @State private var glowScale: CGFloat = 0.8
    @State private var glowOpacity: Double = 0.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .background(
                Circle()
                    .fill(color.opacity(0.3))
                    .scaleEffect(glowScale)
                    .opacity(glowOpacity)
                    .blur(radius: 8)
            )
            .onChange(of: trigger) { _ in
                withAnimation(MotionAgent.bouncy) {
                    scale = 1.25
                    glowScale = 1.6
                    glowOpacity = 0.6
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(MotionAgent.gentle) {
                        scale = 1.0
                        glowScale = 2.0
                        glowOpacity = 0.0
                    }
                }
            }
    }
}

// MARK: - Animated Number Counter
/// Smoothly increments displayed number with spring effect
struct AnimatedCounter: View {
    let value: Int
    let prefix: String
    let suffix: String
    let color: Color
    
    @State private var displayValue: Int = 0
    @State private var scale: CGFloat = 1.0
    
    init(_ value: Int, prefix: String = "", suffix: String = "", color: Color = .white) {
        self.value = value
        self.prefix = prefix
        self.suffix = suffix
        self.color = color
    }
    
    var body: some View {
        Text("\(prefix)\(displayValue)\(suffix)")
            .scaleEffect(scale)
            .onChange(of: value) { newVal in
                animateTo(newVal)
            }
            .onAppear { displayValue = value }
    }
    
    private func animateTo(_ target: Int) {
        let diff = target - displayValue
        guard diff != 0 else { return }
        
        withAnimation(MotionAgent.bouncy) { scale = 1.15 }
        
        let steps = min(abs(diff), 10)
        let stepVal = diff / max(steps, 1)
        
        for i in 0..<steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.04) {
                displayValue += stepVal
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps) * 0.04) {
            displayValue = target
            withAnimation(MotionAgent.gentle) { scale = 1.0 }
        }
    }
}

// MARK: - Breathing Orb with Ripple
/// Pulsing orb with expanding outer ripple ring, syncs with breathing state
struct BreathingOrbOverlay: View {
    let isInhaling: Bool
    let color: Color
    
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.4
    
    var body: some View {
        ZStack {
            // Outer ripple ring
            Circle()
                .stroke(color.opacity(rippleOpacity), lineWidth: 1.5)
                .scaleEffect(rippleScale)
                .animation(
                    .easeInOut(duration: 4).repeatForever(autoreverses: true),
                    value: isInhaling
                )
            
            // Secondary ripple
            Circle()
                .stroke(color.opacity(rippleOpacity * 0.5), lineWidth: 1)
                .scaleEffect(rippleScale * 1.15)
                .animation(
                    .easeInOut(duration: 4).repeatForever(autoreverses: true).delay(0.5),
                    value: isInhaling
                )
        }
        .onChange(of: isInhaling) { inhaling in
            withAnimation(.easeInOut(duration: 4)) {
                rippleScale = inhaling ? 1.3 : 0.9
                rippleOpacity = inhaling ? 0.5 : 0.15
            }
        }
        .onAppear {
            rippleScale = isInhaling ? 1.3 : 0.9
            rippleOpacity = isInhaling ? 0.5 : 0.15
        }
    }
}

// MARK: - Micro Shake Effect
/// Subtle horizontal shake for wrong answers
struct ShakeModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var offset: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _ in
                guard trigger else { return }
                withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) {
                    offset = -8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) { offset = 8 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.spring(response: 0.08, dampingFraction: 0.3)) { offset = -4 }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
                    withAnimation(.spring(response: 0.1, dampingFraction: 0.5)) { offset = 0 }
                    trigger = false
                }
            }
    }
}

// MARK: - Snap Scale Effect
/// Quick snap scale for correct answers: 1 → 1.12 → 1
struct SnapScaleModifier: ViewModifier {
    @Binding var trigger: Bool
    @State private var scale: CGFloat = 1.0
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onChange(of: trigger) { _ in
                guard trigger else { return }
                withAnimation(MotionAgent.micro) { scale = 1.12 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(MotionAgent.gentle) { scale = 1.0 }
                    trigger = false
                }
            }
    }
}

// MARK: - Completion Radial Burst
/// Vector-based radial burst animation for completions
struct RadialBurstOverlay: View {
    @Binding var isActive: Bool
    var color: Color = .yellow
    
    @State private var rays: [RayData] = (0..<8).map { i in
        RayData(angle: Double(i) * 45.0)
    }
    @State private var burstScale: CGFloat = 0.3
    @State private var burstOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            ForEach(rays.indices, id: \.self) { i in
                Capsule()
                    .fill(color.opacity(burstOpacity))
                    .frame(width: 3, height: 20)
                    .offset(y: -35 * burstScale)
                    .rotationEffect(.degrees(rays[i].angle))
            }
        }
        .onChange(of: isActive) { active in
            guard active else { return }
            withAnimation(.easeOut(duration: 0.4)) {
                burstScale = 1.5
                burstOpacity = 0.8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeIn(duration: 0.3)) {
                    burstOpacity = 0.0
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                burstScale = 0.3
                isActive = false
            }
        }
    }
    
    struct RayData { let angle: Double }
}

// MARK: - Waveform Visualizer (Simulated)
/// Lightweight simulated audio waveform using SwiftUI shapes
struct SimulatedWaveform: View {
    let isPlaying: Bool
    let color: Color
    let barCount: Int
    
    @State private var heights: [CGFloat]
    
    init(isPlaying: Bool, color: Color = .cyan, barCount: Int = 12) {
        self.isPlaying = isPlaying
        self.color = color
        self.barCount = barCount
        _heights = State(initialValue: (0..<barCount).map { _ in CGFloat.random(in: 0.2...0.5) })
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.8), color.opacity(0.3)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: 30 * heights[i])
            }
        }
        .frame(height: 30)
        .onAppear { if isPlaying { startAnimating() } }
        .onChange(of: isPlaying) { playing in
            if playing { startAnimating() } else { resetBars() }
        }
    }
    
    private func startAnimating() {
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
            guard isPlaying else { timer.invalidate(); return }
            withAnimation(.easeInOut(duration: 0.12)) {
                heights = (0..<barCount).map { _ in CGFloat.random(in: 0.15...1.0) }
            }
        }
    }
    
    private func resetBars() {
        withAnimation(.easeOut(duration: 0.3)) {
            heights = (0..<barCount).map { _ in CGFloat.random(in: 0.2...0.4) }
        }
    }
}

// MARK: -  Ambient Glow Modifier
/// Subtle reactive background glow that shifts based on mood
struct AmbientGlowModifier: ViewModifier {
    let moodColor: Color
    
    func body(content: Content) -> some View {
        content.background(
            RadialGradient(
                colors: [moodColor.opacity(0.08), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 1.5), value: moodColor.description)
        )
    }
}

// MARK: - Session Duration Counter
/// Animated session timer display
struct SessionDurationLabel: View {
    let startDate: Date?
    @State private var elapsed: Int = 0
    @State private var timer: Timer?
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "clock")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
            Text(formatTime(elapsed))
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
        }
        .onAppear { startTimer() }
        .onDisappear { timer?.invalidate() }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard let start = startDate else { return }
            elapsed = Int(Date().timeIntervalSince(start))
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60, s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Floating Idle Animation
/// Soft floating effect for static elements
struct FloatingModifier: ViewModifier {
    @State private var offset: CGFloat = 0
    let amplitude: CGFloat
    let duration: Double
    
    init(amplitude: CGFloat = 4, duration: Double = 3) {
        self.amplitude = amplitude
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: offset)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    offset = amplitude
                }
            }
    }
}

// MARK: - XP Badge Overlay
/// Animated "+X XP" badge that appears and fades
struct XPBadgeModifier: ViewModifier {
    @ObservedObject var engagement: EngagementAgent = .shared
    
    func body(content: Content) -> some View {
        content.overlay(
            ZStack {
                if engagement.showXPToast {
                    Text("+\(engagement.lastXPGain) XP")
                        .font(.system(size: 13, weight: .heavy, design: .rounded))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.6))
                        )
                        .shadow(color: .yellow.opacity(0.4), radius: 8)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.5).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .offset(y: -20)
                }
            }
            .animation(MotionAgent.bouncy, value: engagement.showXPToast),
            alignment: .top
        )
    }
}

// MARK: - View Extension Helpers
extension View {
    func emojiBounce(trigger: Binding<Bool>, color: Color = .yellow) -> some View {
        modifier(EmojiBounceModifier(trigger: trigger, color: color))
    }
    
    func microShake(trigger: Binding<Bool>) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
    
    func snapScale(trigger: Binding<Bool>) -> some View {
        modifier(SnapScaleModifier(trigger: trigger))
    }
    
    func floatingIdle(amplitude: CGFloat = 4, duration: Double = 3) -> some View {
        modifier(FloatingModifier(amplitude: amplitude, duration: duration))
    }
    
    func ambientGlow(mood: Color) -> some View {
        modifier(AmbientGlowModifier(moodColor: mood))
    }
    
    func xpBadge() -> some View {
        modifier(XPBadgeModifier())
    }
}
