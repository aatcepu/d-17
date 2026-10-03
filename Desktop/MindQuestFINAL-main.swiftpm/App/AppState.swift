import SwiftUI
import AVFoundation

@MainActor
final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    
    func playTapSound(enabled: Bool) {
        guard enabled else { return }
        // For Swift Playgrounds without external assets, we can use a system sound or simple beep.
        // We'll use AudioServicesPlaySystemSound as a lightweight tap feedback.
        AudioServicesPlaySystemSound(1104) // Tock sound
    }
}

struct MoodEntry: Codable, Identifiable {
    var id = UUID()
    let date: Date
    let text: String
    let mood: String
    let emoji: String
    let activities: [String]
    let levelCompleted: Int?
}

class AppState: ObservableObject {
    @Published var hasFinishedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasFinishedOnboarding, forKey: "hasFinishedOnboarding") }
    }
    
    @Published var activityLevels: [String: Int] {
        didSet { UserDefaults.standard.set(activityLevels, forKey: "activityLevels") }
    }
    
    @Published var moodHistory: [MoodEntry] {
        didSet {
            if let encoded = try? JSONEncoder().encode(moodHistory) {
                UserDefaults.standard.set(encoded, forKey: "moodHistory")
            }
        }
    }
    
    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: "userName") }
    }
    
    @Published var showQuizCelebration: Bool = false
    
    @Published var selectedAvatar: AvatarType {
        didSet { UserDefaults.standard.set(selectedAvatar.rawValue, forKey: "selectedAvatar") }
    }
    
    @Published var isDarkMode: Bool {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode") }
    }
    
    @Published var selectedTab: Int = 0 // Used for programmatic navigation
    
    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: "notificationsEnabled") }
    }
    
    @Published var notificationTime: Date {
        didSet { UserDefaults.standard.set(notificationTime, forKey: "notificationTime") }
    }
    
    @Published var soundsEnabled: Bool {
        didSet { UserDefaults.standard.set(soundsEnabled, forKey: "soundsEnabled") }
    }
    
    // MARK: - Wellness Tracking
    @Published var wellnessLogs: [DailyWellnessLog] {
        didSet {
            if let encoded = try? JSONEncoder().encode(wellnessLogs) {
                UserDefaults.standard.set(encoded, forKey: "wellnessLogs")
            }
        }
    }
    
    init() {
        self.hasFinishedOnboarding = UserDefaults.standard.bool(forKey: "hasFinishedOnboarding")
        self.activityLevels = UserDefaults.standard.dictionary(forKey: "activityLevels") as? [String: Int] ?? [
            "🌟": 0, "😊": 0, "😌": 0, "😕": 0, "😔": 0
        ]
        
        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        if let avatarRaw = UserDefaults.standard.string(forKey: "selectedAvatar"), let avatar = AvatarType(rawValue: avatarRaw) {
            self.selectedAvatar = avatar
        } else {
            self.selectedAvatar = .robot
        }
        self.isDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
        self.notificationsEnabled = UserDefaults.standard.bool(forKey: "notificationsEnabled")
        self.notificationTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date ?? Date()
        self.soundsEnabled = UserDefaults.standard.object(forKey: "soundsEnabled") as? Bool ?? true
        
        if let data = UserDefaults.standard.data(forKey: "moodHistory"),
           let decoded = try? JSONDecoder().decode([MoodEntry].self, from: data) {
            self.moodHistory = decoded
        } else {
            self.moodHistory = []
        }
        
        if let data = UserDefaults.standard.data(forKey: "wellnessLogs"),
           let decoded = try? JSONDecoder().decode([DailyWellnessLog].self, from: data) {
            self.wellnessLogs = decoded
        } else {
            self.wellnessLogs = []
        }
    }
    
    // MARK: - Mood Streak
    var currentStreak: Int {
        if moodHistory.isEmpty { return 0 }
        
        let sortedHistory = moodHistory.sorted { $0.date > $1.date }
        var streak = 0
        var lastDate: Date?
        
        let calendar = Calendar.current
        
        for entry in sortedHistory {
            if let previousDate = lastDate {
                if calendar.isDate(entry.date, inSameDayAs: previousDate) {
                    continue
                } else if let dayBefore = calendar.date(byAdding: .day, value: -1, to: previousDate),
                          calendar.isDate(entry.date, inSameDayAs: dayBefore) {
                    streak += 1
                    lastDate = entry.date
                } else {
                    break
                }
            } else {
                if calendar.isDateInToday(entry.date) || calendar.isDateInYesterday(entry.date) {
                    streak = 1
                    lastDate = entry.date
                } else {
                    return 0
                }
            }
        }
        
        return streak
    }
    
    // MARK: - Latest Mood
    var latestMoodEmoji: String {
        moodHistory.first?.emoji ?? "😌"
    }
    
    // MARK: - Level Progression
    func completeLevel(for mood: String) {
        let currentLevel = activityLevels[mood] ?? 0
        if currentLevel < 3 {
            activityLevels[mood] = currentLevel + 1
        }
    }
    
    func addHistoryEntry(text: String, mood: String, emoji: String, level: Int?, activities: [String] = []) {
        let entry = MoodEntry(date: Date(), text: text, mood: mood, emoji: emoji, activities: activities, levelCompleted: level)
        moodHistory.insert(entry, at: 0)
    }
    
    func updateLatestEntry(activities: [String]) {
        guard !moodHistory.isEmpty else { return }
        let entry = moodHistory[0]
        let newEntry = MoodEntry(
            id: entry.id,
            date: entry.date,
            text: entry.text,
            mood: entry.mood,
            emoji: entry.emoji,
            activities: activities,
            levelCompleted: entry.levelCompleted
        )
        moodHistory[0] = newEntry
    }
    
    // MARK: - Wellness Log Helpers
    var todaysLog: DailyWellnessLog {
        let calendar = Calendar.current
        return wellnessLogs.first { calendar.isDateInToday($0.date) } ?? .empty()
    }
    
    func updateTodaysLog(_ update: (inout DailyWellnessLog) -> Void) {
        let calendar = Calendar.current
        if let index = wellnessLogs.firstIndex(where: { calendar.isDateInToday($0.date) }) {
            var log = wellnessLogs[index]
            update(&log)
            wellnessLogs[index] = log
        } else {
            var log = DailyWellnessLog.empty()
            update(&log)
            wellnessLogs.insert(log, at: 0)
        }
    }
    
    func wellnessLog(for date: Date) -> DailyWellnessLog? {
        let calendar = Calendar.current
        return wellnessLogs.first { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    var weeklyWellnessAverage: Int {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        let recentLogs = wellnessLogs.filter { $0.date >= weekAgo }
        guard !recentLogs.isEmpty else { return 0 }
        return recentLogs.map { $0.overallScore }.reduce(0, +) / recentLogs.count
    }
    
    var wellnessStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        for _ in 0..<365 {
            if wellnessLogs.contains(where: { calendar.isDate($0.date, inSameDayAs: checkDate) && $0.overallScore > 0 }) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    // MARK: - Mood Calendar Helpers
    func moodEntries(for date: Date) -> [MoodEntry] {
        let calendar = Calendar.current
        return moodHistory.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func dominantMood(for date: Date) -> MoodEntry? {
        moodEntries(for: date).first
    }
    
    // MARK: - Improvement Summary
    var moodTrend: String {
        guard moodHistory.count >= 4 else { return "neutral" }
        let recent = Array(moodHistory.prefix(3))
        let older = Array(moodHistory.dropFirst(3).prefix(3))
        
        let recentAvg = Double(recent.compactMap { moodScore(for: $0.mood) }.reduce(0, +)) / max(1.0, Double(recent.count))
        let olderAvg = Double(older.compactMap { moodScore(for: $0.mood) }.reduce(0, +)) / max(1.0, Double(older.count))
        
        if recentAvg > olderAvg + 0.3 { return "improving" }
        if recentAvg < olderAvg - 0.3 { return "declining" }
        return "stable"
    }
    
    private func moodScore(for mood: String) -> Int {
        switch mood {
        case "Euphorically Happy": return 5
        case "Joyful & Positive": return 4
        case "Balanced & Calm": return 3
        case "Slightly Down": return 2
        case "Deeply Stressed or Sad": return 1
        default: return 3
        }
    }
    
    var averageMoodScore: Double {
        guard !moodHistory.isEmpty else { return 3.0 }
        let scores = moodHistory.prefix(14).map { moodScore(for: $0.mood) }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }
    
    var topMoodActivities: [String] {
        let happyEntries = moodHistory.filter { moodScore(for: $0.mood) >= 4 }
        var activityCounts: [String: Int] = [:]
        for entry in happyEntries {
            for activity in entry.activities {
                activityCounts[activity, default: 0] += 1
            }
        }
        return activityCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
    }
    
    // MARK: - Reset
    func resetProfile() {
        hasFinishedOnboarding = false
        activityLevels = ["🌟": 0, "😊": 0, "😌": 0, "😕": 0, "😔": 0]
        moodHistory = []
        wellnessLogs = []
        UserDefaults.standard.removeObject(forKey: "hasFinishedOnboarding")
        UserDefaults.standard.removeObject(forKey: "activityLevels")
        UserDefaults.standard.removeObject(forKey: "moodHistory")
        UserDefaults.standard.removeObject(forKey: "wellnessLogs")
    }
}
