import SwiftUI
import UIKit

// MARK: - BouncyButtonPressStyle
struct BouncyButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - HapticAgent (Production-Grade)
/// Centralized haptic feedback manager with preloaded generators,
/// deduplication, compound patterns, and performance safety.
@MainActor
final class HapticAgent {
    static let shared = HapticAgent()
    
    // Preloaded generators for zero-latency response
    private let lightGen = UIImpactFeedbackGenerator(style: .light)
    private let mediumGen = UIImpactFeedbackGenerator(style: .medium)
    private let heavyGen = UIImpactFeedbackGenerator(style: .heavy)
    private let rigidGen = UIImpactFeedbackGenerator(style: .rigid)
    private let softGen = UIImpactFeedbackGenerator(style: .soft)
    private let selectionGen = UISelectionFeedbackGenerator()
    private let notificationGen = UINotificationFeedbackGenerator()
    
    // Deduplication: prevent rapid duplicate triggers
    private var lastTriggerTimes: [String: TimeInterval] = [:]
    private let minInterval: TimeInterval = 0.05 // 50ms minimum between same type
    
    private init() {
        prepareAll()
    }
    
    /// Prepare all generators for minimum latency
    func prepareAll() {
        lightGen.prepare()
        mediumGen.prepare()
        heavyGen.prepare()
        rigidGen.prepare()
        softGen.prepare()
        selectionGen.prepare()
        notificationGen.prepare()
    }
    
    // MARK: - Core Haptic Methods
    
    func playSelection() {
        guard canTrigger("selection") else { return }
        selectionGen.selectionChanged()
        selectionGen.prepare()
    }
    
    func playImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat = 1.0) {
        let key = "impact_\(style.rawValue)"
        guard canTrigger(key) else { return }
        
        let gen: UIImpactFeedbackGenerator
        switch style {
        case .light: gen = lightGen
        case .medium: gen = mediumGen
        case .heavy: gen = heavyGen
        case .rigid: gen = rigidGen
        case .soft: gen = softGen
        @unknown default: gen = lightGen
        }
        gen.impactOccurred(intensity: intensity)
        gen.prepare()
    }
    
    func playNotification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard canTrigger("notification_\(type.rawValue)") else { return }
        notificationGen.notificationOccurred(type)
        notificationGen.prepare()
    }
    
    // MARK: - Compound Patterns
    
    /// Success celebration: medium impact + success notification
    func celebrateSuccess() {
        playImpact(.medium)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [self] in
            playNotification(.success)
        }
    }
    
    /// Milestone celebration: heavy impact + success notification
    func celebrateMilestone() {
        playImpact(.heavy)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { [self] in
            playNotification(.success)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [self] in
            playImpact(.rigid, intensity: 0.6)
        }
    }
    
    /// Gentle warning: soft impact + warning notification
    func gentleWarning() {
        playImpact(.soft, intensity: 0.5)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            playNotification(.warning)
        }
    }
    
    /// Countdown tick pattern for timers
    func countdownTick() {
        playImpact(.light, intensity: 0.7)
    }
    
    /// Breathing sync: soft inhale/exhale
    func breathingPulse() {
        playImpact(.soft, intensity: 0.4)
    }
    
    // MARK: - Deduplication
    private func canTrigger(_ key: String) -> Bool {
        guard StabilityAgent.shared.isHapticAllowed else { return false }
        let now = ProcessInfo.processInfo.systemUptime
        if let last = lastTriggerTimes[key], now - last < minInterval {
            return false
        }
        lastTriggerTimes[key] = now
        return StabilityAgent.shared.recordTrigger()
    }
}

// MARK: - StabilityAgent
/// Ensures haptic generators are used safely: prevents spam, respects background state.
@MainActor
final class StabilityAgent {
    static let shared = StabilityAgent()
    
    private var triggerTimestamps: [TimeInterval] = []
    private let maxTriggersPerSecond = 10
    private(set) var isHapticAllowed = true
    
