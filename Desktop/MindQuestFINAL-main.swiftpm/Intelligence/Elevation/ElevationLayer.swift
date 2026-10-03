import SwiftUI

// ═══════════════════════════════════════════════════════════════
// MARK: - PHASE 1: Emotional Warmth & Intelligent Welcome
// ═══════════════════════════════════════════════════════════════

/// SmartWelcomeAgent — time-aware, mood-aware greeting intelligence
@MainActor
final class SmartWelcomeAgent: ObservableObject {
    static let shared = SmartWelcomeAgent()
    
    @Published var showWelcomeBack: Bool = false
    @Published var welcomeBackMessage: String = ""
    @Published var suggestedActivity: String = ""
    
    private init() {
        checkReturnExperience()
    }
    
    var smartGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<21: return "Good Evening"
        default: return "Good Night"
        }
    }
    
    var greetingEmoji: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "☀️"
        case 12..<17: return "🌤️"
        case 17..<21: return "🌆"
        default: return "🌙"
        }
    }
    
    /// Mood-aware subtitle based on last logged mood
    func smartSubtitle(lastMood: String?) -> String {
        guard let mood = lastMood else { return "How are you feeling today?" }
        switch mood {
        case "😔", "Deeply Stressed or Sad":
            return "Remember, it's okay to take it slow 💜"
        case "😕", "Slightly Down":
            return "Every step counts. You're doing great 🌱"
        case "😌", "Balanced & Calm":
            return "Maintaining balance — keep it going ✨"
        case "😊", "Joyful & Positive":
            return "Your energy is inspiring! 🌟"
        case "🌟", "Euphorically Happy":
            return "What a beautiful mindset! ☀️"
        default:
            return "How are you feeling today?"
        }
    }
    
    /// Gentle return experience (2+ day inactivity)
    private func checkReturnExperience() {
        let lastOpenKey = "last_app_open_date"
        let lastOpen = UserDefaults.standard.object(forKey: lastOpenKey) as? Date
        UserDefaults.standard.set(Date(), forKey: lastOpenKey)
        
        guard let last = lastOpen else { return }
        let daysSince = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
        
        if daysSince >= 2 {
            welcomeBackMessage = daysSince >= 7
                ? "It's been a while! We missed you 💜"
                : "Welcome back! Ready to continue your journey?"
            suggestedActivity = daysSince >= 7
                ? "Start with a quick breathing exercise"
                : "How about a mood check-in?"
            showWelcomeBack = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                withAnimation(.easeOut(duration: 0.5)) {
                    self.showWelcomeBack = false
                }
            }
        }
    }
}

// MARK: - Welcome Back Overlay (non-intrusive)
struct WelcomeBackOverlay: View {
    @ObservedObject var agent = SmartWelcomeAgent.shared
    @State private var appear = false
    
    var body: some View {
        if agent.showWelcomeBack {
            VStack {
                VStack(spacing: 8) {
                    Text(agent.welcomeBackMessage)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.overlayText)
                    
                    Text(agent.suggestedActivity)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(Theme.overlayText.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.overlayBackground)
                )
                .shadow(color: Theme.secondary.opacity(0.2), radius: 10)
                .padding(.horizontal, 24)
                .padding(.top, 70)
                .scaleEffect(appear ? 1 : 0.8)
                .opacity(appear ? 1 : 0)
                
                Spacer()
            }
            .allowsHitTesting(false)
            .onAppear {
                HapticAgent.shared.playImpact(.soft, intensity: 0.4)
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    appear = true
                }
            }
        }
    }
}

// MARK: - Daily Intent Prompt
struct DailyIntentCard: View {
    @State private var todaysIntent: String = UserDefaults.standard.string(forKey: "daily_intent_\(Calendar.current.component(.day, from: Date()))") ?? ""
    @State private var isEditing = false
    @FocusState private var isFocused: Bool
    
