//
//  CaliberationView.swift
//  bspeak
//
//  Created by Student on 21/08/26.
//

import SwiftUI
import Combine

struct CalibrationView: View {

    var onComplete: () -> Void = {}

    @State private var stage: CalibStage = .intro
    @State private var blinkCount        = 0
    @State private var isWatching        = false
    @State private var eyePulse          = false
    @State private var progress: Double  = 0.0
    @State private var message           = "Get ready..."
    let totalBlinks = 5

    enum CalibStage {
        case intro
        case calibrating
        case done
    }

    var body: some View {
        ZStack {
            Color.bsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                switch stage {
                case .intro:    introView
                case .calibrating: calibratingView
                case .done:     doneView
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    // ── INTRO ─────────────────────────────────────────────────
    var introView: some View {
        VStack(spacing: 0) {
            Text("👁")
                .font(.system(size: 64))
                .padding(.bottom, 32)

            Text("Calibration")
                .font(.custom("AvenirNext-Heavy", size: 32))
                .tracking(2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.bsLavender, Color.bsPrimary],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .padding(.bottom, 16)

            Text("BlinkSpeak needs to learn how\nyour eyes blink naturally.\n\nBlink normally 5 times when\nyou see the eye on screen.")
                .font(.system(size: 15))
                .foregroundColor(.bsTextMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 48)

            Button {
                withAnimation {
                    stage = .calibrating
                    isWatching = true
                    startEyePulse()
                }
            } label: {
                Text("START CALIBRATION")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(3)
                    .foregroundColor(.bsLavender)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.bsPrimary.opacity(0.2))
                            .overlay(
                                Capsule()
                                    .stroke(Color.bsPrimary.opacity(0.5), lineWidth: 1.5)
                            )
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // ── CALIBRATING ───────────────────────────────────────────
    var calibratingView: some View {
        VStack(spacing: 0) {

            // Eye animation
            ZStack {
                // Outer pulse ring
                Circle()
                    .stroke(Color.bsPrimary.opacity(eyePulse ? 0.4 : 0.1), lineWidth: 2)
                    .frame(width: eyePulse ? 180 : 160, height: eyePulse ? 180 : 160)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: eyePulse)

                // Inner circle
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.bsLilac.opacity(0.8), Color.bsDeep],
                            center: .center,
                            startRadius: 0,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)
                    .shadow(color: .bsPrimary.opacity(0.5), radius: 20)

                // Pupil
                Circle()
                    .fill(Color.black)
                    .frame(width: 44, height: 44)

                // Highlight
                Circle()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 12, height: 12)
                    .offset(x: -12, y: -12)
            }
            .padding(.bottom, 44)

            // Message
            Text(message)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.bsLavender)
                .multilineTextAlignment(.center)
                .padding(.bottom, 32)
                .animation(.easeInOut, value: message)

            // Progress bar
            VStack(spacing: 12) {
                // Blink count
                HStack {
                    Text("BLINKS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(.bsTextMuted)
                    Spacer()
                    Text("\(blinkCount) / \(totalBlinks)")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.bsPrimary)
                }

                // Progress track
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background track
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.bsSurface)
                            .frame(height: 8)

                        // Fill
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.bsLilac, Color.bsPrimary],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * progress,
                                height: 8
                            )
                            .animation(.spring(duration: 0.4), value: progress)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 40)

            // Simulate blink button
            // In final app this fires from real blink detection
            // For now tap to test the calibration flow
            Button {
                registerBlink()
            } label: {
                Text("TAP TO SIMULATE BLINK")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.bsTextDim)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.bsBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            Text("(Camera blink detection replaces this later)")
                .font(.system(size: 10))
                .foregroundColor(.bsTextDim.opacity(0.5))
                .padding(.top, 8)
        }
    }

    // ── DONE ──────────────────────────────────────────────────
    var doneView: some View {
        VStack(spacing: 0) {
            // Success icon
            ZStack {
                Circle()
                    .fill(Color.bsSuccess.opacity(0.12))
                    .frame(width: 120, height: 120)
                Circle()
                    .fill(Color.bsSuccess.opacity(0.2))
                    .frame(width: 90, height: 90)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.bsSuccess)
            }
            .padding(.bottom, 36)

            Text("Calibration Complete")
                .font(.custom("AvenirNext-Heavy", size: 28))
                .tracking(1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.bsLavender, Color.bsSuccess],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Text("BlinkSpeak has learned your\nblink pattern. You are ready.")
                .font(.system(size: 15))
                .foregroundColor(.bsTextMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.bottom, 52)

            Button {
                onComplete()
            } label: {
                HStack(spacing: 10) {
                    Text("OPEN BLINKSPEAK")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)
                    Image(systemName: "eye.fill")
                        .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.bsLavender)
                .padding(.horizontal, 40)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(Color.bsPrimary.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(Color.bsPrimary.opacity(0.5), lineWidth: 1.5)
                        )
                )
                .shadow(color: .bsPrimary.opacity(0.35), radius: 16)
            }
            .buttonStyle(.plain)
        }
    }

    // ── HELPERS ───────────────────────────────────────────────
    func startEyePulse() {
        eyePulse = true
        message = "Blink naturally when ready"
    }

    func registerBlink() {
        guard blinkCount < totalBlinks else { return }

        blinkCount += 1
        progress = Double(blinkCount) / Double(totalBlinks)

        // Update message based on progress
        switch blinkCount {
        case 1: message = "Good! Keep going..."
        case 2: message = "Perfect, natural blinks..."
        case 3: message = "Halfway there..."
        case 4: message = "Almost done..."
        case 5:
            message = "Done!"
            // Small delay then show success
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    stage = .done
                }
            }
        default: break
        }

        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
}

#Preview {
    CalibrationView()
}
