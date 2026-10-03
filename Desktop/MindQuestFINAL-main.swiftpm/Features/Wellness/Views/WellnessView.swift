import SwiftUI

struct WellnessView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateRings = false
    @State private var showMealSheet = false
    @State private var expandedTracker: String? = nil
    
    private var todayLog: DailyWellnessLog {
        appState.todaysLog
    }
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            // Accent glow
            RadialGradient(
                colors: [Theme.wellness.opacity(0.06), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Header
                    AppHeader(
                        title: "Wellness",
                        subtitle: dayString,
                        trailingView: HStack(spacing: 12) {
                            // Streak info
                            if appState.wellnessStreak > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "flame.fill")
                                        .font(.caption2)
                                        .foregroundColor(Theme.warmGlow)
                                    Text("\(appState.wellnessStreak)")
                                        .font(.system(.caption2, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(Theme.warmGlow)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Theme.warmGlow.opacity(0.1))
                                .cornerRadius(8)
                            }
                            
                            // Overall Score Ring
                            ZStack {
                                ProgressRing(
                                    progress: Double(todayLog.overallScore) / 100.0,
                                    color: scoreColor,
                                    lineWidth: 4,
                                    size: 44
                                )
                                .opacity(animateRings ? 1 : 0.3)
                                
                                Text("\(todayLog.overallScore)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }.asAnyView()
                    )
                    
                    // MARK: - Top Row Rings
                    HStack(spacing: 14) {
                        MiniRingCard(
                            title: "Water",
                            value: "\(todayLog.waterCups)/8",
                            icon: "drop.fill",
                            progress: todayLog.waterProgress,
                            color: Color(red: 0.3, green: 0.65, blue: 1.0),
                            animate: animateRings
                        )
                        
                        MiniRingCard(
                            title: "Sleep",
                            value: String(format: "%.1fh", todayLog.sleepHours),
                            icon: "moon.fill",
                            progress: todayLog.sleepProgress,
                            color: Color(red: 0.55, green: 0.35, blue: 0.95),
                            animate: animateRings
                        )
                        
                        MiniRingCard(
                            title: "Exercise",
                            value: "\(todayLog.exerciseMinutes)m",
                            icon: "flame.fill",
                            progress: todayLog.exerciseProgress,
                            color: Color(red: 1.0, green: 0.4, blue: 0.3),
                            animate: animateRings
                        )
                    }
                    
                    // Today's Best Action
                    TodaysBestActionCard()
                    
                    // MARK: - Water Tracker
                    WellnessTrackerCard(
                        title: "Water Intake",
                        subtitle: "\(todayLog.waterCups) of 8 cups",
                        icon: "drop.fill",
                        color: Color(red: 0.3, green: 0.65, blue: 1.0),
                        isExpanded: expandedTracker == "water"
                    ) {
                        HapticAgent.shared.playImpact(.soft, intensity: 0.4)
                        withAnimation(.spring()) { expandedTracker = expandedTracker == "water" ? nil : "water" }
                    } content: {
                        VStack(spacing: 16) {
                            // Water drops visual
                            HStack(spacing: 8) {
                                ForEach(0..<8, id: \.self) { i in
                                    Image(systemName: i < todayLog.waterCups ? "drop.fill" : "drop")
                                        .font(.title3)
                                        .foregroundColor(i < todayLog.waterCups ? Color(red: 0.3, green: 0.65, blue: 1.0) : Theme.textSecondary.opacity(0.4))
                                        .scaleEffect(i < todayLog.waterCups ? 1.1 : 0.9)
                                        .shadow(color: i < todayLog.waterCups ? Color(red: 0.3, green: 0.65, blue: 1.0).opacity(0.4) : .clear, radius: 5)
                                }
                            }
                            
                            HStack(spacing: 20) {
                                Button(action: {
                                    HapticAgent.shared.playImpact(.soft, intensity: 0.5)
                                    appState.updateTodaysLog { log in
                                        log.waterCups = max(0, log.waterCups - 1)
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                Text("\(todayLog.waterCups) cups")
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textPrimary)
                                
                                Button(action: {
                                    HapticAgent.shared.playImpact(.light)
                                    appState.updateTodaysLog { log in
                                        log.waterCups = min(16, log.waterCups + 1)
                                    }
                                    HydrationAgent.shared.evaluateHydration(cups: appState.todaysLog.waterCups)
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(Color(red: 0.3, green: 0.65, blue: 1.0))
                                }
                            }
                        }
                    }
                    
                    // MARK: - Sleep Tracker
                    WellnessTrackerCard(
                        title: "Sleep Tracker",
                        subtitle: String(format: "%.1f hours", todayLog.sleepHours),
                        icon: "moon.fill",
                        color: Color(red: 0.55, green: 0.35, blue: 0.95),
                        isExpanded: expandedTracker == "sleep"
                    ) {
                        HapticAgent.shared.playImpact(.soft, intensity: 0.4)
                        withAnimation(.spring()) { expandedTracker = expandedTracker == "sleep" ? nil : "sleep" }
                    } content: {
                        VStack(spacing: 16) {
                            // Moon phases
                            HStack(spacing: 12) {
                                ForEach(1...5, id: \.self) { quality in
                                    VStack(spacing: 4) {
                                        Text(moonPhase(quality))
                                            .font(.title2)
                                            .opacity(quality <= todayLog.sleepQuality ? 1.0 : 0.3)
                                        Text("\(quality)")
                                            .font(.system(size: 10, design: .rounded))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    .onTapGesture {
                                        HapticAgent.shared.playImpact(.soft, intensity: 0.6)
                                        appState.updateTodaysLog { log in
                                            log.sleepQuality = quality
                                        }
                                    }
                                }
                            }
                            
                            VStack(spacing: 8) {
                                Text(String(format: "%.1f hours", todayLog.sleepHours))
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textPrimary)
                                
                                Slider(value: Binding(
                                    get: { todayLog.sleepHours },
                                    set: { val in appState.updateTodaysLog { $0.sleepHours = val } }
                                ), in: 0...14, step: 0.5)
                                .tint(Color(red: 0.55, green: 0.35, blue: 0.95))
                                
                                HStack {
                                    Text("0h").font(.caption2).foregroundColor(Theme.textSecondary)
                                    Spacer()
                                    Text("14h").font(.caption2).foregroundColor(Theme.textSecondary)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Meals Log
                    WellnessTrackerCard(
                        title: "Meals",
                        subtitle: "\(todayLog.meals.count) logged",
                        icon: "fork.knife",
                        color: Color(red: 0.2, green: 0.8, blue: 0.4),
                        isExpanded: expandedTracker == "meals"
                    ) {
                        withAnimation(.spring()) { expandedTracker = expandedTracker == "meals" ? nil : "meals" }
                    } content: {
                        VStack(spacing: 12) {
                            // Meal type quick buttons
                            HStack(spacing: 10) {
                                ForEach(MealType.allCases, id: \.rawValue) { type in
                                    let hasLogged = todayLog.meals.contains { $0.type == type }
                                    Button(action: {
                                        if !hasLogged {
                                            appState.updateTodaysLog { log in
                                                log.meals.append(MealEntry(type: type, description: type.rawValue, time: Date()))
                                            }
                                        }
                                    }) {
                                        VStack(spacing: 6) {
                                            Text(type.emoji)
                                                .font(.title2)
                                            Text(type.rawValue)
                                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                                .foregroundColor(hasLogged ? Theme.textPrimary : Theme.textSecondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(hasLogged ? Color.green.opacity(0.15) : Theme.glassBackground)
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(hasLogged ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                            
                            if !todayLog.meals.isEmpty {
                                ForEach(todayLog.meals) { meal in
                                    HStack {
                                        Text(meal.type.emoji)
                                        Text(meal.type.rawValue)
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(Theme.textPrimary)
                                        Spacer()
                                        Text(timeString(meal.time))
                                            .font(.system(.caption, design: .rounded))
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    .padding(10)
                                    .background(Theme.glassBackground)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                    
                    // MARK: - Study & Work Hours
                    HStack(spacing: 14) {
                        TimeTrackerMini(
                            title: "Study",
                            hours: todayLog.studyHours,
                            icon: "book.fill",
                            color: Theme.puzzles,
                            onIncrement: { appState.updateTodaysLog { $0.studyHours = min(24, $0.studyHours + 0.5) } },
                            onDecrement: { appState.updateTodaysLog { $0.studyHours = max(0, $0.studyHours - 0.5) } }
                        )
                        
                        TimeTrackerMini(
                            title: "Work",
                            hours: todayLog.workHours,
                            icon: "briefcase.fill",
                            color: Theme.accent,
                            onIncrement: { appState.updateTodaysLog { $0.workHours = min(24, $0.workHours + 0.5) } },
                            onDecrement: { appState.updateTodaysLog { $0.workHours = max(0, $0.workHours - 0.5) } }
                        )
                    }
                    
                    // MARK: - Screen Time & Exercise
                    HStack(spacing: 14) {
                        TimeTrackerMini(
                            title: "Screen",
                            hours: todayLog.screenTimeHours,
                            icon: "iphone",
                            color: Color.red.opacity(0.8),
                            onIncrement: { appState.updateTodaysLog { $0.screenTimeHours = min(24, $0.screenTimeHours + 0.5) } },
                            onDecrement: { appState.updateTodaysLog { $0.screenTimeHours = max(0, $0.screenTimeHours - 0.5) } }
                        )
                        
                        TimeTrackerMini(
                            title: "Exercise",
                            hours: Double(todayLog.exerciseMinutes) / 60.0,
                            icon: "figure.run",
                            color: Theme.health,
                            isMinutes: true,
                            minutes: todayLog.exerciseMinutes,
                            onIncrement: { appState.updateTodaysLog { $0.exerciseMinutes = min(300, $0.exerciseMinutes + 5) } },
                            onDecrement: { appState.updateTodaysLog { $0.exerciseMinutes = max(0, $0.exerciseMinutes - 5) } }
                        )
                    }
                    
                    // MARK: - Daily Insight
                    DailyInsightCard(log: todayLog)
                }
                .padding()
                .padding(.bottom, 90)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8).delay(0.3)) {
                animateRings = true
            }
        }
    }
    
    private var dayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
    
    private var scoreColor: Color {
        let score = todayLog.overallScore
        if score >= 75 { return Color(red: 0.2, green: 0.9, blue: 0.5) }
        if score >= 50 { return Theme.accent }
        if score >= 25 { return Color.orange }
        return Color.red
    }
    
    private func moonPhase(_ quality: Int) -> String {
        switch quality {
        case 1: return "🌑"
        case 2: return "🌒"
        case 3: return "🌓"
        case 4: return "🌔"
        case 5: return "🌕"
        default: return "🌓"
        }
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Mini Ring Card
struct MiniRingCard: View {
    let title: String
    let value: String
    let icon: String
    let progress: Double
    let color: Color
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ProgressRing(
                progress: animate ? progress : 0,
                color: color,
                lineWidth: 5,
                size: 50
            )
            .overlay(
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
            )
            
            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Theme.textPrimary)
            
            Text(title)
                .font(.system(size: 10, design: .rounded))
                .foregroundColor(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Theme.glassBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .animation(.spring(response: 1.0), value: animate)
    }
}

// MARK: - Wellness Tracker Card
struct WellnessTrackerCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let isExpanded: Bool
    let toggleAction: () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row — always visible
            Button(action: toggleAction) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.12))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: icon)
                            .font(.system(size: 18))
                            .foregroundColor(color)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.textPrimary)
                        
                        Text(subtitle)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(Theme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expandable Content
            if isExpanded {
                content
                    .padding(.top, 16)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(18)
        .background(Theme.glassBackground)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isExpanded ? color.opacity(0.3) : Theme.divider, lineWidth: 1)
        )
        .shadow(color: isExpanded ? color.opacity(0.1) : .clear, radius: 10, y: 5)
    }
}

// MARK: - Time Tracker Mini
struct TimeTrackerMini: View {
    let title: String
    let hours: Double
    let icon: String
    let color: Color
    var isMinutes: Bool = false
    var minutes: Int = 0
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.textPrimary)
            }
            
            Text(isMinutes ? "\(minutes) min" : String(format: "%.1f hrs", hours))
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(Theme.textPrimary)
            
            HStack(spacing: 16) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle")
                        .font(.title3)
                        .foregroundColor(Theme.textSecondary)
                }
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(color)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Theme.glassBackground)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

// MARK: - Daily Insight Card
struct DailyInsightCard: View {
    let log: DailyWellnessLog
    
    private var insight: (emoji: String, title: String, message: String) {
        let score = log.overallScore
        if score >= 80 {
            return ("🌟", "Excellent Day!", "You're crushing it! Keep up the amazing wellness habits.")
        } else if score >= 60 {
            return ("😊", "Good Progress!", "You're doing well. Try to get a bit more sleep or water for a perfect day.")
        } else if score >= 40 {
            return ("💡", "Room to Grow", "Consider adding some exercise or drinking more water today.")
        } else if score > 0 {
            return ("🌱", "Just Starting", "Every small step counts! Try logging one more meal or adding a cup of water.")
        } else {
            return ("☀️", "New Day", "Tap the trackers above to start logging your wellness!")
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(insight.emoji)
                    .font(.title2)
                
                Text(insight.title)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
            }
            
            Text(insight.message)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                Theme.glassBackground
                RadialGradient(
                    colors: [Theme.wellness.opacity(0.12), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 200
                )
            }
        )
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Theme.divider, lineWidth: 1)
        )
    }
}

struct WellnessView_Previews: PreviewProvider {
    static var previews: some View {
        WellnessView()
            .environmentObject(AppState())
    }
}