    private init() {
        // Observe app lifecycle
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.isHapticAllowed = false }
        }
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.isHapticAllowed = true
                HapticAgent.shared.prepareAll()
            }
        }
    }
    
    /// Rate limiter: returns true if trigger is allowed
    func recordTrigger() -> Bool {
        let now = ProcessInfo.processInfo.systemUptime
        triggerTimestamps = triggerTimestamps.filter { now - $0 < 1.0 }
        guard triggerTimestamps.count < maxTriggersPerSecond else { return false }
        triggerTimestamps.append(now)
        return true
    }
}

// MARK: - EngagementAgent (XP + Streaks + Milestones + Levels)
@MainActor
final class EngagementAgent: ObservableObject {
    static let shared = EngagementAgent()
    private let startTime = Date()
    
    // XP & Level System
    @Published var totalXP: Int {
        didSet { UserDefaults.standard.set(totalXP, forKey: "engagement_total_xp") }
    }
    @Published var showXPToast: Bool = false
    @Published var lastXPGain: Int = 0
    
    var currentLevel: Int { max(1, totalXP / 50) }
    var xpInCurrentLevel: Int { totalXP % 50 }
    var xpForNextLevel: Int { 50 }
    var levelProgress: Double { Double(xpInCurrentLevel) / Double(xpForNextLevel) }
    
    var levelTitle: String {
        switch currentLevel {
        case 1: return "Mindful Beginner"
        case 2...3: return "Wellness Explorer"
        case 4...6: return "Inner Seeker"
        case 7...10: return "Balance Master"
        case 11...15: return "Zen Architect"
        default: return "Enlightened Soul"
        }
    }
    
    // Streak System
    @Published var moodStreak: Int {
        didSet { UserDefaults.standard.set(moodStreak, forKey: "engagement_mood_streak") }
    }
    @Published var activityStreak: Int {
        didSet { UserDefaults.standard.set(activityStreak, forKey: "engagement_activity_streak") }
    }
    @Published var puzzleStreak: Int {
        didSet { UserDefaults.standard.set(puzzleStreak, forKey: "engagement_puzzle_streak") }
    }
    
    var timeInvestedToday: Int {
        let key = "engagement_today_minutes"
        let stored = UserDefaults.standard.integer(forKey: key)
        let sessionMin = Int(Date().timeIntervalSince(startTime) / 60)
        return stored + sessionMin
    }
    
    private init() {
        totalXP = UserDefaults.standard.integer(forKey: "engagement_total_xp")
        moodStreak = UserDefaults.standard.integer(forKey: "engagement_mood_streak")
        activityStreak = UserDefaults.standard.integer(forKey: "engagement_activity_streak")
        puzzleStreak = UserDefaults.standard.integer(forKey: "engagement_puzzle_streak")
    }
    
    // MARK: - XP Awards
    func awardXP(_ amount: Int, source: String) {
        lastXPGain = amount
        totalXP += amount
        
        // Trigger milestone haptics
        let milestones = [50, 100, 250, 500, 1000]
        let prevTotal = totalXP - amount
        for milestone in milestones {
            if prevTotal < milestone && totalXP >= milestone {
                HapticAgent.shared.celebrateMilestone()
                return
            }
        }
        
        // Standard reward haptic
        showXPToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.showXPToast = false
        }
    }
    
    func logMoodCheckIn() {
        awardXP(5, source: "mood")
        incrementStreak(&moodStreak, key: "engagement_mood_streak_date")
        // Streak achievements
        if moodStreak >= 3 { AchievementAgent.shared.checkAndUnlock(.streak3) }
        if moodStreak >= 7 { AchievementAgent.shared.checkAndUnlock(.streak7) }
        if moodStreak >= 30 { AchievementAgent.shared.checkAndUnlock(.streak30) }
    }
    
    func logPuzzleComplete() {
        awardXP(8, source: "puzzle")
        incrementStreak(&puzzleStreak, key: "engagement_puzzle_streak_date")
        let total = UserDefaults.standard.integer(forKey: "total_puzzles_completed") + 1
        UserDefaults.standard.set(total, forKey: "total_puzzles_completed")
        if total >= 10 { AchievementAgent.shared.checkAndUnlock(.puzzleMaster) }
    }
    
    func logWorkoutComplete() {
        awardXP(10, source: "workout")
        incrementStreak(&activityStreak, key: "engagement_activity_streak_date")
    }
    
    func logMusicSession() {
        awardXP(6, source: "music")
        let count = UserDefaults.standard.integer(forKey: "total_music_sessions") + 1
        UserDefaults.standard.set(count, forKey: "total_music_sessions")
        if count >= 3 { AchievementAgent.shared.checkAndUnlock(.musicLover) }
    }
    
    // MARK: - Streak Logic
    private func incrementStreak(_ streak: inout Int, key: String) {
        let calendar = Calendar.current
        let lastDateKey = key
        let lastDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date
        
        if let last = lastDate, calendar.isDateInToday(last) {
            return // Already logged today
        }
        
        if let last = lastDate, calendar.isDateInYesterday(last) {
            streak += 1
        } else {
            streak = 1
        }
        
        UserDefaults.standard.set(Date(), forKey: lastDateKey)
        
        // Streak milestone haptics
        let milestones = [3, 5, 7, 14, 30]
        if milestones.contains(streak) {
            HapticAgent.shared.celebrateMilestone()
        }
    }
}

