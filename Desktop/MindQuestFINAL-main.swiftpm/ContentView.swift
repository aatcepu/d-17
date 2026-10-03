import SwiftUI

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashScreenView(showSplash: $showSplash)
            } else {
                Group {
                    if appState.hasFinishedOnboarding {
                        MainTabView()
                    } else {
                        IntroView(appState: appState)
                    }
                }
                .environmentObject(appState)
                .preferredColorScheme(appState.isDarkMode ? .dark : .light)
            }
        }
    }
}

struct SplashScreenView: View {
    @Binding var showSplash: Bool
    @State private var opacity = 0.0
    @State private var scale = 0.8
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack {
                // We'll use a placeholder bird icon for now (or pigeon if available)
                Image(systemName: "bird.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Theme.primary)
                    .shadow(color: Theme.primary.opacity(0.5), radius: 20)
                
                Text("MindQuest")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .padding(.top, 20)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.easeIn(duration: 1.0)) {
                opacity = 1.0
                scale = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch appState.selectedTab {
                case 0: HomeView()
                case 1: DiscoverView()
                case 2: WellnessView()
                case 3: JourneyView()
                case 4: ProfileView()
                default: HomeView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .xpBadge()
            .achievementOverlay()
            .focusSpotlight()
            .encouragementOverlay()
            .overlay(WelcomeBackOverlay())
            .onAppear { EncouragementAgent.shared.maybeShowMessage() }
            
            // Custom Tab 
            HStack(spacing: 0) {
                TabBarButton(icon: "house.fill", label: "Home", isSelected: appState.selectedTab == 0) {
                    HapticAgent.shared.playSelection()
                    SoundManager.shared.playTapSound(enabled: appState.soundsEnabled)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { appState.selectedTab = 0 }
                }
                TabBarButton(icon: "sparkles", label: "Discover", isSelected: appState.selectedTab == 1) {
                    HapticAgent.shared.playSelection()
                    SoundManager.shared.playTapSound(enabled: appState.soundsEnabled)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { appState.selectedTab = 1 }
                }
                TabBarButton(icon: "heart.text.clipboard.fill", label: "Wellness", isSelected: appState.selectedTab == 2) {
                    HapticAgent.shared.playSelection()
                    SoundManager.shared.playTapSound(enabled: appState.soundsEnabled)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { appState.selectedTab = 2 }
                }
                TabBarButton(icon: "chart.bar.fill", label: "Journey", isSelected: appState.selectedTab == 3) {
                    HapticAgent.shared.playSelection()
                    SoundManager.shared.playTapSound(enabled: appState.soundsEnabled)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { appState.selectedTab = 3 }
                }
                TabBarButton(icon: "person.fill", label: "Profile", isSelected: appState.selectedTab == 4) {
                    HapticAgent.shared.playSelection()
                    SoundManager.shared.playTapSound(enabled: appState.soundsEnabled)
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { appState.selectedTab = 4 }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 28)
            .background(
                ZStack {
                    // Glass base
                    Rectangle()
                        .fill(Theme.cardBackground.opacity(0.8))
                        .background(.ultraThinMaterial)
                    
                    // Top border glow
                    VStack {
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.08), Color.clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 1)
                        Spacer()
                    }
                }
                .ignoresSafeArea(.all, edges: .bottom)
            )
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? Theme.secondary : .gray.opacity(0.5))
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                    .shadow(color: isSelected ? Theme.secondary.opacity(0.4) : .clear, radius: 8)
                
                Text(label)
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? Theme.secondary : .gray.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(SubtleTapButtonStyle())
    }
}
