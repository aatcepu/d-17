import SwiftUI

// MARK: - CognitiveInsightAgent
/// Central intelligence engine that analyzes existing mood/wellness data
/// to produce advanced behavioral insights. No new data collection — pure computation.
@MainActor
final class CognitiveInsightAgent: ObservableObject {
    static let shared = CognitiveInsightAgent()
    
    // MARK: - Published Insights
    @Published var stabilityState: StabilityState = .stable
    @Published var stabilityScores: [Double] = []
    @Published var recoveryAvgHours: Double = 0
    @Published var bestRecoveryActivity: String = ""
    @Published var rhythmSlots: [Double] = Array(repeating: 0, count: 24)
    @Published var peakWindowLabel: String = "No data yet"
    @Published var harmonyRatio: Double = 0.5 // 0 = all calm, 1 = all logic
    @Published var harmonyLabel: String = "Balanced"
    @Published var fatigueLevel: FatigueLevel = .none
    @Published var focusCapitalHours: Double = 0
    @Published var resonanceMatches: [(activity: String, score: Double)] = []
    @Published var velocityState: VelocityState = .steady
    @Published var narrativeText: String = ""
    
    // MARK: - Enums
    enum StabilityState: String {
        case stable = "Stable"
        case adaptive = "Adaptive"
        case fluctuating = "Fluctuating"
        
        var icon: String {
            switch self {
            case .stable: return "circle.fill"
            case .adaptive: return "arrow.triangle.swap"
            case .fluctuating: return "waveform.path"
            }
        }
        
        var color: Color {
            switch self {
            case .stable: return Color(red: 0.2, green: 0.9, blue: 0.5)
            case .adaptive: return Color(red: 0.37, green: 0.83, blue: 0.78)
            case .fluctuating: return Color(red: 1.0, green: 0.68, blue: 0.26)
            }
        }
        
        var tooltip: String {
            switch self {
            case .stable: return "Your emotions have been consistent. Stability builds resilience."
            case .adaptive: return "Emotional flexibility is normal. You're adjusting well to change."
            case .fluctuating: return "High variation detected. Consistency improves with routine."
            }
        }
    }
    
    enum FatigueLevel {
        case none, mild, moderate
        
        var message: String? {
            switch self {
            case .none: return nil
            case .mild: return "Your system suggests a gentle pause."
            case .moderate: return "Your system suggests restoration. Consider a calm activity."
            }
        }
    }
    
    enum VelocityState: String {
        case accelerating = "Accelerating"
        case steady = "Steady"
        case decelerating = "Decelerating"
        
        var icon: String {
            switch self {
            case .accelerating: return "arrow.up.right"
            case .steady: return "arrow.right"
            case .decelerating: return "arrow.down.right"
            }
        }
    }
    
    private init() {}
    
    // MARK: - Main Analysis
    func analyze(history: [MoodEntry], wellnessLogs: [DailyWellnessLog], focusMinutes: Int) {
        analyzeStability(history)
        analyzeRecovery(history)
        analyzeRhythm(history)
        analyzeHarmony(history)
        analyzeFatigue(history, wellnessLogs: wellnessLogs)
        focusCapitalHours = Double(focusMinutes) / 60.0
        analyzeResonance(history)
        analyzeVelocity(wellnessLogs)
        generateNarrative(history, wellnessLogs: wellnessLogs)
    }
    
    // MARK: - 1. Emotional Stability Spectrum
    private func analyzeStability(_ history: [MoodEntry]) {
        let recent = Array(history.prefix(7))
        guard recent.count >= 3 else {
            stabilityState = .stable
            stabilityScores = recent.map { Double(moodScore($0.emoji)) }
            return
        }
        
        let scores = recent.map { Double(moodScore($0.emoji)) }
        stabilityScores = scores
        
        // Calculate standard deviation
        let mean = scores.reduce(0, +) / Double(scores.count)
        let variance = scores.map { ($0 - mean) * ($0 - mean) }.reduce(0, +) / Double(scores.count)
        let stdDev = sqrt(variance)
        
        if stdDev < 0.6 {
            stabilityState = .stable
        } else if stdDev < 1.2 {
            stabilityState = .adaptive
        } else {
            stabilityState = .fluctuating
        }
    }
    
