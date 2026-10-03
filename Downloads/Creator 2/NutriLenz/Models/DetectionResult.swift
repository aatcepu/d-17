import Foundation
import UIKit
import Vision

struct DetectionResult: Identifiable, Codable {
    let id = UUID()
    var detectedItems: [FoodItem]
    var confidenceThreshold: Double
    var processingTime: TimeInterval
    var originalImage: Data?
    
    init(detectedItems: [FoodItem] = [], confidenceThreshold: Double = 0.5, processingTime: TimeInterval = 0, originalImage: Data? = nil) {
        self.detectedItems = detectedItems
        self.confidenceThreshold = confidenceThreshold
        self.processingTime = processingTime
        self.originalImage = originalImage
    }
    
    var totalCalories: Double {
        return detectedItems.reduce(0) { $0 + $1.nutritionFacts.calories }
    }
    
    var totalProtein: Double {
        return detectedItems.reduce(0) { $0 + $1.nutritionFacts.protein }
    }
    
    var totalCarbs: Double {
        return detectedItems.reduce(0) { $0 + $1.nutritionFacts.carbs }
    }
    
    var totalFat: Double {
        return detectedItems.reduce(0) { $0 + $1.nutritionFacts.fat }
    }
    
    var topConfidence: Double {
        return detectedItems.max { $0.confidence < $1.confidence }?.confidence ?? 0
    }
    
    var averageConfidence: Double {
        guard !detectedItems.isEmpty else { return 0 }
        return detectedItems.reduce(0) { $0 + $1.confidence } / Double(detectedItems.count)
    }
    
    var detectionCount: Int {
        return detectedItems.count
    }
    
    var mealScore: Int {
        // Simplified scoring based on variety and nutrition balance
        let varietyScore = min(50, detectedItems.count * 10)
        let nutritionScore = Int(averageConfidence * 50)
        return min(100, varietyScore + nutritionScore)
    }
}