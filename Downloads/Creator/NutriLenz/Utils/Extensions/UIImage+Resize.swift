import UIKit

extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage? {
        let frame = CGRect(origin: .zero, size: targetSize)
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        self.draw(in: frame)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    func scaledImage(maxSize: CGSize) -> UIImage? {
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)
        
        if scaleFactor >= 1.0 {
            return self // Image is already smaller than max size
        }
        
        let newSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        return resized(to: newSize)
    }
    
    func toData(maxSize: CGSize = Constants.maxImageSize) -> Data? {
        if let scaledImage = self.scaledImage(maxSize: maxSize),
           let jpegData = scaledImage.jpegData(compressionQuality: 0.8) {
            return jpegData
        }
        
        // Fallback to original image if scaling failed
        return self.jpegData(compressionQuality: 0.8)
    }
}