    // MARK: - 2. Emotional Recovery Curve
    private func analyzeRecovery(_ history: [MoodEntry]) {
        guard history.count >= 4 else {
            recoveryAvgHours = 0
            bestRecoveryActivity = ""
            return
        }
        
        var recoveryTimes: [Double] = []
        var recoveryActivities: [String: Int] = [:]
        
        let sorted = history.sorted { $0.date < $1.date }
        var inDip = false
        var dipStart: Date?
        
        for i in 0..<sorted.count {
            let score = moodScore(sorted[i].emoji)
            if score <= 2 && !inDip {
                inDip = true
                dipStart = sorted[i].date
            } else if score >= 4 && inDip, let start = dipStart {
                let hours = sorted[i].date.timeIntervalSince(start) / 3600
                if hours > 0 && hours < 168 { // Max 1 week
                    recoveryTimes.append(hours)
                    for activity in sorted[i].activities {
                        recoveryActivities[activity, default: 0] += 1
                    }
                }
                inDip = false
                dipStart = nil
            }
        }
        
        recoveryAvgHours = recoveryTimes.isEmpty ? 0 : recoveryTimes.reduce(0, +) / Double(recoveryTimes.count)
        bestRecoveryActivity = recoveryActivities.max(by: { $0.value < $1.value })?.key ?? ""
    }
    
    // MARK: - 3. Performance Rhythm Signature
    private func analyzeRhythm(_ history: [MoodEntry]) {
        var slots = Array(repeating: (total: 0.0, count: 0), count: 24)
        
        for entry in history {
            let hour = Calendar.current.component(.hour, from: entry.date)
            let score = Double(moodScore(entry.emoji))
            slots[hour].total += score
            slots[hour].count += 1
        }
        
        rhythmSlots = slots.map { slot in
            slot.count > 0 ? slot.total / Double(slot.count) : 0
        }
        
        // Find peak window
        guard let maxSlot = rhythmSlots.enumerated().filter({ $0.element > 0 }).max(by: { $0.element < $1.element }) else {
            peakWindowLabel = "Check in more to discover your rhythm"
            return
        }
        
        let hour = maxSlot.offset
        let endHour = (hour + 2) % 24
        let formatter = { (h: Int) -> String in
            if h == 0 { return "12 AM" }
            if h < 12 { return "\(h) AM" }
            if h == 12 { return "12 PM" }
            return "\(h - 12) PM"
        }
        peakWindowLabel = "\(formatter(hour)) – \(formatter(endHour))"
    }
    
    // MARK: - 4. Neural Harmony Scale
    private func analyzeHarmony(_ history: [MoodEntry]) {
        let logicActivities = Set(["Speed Puzzle", "Memory Match", "Reaction Test", "HIIT Burst",
                                    "Hard Sudoku", "Logic Grid", "Crossword", "Brain Teaser",
                                    "Number Path", "Pattern Match", "Sprint Intervals"])
        let calmActivities = Set(["Yoga Flow", "Breathing", "Meditation", "Lo-fi Chill",
                                   "Nature Sounds", "Zen Garden", "Body Scan", "Sound Bath",
                                   "Gentle Walk", "Stretching", "Coloring Page", "Jigsaw Zen"])
        
        var logicCount = 0
        var calmCount = 0
        
        for entry in history {
            for activity in entry.activities {
                if logicActivities.contains(where: { activity.contains($0) }) {
                    logicCount += 1
                } else if calmActivities.contains(where: { activity.contains($0) }) {
                    calmCount += 1
                }
            }
        }
        
        let total = logicCount + calmCount
        if total == 0 {
            harmonyRatio = 0.5
            harmonyLabel = "Balanced"
        } else {
            harmonyRatio = Double(logicCount) / Double(total)
            if harmonyRatio > 0.65 {
                harmonyLabel = "Harmony tilted toward logic"
            } else if harmonyRatio < 0.35 {
                harmonyLabel = "Harmony tilted toward calm"
            } else {
                harmonyLabel = "Neural harmony achieved"
            }
        }
    }
    
