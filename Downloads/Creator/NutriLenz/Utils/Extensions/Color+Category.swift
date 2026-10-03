import SwiftUI

extension Color {
    // Nutrition-specific colors
    static let proteinColor = Color.red
    static let carbColor = Color.blue
    static let fatColor = Color.yellow
    static let fiberColor = Color.green
    static let sugarColor = Color.purple
    
    // Health score colors
    static let excellentScore = Color(red: 0.2, green: 0.7, blue: 0.2) // Dark green
    static let goodScore = Color(red: 0.3, green: 0.7, blue: 0.3)     // Green
    static let averageScore = Color(red: 0.9, green: 0.7, blue: 0.2)  // Yellow
    static let poorScore = Color(red: 0.9, green: 0.3, blue: 0.2)     // Red
    
    // Meal category colors
    static let breakfastColor = Color.orange
    static let lunchColor = Color.blue
    static let dinnerColor = Color.purple
    static let snackColor = Color.green
    
    static func healthScoreColor(for score: Int) -> Color {
        switch score {
        case 80...100:
            return .excellentScore
        case 60..<80:
            return .goodScore
        case 40..<60:
            return .averageScore
        default:
            return .poorScore
        }
    }
    
    static func macroColor(for macro: String) -> Color {
        switch macro.lowercased() {
        case "protein":
            return .proteinColor
        case "carbs", "carbohydrates":
            return .carbColor
        case "fat", "lipids":
            return .fatColor
        case "fiber":
            return .fiberColor
        case "sugar":
            return .sugarColor
        default:
            return .gray
        }
    }
}