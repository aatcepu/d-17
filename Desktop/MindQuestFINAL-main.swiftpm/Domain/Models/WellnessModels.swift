import SwiftUI

// MARK: - Daily Wellness Log
struct DailyWellnessLog: Codable, Identifiable {
    var id = UUID()
    let date: Date
    var waterCups: Int           // Goal: 8 cups
    var sleepHours: Double       // Hours slept
    var sleepQuality: Int        // 1-5 rating
    var meals: [MealEntry]
    var studyHours: Double
    var workHours: Double
    var screenTimeHours: Double
    var exerciseMinutes: Int
    
    var dateKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var waterProgress: Double {
        min(Double(waterCups) / 8.0, 1.0)
    }
    
    var sleepProgress: Double {
        min(sleepHours / 8.0, 1.0)
    }
    
    var exerciseProgress: Double {
        min(Double(exerciseMinutes) / 30.0, 1.0)
    }
    
    var overallScore: Int {
        var score = 0
        if waterCups >= 6 { score += 20 }
        else if waterCups >= 4 { score += 10 }
        if sleepHours >= 7 { score += 25 }
        else if sleepHours >= 5 { score += 12 }
        if !meals.isEmpty { score += min(meals.count * 8, 20) }
        if exerciseMinutes >= 30 { score += 20 }
        else if exerciseMinutes >= 15 { score += 10 }
        if screenTimeHours <= 4 { score += 15 }
        else if screenTimeHours <= 6 { score += 8 }
        return min(score, 100)
    }
    
    static func empty(for date: Date = Date()) -> DailyWellnessLog {
        DailyWellnessLog(
            date: date,
            waterCups: 0,
            sleepHours: 0,
            sleepQuality: 3,
            meals: [],
            studyHours: 0,
            workHours: 0,
            screenTimeHours: 0,
            exerciseMinutes: 0
        )
    }
}

// MARK: - Meal Entry
struct MealEntry: Codable, Identifiable {
    var id = UUID()
    let type: MealType
    let description: String
    let time: Date
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snack: return "🍎"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "cup.and.saucer.fill"
        case .lunch: return "fork.knife"
        case .dinner: return "moon.stars.fill"
        case .snack: return "leaf.fill"
        }
    }
}

// MARK: - Activity Recommendation
struct ActivityRecommendation: Identifiable {
    let id = UUID()
    let category: ActivityCategory
    let name: String
    let description: String
    let icon: String // Keeping icon for UI consistency in lists
    let duration: String
    let difficulty: String
    let accentColor: Color
    let instructions: String
    let heroImage: String // SF Symbol name or asset name
}

enum ActivityCategory: String, CaseIterable {
    case health = "Health"
    case fitness = "Fitness"
    case games = "Games"
    case music = "Music"
    case puzzles = "Puzzles"
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .fitness: return "figure.run"
        case .games: return "gamecontroller.fill"
        case .music: return "music.note.list"
        case .puzzles: return "puzzlepiece.extension.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return Color(red: 1.0, green: 0.36, blue: 0.36)
        case .fitness: return Color(red: 0.2, green: 0.8, blue: 0.4)
        case .games: return Color(red: 0.55, green: 0.35, blue: 0.95)
        case .music: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .puzzles: return Color(red: 0.3, green: 0.7, blue: 1.0)
        }
    }
}