// MARK: - HydrationAgent (Visual + Streak Logic)
@MainActor
final class HydrationAgent: ObservableObject {
    static let shared = HydrationAgent()
    
    @Published var dailyGoal: Int = 8
    @Published var hydrationStreak: Int
    
    private init() {
        hydrationStreak = UserDefaults.standard.integer(forKey: "hydration_streak")
    }
    
    func getHydrationStreak() -> Int { hydrationStreak }
    
    /// Called when water intake changes
    func evaluateHydration(cups: Int) {
        let calendar = Calendar.current
        let lastLogDate = UserDefaults.standard.object(forKey: "hydration_last_date") as? Date
        
        if cups >= dailyGoal {
            if let last = lastLogDate, calendar.isDateInToday(last) {
                return // Already counted today
            }
            // Goal met today
            if let last = lastLogDate, calendar.isDateInYesterday(last) {
                hydrationStreak += 1
            } else if lastLogDate == nil || !calendar.isDateInToday(lastLogDate!) {
                hydrationStreak = 1
            }
            UserDefaults.standard.set(Date(), forKey: "hydration_last_date")
            UserDefaults.standard.set(hydrationStreak, forKey: "hydration_streak")
            
            // Milestone celebrations
            if [3, 5, 7, 14, 30].contains(hydrationStreak) {
                HapticAgent.shared.celebrateMilestone()
            }
        }
    }
    
    var hydrationLevel: String {
        switch hydrationStreak {
        case 0: return "Start your streak!"
        case 1...2: return "Building momentum"
        case 3...6: return "Getting consistent!"
        case 7...13: return "Week warrior 💧"
        default: return "Hydration master 🏆"
        }
    }
}

// MARK: - FocusAgent (Deep Focus Detection + Auto-Badge)
@MainActor
final class FocusAgent: ObservableObject {
    static let shared = FocusAgent()
    
    @Published var sessionMinutes: Int = 0
    @Published var totalFocusMinutes: Int = UserDefaults.standard.integer(forKey: "total_focus_minutes")
    @Published var totalSessions: Int = UserDefaults.standard.integer(forKey: "total_focus_sessions")
    @Published var isInDeepFocus: Bool = false
    @Published var showFocusBadge: Bool = false
    @Published var focusBadgeText: String = ""
    
    private var sessionStart: Date?
    private var focusCheckTimer: Timer?
    
    private init() {}
    
