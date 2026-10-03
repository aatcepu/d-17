import SwiftUI

// MARK: - Insight Dashboard View
/// Premium analytics dashboard displaying cognitive insights. Integrated into JourneyView.
struct InsightDashboardView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var agent = CognitiveInsightAgent.shared
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Section Header
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                    .font(.headline)
                    .foregroundColor(Theme.secondary)
                Text("Cognitive Insights")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("AI")
                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.secondary.opacity(0.15))
                    .cornerRadius(6)
            }
            
            // 1. Emotional Stability Spectrum
            StabilitySpectrumCard(agent: agent, animateIn: animateIn)
            
            // 2. Performance Rhythm Signature
            RhythmSignatureCard(agent: agent, animateIn: animateIn)
            
            // 3. Neural Harmony Scale
            NeuralHarmonyCard(agent: agent, animateIn: animateIn)
            
            // 4. Recovery Curve
            if agent.recoveryAvgHours > 0 {
                RecoveryCurveCard(agent: agent, animateIn: animateIn)
            }
            
            // 5. Resonance Profile
            if !agent.resonanceMatches.isEmpty {
                ResonanceProfileCard(agent: agent, animateIn: animateIn)
            }
            
            // 6. Cognitive Fatigue Signal
            if let message = agent.fatigueLevel.message {
                FatigueSignalCard(message: message, animateIn: animateIn)
            }
        }
        .onAppear {
            agent.analyze(
                history: appState.moodHistory,
                wellnessLogs: appState.wellnessLogs,
                focusMinutes: FocusAgent.shared.totalFocusMinutes
            )
            withAnimation(.spring(response: 0.6).delay(0.2)) {
                animateIn = true
            }
        }
    }
}

// MARK: - Stability Spectrum Card
struct StabilitySpectrumCard: View {
    let agent: CognitiveInsightAgent
    let animateIn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: agent.stabilityState.icon)
                    .foregroundColor(agent.stabilityState.color)
                    .font(.subheadline)
                Text("Emotional Stability")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text(agent.stabilityState.rawValue)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(agent.stabilityState.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(agent.stabilityState.color.opacity(0.18))
                    .cornerRadius(8)
            }
            
            // 7-day smooth sparkline
            if agent.stabilityScores.count >= 2 {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h: CGFloat = 36
                    let stepX = w / CGFloat(agent.stabilityScores.count - 1)
                    
                    ZStack {
                        // Gradient fill
                        Path { path in
                            for (i, score) in agent.stabilityScores.enumerated() {
                                let x = CGFloat(i) * stepX
                                let y = h - ((CGFloat(score) - 1) / 4.0) * h
                                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                            path.addLine(to: CGPoint(x: w, y: h))
                            path.addLine(to: CGPoint(x: 0, y: h))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [agent.stabilityState.color.opacity(0.2), .clear],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        
                        // Line
                        Path { path in
                            for (i, score) in agent.stabilityScores.enumerated() {
                                let x = CGFloat(i) * stepX
                                let y = h - ((CGFloat(score) - 1) / 4.0) * h
                                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                        }
                        .stroke(agent.stabilityState.color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                }
                .frame(height: 36)
            }
            
            // Tooltip
            Text(agent.stabilityState.tooltip)
                .font(.system(size: 11, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(agent.stabilityState.color.opacity(0.15), lineWidth: 0.5))
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
    }
}

// MARK: - Performance Rhythm Signature
struct RhythmSignatureCard: View {
    let agent: CognitiveInsightAgent
    let animateIn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(Theme.accent)
                    .font(.subheadline)
                Text("Your Focus Window")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text(agent.peakWindowLabel)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.accent)
            }
            
            // 24hr horizontal gradient strip
            GeometryReader { geo in
                let slots = agent.rhythmSlots
                let maxVal = max(slots.max() ?? 1, 1)
                
                HStack(spacing: 1) {
                    ForEach(0..<24, id: \.self) { hour in
                        let intensity = slots[hour] / maxVal
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Theme.accent.opacity(intensity * 0.8 + 0.12))
                            .frame(height: 20)
                    }
                }
                .cornerRadius(6)
            }
            .frame(height: 20)
            
            // Time labels
            HStack {
                Text("12 AM")
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("12 PM")
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                Spacer()
                Text("11 PM")
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.accent.opacity(0.12), lineWidth: 0.5))
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
    }
}

