import Foundation

enum AppError: Error, LocalizedError {
    case cameraAccessDenied
    case cameraUnavailable
    case mlModelNotFound
    case visionProcessingFailed
    case invalidImageData
    case portionEstimationFailed
    case nutritionDataMissing
    case databaseError(String)
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .cameraAccessDenied:
            return "Camera access has been denied. Please enable camera access in Settings."
        case .cameraUnavailable:
            return "Camera is unavailable on this device."
        case .mlModelNotFound:
            return "Machine learning model not found."
        case .visionProcessingFailed:
            return "Failed to process image with Vision framework."
        case .invalidImageData:
            return "Invalid image data provided."
        case .portionEstimationFailed:
            return "Failed to estimate food portions."
        case .nutritionDataMissing:
            return "Nutrition data not available for detected food."
        case .databaseError(let message):
            return "Database error: \(message)"
        case .networkError:
            return "Network error occurred."
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}