//
//  ContentView.swift
//  bspeak
//
//  Created by Student on 20/08/26.
//

import SwiftUI
import Combine

struct ContentView: View {

    // Checks if user has already done onboarding before
    @AppStorage("hasOnboarded") private var hasOnboarded = false

    @State private var showSplash     = true
    @State private var showOnboarding = false
    @State private var showMain       = false

    var body: some View {
        ZStack {
            Color.bsBackground.ignoresSafeArea()

            if showSplash {
                SplashView()
                    .transition(.opacity)

            } else if showOnboarding {
                OnboardingView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showOnboarding = false
                        showMain       = true
                        hasOnboarded   = true
                    }
                })
                .transition(.opacity)

            } else if showMain {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            // Splash shows for 3 seconds then auto advances
            // No tap needed — user does not have to do anything
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showSplash = false
                    // First launch goes to onboarding
                    // Returning users go straight to camera
                    if hasOnboarded {
                        showMain = true
                    } else {
                        showOnboarding = true
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
