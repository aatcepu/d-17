import Foundation
import UIKit
import CoreImage

class PortionEstimator: ObservableObject {
    
    func estimatePortionSize(for foodItem: FoodItem, in image: UIImage) -> PortionEstimate {
        // In a real implementation, this would analyze the image to estimate the actual size
        // For now, we'll return a default estimate based on the food type
        
        // This is a simplified approach - a real implementation would:
        // 1. Analyze the image to find the plate/food area
        // 2. Estimate the relative size compared to known objects
        // 3. Calculate the actual weight based on density information
        
        let estimatedWeight = estimateWeightBasedOnFoodType(foodItem.name)
        
        let multiplier = estimatedWeight / Constants.defaultPortionBaseWeight
        
        return PortionEstimate(
            size: determinePortionSize(from: multiplier),
            weightInGrams: estimatedWeight,
            multiplier: multiplier
        )
    }
    
    private func estimateWeightBasedOnFoodType(_ foodName: String) -> Double {
        // This would be much more sophisticated in reality with actual food density data
        let baseWeights: [String: Double] = [
            "apple": 182,
            "banana": 118,
            "orange": 131,
            "bread slice": 40,
            "chicken breast": 120,
            "rice": 158,  // per cup
            "broccoli": 91,
            "carrot": 61,
            "potato": 201,
            "cheese": 28,
            "egg": 50
        ]
        
        // Normalize food name for lookup
        let normalizedFoodName = foodName.lowercased()
        
        for (knownFood, weight) in baseWeights {
            if normalizedFoodName.contains(knownFood) {
                return weight
            }
        }
        
        // Default to 100g if we don't have specific data
        return 100.0
    }
    
    private func determinePortionSize(from multiplier: Double) -> PortionEstimate.PortionSize {
        if multiplier < 0.7 {
            return .small
        } else if multiplier < 1.3 {
            return .medium
        } else if multiplier < 1.8 {
            return .large
        } else {
            return .extraLarge
        }
    }
    
    // Advanced method that would analyze the image more thoroughly
    func analyzeImageForPortionEstimation(image: UIImage) -> Double {
        // This would perform image analysis to estimate relative size
        // For example, by detecting plate edges and comparing food area to plate area
        // Or by using depth estimation if available
        
        // For now, return a placeholder value
        return 1.0 // multiplier
    }
    
    func refinePortionEstimate(
        initialEstimate: PortionEstimate,
        withUserInput userInput: Double?,
        in image: UIImage
    ) -> PortionEstimate {
        // If user provided input, use that
        if let userWeight = userInput {
            let multiplier = userWeight / Constants.defaultPortionBaseWeight
            return PortionEstimate(
                size: determinePortionSize(from: multiplier),
                weightInGrams: userWeight,
                multiplier: multiplier
            )
        }
        
        // Otherwise, return the initial estimate
        return initialEstimate
    }
    
    func calculateNutritionWithPortionAdjustment(
        baseNutrition: NutritionFacts,
        portionEstimate: PortionEstimate
    ) -> NutritionFacts {
        // Scale all nutrition facts according to the portion multiplier
        return NutritionFacts(
            calories: baseNutrition.calories * portionEstimate.multiplier,
            protein: baseNutrition.protein * portionEstimate.multiplier,
            carbs: baseNutrition.carbs * portionEstimate.multiplier,
            fat: baseNutrition.fat * portionEstimate.multiplier,
            fiber: baseNutrition.fiber * portionEstimate.multiplier,
            sugar: baseNutrition.sugar * portionEstimate.multiplier
        )
    }
}

// Extension to fix typo in the calculateNutritionWithPortionAdjustment method
extension PortionEstimator {
    private func calculateNutritionWithPortionAdjustmentFixed(
        baseNutrition: NutritionFacts,
        portionEstimate: PortionEstimate
    ) -> NutritionFacts {
        // Scale all nutrition facts according to the portion multiplier
        return NutritionFacts(
            calories: baseNutrition.calories * portionEstimate.multiplier,
            protein: baseNutrition.protein * portionEstimate.multiplier,
            carbs: baseNutrition.carbs * portionEstimate.multiplier,
            fat: baseNutrition.fat * portionEstimate.multiplier,
            fiber: baseNutrition.fiber * portionEstimate.multiplier,
            sugar: baseNutrition.sugar * portionEstimate.multiplier
        )
    }
}