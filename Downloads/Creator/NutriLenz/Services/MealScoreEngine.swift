import Foundation

class MealScoreEngine: ObservableObject {
    
    func calculateMealScore(for meal: Meal) -> Int {
        // Calculate a comprehensive score based on multiple factors:
        // 1. Nutritional balance
        // 2. Food variety
        // 3. Healthiness of ingredients
        // 4. Caloric appropriateness
        
        let balanceScore = calculateBalanceScore(for: meal)
        let varietyScore = calculateVarietyScore(for: meal)
        let healthinessScore = calculateHealthinessScore(for: meal)
        let caloricScore = calculateCaloricScore(for: meal)
        
        // Weighted average of all scores
        let totalScore = (balanceScore * 0.3) + (varietyScore * 0.2) + 
                         (healthinessScore * 0.3) + (caloricScore * 0.2)
        
        return Int(totalScore)
    }
    
    private func calculateBalanceScore(for meal: Meal) -> Double {
        // Evaluate how balanced the macronutrients are
        // Ideal ratio: ~25% protein, ~50% carbs, ~25% fat (by calories)
        
        let totalCalories = meal.totalCalories
        guard totalCalories > 0 else { return 50 }
        
        let proteinCalories = meal.totalProtein * 4
        let carbCalories = meal.totalCarbs * 4
        let fatCalories = meal.totalFat * 9
        
        let proteinRatio = proteinCalories / totalCalories
        let carbRatio = carbCalories / totalCalories
        let fatRatio = fatCalories / totalCalories
        
        // Calculate deviation from ideal ratios
        let idealProteinRatio: Double = 0.25
        let idealCarbRatio: Double = 0.50
        let idealFatRatio: Double = 0.25
        
        let proteinDeviation = abs(proteinRatio - idealProteinRatio)
        let carbDeviation = abs(carbRatio - idealCarbRatio)
        let fatDeviation = abs(fatRatio - idealFatRatio)
        
        // Convert deviations to scores (lower deviation = higher score)
        let maxDeviation = max(proteinDeviation, carbDeviation, fatDeviation)
        let balanceScore = max(0, (1 - maxDeviation) * 100)
        
        return balanceScore
    }
    
    private func calculateVarietyScore(for meal: Meal) -> Double {
        // Score based on number of different food items
        // More variety generally indicates better nutrition
        
        let maxVarietyScore: Double = 30
        let varietyFactor = Double(min(meal.foods.count, 10)) / 10.0 // Cap at 10 items
        
        return varietyFactor * maxVarietyScore
    }
    
    private func calculateHealthinessScore(for meal: Meal) -> Double {
        // Score based on nutritional quality
        // Consider fiber, vitamins, minerals, and negative factors like excess sugar/sodium
        
        // For simplicity, we'll use a basic calculation
        // In a real app, this would use more comprehensive nutrition data
        
        var score: Double = 50 // Base score
        
        // Bonus for high fiber content
        let totalFiber = meal.foods.reduce(0) { $0 + $1.nutritionFacts.fiber }
        if totalFiber > 5 {
            score += 10
        } else if totalFiber > 2 {
            score += 5
        }
        
        // Bonus for high protein content
        if meal.totalProtein > 20 {
            score += 10
        } else if meal.totalProtein > 10 {
            score += 5
        }
        
        // Penalty for high sugar content
        let totalSugar = meal.foods.reduce(0) { $0 + $1.nutritionFacts.sugar }
        if totalSugar > 25 {
            score -= 15
        } else if totalSugar > 15 {
            score -= 10
        }
        
        // Ensure score stays within bounds
        return max(0, min(100, score))
    }
    
    private func calculateCaloricScore(for meal: Meal) -> Double {
        // Score based on whether calories are appropriate for a meal
        // Assuming a typical meal should be between 300-700 calories
        
        let minCalories: Double = 300
        let maxCalories: Double = 700
        
        if meal.totalCalories >= minCalories && meal.totalCalories <= maxCalories {
            // Perfect score for ideal range
            return 100
        } else if meal.totalCalories < minCalories {
            // Lower score for too few calories
            return max(0, (meal.totalCalories / minCalories) * 60)
        } else {
            // Lower score for too many calories
            return max(0, (maxCalories / meal.totalCalories) * 60)
        }
    }
    
    func getMealQualityFeedback(for meal: Meal) -> String {
        let score = calculateMealScore(for: meal)
        
        if score >= 80 {
            return "Excellent! This is a well-balanced, nutritious meal."
        } else if score >= 60 {
            return "Good job! This meal has good nutritional value."
        } else if score >= 40 {
            return "Fair meal. Consider adding more variety or healthier options."
        } else {
            return "This meal could be improved. Try to balance your macros and add more nutrients."
        }
    }
    
    func getSpecificSuggestions(for meal: Meal) -> [String] {
        var suggestions: [String] = []
        
        // Check if meal is too high in calories
        if meal.totalCalories > 700 {
            suggestions.append("Consider reducing portion sizes to lower calorie count")
        }
        
        // Check protein content
        if meal.totalProtein < 15 {
            suggestions.append("Add more protein sources like lean meats, beans, or dairy")
        }
        
        // Check vegetable content
        if !meal.foods.contains(where: { $0.name.lowercased().contains("vegetable") || 
                                       $0.name.lowercased().contains("salad") ||
                                       $0.name.lowercased().contains("broccoli") ||
                                       $0.name.lowercased().contains("spinach") ||
                                       $0.name.lowercased().contains("carrot") }) {
            suggestions.append("Try to include more vegetables for vitamins and fiber")
        }
        
        // Check sugar content
        let totalSugar = meal.foods.reduce(0) { $0 + $1.nutritionFacts.sugar }
        if totalSugar > 25 {
            suggestions.append("Consider reducing high-sugar items")
        }
        
        return suggestions.isEmpty ? ["Great meal! No specific improvements needed."] : suggestions
    }
}