    func startSession() {
        sessionStart = Date()
        isInDeepFocus = false
        
        // Check for deep focus every 30 seconds
        focusCheckTimer?.invalidate()
        focusCheckTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkDeepFocus()
            }
        }
    }
    
    func endSession() {
        focusCheckTimer?.invalidate()
        focusCheckTimer = nil
        guard let start = sessionStart else { return }
        let minutes = Int(Date().timeIntervalSince(start) / 60)
        sessionMinutes = minutes
        totalFocusMinutes += minutes
        totalSessions += 1
        UserDefaults.standard.set(totalFocusMinutes, forKey: "total_focus_minutes")
        UserDefaults.standard.set(totalSessions, forKey: "total_focus_sessions")
        sessionStart = nil
        isInDeepFocus = false
        
        // Auto-badge for significant sessions
        if minutes >= 5 {
            awardFocusBadge("Deep Focus: \(minutes)m 🧠")
            AchievementAgent.shared.checkAndUnlock(.deepFocus5)
        }
        if minutes >= 15 {
            AchievementAgent.shared.checkAndUnlock(.deepFocus15)
        }
    }
    
    private func checkDeepFocus() {
        guard let start = sessionStart else { return }
        let minutes = Int(Date().timeIntervalSince(start) / 60)
        if minutes >= 5 && !isInDeepFocus {
            isInDeepFocus = true
            HapticAgent.shared.playImpact(.soft, intensity: 0.4)
        }
    }
    
    private func awardFocusBadge(_ text: String) {
        focusBadgeText = text
        showFocusBadge = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showFocusBadge = false
        }
    }
}

// MARK: - BehaviorInsightAgent
@MainActor
final class BehaviorInsightAgent: ObservableObject {
    static let shared = BehaviorInsightAgent()
    
    @Published var currentInsight: String = ""
    @Published var insightType: String = "general"
    
    private init() {}
    
    func analyze(history: [MoodEntry], wellnessStreak: Int, hydrationStreak: Int) {
        if wellnessStreak >= 7 {
            currentInsight = "Your consistency is building real momentum."
            insightType = "streak"
        } else if history.count >= 5 {
            let recent = history.prefix(5).map { moodScore($0.emoji) }
            let avg = Double(recent.reduce(0, +)) / Double(recent.count)
            if avg >= 4.0 {
                currentInsight = "You've been in a great headspace lately."
                insightType = "positive"
            } else if avg <= 2.0 {
                currentInsight = "Be gentle with yourself. Growth isn't always linear."
                insightType = "supportive"
            } else {
                currentInsight = "Keep showing up — awareness is the first step."
                insightType = "general"
            }
        } else {
            currentInsight = "Check in more to unlock deeper insights."
            insightType = "general"
        }
    }
    
    private func moodScore(_ emoji: String) -> Int {
        switch emoji {
        case "🌟": return 5; case "😊": return 4; case "😌": return 3
        case "😕": return 2; case "😔": return 1; default: return 3
        }
    }
}

// MARK: - Hidden Achievement Framework
@MainActor
enum Achievement: String, CaseIterable {
    case firstCheckIn = "first_checkin"
    case streak3 = "streak_3"
    case streak7 = "streak_7"
    case streak30 = "streak_30"
    case puzzleMaster = "puzzle_master"
    case hydrationWeek = "hydration_week"
    case deepFocus5 = "deep_focus_5"
    case deepFocus15 = "deep_focus_15"
    case wellnessWarrior = "wellness_warrior"
    case nightOwl = "night_owl"
    case musicLover = "music_lover"
    case zenMaster = "zen_master"
    
    var title: String {
        switch self {
        case .firstCheckIn: return "First Step"
        case .streak3: return "3-Day Streak"
        case .streak7: return "Week Warrior"
        case .streak30: return "Monthly Master"
        case .puzzleMaster: return "Puzzle Pro"
        case .hydrationWeek: return "Hydration Hero"
        case .deepFocus5: return "Deep Focus"
        case .deepFocus15: return "Focus Champion"
        case .wellnessWarrior: return "Wellness Warrior"
        case .nightOwl: return "Night Owl"
        case .musicLover: return "Music Lover"
        case .zenMaster: return "Zen Master"
        }
    }
    
