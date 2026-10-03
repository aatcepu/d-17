//
//  DetectView.swift
//  bspeak
//
//  Created by Student on 31/08/26.
//

import SwiftUI
import AVFoundation

struct DetectView: View {

    @StateObject private var camera   = CameraManager()
    @StateObject private var detector = FaceDetector()

    @State private var sentence: [String] = []
    @State private var showBlinkFlash     = false

    var body: some View {
        ZStack {
            Color.bsBackground.ignoresSafeArea()

            if !camera.permissionGranted {
                permissionDeniedView
            } else {
                mainContent
            }
        }
        .onAppear {
            camera.onFrame = { pixelBuffer in
                self.detector.processFrame(pixelBuffer)
            }
        }
        .onChange(of: detector.blinkEvent) { _, newEvent in
            handleBlink(newEvent)
        }
        .onDisappear {
            camera.stop()
        }
        .preferredColorScheme(.light)
    }

    // ── MAIN CONTENT ─────────────────────────────────────────
    var mainContent: some View {
        VStack(spacing: 0) {
            topBar
            cameraFeed
            earReadout
            sentenceBar
        }
    }

    // ── TOP BAR ──────────────────────────────────────────────
    var topBar: some View {
        HStack {
            HStack(spacing: 0) {
                Text("Blink")
                    .font(.custom("AvenirNext-Heavy", size: 20))
                    .tracking(1)
                    .foregroundColor(.bsDeep)
                Text("Speak")
                    .font(.custom("AvenirNext-Heavy", size: 20))
                    .tracking(1)
                    .foregroundColor(.bsPrimary)
            }

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(
                        detector.faceDetected
                        ? Color.bsSuccess
                        : Color.bsAlert
                    )
                    .frame(width: 7, height: 7)
                    .shadow(
                        color: detector.faceDetected
                        ? Color.bsSuccess.opacity(0.5)
                        : Color.bsAlert.opacity(0.5),
                        radius: 4
                    )

                Text(detector.faceDetected ? "DETECTING" : "NO FACE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(
                        detector.faceDetected
                        ? .bsSuccess
                        : .bsAlert
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.bsSurface)
                    .overlay(
                        Capsule()
                            .stroke(Color.bsBorder, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .background(Color.bsBackground)
    }

    // ── CAMERA FEED ───────────────────────────────────────────
    var cameraFeed: some View {
        GeometryReader { geo in
            ZStack {
                // Live camera
                CameraPreviewView(session: camera.session)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                // Yellow flash on blink
                if showBlinkFlash {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.bsYellow.opacity(0.25))
                        .allowsHitTesting(false)
                }

                // Face bounding box
                if detector.faceDetected {
                    FaceBoxView(
                        boundingBox: detector.faceBoundingBox,
                        size: geo.size,
                        leftOpen: detector.leftEyeOpen,
                        rightOpen: detector.rightEyeOpen
                    )
                }

                // No face warning
                if !detector.faceDetected {
                    VStack(spacing: 10) {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 28))
                            .foregroundColor(.bsAlert)
                        Text("Move closer to camera")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.bsTextPrimary)
                        Text("Ensure good lighting")
                            .font(.system(size: 11))
                            .foregroundColor(.bsTextMuted)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.9))
                    )
                }
            }
        }
        .frame(height: 300)
        .padding(.horizontal, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    detector.faceDetected
                    ? Color.bsPrimary.opacity(0.4)
                    : Color.bsAlert.opacity(0.4),
                    lineWidth: 1.5
                )
                .padding(.horizontal, 16)
        )
    }

    // ── EAR READOUT ───────────────────────────────────────────
    var earReadout: some View {
        HStack(spacing: 0) {
            earCard(
                label: "LEFT",
                value: detector.leftEAR,
                isOpen: detector.leftEyeOpen
            )
            Rectangle()
                .fill(Color.bsBorder)
                .frame(width: 1, height: 44)
            earCard(
                label: "AVG",
                value: detector.averageEAR,
                isOpen: detector.averageEAR > detector.earThreshold
            )
            Rectangle()
                .fill(Color.bsBorder)
                .frame(width: 1, height: 44)
            earCard(
                label: "RIGHT",
                value: detector.rightEAR,
                isOpen: detector.rightEyeOpen
            )
        }
        .background(Color.bsSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.bsBorder, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    func earCard(
        label: String,
        value: Double,
        isOpen: Bool
    ) -> some View {
        VStack(spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundColor(.bsTextDim)

            Text(String(format: "%.3f", value))
                .font(.system(
                    size: 20,
                    weight: .bold,
                    design: .monospaced
                ))
                .foregroundColor(
                    value < detector.earThreshold && value > 0
                    ? Color.bsAlert
                    : Color.bsPrimary
                )

            Image(systemName: isOpen ? "eye" : "eye.slash")
                .font(.system(size: 10))
                .foregroundColor(isOpen ? .bsSuccess : .bsAlert)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
    }

    // ── SENTENCE BAR ──────────────────────────────────────────
    var sentenceBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("OUTPUT")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(2.5)
                    .foregroundColor(.bsTextDim)
                Spacer()
                Text("LONG BLINK to speak")
                    .font(.system(size: 9))
                    .tracking(1)
                    .foregroundColor(.bsTextDim)
            }

            if sentence.isEmpty {
                Text("Select phrases from AAC tab...")
                    .font(.system(size: 14))
                    .foregroundColor(.bsTextDim)
                    .italic()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    Text(sentence.joined(separator: " "))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.bsTextPrimary)
                }
            }

            HStack(spacing: 8) {
                // Speak button — yellow accent
                Button {
                    guard !sentence.isEmpty else { return }
                    SpeechManager.shared.speak(
                        sentence.joined(separator: " ")
                    )
                } label: {
                    Label("SPEAK", systemImage: "speaker.wave.2.fill")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.bsYellowDeep)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.bsYellowSoft)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.bsYellow.opacity(0.5),
                                                lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)

                // Clear button — blue
                Button {
                    withAnimation { sentence.removeAll() }
                } label: {
                    Label("CLEAR", systemImage: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundColor(.bsPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.bsLavender.opacity(0.3))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.bsPrimary.opacity(0.3),
                                                lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bsSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.bsBorder, lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // ── PERMISSION DENIED ─────────────────────────────────────
    var permissionDeniedView: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "camera.slash")
                .font(.system(size: 52))
                .foregroundColor(.bsAlert)

            Text("Camera Access Needed")
                .font(.custom("AvenirNext-Heavy", size: 24))
                .foregroundColor(.bsDeep)

            Text("BlinkSpeak needs camera access\nto detect eye blinks.\n\nGo to Settings → bspeak\n→ enable Camera.")
                .font(.system(size: 14))
                .foregroundColor(.bsTextMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(5)

            Spacer()
        }
        .padding(32)
        .background(Color.bsBackground)
    }

    // ── BLINK HANDLER ─────────────────────────────────────────
    func handleBlink(_ event: BlinkEvent) {
        guard event != .none else { return }

        // Yellow flash on blink
        withAnimation(.easeIn(duration: 0.1)) {
            showBlinkFlash = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.2)) {
                showBlinkFlash = false
            }
        }

        // Long blink speaks sentence
        if event == .long && !sentence.isEmpty {
            SpeechManager.shared.speak(
                sentence.joined(separator: " ")
            )
        }
    }
}

