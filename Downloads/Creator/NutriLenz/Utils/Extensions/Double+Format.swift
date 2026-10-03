import Foundation

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var formattedCalories: String {
        return "\(Int(self)) cal"
    }
    
    var formattedGrams: String {
        return String(format: "%.1fg", self)
    }
    
    var formattedPercentage: String {
        return String(format: "%.0f%%", self)
    }
    
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
    
    var oneDecimalPlaceString: String {
        return String(format: "%.1f", self)
    }
}