// MARK: - Neural Harmony Scale
struct NeuralHarmonyCard: View {
    let agent: CognitiveInsightAgent
    let animateIn: Bool
    @State private var animateRing = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain")
                    .foregroundColor(Theme.discover)
                    .font(.subheadline)
                Text("Neural Harmony")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
            }
            
            HStack(spacing: 20) {
                // Circular meter
                ZStack {
                    Circle()
                        .stroke(Theme.textPrimary.opacity(0.12), lineWidth: 6)
                        .frame(width: 64, height: 64)
                    
                    // Calm arc (bottom half - left)
                    Circle()
                        .trim(from: 0, to: animateRing ? CGFloat(1 - agent.harmonyRatio) * 0.5 : 0)
                        .stroke(Theme.secondary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    
                    // Logic arc (top half - right)
                    Circle()
                        .trim(from: 0.5, to: animateRing ? 0.5 + CGFloat(agent.harmonyRatio) * 0.5 : 0.5)
                        .stroke(Theme.discover, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 1) {
                        Text("\(Int(agent.harmonyRatio * 100))")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        Text("%")
                            .font(.system(size: 9, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Circle().fill(Theme.discover).frame(width: 8, height: 8)
                        Text("Logic")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                        Spacer()
                        Circle().fill(Theme.secondary).frame(width: 8, height: 8)
                        Text("Calm")
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Text(agent.harmonyLabel)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textPrimary)
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.discover.opacity(0.12), lineWidth: 0.5))
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).delay(0.4)) {
                animateRing = true
            }
        }
    }
}

// MARK: - Recovery Curve Card
struct RecoveryCurveCard: View {
    let agent: CognitiveInsightAgent
    let animateIn: Bool
    @State private var curveProgress: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "arrow.uturn.up")
                    .foregroundColor(Color(red: 0.2, green: 0.9, blue: 0.5))
                    .font(.subheadline)
                Text("Emotional Recovery")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Text("\(Int(agent.recoveryAvgHours))h avg")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.2, green: 0.9, blue: 0.5))
            }
            
            // Animated recovery curve
            GeometryReader { geo in
                Path { path in
                    let w = geo.size.width
                    let h: CGFloat = 30
                    path.move(to: CGPoint(x: 0, y: h))
                    path.addCurve(
                        to: CGPoint(x: w * curveProgress, y: h * 0.15),
                        control1: CGPoint(x: w * 0.3 * curveProgress, y: h * 0.8),
                        control2: CGPoint(x: w * 0.6 * curveProgress, y: h * 0.1)
                    )
                }
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.9, blue: 0.5).opacity(0.3), Color(red: 0.2, green: 0.9, blue: 0.5)],
                        startPoint: .leading, endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                )
            }
            .frame(height: 30)
            
            if !agent.bestRecoveryActivity.isEmpty {
                Text("You recover faster after \(agent.bestRecoveryActivity.lowercased()) sessions.")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(red: 0.2, green: 0.9, blue: 0.5).opacity(0.2), lineWidth: 0.5))
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.5)) {
                curveProgress = 1.0
            }
        }
    }
}

// MARK: - Resonance Profile Card
struct ResonanceProfileCard: View {
    let agent: CognitiveInsightAgent
    let animateIn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "waveform.circle.fill")
                    .foregroundColor(Theme.music)
                    .font(.subheadline)
                Text("Resonance Profile")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
            }
            
            ForEach(Array(agent.resonanceMatches.enumerated()), id: \.offset) { index, match in
                HStack(spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 10, weight: .heavy, design: .rounded))
                        .foregroundColor(Theme.music)
                        .frame(width: 18, height: 18)
                        .background(Theme.music.opacity(0.12))
                        .cornerRadius(5)
                    
                    Text(match.activity)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                    
                    Spacer()
                    
                    // Score bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Theme.textPrimary.opacity(0.12)).frame(height: 4)
                            Capsule().fill(Theme.music).frame(width: geo.size.width * CGFloat(match.score / 5.0), height: 4)
                        }
                    }
                    .frame(width: 60, height: 4)
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.music.opacity(0.12), lineWidth: 0.5))
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 12)
    }
}

// MARK: - Fatigue Signal Card
struct FatigueSignalCard: View {
    let message: String
    let animateIn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "leaf.fill")
                .foregroundColor(Theme.wellness)
                .font(.subheadline)
            
            Text(message)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(Theme.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding(14)
        .background(Theme.wellness.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.wellness.opacity(0.15), lineWidth: 0.5))
        .opacity(animateIn ? 1 : 0)
        .offset(y: animateIn ? 0 : 8)
    }
}
