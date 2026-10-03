import SwiftUI
import NaturalLanguage

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var userResponse: String = ""
    @State private var predictedMood: String = ""
    @State private var moodEmoji: String = "❓"
    @State private var showResult: Bool = false
    @State private var isAnalyzing: Bool = false
    @State private var showActivityPlayer: Bool = false
    @State private var showCharacter: Bool = false
    @State private var showCard: Bool = false
    @State private var selectedActivities: [String] = []
    @State private var showCelebration: Bool = false
    @State private var lastQuizScore: Int = 0
    
    // Time-based greeting
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    // private var greetingIcon: String {
    //     let hour = Calendar.current.component(.hour, from: Date())
    //     switch hour {
    //     case 5..<12: return "🌅"
    //     case 12..<17: return "☀️"
    //     case 17..<21: return "🌇"
    //     default: return "🌙"
    //     }
    // }
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            // Mood-responsive accent glow
            Theme.moodGradient(for: showResult ? moodEmoji : "😌")
                .ignoresSafeArea()
            
            // Ambient micro-particle drift
            AmbientParticleOverlay(moodEmoji: showResult ? moodEmoji : "😌")
                .ignoresSafeArea()
                .allowsHitTesting(false)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    // Personalized Greeting + Streak
                    AppHeader(
                        title: "\(SmartWelcomeAgent.shared.smartGreeting), \(appState.userName)",
                        subtitle: SmartWelcomeAgent.shared.smartSubtitle(lastMood: appState.moodHistory.first?.emoji),
                        trailingView: Group {
                            if appState.currentStreak > 0 {
                                HStack(spacing: 5) {
                                    Text("🔥")
                                        .font(.system(size: 18))
                                    Text("\(appState.currentStreak)")
                                        .font(.system(.headline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.warmGlow)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Theme.warmGlow.opacity(0.12)))
                                .overlay(Capsule().stroke(Theme.warmGlow.opacity(0.25), lineWidth: 1))
                                .streakPulse(isActive: appState.currentStreak >= 3)
                            }
                        }.asAnyView()
                    )
                    
                    // Stats and Wellness flow
                    VStack(spacing: 16) {
                        // Stats Row
                        HStack(spacing: 12) {
                            StatPill(icon: "checkmark.circle.fill", label: "\(appState.moodHistory.count) check-ins", color: Theme.secondary)
                            
                            if !appState.moodHistory.isEmpty {
                                StatPill(icon: "face.smiling.fill", label: "Last: \(appState.moodHistory.first?.emoji ?? "❓")", color: Theme.primary)
                            }
                        }
                        
                        // Quick Wellness Summary
                        let log = appState.todaysLog
                        HStack(spacing: 10) {
                            WellnessPill(icon: "drop.fill", value: "\(log.waterCups)/8", color: Color(red: 0.3, green: 0.65, blue: 1.0))
                            WellnessPill(icon: "moon.fill", value: String(format: "%.0fh", log.sleepHours), color: Color(red: 0.55, green: 0.35, blue: 0.95))
                            WellnessPill(icon: "flame.fill", value: "\(log.exerciseMinutes)m", color: Color(red: 1.0, green: 0.4, blue: 0.3))
                            WellnessPill(icon: "heart.fill", value: "\(log.overallScore)%", color: Theme.wellness)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Daily Intent + Micro-Insights
                    VStack(spacing: 8) {
                        DailyIntentCard()
                        HStack(spacing: 8) {
                            TimeInvestedPill()
                            Spacer()
                        }
                        RotatingInsightCard(moodHistory: appState.moodHistory)
                    }
                    .padding(.horizontal)
                    
                    // 3D Mood Cluster
                    FloatingEmotionCluster()
                        .floatingIdle(amplitude: 3, duration: 4)
                        .scaleEffect(showCharacter ? 1.0 : 0.5)
                        .opacity(showCharacter ? 1.0 : 0.0)
                        .offset(y: showCharacter ? 0 : 20)
                    
                    // Quiz-Style Mood Check-in Card
                    if !showResult {
                        MoodQuizCard(
                            isAnalyzing: $isAnalyzing,
                            onCompletion: { score in
                                lastQuizScore = score
                                analyzeQuizMood(score: score)
                            }
                        )
                        .offset(y: showCard ? 0 : 50)
                        .opacity(showCard ? 1.0 : 0.0)
                        .padding(.horizontal)
                    }
                    
                    // Result Section
                    if showResult {
                        VStack(spacing: 20) {
                            // AI Analysis Card
                            PremiumResultCard(
                                title: "AI Analysis",
                                subtitle: "Predicted Mood: \(predictedMood)",
                                content: moodQuote,
                                icon: "brain.head.profile",
                                accentColor: Theme.secondary
                            )
                            
                            // Mood Sparkline (7-day trend)
                            if appState.moodHistory.count >= 2 {
                                MoodSparkline(moodHistory: appState.moodHistory)
                            }
                            
                            // Activity Selection (Detailed Logging)
                            ActivitySelectionView(selectedActivities: $selectedActivities)
                                .onChange(of: selectedActivities) { _ in
                                    appState.updateLatestEntry(activities: selectedActivities)
                                }
                            
                            // Interactive Wellness Quest Card (Simplified Shortcut)
                            PremiumResultCard(
                                title: "Today's Quest",
                                subtitle: suggestedActivityTitle,
                                content: suggestedActivityDescription,
                                icon: suggestedActivityIcon,
                                accentColor: Theme.primary,
                                isQuest: true,
                                action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        appState.selectedTab = 1
                                    }
                                },
                                actionText: nil
                            )
                            
                            // Daily Wellness Tip
                            WellnessTipCard()
                            
                            // Retake Quiz Button
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    showResult = false
                                    showCelebration = false
                                    predictedMood = ""
                                    moodEmoji = "❓"
                                    selectedActivities = []
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.counterclockwise")
                                        .font(.subheadline)
                                    Text("Retake Quiz")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(Theme.textSecondary)
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                                .background(Theme.glassBackground)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Theme.divider, lineWidth: 1)
                                )
                            }
                        }
                        .transition(.asymmetric(insertion: .move(edge: .bottom).combined(with: .opacity), removal: .opacity))
                    }
                }
                .padding()
                .padding(.bottom, 80)
            }
            
            // Dynamic Island Simulation
            DynamicIslandSimulation(
                title: suggestedActivityTitle,
                subtitle: "Active Wellness Quest",
                icon: suggestedActivityIcon,
                isVisible: $showActivityPlayer
            )
            
            // Celebration Overlay
            if showCelebration {
                CelebrationEffect()
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                            withAnimation { showCelebration = false }
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $showActivityPlayer) {
            ActivityPlayerView(moodEmoji: moodEmoji, appState: appState)
        }
        .onAppear {
            if !showCharacter {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                    showCharacter = true
                }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.5)) {
                    showCard = true
                }
            }
        }
        .onChange(of: appState.showQuizCelebration) { newValue in
            if newValue {
                withAnimation {
                    showCelebration = true
                    appState.showQuizCelebration = false
                }
            }
        }
    }
    
    // Dynamic Activity Selection Logic
    private var suggestedGame: ActivityRecommendation? {
        MoodActivities.recommendations(for: moodEmoji, category: .games).first
    }
    
    private var suggestedActivityTitle: String {
        suggestedGame?.name ?? "Mindful Moment"
    }
    
    private var suggestedActivityDescription: String {
        suggestedGame?.description ?? "A simple exercise to reconnect with yourself."
    }
    
    private var suggestedActivityIcon: String {
        suggestedGame?.icon ?? "star.fill"
    }
    
    private var suggestedActivityButtonText: String {
        "Start Quest"
    }
    
    // Quiz-based Mood Analysis Logic
    private func analyzeQuizMood(score: Int) {
        isAnalyzing = true
        showResult = false
        selectedActivities = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            mapScoreToMood(score: score)
            
            withAnimation(.spring()) {
                isAnalyzing = false
                showResult = true
                
                // Trigger celebration for all completions
                appState.showQuizCelebration = true
                
                // Save to history
                appState.addHistoryEntry(
                    text: "Mood check-in via quiz (Score: \(score))",
                    mood: predictedMood,
                    emoji: moodEmoji,
                    level: nil
                )
            }
        }
    }
    
    private func mapScoreToMood(score: Int) {
        if score >= 19 {
            predictedMood = "Euphorically Happy"
            moodEmoji = "🌟"
        } else if score >= 17 {
            predictedMood = "Joyful & Positive"
            moodEmoji = "😊"
        } else if score >= 13 {
            predictedMood = "Balanced & Calm"
            moodEmoji = "😌"
        } else if score >= 9 {
            predictedMood = "Slightly Down"
            moodEmoji = "😕"
        } else {
            predictedMood = "Deeply Stressed or Sad"
            moodEmoji = "😔"
        }
    }
    
    private var moodQuote: String {
        switch moodEmoji {
        case "🌟": return "You're glowing! Keep riding this amazing wave of positivity."
        case "😊": return "It's a great day! Your energy is inspiring."
        case "😌": return "Inner peace is the greatest wealth. Stay centered."
        case "😕": return "Everyone has off days. Take a deep breath; this too shall pass."
        case "😔": return "It's okay not to be okay. Remember, you're not alone on this journey."
        default: return "Be kind to your mind."
        }
    }
}

// Small stat pill component
struct StatPill: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .cornerRadius(20)
        .overlay(
            Capsule()
                .stroke(color.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Wellness Pill
struct WellnessPill: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundColor(Theme.textPrimary.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            Capsule()
                .stroke(color.opacity(0.15), lineWidth: 0.5)
        )
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
