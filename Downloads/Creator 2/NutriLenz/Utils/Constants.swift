import Foundation
import SwiftUI

struct Constants {
    // App-wide constants
    static let appName = "NutriLenz"
    static let appVersion = "1.0"
    
    // Camera settings
    static let defaultCaptureQuality: UIImagePickerController.QualityType = .high
    static let maxImageSize = CGSize(width: 1920, height: 1080)
    
    // Detection settings
    static let defaultConfidenceThreshold: Float = 0.5
    static let maxDetectionResults = 10
    static let defaultPortionBaseWeight: Double = 100.0 // grams
    
    // UI Colors
    static let primaryColor = Color(red: 0.2, green: 0.6, blue: 0.3) // Green
    static let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.3) // Red
    static let accentColor = Color(red: 0.2, green: 0.4, blue: 0.8) // Blue
    static let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let cardBackgroundColor = Color.white
    static let textColor = Color.black
    static let secondaryTextColor = Color.gray
    
    // Nutrition-related constants
    static let caloriesPerGramProtein: Double = 4
    static let caloriesPerGramCarbs: Double = 4
    static let caloriesPerGramFat: Double = 9
    
    // Meal scoring thresholds
    static let excellentMealScoreThreshold = 80
    static let goodMealScoreThreshold = 60
    static let averageMealScoreThreshold = 40
    
    // Animation durations
    static let defaultAnimationDuration: Double = 0.3
    static let cameraTransitionDuration: Double = 0.5
    
    // File names
    static let nutritionDatabaseFileName = "NutritionDatabase.json"
    static let coreDataModelName = "NutriLenzModel"
    
    // UserDefaults keys
    static let hasCompletedOnboardingKey = "HasCompletedOnboarding"
    static let themePreferenceKey = "ThemePreference"
    static let lastUpdateCheckKey = "LastUpdateCheck"
    
    // Notification identifiers
    static let hydrationReminderIdentifier = "HydrationReminder"
    
    // Chart configurations
    static let dailyCalorieGoal: Double = 2000
    static let dailyProteinGoal: Double = 50
    static let dailyCarbGoal: Double = 250
    static let dailyFatGoal: Double = 70
}