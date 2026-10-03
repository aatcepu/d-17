import Foundation

struct FoodItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var confidence: Double
    var boundingBox: CGRect?
    var nutritionFacts: NutritionFacts
    var portionEstimate: PortionEstimate
    
    init(name: String, confidence: Double = 0.0, boundingBox: CGRect? = nil, nutritionFacts: NutritionFacts, portionEstimate: PortionEstimate) {
        self.name = name
        self.confidence = confidence
        self.boundingBox = boundingBox
        self.nutritionFacts = nutritionFacts
        self.portionEstimate = portionEstimate
    }
}

extension FoodItem {
    var displayCalories: String {
        return "\(Int(nutritionFacts.calories))"
    }
    
    var displayProtein: String {
        return String(format: "%.1fg", nutritionFacts.protein)
    }
    
    var displayCarbs: String {
        return String(format: "%.1fg", nutritionFacts.carbs)
    }
    
    var displayFat: String {
        return String(format: "%.1fg", nutritionFacts.fat)
    }
}