import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showCamera = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding = false
    
    // Define the onboarding slides
    let slides = [
        OnboardingSlide(
            title: "Welcome to NutriLenz",
            subtitle: "Your offline food-intelligence companion.",
            icon: "sparkles"
        ),
        OnboardingSlide(
            title: "True Offline Detection",
            subtitle: "CoreML identifies your meals without internet.",
            icon: "camera.viewfinder"
        ),
        OnboardingSlide(
            title: "Smart Vision Mapping",
            subtitle: "Detect multiple foods using Vision bounding boxes.",
            icon: "square.grid.3x3"
        ),
        OnboardingSlide(
            title: "Know Your Portion",
            subtitle: "Plate-area and pixel analysis for real-world portions.",
            icon: "circle.ruler"
        ),
        OnboardingSlide(
            title: "Macros Made Simple",
            subtitle: "Calories, protein, carbs, fats — instantly calculated.",
            icon: "chart.pie.fill"
        ),
        OnboardingSlide(
            title: "Health Score Insight",
            subtitle: "Get a 0–100 score for each meal.",
            icon: "gauge.with.dots.needle"
        ),
        OnboardingSlide(
            title: "Privacy at the Core",
            subtitle: "Your data stays offline in CoreData. No cloud. No accounts.",
            icon: "lock.shield.fill"
        ),
        OnboardingSlide(
            title: "Track Your Day",
            subtitle: "Beautiful charts summarize your nutrition easily.",
            icon: "chart.line.uptrend.xyaxes"
        ),
        OnboardingSlide(
            title: "Your Meal Library",
            subtitle: "Revisit past meals stored securely on your device.",
            icon: "clock.arrow.circlepath"
        ),
        OnboardingSlide(
            title: "Ready to Begin?",
            subtitle: "Tap below to start your journey.",
            icon: "play.circle.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Skip button in top right corner
                HStack {
                    Spacer()
                    Button("Skip") {
                        finishOnboarding()
                    }
                    .foregroundColor(.gray)
                    .font(.subheadline)
                    .padding()
                }
                
                // Page view for slides
                TabView(selection: $currentPage) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        OnboardingSlideView(slide: slides[index], isFinalSlide: index == slides.count - 1)
                            .tag(index)
                            .onAppear {
                                // Add animation when slide appears
                            }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onChange(of: currentPage) { _ in
                    // Handle page change if needed
                }
                
                // Progress indicators
                HStack(spacing: 8) {
                    ForEach(0..<slides.count, id: \.self) { index in
                        Circle()
                            .fill(currentPage == index ? 
                                  Color(hex: "#4EFFA8") : 
                                  Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Get Started button for the last slide
                if currentPage == slides.count - 1 {
                    Button(action: finishOnboarding) {
                        HStack {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundColor(.black)
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color(hex: "#4EFFA8"), Color(hex: "#00D1FF")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(hex: "#4EFFA8").opacity(0.6), radius: 10, x: 0, y: 0)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5), value: currentPage)
        }
        .environment(\.colorScheme, .dark) // Force dark mode
    }
    
    private func finishOnboarding() {
        hasCompletedOnboarding = true
        showCamera = true
    }
}

// Reusable slide component
struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    let isFinalSlide: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            // Icon with neon glow effect
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "#4EFFA8").opacity(0.2), Color.clear]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 140, height: 140)
                
                Image(systemName: slide.icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(hex: "#4EFFA8"))
                    .shadow(color: Color(hex: "#4EFFA8").opacity(0.8), radius: 15, x: 0, y: 0)
            }
            .padding(.top, 60)
            
            // Title
            Text(slide.title)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
            
            // Subtitle
            Text(slide.subtitle)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// Data model for onboarding slides
struct OnboardingSlide {
    let title: String
    let subtitle: String
    let icon: String
}

// Extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}