import UIKit
import Accelerate
import AVFoundation

extension UIImage {
    func pixelBuffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                     kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(self.size.width),
                                         Int(self.size.height),
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        
        guard status == kCVReturnSuccess else { return nil }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData,
                               width: Int(self.size.width),
                               height: Int(self.size.height),
                               bitsPerComponent: 8,
                               bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!),
                               space: rgbColorSpace,
                               bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1, y: -1)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func scaledTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func scaledToMaxSize(maxSize: CGSize) -> UIImage? {
        let widthRatio = maxSize.width / size.width
        let heightRatio = maxSize.height / size.height
        let scale = min(widthRatio, heightRatio)
        
        if scale > 1.0 {
            return self
        }
        
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        return scaledTo(size: scaledSize)
    }
    
    func toCIImage() -> CIImage? {
        guard let cgImage = self.cgImage else { return nil }
        return CIImage(cgImage: cgImage)
    }
}