    private var hasSetToday: Bool { !todaysIntent.isEmpty }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkle")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text("Today's Intention")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                if hasSetToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Theme.secondary)
                        .font(.caption)
                }
            }
            
            if isEditing || !hasSetToday {
                HStack {
                    TextField("e.g. Stay present and grateful", text: $todaysIntent)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .focused($isFocused)
                        .onSubmit { saveIntent() }
                    
                    if !todaysIntent.isEmpty {
                        Button(action: { saveIntent() }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(Theme.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Theme.glassBackground)
                .cornerRadius(10)
            } else {
                Text("\"" + todaysIntent + "\"")
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .italic()
                    .foregroundColor(Theme.textPrimary.opacity(0.8))
                    .onTapGesture {
                        isEditing = true
                        isFocused = true
                    }
            }
        }
        .padding(14)
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.yellow.opacity(0.1), lineWidth: 0.5)
        )
    }
    
    private func saveIntent() {
        let key = "daily_intent_\(Calendar.current.component(.day, from: Date()))"
        UserDefaults.standard.set(todaysIntent, forKey: key)
        isEditing = false
        isFocused = false
        HapticAgent.shared.playNotification(.success)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - PHASE 2: Living Dashboard Sub-Features
// ═══════════════════════════════════════════════════════════════

// MARK: - Animated Time Invested Counter
struct TimeInvestedPill: View {
    @ObservedObject var engagement = EngagementAgent.shared
    @State private var displayMinutes: Int = 0
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "hourglass")
                .font(.caption2)
                .foregroundColor(Theme.primary)
            Text("\(displayMinutes) min today")
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textSecondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Theme.primary.opacity(0.08))
        .cornerRadius(8)
        .onAppear {
            // Animated count-up
            let target = engagement.timeInvestedToday
            if target > 0 {
                Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                    if displayMinutes < target {
                        displayMinutes += 1
                    } else {
                        timer.invalidate()
                    }
                }
            }
        }
    }
}

// MARK: - Rotating Micro-Insight Cards
struct RotatingInsightCard: View {
    let moodHistory: [MoodEntry]
    @State private var currentIndex = 0
    @State private var opacity: Double = 1
    
    private var insights: [String] {
        var list: [String] = []
        let count = moodHistory.count
        
        if count >= 3 {
            list.append("You've been consistent — \(count) check-ins logged! 📊")
        }
        
        let streak = EngagementAgent.shared.moodStreak
        if streak > 0 {
            list.append("Current streak: \(streak) day\(streak > 1 ? "s" : "") of self-awareness 🔥")
        }
        
        let level = EngagementAgent.shared.currentLevel
        list.append("Level \(level): \(EngagementAgent.shared.levelTitle) ✨")
        
        let focus = FocusAgent.shared.totalFocusMinutes
        if focus > 0 {
            list.append("You've invested \(focus) minutes in focused sessions 🧠")
        }
        
        let hydration = HydrationAgent.shared.hydrationStreak
        if hydration > 0 {
            list.append("\(HydrationAgent.shared.hydrationLevel) — \(hydration) day streak 💧")
        }
        
        if list.isEmpty {
            list.append("Start your journey — every step matters 🌱")
        }
        
        return list
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.caption)
            
            Text(insights[currentIndex % insights.count])
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Theme.cardBackground)
        .cornerRadius(10)
        .opacity(opacity)
        .onAppear {
            guard insights.count > 1 else { return }
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                withAnimation(.easeOut(duration: 0.3)) { opacity = 0 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    currentIndex = (currentIndex + 1) % insights.count
                    withAnimation(.easeIn(duration: 0.3)) { opacity = 1 }
                }
            }
        }
    }
}

// MARK: - Streak Pulse Animation
struct StreakPulseModifier: ViewModifier {
    let isActive: Bool
    @State private var pulse = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                isActive ?
                    Circle()
                        .stroke(Theme.warmGlow.opacity(pulse ? 0 : 0.4), lineWidth: 2)
                        .scaleEffect(pulse ? 1.8 : 1)
                        .animation(.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: pulse)
                        .onAppear { pulse = true }
                    : nil
            )
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - PHASE 3: Journey Storytelling
// ═══════════════════════════════════════════════════════════════

// MARK: - Growth Highlight of the Week
struct GrowthHighlightCard: View {
    let moodHistory: [MoodEntry]
    @State private var appear = false
    