    var icon: String {
        switch self {
        case .firstCheckIn: return "star.fill"
        case .streak3: return "flame.fill"
        case .streak7: return "flame.circle.fill"
        case .streak30: return "crown.fill"
        case .puzzleMaster: return "puzzlepiece.fill"
        case .hydrationWeek: return "drop.fill"
        case .deepFocus5: return "brain.head.profile"
        case .deepFocus15: return "brain.fill"
        case .wellnessWarrior: return "heart.fill"
        case .nightOwl: return "moon.stars.fill"
        case .musicLover: return "music.note.list"
        case .zenMaster: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .firstCheckIn: return .yellow
        case .streak3, .streak7: return .orange
        case .streak30: return Color(red: 1, green: 0.8, blue: 0)
        case .puzzleMaster: return Theme.puzzles
        case .hydrationWeek: return .cyan
        case .deepFocus5, .deepFocus15: return Theme.secondary
        case .wellnessWarrior: return Theme.wellness
        case .nightOwl: return .purple
        case .musicLover: return Theme.accent
        case .zenMaster: return .green
        }
    }
    
    var hint: String {
        switch self {
        case .firstCheckIn: return "Complete your first mood check-in"
        case .streak3: return "Maintain a 3-day streak"
        case .streak7: return "Keep going for 7 days"
        case .streak30: return "An entire month of consistency"
        case .puzzleMaster: return "Complete 10 puzzles"
        case .hydrationWeek: return "Hit water goal for 7 days"
        case .deepFocus5: return "Stay focused for 5+ minutes"
        case .deepFocus15: return "Achieve 15-minute deep focus"
        case .wellnessWarrior: return "Log all wellness areas in a day"
        case .nightOwl: return "Use the app after 10 PM"
        case .musicLover: return "Listen to 3 different soundscapes"
        case .zenMaster: return "Complete 5 breathing sessions"
        }
    }
}

@MainActor
final class AchievementAgent: ObservableObject {
    static let shared = AchievementAgent()
    
    @Published var unlockedAchievements: Set<String>
    @Published var showUnlockBanner: Bool = false
    @Published var latestUnlock: Achievement?
    
    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: "unlocked_achievements") ?? []
        unlockedAchievements = Set(saved)
    }
    
    func isUnlocked(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains(achievement.rawValue)
    }
    
    func checkAndUnlock(_ achievement: Achievement) {
        guard !isUnlocked(achievement) else { return }
        unlockedAchievements.insert(achievement.rawValue)
        UserDefaults.standard.set(Array(unlockedAchievements), forKey: "unlocked_achievements")
        
        latestUnlock = achievement
        showUnlockBanner = true
        HapticAgent.shared.celebrateMilestone()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.showUnlockBanner = false
        }
    }
    
    func checkTimeBasedAchievements() {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 22 || hour < 5 {
            checkAndUnlock(.nightOwl)
        }
    }
    
    var unlockedCount: Int { unlockedAchievements.count }
    var totalCount: Int { Achievement.allCases.count }
}

// MARK: - AchievementGalleryView
struct AchievementGalleryView: View {
    @ObservedObject var agent = AchievementAgent.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .foregroundColor(.yellow)
                Text("Achievements")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("\(agent.unlockedCount)/\(agent.totalCount)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 10) {
                ForEach(Achievement.allCases, id: \.rawValue) { achievement in
                    AchievementBadge(
                        icon: achievement.icon,
                        label: agent.isUnlocked(achievement) ? achievement.title : "???",
                        color: achievement.color,
                        isUnlocked: agent.isUnlocked(achievement),
                        hint: achievement.hint
                    )
                }
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }
}