    // MARK: - 5. Cognitive Fatigue Signal
    private func analyzeFatigue(_ history: [MoodEntry], wellnessLogs: [DailyWellnessLog]) {
        let hour = Calendar.current.component(.hour, from: Date())
        let todayLog = wellnessLogs.first { Calendar.current.isDateInToday($0.date) }
        
        let screenHours = todayLog?.screenTimeHours ?? 0
        let focusMinutes = FocusAgent.shared.sessionMinutes
        
        if (hour >= 21 && screenHours > 5) || focusMinutes > 45 {
            fatigueLevel = .moderate
        } else if (hour >= 19 && screenHours > 3) || focusMinutes > 30 {
            fatigueLevel = .mild
        } else {
            fatigueLevel = .none
        }
    }
    
    // MARK: - 6. Resonance Profile
    private func analyzeResonance(_ history: [MoodEntry]) {
        let musicKeywords = ["Lo-fi", "Nature Sounds", "Sound Bath", "Acoustic", "Ambient",
                             "Upbeat", "Feel-Good", "Calm Waves", "Gentle Rain", "Zen Drone"]
        
        var activityScores: [String: (total: Double, count: Int)] = [:]
        
        for entry in history {
            let score = Double(moodScore(entry.emoji))
            for activity in entry.activities {
                for keyword in musicKeywords {
                    if activity.contains(keyword) {
                        let existing = activityScores[keyword, default: (0, 0)]
                        activityScores[keyword] = (existing.total + score, existing.count + 1)
                    }
                }
            }
        }
        
        resonanceMatches = activityScores
            .map { (activity: $0.key, score: $0.value.total / Double($0.value.count)) }
            .sorted { $0.score > $1.score }
            .prefix(3)
            .map { $0 }
    }
    
    // MARK: - 7. Consistency Velocity
    private func analyzeVelocity(_ logs: [DailyWellnessLog]) {
        guard logs.count >= 7 else {
            velocityState = .steady
            return
        }
        
        let recent = Array(logs.prefix(7)).map { $0.overallScore }
        let older = Array(logs.dropFirst(7).prefix(7)).map { $0.overallScore }
        
        guard !recent.isEmpty, !older.isEmpty else {
            velocityState = .steady
            return
        }
        
        let recentAvg = Double(recent.reduce(0, +)) / Double(recent.count)
        let olderAvg = Double(older.reduce(0, +)) / Double(older.count)
        let delta = recentAvg - olderAvg
        
        if delta > 5 {
            velocityState = .accelerating
        } else if delta < -5 {
            velocityState = .decelerating
        } else {
            velocityState = .steady
        }
    }
    
    // MARK: - 8. Adaptive Narrative Engine
    private func generateNarrative(_ history: [MoodEntry], wellnessLogs: [DailyWellnessLog]) {
        let recentScores = history.prefix(7).map { moodScore($0.emoji) }
        let avgScore = recentScores.isEmpty ? 3.0 : Double(recentScores.reduce(0, +)) / Double(recentScores.count)
        
        let streak = wellnessLogs.prefix(7).filter { $0.overallScore >= 50 }.count
        
        if streak >= 6 {
            narrativeText = "This week you showed remarkable discipline. Your consistency is building something powerful."
        } else if avgScore >= 4.0 {
            narrativeText = "You leaned into growth this week. Your positive momentum is accelerating."
        } else if stabilityState == .stable {
            narrativeText = "Steady and grounded — your emotional foundation is strengthening."
        } else if velocityState == .accelerating {
            narrativeText = "Your wellness trajectory is climbing. Small wins compound over time."
        } else if recoveryAvgHours > 0 && recoveryAvgHours < 24 {
            narrativeText = "You recover quickly from setbacks. That resilience is your superpower."
        } else if !bestRecoveryActivity.isEmpty {
            narrativeText = "Your go-to recovery activity is \(bestRecoveryActivity). Lean into what works."
        } else {
            narrativeText = "Every check-in builds your self-awareness. Keep showing up for yourself."
        }
    }
    
    // MARK: - Emotional Tempo Engine
    /// Returns animation duration scaled by current emotional state
    var emotionalTempoDuration: Double {
        switch stabilityState {
        case .stable: return 0.4
        case .adaptive: return 0.35
        case .fluctuating: return 0.3
        }
    }
    
    var emotionalTempoSpring: Animation {
        .spring(response: emotionalTempoDuration, dampingFraction: 0.7)
    }
    
    // MARK: - Helpers
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