    private var highlight: (icon: String, text: String, color: Color) {
        let thisWeek = moodHistory.filter {
            Calendar.current.isDate($0.date, equalTo: Date(), toGranularity: .weekOfYear)
        }
        
        if thisWeek.count >= 5 {
            return ("trophy.fill", "Outstanding! \(thisWeek.count) check-ins this week", .yellow)
        } else if thisWeek.count >= 3 {
            return ("arrow.up.forward", "Great progress — \(thisWeek.count) check-ins this week", Theme.secondary)
        } else if thisWeek.count >= 1 {
            return ("leaf.fill", "You showed up \(thisWeek.count) time\(thisWeek.count > 1 ? "s" : "") this week", Theme.wellness)
        }
        return ("sparkles", "Your first check-in this week is waiting!", Theme.primary)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(highlight.color.opacity(0.12))
                    .frame(width: 38, height: 38)
                Image(systemName: highlight.icon)
                    .foregroundColor(highlight.color)
                    .font(.system(size: 15))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Growth Highlight")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                Text(highlight.text)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(highlight.color.opacity(0.15), lineWidth: 0.5)
                )
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 10)
        .onAppear {
            withAnimation(.spring(response: 0.5).delay(0.3)) { appear = true }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - PHASE 4: Wellness Intelligence
// ═══════════════════════════════════════════════════════════════

// MARK: - Today's Best Action Card
struct TodaysBestActionCard: View {
    @EnvironmentObject var appState: AppState
    @State private var appear = false
    
    private var recommendation: (icon: String, title: String, subtitle: String, color: Color) {
        let log = appState.todaysLog
        
        if log.waterCups < 4 {
            return ("drop.fill", "Hydrate First", "You've had \(log.waterCups)/8 cups today", Color(red: 0.3, green: 0.65, blue: 1.0))
        }
        if log.sleepHours < 6 {
            return ("moon.fill", "Prioritize Rest", "Sleep is your foundation tonight", Color(red: 0.55, green: 0.35, blue: 0.95))
        }
        if log.exerciseMinutes < 10 {
            return ("figure.walk", "Move Your Body", "Even 10 minutes makes a difference", Theme.fitness)
        }
        if appState.moodHistory.isEmpty || !Calendar.current.isDateInToday(appState.moodHistory.first?.date ?? Date.distantPast) {
            return ("face.smiling", "Check In", "How are you feeling right now?", Theme.primary)
        }
        return ("sparkles", "You're On Track", "Keep up the great work today!", Theme.secondary)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(recommendation.color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: recommendation.icon)
                    .foregroundColor(recommendation.color)
                    .font(.system(size: 16))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("Today's Best Action")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(recommendation.color)
                Text(recommendation.title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
                Text(recommendation.subtitle)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundColor(Theme.textSecondary)
        }
        .padding(14)
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(recommendation.color.opacity(0.12), lineWidth: 0.5)
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 8)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { appear = true }
        }
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - PHASE 5: Discover Surprise Layer
// ═══════════════════════════════════════════════════════════════

// MARK: - Daily Mystery Activity
struct MysteryActivityCard: View {
    @State private var isRevealed = false
    @State private var shimmer = false
    
    private var todaysMystery: (name: String, icon: String, description: String, color: Color) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let mysteries = [
            ("Gratitude Pause", "heart.circle.fill", "Name 3 things you're grateful for right now", Theme.wellness),
            ("Mindful Breathing", "wind", "Take 5 deep breaths with eyes closed", Theme.secondary),
            ("Body Scan", "figure.stand", "Notice how each part of your body feels", Theme.fitness),
            ("Creative Moment", "paintbrush.fill", "Draw or write something spontaneous", Theme.accent),
            ("Kind Word", "text.bubble.fill", "Send a kind message to someone", Theme.primary),
            ("Nature Notice", "leaf.fill", "Step outside and observe nature for 2 minutes", .green),
            ("Memory Lane", "photo.fill", "Look at a happy photo and relive the feeling", .orange),
        ]
        return mysteries[dayOfYear % mysteries.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
                Text("Mystery Activity")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text("Daily")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Theme.glassBackground)
                    .cornerRadius(6)
            }
            
            if isRevealed {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(todaysMystery.color.opacity(0.12))
                            .frame(width: 36, height: 36)
                        Image(systemName: todaysMystery.icon)
                            .foregroundColor(todaysMystery.color)
                            .font(.system(size: 14))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(todaysMystery.name)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        Text(todaysMystery.description)
                            .font(.system(size: 11, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                Button(action: {
                    HapticAgent.shared.playImpact(.medium)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isRevealed = true
                    }
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "sparkles")
                            .foregroundColor(.yellow)
                        Text("Tap to Reveal")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Theme.glassBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [.yellow.opacity(shimmer ? 0.1 : 0), .clear],
                                            startPoint: shimmer ? .trailing : .leading,
                                            endPoint: shimmer ? .leading : .trailing
                                        )
                                    )
                            )
                    )
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                        shimmer = true
                    }
                }
            }
        }
        .padding(14)
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.yellow.opacity(0.1), lineWidth: 0.5)
        )
    }
}

// MARK: - Mini Challenge System (3-Day)
struct MiniChallengeCard: View {
    @State private var challengeDay: Int
    @State private var completed: Bool
    
    private let challenges = [
        ("Log mood 3 days in a row", "face.smiling.fill", Theme.primary),
        ("Hit water goal 3 days straight", "drop.fill", Color(red: 0.3, green: 0.65, blue: 1.0)),
        ("Complete 3 activities this week", "figure.run", Theme.fitness),
        ("Try 3 different soundscapes", "music.note.list", Theme.accent),
    ]
    