private struct AchievementBadge: View {
    let icon: String
    let label: String
    let color: Color
    let isUnlocked: Bool
    let hint: String
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.15) : Color.gray.opacity(0.08))
                    .frame(width: 42, height: 42)
                Image(systemName: isUnlocked ? icon : "lock.fill")
                    .foregroundColor(isUnlocked ? color : Color.gray.opacity(0.3))
                    .font(.system(size: 16))
                if isUnlocked {
                    Circle()
                        .stroke(color.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 42, height: 42)
                }
            }
            Text(label)
                .font(.system(size: 8, weight: .medium, design: .rounded))
                .foregroundColor(isUnlocked ? Theme.textPrimary : Theme.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - AmbientParticleOverlay
struct AmbientParticleOverlay: View {
    let moodEmoji: String
    @State private var particles: [ParticleData] = (0..<12).map { _ in ParticleData() }
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles.indices, id: \.self) { i in
                    Circle()
                        .fill(particleColor.opacity(particles[i].opacity))
                        .frame(width: particles[i].size, height: particles[i].size)
                        .blur(radius: particles[i].size * 0.3)
                        .position(
                            x: particles[i].x * geo.size.width,
                            y: animate ? particles[i].y * geo.size.height : (1 - particles[i].y) * geo.size.height
                        )
                        .animation(
                            .easeInOut(duration: particles[i].duration)
                                .repeatForever(autoreverses: true)
                                .delay(particles[i].delay),
                            value: animate
                        )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { animate = true }
    }
    
    private var particleColor: Color {
        switch moodEmoji {
        case "🌟": return .yellow
        case "😊": return Theme.secondary
        case "😌": return Theme.wellness
        case "😕": return .blue
        case "😔": return .purple
        default: return Theme.secondary
        }
    }
}

private struct ParticleData {
    let x = Double.random(in: 0.05...0.95)
    let y = Double.random(in: 0.05...0.95)
    let size = CGFloat.random(in: 3...10)
    let opacity = Double.random(in: 0.03...0.12)
    let duration = Double.random(in: 5...12)
    let delay = Double.random(in: 0...3)
}

// MARK: - XP Toast Overlay
struct XPToastOverlay: ViewModifier {
    @ObservedObject var engagement = EngagementAgent.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            Group {
                if engagement.showXPToast {
                    VStack {
                        Spacer()
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text("+\(engagement.lastXPGain) XP")
                                .font(.system(.caption, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Theme.overlayText)
                            Text("(\(engagement.totalXP) total)")
                                .font(.system(size: 10, design: .rounded))
                                .foregroundColor(Theme.overlayText.opacity(0.6))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Theme.overlayBackground)
                                .clipShape(Capsule())
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 100)
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: engagement.showXPToast)
                }
            }
        )
    }
}

// MARK: - Achievement Unlock Banner
struct AchievementBannerModifier: ViewModifier {
    @ObservedObject var agent = AchievementAgent.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            VStack {
                if agent.showUnlockBanner, let achievement = agent.latestUnlock {
                    HStack(spacing: 10) {
                        Image(systemName: achievement.icon)
                            .foregroundColor(achievement.color)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Achievement Unlocked!")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(Theme.overlayText.opacity(0.7))
                            Text(achievement.title)
                                .font(.system(size: 14, weight: .heavy, design: .rounded))
                                .foregroundColor(Theme.overlayText)
                        }
                        Spacer()
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.overlayBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    )
                    .shadow(color: achievement.color.opacity(0.3), radius: 12)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: agent.showUnlockBanner)
        )
    }
}

// MARK: - Focus Badge Overlay
struct FocusBadgeModifier: ViewModifier {
    @ObservedObject var focus = FocusAgent.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            VStack {
                Spacer()
                if focus.showFocusBadge {
                    HStack(spacing: 6) {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(Theme.secondary)
                        Text(focus.focusBadgeText)
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.overlayText)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Theme.overlayBackground))
                    .shadow(color: Theme.secondary.opacity(0.3), radius: 8)
                    .transition(.scale.combined(with: .opacity))
                    .padding(.bottom, 120)
                }
            }
            .animation(.spring(response: 0.4), value: focus.showFocusBadge)
        )
    }
}

// MARK: - View Modifier Extensions
extension View {
    func achievementOverlay() -> some View {
        modifier(AchievementBannerModifier())
    }
    
    func focusSpotlight() -> some View {
        modifier(FocusBadgeModifier())
    }
    
    func xpRewardOverlay() -> some View {
        self.modifier(XPToastOverlay())
    }
}
