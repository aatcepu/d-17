import Foundation

struct Meal: Identifiable, Codable {
    let id = UUID()
    var name: String
    var date: Date
    var foods: [FoodItem]
    var image: Data? // Store image as Data for offline access
    var totalCalories: Double
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var mealScore: Int // 0-100 score based on nutritional balance
    
    init(name: String = "My Meal", date: Date = Date(), foods: [FoodItem], image: Data? = nil) {
        self.name = name
        self.date = date
        self.foods = foods
        self.image = image
        
        // Calculate totals
        self.totalCalories = foods.reduce(0) { $0 + $1.nutritionFacts.calories }
        self.totalProtein = foods.reduce(0) { $0 + $1.nutritionFacts.protein }
        self.totalCarbs = foods.reduce(0) { $0 + $1.nutritionFacts.carbs }
        self.totalFat = foods.reduce(0) { $0 + $1.nutritionFacts.fat }
        
        // Calculate meal score (simplified calculation)
        self.mealScore = calculateMealScore()
    }
    
    private func calculateMealScore() -> Int {
        // Simplified meal scoring algorithm
        // Consider balance of macros, variety of foods, etc.
        let baseScore = min(100, Int((totalCalories / 500) * 30)) // Base on calories
        let varietyBonus = min(30, foods.count * 5) // Bonus for variety
        let balanceScore = calculateBalanceScore()
        
        let rawScore = max(0, min(100, baseScore + varietyBonus + balanceScore))
        return rawScore
    }
    
    private func calculateBalanceScore() -> Int {
        // Calculate how balanced the meal is based on macro distribution
        let total = totalProtein + totalCarbs + totalFat
        guard total > 0 else { return 0 }
        
        let proteinRatio = totalProtein / total
        let carbsRatio = totalCarbs / total
        let fatRatio = totalFat / total
        
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
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedCalories: String {
        return "\(Int(totalCalories)) cal"
    }
    
    var macrosRatio: (protein: Double, carbs: Double, fat: Double) {
        let total = totalProtein * 4 + totalCarbs * 4 + totalFat * 9
        if total == 0 { return (0, 0, 0) }
        
        let proteinPercent = (totalProtein * 4) / total * 100
        let carbsPercent = (totalCarbs * 4) / total * 100
        let fatPercent = (totalFat * 9) / total * 100
        
        return (proteinPercent, carbsPercent, fatPercent)
    }
}