    init() {
        let weekOfYear = Calendar.current.component(.weekOfYear, from: Date())
        _challengeDay = State(initialValue: Calendar.current.component(.weekday, from: Date()) - 1)
        let idx = weekOfYear % 4
        _completed = State(initialValue: UserDefaults.standard.bool(forKey: "challenge_\(weekOfYear)_done"))
    }
    
    private var currentChallenge: (String, String, Color) {
        let week = Calendar.current.component(.weekOfYear, from: Date())
        return challenges[week % challenges.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "flag.fill")
                    .foregroundColor(currentChallenge.2)
                    .font(.caption)
                Text("Weekly Challenge")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
            }
            
            HStack(spacing: 10) {
                Image(systemName: currentChallenge.1)
                    .foregroundColor(currentChallenge.2)
                    .font(.system(size: 14))
                
                Text(currentChallenge.0)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
            }
            
            // Progress dots
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { day in
                    Circle()
                        .fill(day < min(challengeDay, 3) ? currentChallenge.2 : Theme.textPrimary.opacity(0.1))
                        .frame(width: 10, height: 10)
                        .overlay(
                            day < min(challengeDay, 3) ?
                            Image(systemName: "checkmark")
                                .font(.system(size: 6, weight: .bold))
                                .foregroundColor(.white) : nil
                        )
                }
                Text("Day \(min(challengeDay + 1, 3))/3")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
        }
        .padding(14)
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(currentChallenge.2.opacity(0.12), lineWidth: 0.5)
        )
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - PHASE 6: Profile Depth
// ═══════════════════════════════════════════════════════════════

// MARK: - Wellness DNA Ring
struct WellnessDNARing: View {
    let waterScore: Double  // 0-1
    let sleepScore: Double  // 0-1
    let exerciseScore: Double  // 0-1
    let moodScore: Double  // 0-1
    @State private var animateRings = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "dna")
                    .foregroundColor(Theme.secondary)
                    .font(.caption)
                Text("Wellness DNA")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
            }
            
            ZStack {
                // Water ring (outer)
                Circle()
                    .stroke(Color(red: 0.3, green: 0.65, blue: 1.0).opacity(0.1), lineWidth: 5)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: animateRings ? waterScore : 0)
                    .stroke(Color(red: 0.3, green: 0.65, blue: 1.0), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                // Sleep ring
                Circle()
                    .stroke(Color(red: 0.55, green: 0.35, blue: 0.95).opacity(0.1), lineWidth: 5)
                    .frame(width: 64, height: 64)
                Circle()
                    .trim(from: 0, to: animateRings ? sleepScore : 0)
                    .stroke(Color(red: 0.55, green: 0.35, blue: 0.95), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 64, height: 64)
                    .rotationEffect(.degrees(-90))
                
                // Exercise ring
                Circle()
                    .stroke(Color(red: 1.0, green: 0.4, blue: 0.3).opacity(0.1), lineWidth: 5)
                    .frame(width: 48, height: 48)
                Circle()
                    .trim(from: 0, to: animateRings ? exerciseScore : 0)
                    .stroke(Color(red: 1.0, green: 0.4, blue: 0.3), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))
                
                // Mood core
                Circle()
                    .fill(Theme.secondary.opacity(animateRings ? moodScore * 0.3 : 0))
                    .frame(width: 30, height: 30)
                Image(systemName: "heart.fill")
                    .foregroundColor(Theme.wellness)
                    .font(.system(size: 10))
            }
            
            // Legend
            HStack(spacing: 14) {
                DNALegendDot(color: Color(red: 0.3, green: 0.65, blue: 1.0), label: "Water")
                DNALegendDot(color: Color(red: 0.55, green: 0.35, blue: 0.95), label: "Sleep")
                DNALegendDot(color: Color(red: 1.0, green: 0.4, blue: 0.3), label: "Move")
                DNALegendDot(color: Theme.wellness, label: "Mood")
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                animateRings = true
            }
        }
    }
}

private struct DNALegendDot: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundColor(Theme.textSecondary)
        }
    }
}

// MARK: - Consistency Velocity Meter
struct ConsistencyVelocityMeter: View {
    let checkInCount: Int
    let daysSinceJoin: Int
    @State private var fillWidth: CGFloat = 0
    
    private var velocity: Double {
        guard daysSinceJoin > 0 else { return 0 }
        return min(Double(checkInCount) / Double(daysSinceJoin), 1.0)
    }
    
