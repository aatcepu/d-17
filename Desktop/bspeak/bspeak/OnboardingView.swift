//
//  OnboardingView.swift
//  bspeak
//
//  Created by Student on 21/08/26.
//

import SwiftUI

struct OnboardingView: View {

    var onComplete: () -> Void = {}

    // Tracks which slide we are on
    @State private var currentPage = 0

    // The 3 slides content
    let slides: [OnboardingSlide] = [
        OnboardingSlide(
            icon: "eye.fill",
            title: "Welcome to\nBlinkSpeak",
            subtitle: "BlinkSpeak lets people communicate \n using only their eyes.\n No touching required after setup.",
            hint: "For caregivers and families"
        ),
        OnboardingSlide(
            icon: "camera.fill",
            title: "Setting Up",
            subtitle: "Position the device 30–50cm from\nthe user's face.\nEnsure the room is well lit.\nThe app does everything else.",
            hint: "Front camera will start automatically"
        ),
        OnboardingSlide(
            icon: "hand.tap.fill",
            title: "How Blinking Works",
            subtitle: "Single blink — select a word\nLong blink (2 seconds) — speak\nThe grid scans by itself.\nNo touch needed at all.",
            hint: "Tap Begin to start calibration"
        )
    ]

    var body: some View {
        ZStack {
            Color.bsBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Slide content
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        slideView(slides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Bottom controls
                bottomControls
                    .padding(.bottom, 48)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
    }

    // ── SINGLE SLIDE ─────────────────────────────────────────
    func slideView(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon in glowing circle
            ZStack {
                Circle()
                    .fill(Color.bsPrimary.opacity(0.08))
                    .frame(width: 140, height: 140)

                Circle()
                    .fill(Color.bsPrimary.opacity(0.13))
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.bsLilac, Color.bsDeep],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .bsPrimary.opacity(0.4), radius: 20)

                Image(systemName: slide.icon)
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.bsLavender)
            }
            .padding(.bottom, 44)

            // Title
            Text(slide.title)
                .font(.custom("AvenirNext-Heavy", size: 28))
                .tracking(1)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.bsLavender, Color.bsLilac],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)

            // Subtitle
            Text(slide.subtitle)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.bsTextMuted)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 36)
                .padding(.bottom, 24)

            // Hint tag
            Text(slide.hint)
                .font(.system(size: 10, weight: .semibold))
                .tracking(2)
                .foregroundColor(.bsTextDim)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.bsSurface)
                        .overlay(
                            Capsule()
                                .stroke(Color.bsBorder, lineWidth: 1)
                        )
                )

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // ── BOTTOM CONTROLS ──────────────────────────────────────
    var bottomControls: some View {
        VStack(spacing: 28) {
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<slides.count, id: \.self) { index in
                    Capsule()
                        .fill(
                            currentPage == index
                            ? Color.bsPrimary
                            : Color.bsBorder
                        )
                        .frame(
                            width: currentPage == index ? 24 : 8,
                            height: 8
                        )
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }

            // Next or Begin button
            Button {
                if currentPage < slides.count - 1 {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage += 1
                    }
                } else {
                    onComplete()
                }
            } label: {
                HStack(spacing: 10) {
                    Text(currentPage < slides.count - 1 ? "NEXT" : "BEGIN")
                        .font(.system(size: 12, weight: .bold))
                        .tracking(3)

                    Image(systemName: currentPage < slides.count - 1
                          ? "arrow.right"
                          : "eye.fill"
                    )
                    .font(.system(size: 12, weight: .bold))
                }
                .foregroundColor(.bsLavender)
                .padding(.horizontal, 48)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.bsPrimary.opacity(0.3),
                                    Color.bsDeep.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.bsPrimary.opacity(0.5), lineWidth: 1.5)
                        )
                )
                .shadow(color: .bsPrimary.opacity(0.3), radius: 16)
            }
            .buttonStyle(.plain)
        }
    }
}

// ── DATA MODEL ────────────────────────────────────────────────
struct OnboardingSlide {
    let icon: String
    let title: String
    let subtitle: String
    let hint: String
}

#Preview {
    OnboardingView()
}
