import Foundation
import SwiftUI
import Combine

class DashboardViewModel: ObservableObject {
    @Published var dailySummary: DailyNutritionSummary = DailyNutritionSummary()
    @Published var weeklyData: [WeeklyNutritionData] = []
    @Published var frequentFoods: [FrequentFoodItem] = []
    @Published var hydrationIndex: Int = 75
    @Published var mealQualityScore: Int = 82
    @Published var balanceMeter: Int = 85
    
    private var nutritionVM = NutritionViewModel()
    private var mealHistoryVM: MealHistoryViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(mealHistoryViewModel: MealHistoryViewModel) {
        self.mealHistoryVM = mealHistoryViewModel
        
        // Observe changes in meal history to update dashboard
        mealHistoryVM.$meals
            .sink { [weak self] meals in
                self?.updateDashboardData(for: meals)
            }
            .store(in: &cancellables)
        
        generateSampleWeeklyData()
        generateSampleFrequentFoods()
    }
    
    private func updateDashboardData(for meals: [Meal]) {
        dailySummary = nutritionVM.calculateDailyTotals(for: meals)
        hydrationIndex = nutritionVM.calculateHydrationIndex(meals: meals)
        mealQualityScore = dailySummary.averageMealScore
        balanceMeter = calculateBalanceMeter(for: meals)
    }
    
    private func calculateBalanceMeter(for meals: [Meal]) -> Int {
        // Calculate a balance score based on meal variety and nutrition
        guard !meals.isEmpty else { return 50 }
        
        // Average the meal scores
        let totalScore = meals.reduce(0) { $0 + $1.mealScore }
        let avgScore = totalScore / meals.count
        
        return min(100, max(0, avgScore))
    }
    
    private func generateSampleWeeklyData() {
        let calendar = Calendar.current
        var weekData: [WeeklyNutritionData] = []
        
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: -i, to: Date()) ?? Date()
            
            // Create sample data for each day
            weekData.append(WeeklyNutritionData(
                date: date,
                calories: Double(Int.random(in: 1500...2500)),
                protein: Double(Int.random(in: 40...80)),
                carbs: Double(Int.random(in: 150...300)),
                fat: Double(Int.random(in: 40...90)),
                mealCount: Int.random(in: 2...5),
                mealScore: Int.random(in: 60...95)
            ))
        }
        
        weeklyData = weekData.reversed() // Chronological order
    }
    
    private func generateSampleFrequentFoods() {
        frequentFoods = [
            FrequentFoodItem(foodName: "Chicken", frequency: 12),
            FrequentFoodItem(foodName: "Rice", frequency: 10),
            FrequentFoodItem(foodName: "Broccoli", frequency: 8),
            FrequentFoodItem(foodName: "Apple", frequency: 7),
            FrequentFoodItem(foodName: "Banana", frequency: 6),
            FrequentFoodItem(foodName: "Salmon", frequency: 5),
            FrequentFoodItem(foodName: "Spinach", frequency: 4)
        ]
    }
    
    func refreshData() {
        // Refresh the dashboard data
        updateDashboardData(for: mealHistoryVM.meals)
    }
    
    func getCaloriesRemaining() -> Double {
        return max(0, Constants.dailyCalorieGoal - dailySummary.totalCalories)
    }
    
    func getProgressPercentage(for macro: String) -> Double {
        switch macro.lowercased() {
        case "protein":
            return dailySummary.proteinGoalProgress
        case "carbs", "carbohydrates":
            return dailySummary.carbsGoalProgress
        case "fat":
            return dailySummary.fatGoalProgress
        default:
            return 0
        }
    }
    
    func getWeeklyAverage(for macro: String) -> Double {
        guard !weeklyData.isEmpty else { return 0 }
        
        let sum: Double
        switch macro.lowercased() {
        case "calories":
            sum = weeklyData.reduce(0) { $0 + $1.calories }
        case "protein":
            sum = weeklyData.reduce(0) { $0 + $1.protein }
        case "carbs", "carbohydrates":
            sum = weeklyData.reduce(0) { $0 + $1.carbs }
        case "fat":
            sum = weeklyData.reduce(0) { $0 + $1.fat }
        default:
            sum = 0
        }
        
        return sum / Double(weeklyData.count)
    }
}

struct WeeklyNutritionData {
    let date: Date
    let calories: Double
    let protein: Double
    let carbs: Double
    let fat: Double
    let mealCount: Int
    let mealScore: Int
    
    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct FrequentFoodItem {
    let foodName: String
    let frequency: Int
}