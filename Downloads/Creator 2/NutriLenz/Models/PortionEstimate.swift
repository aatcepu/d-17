import Foundation

struct PortionEstimate: Identifiable, Codable {
    let id = UUID()
    var size: PortionSize
    var weightInGrams: Double
    var multiplier: Double // Factor to multiply nutrition facts by
    
    init(size: PortionSize = .medium, weightInGrams: Double = 100, multiplier: Double = 1.0) {
        self.size = size
        self.weightInGrams = weightInGrams
        self.multiplier = multiplier
    }
    
    enum PortionSize: String, CaseIterable, Codable {
        case small = "Small"
        case medium = "Medium" 
        case large = "Large"
        case extraLarge = "Extra Large"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    mutating func updateMultiplier(baseWeight: Double) {
        // Calculate multiplier based on comparison to base weight
        self.multiplier = weightInGrams / baseWeight
    }
    
    var displayWeight: String {
        return String(format: "%.0fg", weightInGrams)
    }
    
    var displayMultiplier: String {
        return String(format: "%.2fx", multiplier)
    }
}