    private var velocityLabel: String {
        switch velocity {
        case 0.8...1.0: return "Exceptional"
        case 0.6..<0.8: return "Strong"
        case 0.4..<0.6: return "Growing"
        case 0.2..<0.4: return "Building"
        default: return "Starting"
        }
    }
    
    private var velocityColor: Color {
        switch velocity {
        case 0.8...1.0: return .yellow
        case 0.6..<0.8: return Theme.secondary
        case 0.4..<0.6: return Theme.wellness
        default: return Theme.textSecondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "gauge.medium")
                    .foregroundColor(velocityColor)
                    .font(.caption)
                Text("Consistency Velocity")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Spacer()
                Text(velocityLabel)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(velocityColor)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.glassBackground)
                        .frame(height: 6)
                    Capsule()
                        .fill(
                            LinearGradient(colors: [velocityColor.opacity(0.6), velocityColor], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: fillWidth, height: 6)
                        .shadow(color: velocityColor.opacity(0.3), radius: 4)
                }
                .onAppear {
                    withAnimation(.easeOut(duration: 1.0).delay(0.4)) {
                        fillWidth = geo.size.width * velocity
                    }
                }
            }
            .frame(height: 6)
        }
        .padding(14)
        .background(Theme.cardBackground)
        .cornerRadius(14)
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - PHASE 7: Engagement Elegance
// ═══════════════════════════════════════════════════════════════

// MARK: - Rare Encouragement Injection
@MainActor
final class EncouragementAgent: ObservableObject {
    static let shared = EncouragementAgent()
    
    @Published var showMessage = false
    @Published var currentMessage = ""
    
    private let messages = [
        "You're building something beautiful 🌿",
        "Consistency is your superpower ⚡",
        "Small steps lead to big transformations ✨",
        "Your well-being journey matters 💜",
        "Growth looks good on you 🌱",
        "Today's effort is tomorrow's strength 💪",
        "You showed up — that's what counts 🌟",
    ]
    
    private init() {}
    
    func maybeShowMessage() {
        // 15% chance each app open
        guard Int.random(in: 0..<100) < 15 else { return }
        currentMessage = messages.randomElement() ?? ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.spring(response: 0.5)) {
                self.showMessage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation(.easeOut(duration: 0.5)) {
                    self.showMessage = false
                }
            }
        }
    }
}

struct EncouragementOverlay: ViewModifier {
    @ObservedObject var agent = EncouragementAgent.shared
    
    func body(content: Content) -> some View {
        content.overlay(
            VStack {
                Spacer()
                if agent.showMessage {
                    HStack(spacing: 8) {
                        Text("💜")
                        Text(agent.currentMessage)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.overlayText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Capsule().fill(Theme.overlayBackground))
                    .shadow(color: Theme.secondary.opacity(0.2), radius: 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 140)
                }
            }
            .animation(.spring(response: 0.4), value: agent.showMessage)
        )
    }
}

extension View {
    func streakPulse(isActive: Bool) -> some View {
        modifier(StreakPulseModifier(isActive: isActive))
    }
    
    func encouragementOverlay() -> some View {
        modifier(EncouragementOverlay())
    }
}

// ═══════════════════════════════════════════════════════════════
// MARK: - EXTRA: Dynamic Island Simulation
// ═══════════════════════════════════════════════════════════════

/// A premium simulated Dynamic Island for "Live Activity" feel during sessions
struct DynamicIslandSimulation: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isVisible: Bool
    
    @State private var expanded = false
    @State private var appear = false
    
    var body: some View {
        VStack {
            if isVisible {
                HStack(spacing: 12) {
                    // Left Icon
                    ZStack {
                        Circle()
                            .fill(Theme.secondary.opacity(0.2))
                            .frame(width: 26, height: 26)
                        Image(systemName: icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Theme.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.overlayText)
                        Text(subtitle)
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(Theme.overlayText.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    // Live indicator
                    HStack(spacing: 3) {
                        ForEach(0..<3) { i in
                            RoundedRectangle(cornerRadius: 1)
                                .fill(Theme.secondary)
                                .frame(width: 2, height: CGFloat.random(in: 6...12))
                                .opacity(appear ? 1 : 0.3)
                                .animation(.easeInOut(duration: 0.5).repeatForever().delay(Double(i) * 0.1), value: appear)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(width: expanded ? 240 : 180)
                .background(
                    Capsule()
                        .fill(Theme.overlayBackground)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                )
                .padding(.top, 10)
                .scaleEffect(appear ? 1 : 0.8)
                .opacity(appear ? 1 : 0)
                .onAppear {
                    appear = true
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                        expanded = true
                    }
                }
            }
            Spacer()
        }
        .allowsHitTesting(false)
    }
}
