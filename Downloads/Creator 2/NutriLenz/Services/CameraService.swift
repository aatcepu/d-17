import Foundation
import AVFoundation
import UIKit
import SwiftUI

class CameraService: NSObject, ObservableObject {
    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var captureCompletion: ((Result<UIImage, Error>) -> Void)?
    
    @Published var authorizationStatus: AVAuthorizationStatus = .notDetermined
    @Published var isSessionRunning = false
    
    override init() {
        super.init()
        setupSession()
    }
    
    private func setupSession() {
        session.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
        } catch {
            print("Error setting up camera input: \(error)")
        }
    }
    
    func requestCameraAccess(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.authorizationStatus = granted ? .authorized : .denied
                completion(granted)
            }
        }
    }
    
    func startSession() {
        guard authorizationStatus == .authorized else { return }
        
        if !session.isRunning {
            session.startRunning()
            isSessionRunning = true
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
            isSessionRunning = false
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        if previewLayer == nil {
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill
        }
        return previewLayer!
    }
    
    func capturePhoto(completion: @escaping (Result<UIImage, Error>) -> Void) {
        guard authorizationStatus == .authorized else {
            completion(.failure(AppError.cameraAccessDenied))
            return
        }
        
        guard session.isRunning else {
            completion(.failure(AppError.cameraUnavailable))
            return
        }
        
        captureCompletion = completion
        
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.flashMode = .auto
        photoSettings.isHighResolutionPhotoEnabled = true
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        guard device.hasFlash else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.torchMode == .off ? .on : .off
            device.unlockForConfiguration()
        } catch {
            print("Error toggling flash: \(error)")
        }
    }
    
    func switchCamera() {
        // Stop current session
        let wasRunning = session.isRunning
        if wasRunning {
            session.stopRunning()
        }
        
        // Remove existing inputs
        let currentInputs = session.inputs
        for input in currentInputs {
            session.removeInput(input)
        }
        
        // Find new camera
        let newPosition: AVCaptureDevice.Position = currentCameraPosition() == .back ? .front : .back
        guard let newCamera = camera(with: newPosition) else { return }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
            }
            
            // Restart session if it was running
            if wasRunning {
                session.startRunning()
            }
        } catch {
            print("Error switching camera: \(error)")
        }
    }
    
    private func currentCameraPosition() -> AVCaptureDevice.Position {
        for input in session.inputs {
            if let deviceInput = input as? AVCaptureDeviceInput {
                return deviceInput.device.position
            }
        }
        return .unspecified
    }
    
    private func camera(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: position
        )
        
        return deviceDiscoverySession.devices.first
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            captureCompletion?(.failure(error))
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            captureCompletion?(.failure(AppError.invalidImageData))
            return
        }
        
        captureCompletion?(.success(image))
    }
}