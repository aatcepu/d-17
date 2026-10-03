import SwiftUI

// MARK: - EvolutionAgent
/// Tracks long-term personal growth, dynamic identity, and habit solidification.
@MainActor
final class EvolutionAgent: ObservableObject {
    static let shared = EvolutionAgent()
    
    // MARK: - Published State
    @Published var growthScores: [Double] = []          // Monthly averages
    @Published var currentArchetype: Archetype = .explorer
    @Published var habitPhase: HabitPhase = .forming
    @Published var totalReflections: Int = 0
    @Published var milestones: [Int] = []               // Crossed milestones
    @Published var consistencyDays: Int = 0
    
    // MARK: - Archetype System
    enum Archetype: String {
        case explorer = "Explorer"
        case builder = "Builder"
        case guardian = "Guardian"
        case visionary = "Visionary"
        case sage = "Sage"
        
        var icon: String {
            switch self {
            case .explorer: return "safari.fill"
            case .builder: return "hammer.fill"
            case .guardian: return "shield.fill"
            case .visionary: return "eye.fill"
            case .sage: return "graduationcap.fill"
            }
        }
        
        var description: String {
            switch self {
            case .explorer: return "Curious and open. You're discovering what works for you."
            case .builder: return "Consistent and growing. You're building strong habits."
            case .guardian: return "Steady and protective. You maintain your wellness routines."
            case .visionary: return "Focused and aware. You see patterns others miss."
            case .sage: return "Wise and balanced. Your self-awareness is remarkable."
            }
        }
        
        var color: Color {
            switch self {
            case .explorer: return Color(red: 0.37, green: 0.83, blue: 0.78)
            case .builder: return Color(red: 1.0, green: 0.68, blue: 0.26)
            case .guardian: return Color(red: 0.2, green: 0.8, blue: 0.4)
            case .visionary: return Color(red: 0.55, green: 0.35, blue: 0.95)
            case .sage: return Color(red: 0.29, green: 0.55, blue: 1.0)
            }
        }
    }
    
    // MARK: - Habit Solidification Phases
    enum HabitPhase: String {
        case forming = "Forming"
        case strengthening = "Strengthening"
        case solidified = "Solidified"
        
        var icon: String {
            switch self {
            case .forming: return "circle.dashed"
            case .strengthening: return "circle.bottomhalf.filled"
            case .solidified: return "circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .forming: return Color(red: 1.0, green: 0.68, blue: 0.26)
            case .strengthening: return Color(red: 0.37, green: 0.83, blue: 0.78)
            case .solidified: return Color(red: 0.2, green: 0.9, blue: 0.5)
            }
        }
        
        var progress: Double {
            switch self {
            case .forming: return 0.33
            case .strengthening: return 0.66
            case .solidified: return 1.0
            }
        }
    }
    
    private init() {}
    
    // MARK: - Analysis
    func analyze(history: [MoodEntry], wellnessLogs: [DailyWellnessLog], streak: Int) {
        totalReflections = history.count
        consistencyDays = streak
        
        computeGrowthCurve(history)
        computeArchetype(history, streak: streak)
        computeHabitPhase(streak)
        computeMilestones()
    }
    
    // MARK: - Evolution Curve (Monthly Growth)
    private func computeGrowthCurve(_ history: [MoodEntry]) {
        let calendar = Calendar.current
        var monthlyScores: [String: [Int]] = [:]
        
        for entry in history {
            let components = calendar.dateComponents([.year, .month], from: entry.date)
            let key = "\(components.year ?? 0)-\(components.month ?? 0)"
            let score = moodScore(entry.emoji)
            monthlyScores[key, default: []].append(score)
        }
        
        // Sort by date key and compute averages
        let sorted = monthlyScores.sorted { $0.key < $1.key }
        growthScores = sorted.map { month in
            let avg = Double(month.value.reduce(0, +)) / Double(month.value.count)
            return avg
        }
    }
    
