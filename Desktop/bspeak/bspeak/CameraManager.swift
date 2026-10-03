//
//  CameraManager.swift
//  bspeak
//
//  Created by Student on 31/08/26.
//

import AVFoundation
import SwiftUI
import Combine

class CameraManager: NSObject, ObservableObject {

    var isRunning = false
    var permissionGranted = false
    let session = AVCaptureSession()

    private let queue = DispatchQueue(
        label: "com.bspeak.camera",
        qos: .userInitiated
    )

    // Every frame fires through this callback
    var onFrame: ((CVPixelBuffer) -> Void)?

    override init() {
        super.init()
        checkPermission()
    }

    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            permissionGranted = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.permissionGranted = granted
                    if granted { self.setupCamera() }
                }
            }
        default:
            permissionGranted = false
        }
    }

    private func setupCamera() {
        queue.async { [weak self] in
            guard let self else { return }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            // Front camera
            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .front
            ) else {
                print("❌ No front camera found")
                return
            }

            guard let input = try? AVCaptureDeviceInput(device: device) else {
                print("❌ Cannot create camera input")
                return
            }

            if self.session.canAddInput(input) {
                self.session.addInput(input)
            }

            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: self.queue)
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String:
                    kCVPixelFormatType_32BGRA
            ]

            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
            }

            if let connection = output.connection(with: .video) {
                connection.videoRotationAngle = 90
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }

            self.session.commitConfiguration()
            self.session.startRunning()
            self.isRunning = true
            print("✅ Camera running")
        }
    }

    func start() {
        queue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
                self.isRunning = true
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
                self.isRunning = false
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        onFrame?(pixelBuffer)
    }
}