// ── FACE BOUNDING BOX ─────────────────────────────────────────
struct FaceBoxView: View {

    let boundingBox: CGRect
    let size: CGSize
    let leftOpen: Bool
    let rightOpen: Bool

    var screenRect: CGRect {
        CGRect(
            x: boundingBox.minX * size.width,
            y: (1 - boundingBox.maxY) * size.height,
            width: boundingBox.width * size.width,
            height: boundingBox.height * size.height
        )
    }

    var body: some View {
        Canvas { ctx, _ in
            let rect   = screenRect
            let corner: CGFloat = 22
            let lw: CGFloat     = 2.5
            let col = GraphicsContext.Shading.color(Color.bsPrimary)

            // Top left
            var tl = Path()
            tl.move(to: CGPoint(x: rect.minX, y: rect.minY + corner))
            tl.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            tl.addLine(to: CGPoint(x: rect.minX + corner, y: rect.minY))
            ctx.stroke(tl, with: col,
                style: StrokeStyle(lineWidth: lw, lineCap: .round))

            // Top right
            var tr = Path()
            tr.move(to: CGPoint(x: rect.maxX - corner, y: rect.minY))
            tr.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            tr.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + corner))
            ctx.stroke(tr, with: col,
                style: StrokeStyle(lineWidth: lw, lineCap: .round))

            // Bottom left
            var bl = Path()
            bl.move(to: CGPoint(x: rect.minX, y: rect.maxY - corner))
            bl.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            bl.addLine(to: CGPoint(x: rect.minX + corner, y: rect.maxY))
            ctx.stroke(bl, with: col,
                style: StrokeStyle(lineWidth: lw, lineCap: .round))

            // Bottom right
            var br = Path()
            br.move(to: CGPoint(x: rect.maxX - corner, y: rect.maxY - corner))
            br.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            br.addLine(to: CGPoint(x: rect.maxX - corner, y: rect.maxY))
            ctx.stroke(br, with: col,
                style: StrokeStyle(lineWidth: lw, lineCap: .round))
        }

        // Eye dots at bottom of face box
        HStack(spacing: 28) {
            eyeDot(label: "L", isOpen: leftOpen)
            eyeDot(label: "R", isOpen: rightOpen)
        }
        .position(
            x: screenRect.midX,
            y: screenRect.maxY - 22
        )
    }

    func eyeDot(label: String, isOpen: Bool) -> some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isOpen ? Color.bsSuccess : Color.bsTextDim)
                .frame(width: 10, height: 10)
                .shadow(
                    color: isOpen
                    ? Color.bsSuccess.opacity(0.6)
                    : .clear,
                    radius: 4
                )
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(1)
                .foregroundColor(Color.bsTextDim)
        }
    }
}

#Preview {
    ZStack {
        Color.bsBackground.ignoresSafeArea()
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "eye.fill")
                .font(.system(size: 52))
                .foregroundColor(.bsPrimary)
            Text("DetectView")
                .font(.custom("AvenirNext-Heavy", size: 24))
                .foregroundColor(.bsDeep)
            Text("Requires real device for camera")
                .font(.system(size: 13))
                .foregroundColor(.bsTextMuted)
            Spacer()
        }
    }
    .preferredColorScheme(.light)
}
