import Foundation
import AVFoundation
import UIKit
import SwiftUI

class CameraViewModel: ObservableObject {
    @Published var capturedImage: UIImage?
    @Published var isCapturing: Bool = false
    @Published var errorMessage: String?
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    
    private let session = AVCaptureSession()
    private var videoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                if granted {
                    self.authorizationStatus = .authorized
                } else {
                    self.authorizationStatus = .denied
                    self.errorMessage = "Camera access denied"
                }
            }
        }
    }
    
    func setupCamera() throws {
        guard authorizationStatus == .authorized else {
            throw AppError.cameraAccessDenied
        }
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            throw AppError.cameraUnavailable
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            session.beginConfiguration()
            session.sessionPreset = .photo
            
            // Remove existing inputs if any
            for existingInput in session.inputs {
                session.removeInput(existingInput)
            }
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            // Remove existing outputs if any
            for existingOutput in session.outputs {
                session.removeOutput(existingOutput)
            }
            
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
            }
            
            session.commitConfiguration()
            
        } catch {
            throw AppError.cameraUnavailable
        }
    }
    
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard session.isRunning else {
            completion(.failure(AppError.cameraUnavailable))
            return
        }
        
        isCapturing = true
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.qualityPrioritization = .quality
        photoSettings.isHighResolutionPhotoEnabled = true
        
        let photoCaptureDelegate = PhotoCaptureDelegate { result in
            DispatchQueue.main.async {
                self.isCapturing = false
                completion(result)
            }
        }
        
        videoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureDelegate)
    }
    
    func startSession() {
        if !session.isRunning {
            session.startRunning()
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func getPreviewLayer() -> CALayer {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
        }
        return previewLayer!
    }
}

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completionHandler: (Result<UIImage, Error>) -> Void
    
    init(completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        self.completionHandler = completionHandler
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            completionHandler(.failure(error))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            completionHandler(.failure(AppError.invalidImageData))
            return
        }
        
        completionHandler(.success(image))
    }
}