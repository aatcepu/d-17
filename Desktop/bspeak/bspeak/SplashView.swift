//
//  SplashView.swift
//  bspeak
//
//  Created by Student on 20/08/26.
//

import SwiftUI

struct SplashView: View {

    @State private var opacity = 0.0
    @State private var scale = 0.85
    @State private var isPulsing = false

    var onContinue: () -> Void = {}

    var body: some View {
        ZStack {
            // Background
            RadialGradient(
                colors: [
                    Color(red: 0.149, green: 0.082, blue: 0.271),
                    Color.bsBackground
                ],
                center: UnitPoint(x: 0.5, y: 0.38),
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Eye
                ZStack {
                    Circle()
                        .fill(Color.bsPrimary.opacity(0.06))
                        .frame(
                            width: isPulsing ? 160 : 140,
                            height: isPulsing ? 160 : 140
                        )
                    Circle()
                        .fill(Color.bsPrimary.opacity(0.10))
                        .frame(
                            width: isPulsing ? 120 : 108,
                            height: isPulsing ? 120 : 108
                        )
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.45, green: 0.25, blue: 0.85),
                                    Color(red: 0.165, green: 0.063, blue: 0.435)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 43
                            )
                        )
                        .frame(width: 86, height: 86)
                        .shadow(
                            color: Color.bsPrimary.opacity(0.55),
                            radius: isPulsing ? 24 : 16
                        )
                    Circle()
                        .fill(Color.black.opacity(0.85))
                        .frame(width: 32, height: 32)
                    Circle()
                        .fill(Color.white.opacity(0.75))
                        .frame(width: 10, height: 10)
                        .offset(x: -10, y: -10)
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 5, height: 5)
                        .offset(x: 8, y: -8)
                }
                .animation(
                    .easeInOut(duration: 1.8)
                    .repeatForever(autoreverses: true),
                    value: isPulsing
                )
                .padding(.bottom, 44)

                // App name
                Text("EYE TALK")
                    .font(.custom("AvenirNext-Heavy", size: 42))
                    .tracking(6)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color.bsLavender,
                                Color.bsLilac,
                                Color.bsPrimary
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.bottom, 14)

                // Tagline
                Text("SPEAK WITH YOUR EYES")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(4)
                    .foregroundColor(.bsTextMuted)
                    .padding(.bottom, 72)

                // Button
                Button {
                    onContinue()
                } label: {
                    HStack(spacing: 10) {
                        Text("GET STARTED")
                            .font(.system(size: 12, weight: .bold))
                            .tracking(3)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(.bsLavender)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(Color.bsPrimary.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(
                                        Color.bsPrimary.opacity(0.5),
                                        lineWidth: 1.5
                                    )
                            )
                    )
                    .shadow(
                        color: Color.bsPrimary.opacity(0.35),
                        radius: 20
                    )
                }
                .buttonStyle(.plain)

                Spacer()

                // Version
                Text("Swift Student Challenge 2026")
                    .font(.system(size: 10))
                    .tracking(1.5)
                    .foregroundColor(.bsTextMuted.opacity(0.4))
                    .padding(.bottom, 32)
            }
            .opacity(opacity)
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                opacity = 1.0
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                isPulsing = true
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .ignoresSafeArea()
    }
}

#Preview {
    SplashView()
}