    // MARK: - Dynamic Identity (Archetype)
    private func computeArchetype(_ history: [MoodEntry], streak: Int) {
        let count = history.count
        let avgScore = history.isEmpty ? 3.0 : Double(history.prefix(14).map { moodScore($0.emoji) }.reduce(0, +)) / Double(min(count, 14))
        
        if count >= 100 && avgScore >= 3.5 {
            currentArchetype = .sage
        } else if count >= 50 && streak >= 14 {
            currentArchetype = .visionary
        } else if streak >= 7 && avgScore >= 3.0 {
            currentArchetype = .guardian
        } else if count >= 20 {
            currentArchetype = .builder
        } else {
            currentArchetype = .explorer
        }
    }
    
    // MARK: - Habit Solidification
    private func computeHabitPhase(_ streak: Int) {
        if streak >= 21 {
            habitPhase = .solidified
        } else if streak >= 7 {
            habitPhase = .strengthening
        } else {
            habitPhase = .forming
        }
    }
    
    // MARK: - Growth Milestones
    private func computeMilestones() {
        let thresholds = [10, 25, 50, 100, 200, 500]
        milestones = thresholds.filter { totalReflections >= $0 }
    }
    
    private func moodScore(_ emoji: String) -> Int {
        switch emoji {
        case "🌟": return 5
        case "😊": return 4
        case "😌": return 3
        case "😕": return 2
        case "😔": return 1
        default: return 3
        }
    }
}

// MARK: - Evolution Curve View (for Profile)
struct EvolutionCurveCard: View {
    @StateObject private var agent = EvolutionAgent.shared
    @EnvironmentObject var appState: AppState
    @State private var curveAnim: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(Theme.secondary)
                    .font(.subheadline)
                Text("Personal Growth Trend")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Spacer()
            }
            
            // Evolution curve
            if agent.growthScores.count >= 2 {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h: CGFloat = 50
                    let stepX = w / CGFloat(agent.growthScores.count - 1)
                    
                    ZStack {
                        // Fill
                        Path { path in
                            for (i, score) in agent.growthScores.enumerated() {
                                let x = CGFloat(i) * stepX * curveAnim
                                let y = h - ((CGFloat(score) - 1) / 4.0) * h
                                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                            path.addLine(to: CGPoint(x: w * curveAnim, y: h))
                            path.addLine(to: CGPoint(x: 0, y: h))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [Theme.secondary.opacity(0.15), .clear],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        
                        // Line
                        Path { path in
                            for (i, score) in agent.growthScores.enumerated() {
                                let x = CGFloat(i) * stepX * curveAnim
                                let y = h - ((CGFloat(score) - 1) / 4.0) * h
                                if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                        }
                        .stroke(Theme.secondary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    }
                }
                .frame(height: 50)
            } else {
                Text("Check in more to see your growth curve")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            
            // Dynamic Identity
            HStack(spacing: 10) {
                Image(systemName: agent.currentArchetype.icon)
                    .foregroundColor(agent.currentArchetype.color)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(agent.currentArchetype.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    Text(agent.currentArchetype.description)
                        .font(.system(size: 11, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            // Habit Phase
            HStack(spacing: 10) {
                Image(systemName: agent.habitPhase.icon)
                    .foregroundColor(agent.habitPhase.color)
                    .font(.caption)
                
                Text("Habit Phase: \(agent.habitPhase.rawValue)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                // Phase progress
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.textPrimary.opacity(0.06)).frame(height: 4)
                        Capsule().fill(agent.habitPhase.color).frame(width: geo.size.width * agent.habitPhase.progress, height: 4)
                    }
                }
                .frame(width: 60, height: 4)
            }
            
            // Milestones
            if !agent.milestones.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(agent.milestones, id: \.self) { milestone in
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.yellow)
                                Text("\(milestone)")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.textPrimary.opacity(0.05))
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.secondary.opacity(0.12), lineWidth: 0.5))
        .onAppear {
            agent.analyze(
                history: appState.moodHistory,
                wellnessLogs: appState.wellnessLogs,
                streak: appState.wellnessStreak
            )
            withAnimation(.easeOut(duration: 1.5).delay(0.3)) {
                curveAnim = 1.0
            }
        }
    }
}
