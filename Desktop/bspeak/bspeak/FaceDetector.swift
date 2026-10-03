//
//  FaceDetector.swift
//  bspeak
//
//  Created by Student on 31/08/26.
//

import Vision
import SwiftUI
import Combine

class FaceDetector: ObservableObject {

    @Published var faceDetected       = false
    @Published var leftEAR: Double    = 0.0
    @Published var rightEAR: Double   = 0.0
    @Published var averageEAR: Double = 0.0
    @Published var faceBoundingBox: CGRect = .zero
    @Published var blinkEvent: BlinkEvent  = .none
    @Published var leftEyeOpen        = true
    @Published var rightEyeOpen       = true

    var earThreshold: Double = 0.15
    private var closedFrameCount  = 0
    private var noFaceFrameCount  = 0
    private let minBlinkFrames    = 4
    private let maxBlinkFrames    = 45
    private let noFaceLimit       = 30

    private lazy var faceLandmarksRequest: VNDetectFaceLandmarksRequest = {
        VNDetectFaceLandmarksRequest { [weak self] request, error in
            if let error {
                print("❌ Vision error: \(error.localizedDescription)")
                return
            }
            self?.processResults(request.results)
        }
    }()

    func processFrame(_ pixelBuffer: CVPixelBuffer) {
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .leftMirrored,
            options: [:]
        )
        do {
            try handler.perform([faceLandmarksRequest])
        } catch {
            print("❌ Vision failed: \(error)")
        }
    }

    private func processResults(_ results: [VNObservation]?) {
        guard
            let observations = results as? [VNFaceObservation],
            let face         = observations.first,
            let landmarks    = face.landmarks,
            let leftEye      = landmarks.leftEye,
            let rightEye     = landmarks.rightEye
        else {
            handleNoFace()
            return
        }

        noFaceFrameCount = 0

        let lEAR   = calculateEAR(points: leftEye.normalizedPoints)
        let rEAR   = calculateEAR(points: rightEye.normalizedPoints)
        let avgEAR = (lEAR + rEAR) / 2.0

        detectBlink(avgEAR: avgEAR)

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.faceDetected    = true
            self.leftEAR         = lEAR
            self.rightEAR        = rEAR
            self.averageEAR      = avgEAR
            self.faceBoundingBox = face.boundingBox
            self.leftEyeOpen     = lEAR > self.earThreshold
            self.rightEyeOpen    = rEAR > self.earThreshold
        }
    }

    // ── EAR FORMULA ───────────────────────────────────────────
    //
    //       1    2
    //   0            3
    //       5    4
    //
    //  EAR = (dist(1,5) + dist(2,4)) / (2 × dist(0,3))
    //  Open eye  ≈ 0.25–0.35
    //  Closed eye ≈ 0.0–0.10
    // ─────────────────────────────────────────────────────────

    private func calculateEAR(points: [CGPoint]) -> Double {
        guard points.count >= 6 else { return 0 }

        let vertical1  = distance(points[1], points[5])
        let vertical2  = distance(points[2], points[4])
        let horizontal = distance(points[0], points[3])

        guard horizontal > 0 else { return 0 }

        return (vertical1 + vertical2) / (2.0 * horizontal)
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> Double {
        let dx = Double(a.x - b.x)
        let dy = Double(a.y - b.y)
        return sqrt(dx * dx + dy * dy)
    }

    private func detectBlink(avgEAR: Double) {
        if avgEAR < earThreshold {
            closedFrameCount += 1
        } else {
            if closedFrameCount >= minBlinkFrames {
                if closedFrameCount <= maxBlinkFrames {
                    fireBlink(.single)
                    print("👁 SINGLE BLINK — \(closedFrameCount) frames")
                } else {
                    fireBlink(.long)
                    print("👁 LONG BLINK — \(closedFrameCount) frames")
                }
            }
            closedFrameCount = 0
        }
    }

    private func fireBlink(_ event: BlinkEvent) {
        DispatchQueue.main.async { [weak self] in
            self?.blinkEvent = event
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                self?.blinkEvent = .none
            }
        }
        let style: UIImpactFeedbackGenerator.FeedbackStyle =
            event == .long ? .heavy : .medium
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    private func handleNoFace() {
        noFaceFrameCount += 1
        closedFrameCount  = 0
        if noFaceFrameCount >= noFaceLimit {
            DispatchQueue.main.async { [weak self] in
                self?.faceDetected = false
                self?.leftEAR      = 0
                self?.rightEAR     = 0
                self?.averageEAR   = 0
            }
        }
    }
}

// ── BLINK EVENT ───────────────────────────────────────────────
enum BlinkEvent: Equatable {
    case none
    case single
    case long
}
