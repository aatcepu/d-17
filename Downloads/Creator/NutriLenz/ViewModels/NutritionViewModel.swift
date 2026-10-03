import Foundation

class NutritionViewModel: ObservableObject {
    @Published var dailySummary: DailyNutritionSummary = DailyNutritionSummary()
    @Published var hydrationIndex: Int = 75
    @Published var mealQualityScore: Int = 82
    
    func calculateDailyTotals(for meals: [Meal]) -> DailyNutritionSummary {
        var summary = DailyNutritionSummary()
        
        for meal in meals {
            summary.totalCalories += meal.totalCalories
            summary.totalProtein += meal.totalProtein
            summary.totalCarbs += meal.totalCarbs
            summary.totalFat += meal.totalFat
        }
        
        // Calculate percentages
        let totalCaloriesFromMacros = summary.totalProtein * 4 + summary.totalCarbs * 4 + summary.totalFat * 9
        if totalCaloriesFromMacros > 0 {
            summary.proteinPercentage = (summary.totalProtein * 4) / totalCaloriesFromMacros * 100
            summary.carbPercentage = (summary.totalCarbs * 4) / totalCaloriesFromMacros * 100
            summary.fatPercentage = (summary.totalFat * 9) / totalCaloriesFromMacros * 100
        }
        
        // Calculate meal quality score based on average of meal scores
        if !meals.isEmpty {
            let totalScore = meals.reduce(0) { $0 + $1.mealScore }
            summary.averageMealScore = totalScore / meals.count
        }
        
        return summary
    }
    
    func getMacroDistribution(for meals: [Meal]) -> MacroDistribution {
        var distribution = MacroDistribution()
        
        for meal in meals {
            distribution.protein += meal.totalProtein
            distribution.carbs += meal.totalCarbs
            distribution.fat += meal.totalFat
        }
        
        return distribution
    }
    
    func calculateHydrationIndex(meals: [Meal], waterIntake: Double = 2.0) -> Int {
        // Calculate hydration based on water intake and meal sodium content
        // For simplicity, we'll use a basic calculation
        let baseIndex = Int(waterIntake * 30) // 30 points per liter
        let mealCountFactor = min(20, meals.count * 5) // Up to 20 points for eating regularly
        
        let hydrationIndex = min(100, baseIndex + mealCountFactor)
        return hydrationIndex
    }
    
    func calculateMealQualityScore(_ meal: Meal) -> Int {
        // Calculate a quality score based on nutritional balance and variety
        let balanceScore = calculateBalanceScore(for: meal)
        let varietyScore = min(30, meal.foods.count * 10) // Up to 30 points for variety
        
        let totalScore = balanceScore + varietyScore
        return min(100, max(0, totalScore))
    }
    
    private func calculateBalanceScore(for meal: Meal) -> Int {
        // Calculate how balanced the meal is based on macro distribution
        let total = meal.totalProtein + meal.totalCarbs + meal.totalFat
        guard total > 0 else { return 0 }
        
        let proteinRatio = meal.totalProtein / total
        let carbsRatio = meal.totalCarbs / total
        let fatRatio = meal.totalFat / total
        
        // Ideal ratios: ~25% protein, ~50% carbs, ~25% fat
        let idealProtein = 0.25
        let idealCarbs = 0.50
        let idealFat = 0.25
        
        let proteinDiff = abs(proteinRatio - idealProtein)
        let carbsDiff = abs(carbsRatio - idealCarbs)
        let fatDiff = abs(fatRatio - idealFat)
        
        // Score based on how close to ideal ratios (lower diff = higher score)
        let maxDiff = max(proteinDiff, carbsDiff, fatDiff)
        let balanceScore = Int((1 - maxDiff) * 40) // Max 40 points for balance
        
        return max(0, balanceScore)
    }
}

struct DailyNutritionSummary {
    var totalCalories: Double = 0
    var totalProtein: Double = 0
    var totalCarbs: Double = 0
    var totalFat: Double = 0
    var proteinPercentage: Double = 0
    var carbPercentage: Double = 0
    var fatPercentage: Double = 0
    var averageMealScore: Int = 0
    
    var remainingCalories: Double {
        return max(0, Constants.dailyCalorieGoal - totalCalories)
    }
    
    var proteinGoalProgress: Double {
        return min(1.0, totalProtein / Constants.dailyProteinGoal)
    }
    
    var carbsGoalProgress: Double {
        return min(1.0, totalCarbs / Constants.dailyCarbGoal)
    }
    
    var fatGoalProgress: Double {
        return min(1.0, totalFat / Constants.dailyFatGoal)
    }
    
    var isCalorieGoalReached: Bool {
        return totalCalories >= Constants.dailyCalorieGoal * 0.9
    }
}

struct MacroDistribution {
    var protein: Double = 0
    var carbs: Double = 0
    var fat: Double = 0
    
    var total: Double {
        return protein + carbs + fat
    }
    
    var proteinPercentage: Double {
        return total > 0 ? (protein / total) * 100 : 0
    }
    
    var carbsPercentage: Double {
        return total > 0 ? (carbs / total) * 100 : 0
    }
    
    var fatPercentage: Double {
        return total > 0 ? (fat / total) * 100 : 0
    }
}