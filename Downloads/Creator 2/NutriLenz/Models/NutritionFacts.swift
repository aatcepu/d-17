import Foundation

struct NutritionFacts: Identifiable, Codable {
    let id = UUID()
    var calories: Double
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    
    init(calories: Double = 0, protein: Double = 0, carbs: Double = 0, fat: Double = 0, fiber: Double = 0, sugar: Double = 0) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
    }
    
    var macrosPercentage: (protein: Double, carbs: Double, fat: Double) {
        let total = protein * 4 + carbs * 4 + fat * 9 // Approximate calories from macros
        if total == 0 { return (0, 0, 0) }
        
        let proteinPercent = (protein * 4) / total * 100
        let carbsPercent = (carbs * 4) / total * 100
        let fatPercent = (fat * 9) / total * 100
        
        return (proteinPercent, carbsPercent, fatPercent)
    }
}