import SwiftUI

struct ImprovementSummaryView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateIn = false
    
    private var trendInfo: (icon: String, label: String, color: Color) {
        switch appState.moodTrend {
        case "improving": return ("arrow.up.right", "Improving", Color(red: 0.2, green: 0.9, blue: 0.5))
        case "declining": return ("arrow.down.right", "Declining", Color.red)
        default: return ("arrow.right", "Stable", Theme.accent)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(trendInfo.color.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: trendInfo.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(trendInfo.color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your Progress")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                    
                    HStack(spacing: 4) {
                        Text("Trend:")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                        Text(trendInfo.label)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(trendInfo.color)
                    }
                }
                
                Spacer()
                
                // Avg Score
                VStack(spacing: 2) {
                    Text(String(format: "%.1f", appState.averageMoodScore))
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    Text("avg mood")
                        .font(.system(size: 9, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            // Stats Grid
            HStack(spacing: 12) {
                SummaryStatBox(
                    label: "Check-ins",
                    value: "\(appState.moodHistory.count)",
                    icon: "checkmark.circle.fill",
                    color: Theme.primary
                )
                
                SummaryStatBox(
                    label: "Streak",
                    value: "\(appState.currentStreak)d",
                    icon: "flame.fill",
                    color: Theme.warmGlow
                )
                
                SummaryStatBox(
                    label: "Wellness",
                    value: "\(appState.weeklyWellnessAverage)%",
                    icon: "heart.fill",
                    color: Theme.wellness
                )
            }
            .opacity(animateIn ? 1 : 0)
            .offset(y: animateIn ? 0 : 10)
            
            // Top Activities
            if !appState.topMoodActivities.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Activities that boost your mood")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textSecondary)
                    
                    HStack(spacing: 8) {
                        ForEach(appState.topMoodActivities, id: \.self) { activity in
                            Text(activity)
                                .font(.system(.caption, design: .rounded))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Theme.secondary.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(Theme.secondary)
                        }
                    }
                }
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 10)
            }
            
            // Personalized Tip
            PersonalizedTip(appState: appState)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 10)
        }
        .padding(20)
        .background(
            ZStack {
                Theme.glassBackground
                RadialGradient(
                    colors: [trendInfo.color.opacity(0.08), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 250
                )
            }
        )
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(
                    LinearGradient(
                        colors: [trendInfo.color.opacity(0.3), trendInfo.color.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: trendInfo.color.opacity(0.1), radius: 12, y: 6)
        .onAppear {
            withAnimation(.spring(response: 0.6).delay(0.3)) {
                animateIn = true
            }
        }
    }
}

// MARK: - Summary Stat Box
struct SummaryStatBox: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.12))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Personalized Tip
struct PersonalizedTip: View {
    let appState: AppState
    
    private var tip: (emoji: String, text: String) {
        let log = appState.todaysLog
        let trend = appState.moodTrend
        
        if log.waterCups < 4 {
            return ("💧", "You're behind on water today. Try drinking a cup right now — it helps both focus and mood!")
        }
        if log.sleepHours > 0 && log.sleepHours < 6 {
            return ("😴", "Less than 6 hours of sleep affects mood significantly. Try to wind down earlier tonight.")
        }
        if log.exerciseMinutes == 0 && log.screenTimeHours > 4 {
            return ("🏃", "High screen time with no exercise? Even a 10-minute walk can reset your energy.")
        }
        if trend == "declining" {
            return ("🌈", "Your mood has been dipping. Consider trying a new activity from the Discover tab!")
        }
        if trend == "improving" {
            return ("⭐", "Your mood trend is positive! Whatever you've been doing, keep it up!")
        }
        if appState.currentStreak >= 7 {
            return ("🔥", "Amazing \(appState.currentStreak)-day streak! Consistency is the key to wellbeing.")
        }
        return ("💡", "Track your wellness daily to see patterns in what affects your mood the most.")
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(tip.emoji)
                .font(.title3)
            
            Text(tip.text)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(Theme.textPrimary.opacity(0.8))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(Theme.glassBackground)
        .cornerRadius(14)
    }
}
