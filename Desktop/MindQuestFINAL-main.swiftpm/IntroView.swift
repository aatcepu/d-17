import SwiftUI

struct IntroView: View {
    @ObservedObject var appState: AppState
    @State private var currentPage = 0 {
        didSet {
            if oldValue != currentPage {
                HapticAgent.shared.playSelection()
            }
        }
    }
    
    let pages = [
        OnboardingData(
            title: "Track & Reflect",
            description: "Log your moods effortlessly and write journals to understand your emotional journey.",
            icon: "heart.fill",
            color: Theme.primary
        ),
        OnboardingData(
            title: "Visualize Growth",
            description: "Identify patterns through interactive charts and receive AI-driven insights for your well-being.",
            icon: "chart.bar.fill",
            color: Theme.secondary
        ),
        OnboardingData(
            title: "Gamify Wellness",
            description: "Build healthy habits, maintain streaks, and earn rewards as you grow every day.",
            icon: "crown.fill",
            color: .orange
        )
    ]
    
    private var totalPageCount: Int { pages.count + 2 }
    
    private var activePageColor: Color {
        if currentPage < pages.count {
            return pages[currentPage].color
        } else if currentPage == 3 {
            return Theme.primary
        } else {
            return Theme.secondary
        }
    }
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPage(data: pages[index])
                            .tag(index)
                    }
                    
                    // New Page 3: Name Entry
                    VStack(spacing: 30) {
                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 80))
                            .foregroundColor(Theme.primary)
                            .shadow(color: Theme.primary.opacity(0.5), radius: 15)
                        
                        VStack(spacing: 15) {
                            Text("What should we call you?")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                            
                            TextField("Your Name", text: $appState.userName)
                                .font(.system(.title3, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Theme.textPrimary.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(Theme.textPrimary)
                                .padding(.horizontal, 40)
                        }
                    }
                    .tag(3)
                    
                    // New Page 4: Avatar Selection
                    VStack(spacing: 30) {
                        VStack(spacing: 10) {
                            Text("Pick your guide")
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(Theme.textPrimary)
                            
                            Text("Choose an avatar to accompany you")
                                .font(.subheadline)
                                .foregroundColor(Theme.textSecondary)
                        }
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(AvatarType.allCases) { avatar in
                                Button(action: {
                                    appState.selectedAvatar = avatar
                                }) {
                                    VStack {
                                        AvatarView(type: avatar, size: 60, addAnimation: appState.selectedAvatar == avatar)
                                            .padding(8)
                                            .background(
                                                Circle()
                                                    .stroke(Theme.secondary, lineWidth: appState.selectedAvatar == avatar ? 2 : 0)
                                            )
                                        
                                        Text(avatar.rawValue.capitalized)
                                            .font(.caption2)
                                            .foregroundColor(appState.selectedAvatar == avatar ? Theme.secondary : Theme.textSecondary)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                    }
                    .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                CustomPageIndicator(
                    currentPage: currentPage,
                    totalPages: totalPageCount,
                    activeColor: activePageColor
                )
                .padding(.bottom, 20)
                
                Button(action: {
                    if currentPage < totalPageCount - 1 {
                        withAnimation(.spring()) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            appState.hasFinishedOnboarding = true
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentPage == totalPageCount - 1 ? "Get Started" : "Next")
                            .font(.system(.headline, design: .rounded))
                        
                        if currentPage == totalPageCount - 1 {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                        }
                    }
                    .foregroundColor(Theme.overlayText) // Adapts to background
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [activePageColor, activePageColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(18)
                    .shadow(color: activePageColor.opacity(0.3), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    .animation(.easeInOut, value: currentPage)
                }
                .disabled(currentPage == 3 && appState.userName.trimmingCharacters(in: .whitespaces).isEmpty) // Disable Next if name is empty
                .opacity(currentPage == 3 && appState.userName.trimmingCharacters(in: .whitespaces).isEmpty ? 0.6 : 1.0)

            }
        }
    }
}

struct CustomPageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    let activeColor: Color
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? activeColor : Color.gray.opacity(0.3))
                    .frame(width: currentPage == index ? 30 : 10, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: currentPage)
            }
        }
    }
}

struct OnboardingData {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPage: View {
    let data: OnboardingData
    @State private var isVisible = false
    @State private var floating = false
    @State private var ringPulse = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Premium Icon Container with Floating + Pulse Animation
            ZStack {
                // Outer Pulse Ring
                Circle()
                    .stroke(data.color.opacity(0.15), lineWidth: 2)
                    .frame(width: 220, height: 220)
                    .scaleEffect(ringPulse ? 1.15 : 1.0)
                    .opacity(ringPulse ? 0 : 0.6)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: false), value: ringPulse)
                
                // Outer Glow
                Circle()
                    .fill(data.color.opacity(0.12))
                    .frame(width: 200, height: 200)
                    .blur(radius: 40)
                
                // Subtle Ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [data.color.opacity(0.3), data.color.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                    .frame(width: 160, height: 160)
                
                // Inner glow circle
                Circle()
                    .fill(data.color.opacity(0.08))
                    .frame(width: 130, height: 130)
                
                // The Icon
                Image(systemName: data.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(data.color)
                    .shadow(color: data.color.opacity(0.5), radius: 15)
            }
            .offset(y: floating ? -8 : 8)
            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: floating)
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0)
            
            VStack(spacing: 15) {
                Text(data.title)
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 15)
                
                Text(data.description)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 10)
            }
            
            Spacer()
            Spacer()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isVisible = true
            }
            floating = true
            ringPulse = true
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(appState: AppState())
    }
}
