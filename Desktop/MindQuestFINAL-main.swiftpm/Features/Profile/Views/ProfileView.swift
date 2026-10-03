import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State private var showResetAlert = false
    @State private var isEditingName = false
    @State private var showAvatarSelection = false
    @State private var floatAvatar = false
    
    let avatars = ["person.circle.fill", "brain.head.profile", "star.circle.fill", "heart.circle.fill", "bolt.circle.fill", "leaf.circle.fill"]
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    AppHeader(
                        title: "Your Profile",
                        subtitle: "Stats, settings & achievements"
                    )
                    .padding(.top, 10)
                    
                    // 1. Personal Information Section
                    VStack(spacing: 15) {
                        // Avatar Display
                        Button(action: { showAvatarSelection = true }) {
                            ZStack {
                                AvatarView(type: appState.selectedAvatar, size: Theme.screenWidth * 0.3, addAnimation: true)
                                
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title)
                                    .foregroundColor(Theme.textPrimary)
                                    .background(Circle().fill(Theme.primary))
                                    .offset(x: 40, y: 40)
                            }
                            .offset(y: floatAvatar ? -4 : 4)
                            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: floatAvatar)
                            .onAppear { floatAvatar = true }
                        }
                        .buttonStyle(BouncyButtonPressStyle())
                        
                        if isEditingName {
                            TextField("Enter Name", text: $appState.userName)
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.center)
                                .submitLabel(.done)
                                .onSubmit { isEditingName = false }
                                .foregroundColor(Theme.textPrimary)
                                .padding(8)
                                .background(Theme.textPrimary.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            HStack {
                                Text(appState.userName)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(Theme.textPrimary)
                                Button(action: { isEditingName = true }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(Theme.textSecondary)
                                }
                                .buttonStyle(BouncyButtonPressStyle())
                            }
                        }
                    }
                    .padding(.top, 30)
                    
                    // XP & Level Progress
                    PremiumSectionCard(title: "Level \(EngagementAgent.shared.currentLevel) — \(EngagementAgent.shared.levelTitle)", icon: "sparkles", accentColor: .yellow) {
                        VStack(spacing: 10) {
                            HStack {
                                Text("\(EngagementAgent.shared.totalXP) XP")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .foregroundColor(.yellow)
                                Spacer()
                                Text("Next: \(EngagementAgent.shared.xpForNextLevel - EngagementAgent.shared.xpInCurrentLevel) XP")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Theme.glassBackground)
                                        .frame(height: 8)
                                    Capsule()
                                        .fill(
                                            LinearGradient(colors: [.yellow, .orange], startPoint: .leading, endPoint: .trailing)
                                        )
                                        .frame(width: geo.size.width * EngagementAgent.shared.levelProgress, height: 8)
                                        .shadow(color: .yellow.opacity(0.3), radius: 4)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 2. Personal Progress Overview
                    PremiumSectionCard(title: "Progress Overview", icon: "chart.bar.fill", accentColor: Theme.secondary) {
                        VStack(spacing: 0) {
                            PremiumProfileRow(title: "Check-ins Completed", value: "\(appState.moodHistory.count)", icon: "checkmark.circle.fill", accentColor: Theme.secondary)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Time Invested Today", value: "\(EngagementAgent.shared.timeInvestedToday) min", icon: "hourglass", accentColor: Theme.primary)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Max Level Reached", value: "Level \(maxLevel)", icon: "chart.bar.fill", accentColor: Theme.secondary)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Current Mood Streak", value: "\(appState.currentStreak) days", icon: "flame.fill", accentColor: Theme.secondary)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Weekly Wellness", value: "\(appState.weeklyWellnessAverage)%", icon: "heart.fill", accentColor: Theme.wellness)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Hydration Consistency", value: "\(HydrationAgent.shared.getHydrationStreak()) days", icon: "drop.fill", accentColor: Color(red: 0.3, green: 0.65, blue: 1.0))
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Wellness Streak", value: "\(appState.wellnessStreak) days", icon: "leaf.fill", accentColor: Theme.fitness)
                        }
                    }
                    
                    // Personal Growth & Evolution
                    PremiumSectionCard(title: "Personal Growth", icon: "arrow.up.forward", accentColor: Theme.secondary) {
                        EvolutionCurveCard()
                    }
                    
                    // Wellness DNA Ring
                    WellnessDNARing(
                        waterScore: min(Double(appState.todaysLog.waterCups) / 8.0, 1.0),
                        sleepScore: min(appState.todaysLog.sleepHours / 9.0, 1.0),
                        exerciseScore: min(Double(appState.todaysLog.exerciseMinutes) / 60.0, 1.0),
                        moodScore: Double(appState.todaysLog.overallScore) / 100.0
                    )
                    .padding(.horizontal)
                    
                    // Consistency Velocity
                    ConsistencyVelocityMeter(
                        checkInCount: appState.moodHistory.count,
                        daysSinceJoin: max(1, Calendar.current.dateComponents([.day], from: appState.moodHistory.last?.date ?? Date(), to: Date()).day ?? 1)
                    )
                    .padding(.horizontal)
                    
                    // 3. App Customization
                    PremiumSectionCard(title: "Customization", icon: "paintpalette.fill", accentColor: .purple) {
                        VStack(spacing: 0) {
                            PremiumToggleRow(title: "Dark Mode", isOn: $appState.isDarkMode, icon: "moon.fill", accentColor: .purple)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumToggleRow(title: "Sound Effects", isOn: $appState.soundsEnabled, icon: "speaker.wave.2.fill", accentColor: .purple)
                        }
                    }
                    
                    // 4. Notifications
                    PremiumSectionCard(title: "Notifications", icon: "bell.fill", accentColor: .orange) {
                        VStack(spacing: 0) {
                            PremiumToggleRow(title: "Daily Reminders", isOn: $appState.notificationsEnabled, icon: "bell.fill", accentColor: .orange)
                                .onChange(of: appState.notificationsEnabled) { enabled in
                                    if enabled {
                                        Task {
                                            let granted = await NotificationManager.shared.requestPermission()
                                            if granted {
                                                NotificationManager.shared.scheduleDailyReminder(at: appState.notificationTime)
                                            } else {
                                                appState.notificationsEnabled = false
                                            }
                                        }
                                    } else {
                                        NotificationManager.shared.cancelReminder()
                                    }
                                }
                            
                            if appState.notificationsEnabled {
                                Divider().background(Theme.textPrimary.opacity(0.1))
                                HStack {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.orange.opacity(0.1))
                                                .frame(width: 32, height: 32)
                                            
                                            Image(systemName: "clock.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.orange)
                                        }
                                        Text("Reminder Time")
                                            .foregroundColor(Theme.textPrimary.opacity(0.8))
                                    }
                                    
                                    Spacer()
                                    
                                    DatePicker("", selection: $appState.notificationTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .colorInvert()
                                        .colorMultiply(.orange)
                                        .onChange(of: appState.notificationTime) { newTime in
                                            HapticAgent.shared.playSelection()
                                            NotificationManager.shared.scheduleDailyReminder(at: newTime)
                                        }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    
                    // 5. Hidden Achievement Gallery (Agent-Driven)
                    AchievementGalleryView()
                        .padding(.horizontal)
                    
                    // 5b. Focus & Time Invested
                    PremiumSectionCard(title: "Focus Stats", icon: "scope", accentColor: .teal) {
                        VStack(spacing: 0) {
                            PremiumProfileRow(title: "Total Focus Time", value: "\(FocusAgent.shared.totalFocusMinutes) min", icon: "timer", accentColor: .teal)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Focus Sessions", value: "\(FocusAgent.shared.totalSessions)", icon: "scope", accentColor: .mint)
                            Divider().background(Theme.textPrimary.opacity(0.1))
                            PremiumProfileRow(title: "Time Invested Today", value: "\(EngagementAgent.shared.timeInvestedToday) min", icon: "clock.fill", accentColor: Theme.secondary)
                        }
                    }
                    
                    // 6. Reports & Reset
                    VStack(spacing: 15) {
                        ShareLink(item: reportText) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Progress Report")
                            }
                            .foregroundColor(Theme.secondary)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.secondary.opacity(0.1))
                            .cornerRadius(15)
                        }
                        
                        Button(action: { showResetAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Reset All Progress")
                            }
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal, Theme.paddingStandard)
                    .padding(.bottom, Theme.screenHeight * 0.12)
                }
            }
        }
        .alert("Reset Profile?", isPresented: $showResetAlert) {
            Button("Reset Everything", role: .destructive) {
                appState.resetProfile()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your mood history, level progress, and settings. This action cannot be undone.")
        }
        .sheet(isPresented: $showAvatarSelection) {
            AvatarSelectionView(selectedAvatar: $appState.selectedAvatar)
        }
    }
    
    private var maxLevel: Int {
        appState.activityLevels.values.max() ?? 0
    }
    
    private var reportText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        
        var report = "🌿 MINDQUEST WELLNESS REPORT 🌿\n"
        report += "Generated on \(formatter.string(from: Date()))\n\n"
        
        report += "👤 USER PROFILE\n"
        report += "Name: \(appState.userName)\n"
        report += "Total Check-ins: \(appState.moodHistory.count)\n"
        report += "Current Streak: \(appState.currentStreak) days\n"
        report += "Max Level: Level \(maxLevel)\n"
        report += "Weekly Wellness: \(appState.weeklyWellnessAverage)%\n"
        report += "Mood Trend: \(appState.moodTrend.capitalized)\n\n"
        
        let log = appState.todaysLog
        report += "💧 TODAY'S WELLNESS\n"
        report += "Water: \(log.waterCups)/8 cups\n"
        report += "Sleep: \(String(format: "%.1f", log.sleepHours)) hours\n"
        report += "Exercise: \(log.exerciseMinutes) minutes\n"
        report += "Meals: \(log.meals.count) logged\n"
        report += "Study: \(String(format: "%.1f", log.studyHours)) hrs | Work: \(String(format: "%.1f", log.workHours)) hrs\n"
        report += "Screen Time: \(String(format: "%.1f", log.screenTimeHours)) hrs\n"
        report += "Overall Score: \(log.overallScore)%\n\n"
        
        report += "📊 MOOD HISTORY\n"
        report += "--------------------------------\n"
        
        if appState.moodHistory.isEmpty {
            report += "No history entries yet.\n"
        } else {
            for entry in appState.moodHistory.prefix(20) {
                report += "Date: \(formatter.string(from: entry.date))\n"
                report += "Mood: \(entry.emoji) \(entry.mood)\n"
                if !entry.activities.isEmpty {
                    report += "Activities: \(entry.activities.joined(separator: ", "))\n"
                }
                if !entry.text.isEmpty {
                    report += "Notes: \(entry.text)\n"
                }
                if let level = entry.levelCompleted {
                    report += "Milestone: Completed Level \(level)\n"
                }
                report += "--------------------------------\n"
            }
        }
        
        report += "\nGenerated by MindQuest App"
        return report
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(AppState())
    }
}
