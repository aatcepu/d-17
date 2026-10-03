import Vision

extension VNObservation {
    func boundingBoxInImage(imageSize: CGSize) -> CGRect {
        // Convert the normalized coordinates to image coordinates
        let x = boundingBox.origin.x * imageSize.width
        let y = (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height
        let width = boundingBox.width * imageSize.width
        let height = boundingBox.height * imageSize.height
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func boundingBoxInView(viewSize: CGSize, imageSize: CGSize) -> CGRect {
        // Scale the bounding box from image coordinates to view coordinates
        let imageToViewScaleX = viewSize.width / imageSize.width
        let imageToViewScaleY = viewSize.height / imageSize.height
        let scale = min(imageToViewScaleX, imageToViewScaleY)
        
        let boundingBoxInImageCoords = boundingBoxInImage(imageSize: imageSize)
        
        let x = boundingBoxInImageCoords.origin.x * imageToViewScaleX
        let y = boundingBoxInImageCoords.origin.y * imageToViewScaleY
        let width = boundingBoxInImageCoords.width * scale
        let height = boundingBoxInImageCoords.height * scale
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

extension VNClassificationObservation {
    func toFoodItem(confidenceThreshold: Float = 0.5) -> FoodItem? {
        guard confidence >= confidenceThreshold else { return nil }
        
        // Create a default NutritionFacts object
        // In a real implementation, we would look up actual nutrition data
        let nutritionFacts = NutritionFacts()
        let portionEstimate = PortionEstimate()
        
        return FoodItem(
            name: identifier,
            confidence: Double(confidence),
            nutritionFacts: nutritionFacts,
            portionEstimate: portionEstimate
        )
    }
}

extension VNRecognizedObjectObservation {
    func toFoodItem(confidenceThreshold: Float = 0.5) -> FoodItem? {
        guard confidence >= confidenceThreshold else { return nil }
        
        // Create a default NutritionFacts object
        let nutritionFacts = NutritionFacts()
        let portionEstimate = PortionEstimate()
        
        return FoodItem(
            name: labels.first?.identifier ?? "Unknown Food",
            confidence: Double(confidence),
            boundingBox: boundingBox,
            nutritionFacts: nutritionFacts,
            portionEstimate: portionEstimate
        )
    }
}