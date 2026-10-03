import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: ActivityCategory = .health
    @State private var preStartActivity: ActivityRecommendation? = nil
    @State private var animateHeader = false
    @State private var animateCards = false
    
    // Game sheet states
    @State private var showColorSorting = false
    @State private var showWordScramble = false
    @State private var showPatternMatch = false
    @State private var showTriviaQuiz = false
    @State private var showSlidingPuzzle = false
    @State private var showReactionTest = false
    @State private var showNumberPath = false
    @State private var showBubblePop = false
    @State private var showMazeGame = false
    @State private var showSoundscape = false
    @State private var selectedSoundscapeActivity: ActivityRecommendation? = nil
    @State private var activeSessionActivity: ActivityRecommendation? = nil
    
    // Mood Audio Engine
    @StateObject private var moodAudio = MoodAudioEngine()
    
    private var currentMood: String {
        appState.latestMoodEmoji
    }
    
    private var moodLabel: String {
        switch currentMood {
        case "🌟": return "Euphoric"
        case "😊": return "Happy"
        case "😌": return "Calm"
        case "😕": return "Down"
        case "😔": return "Stressed"
        default: return "Neutral"
        }
    }
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            RadialGradient(
                colors: [categoryColor.opacity(0.06), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // MARK: - Header
                    AppHeader(
                        title: "Discover",
                        subtitle: "Based on your mood: \(moodLabel)",
                        trailingView: Text(currentMood)
                            .font(.system(size: 40))
                            .shadow(color: categoryColor.opacity(0.4), radius: 8)
                            .scaleEffect(animateHeader ? 1.0 : 0.8)
                            .opacity(animateHeader ? 1.0 : 0.0)
                            .asAnyView()
                    )
                    
                    // MARK: - Category Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(ActivityCategory.allCases, id: \.rawValue) { category in
                                CategoryChip(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    HapticAgent.shared.playSelection()
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                        animateCards = false
                                        // Stop any playing mood audio when switching categories
                                        moodAudio.stop()
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            animateCards = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 4)
                    }
                    
                    // MARK: - Featured Activity Card
                    if let featured = currentActivities.first {
                        FeaturedActivityCard(activity: featured) {
                            launchActivity(featured)
                        }
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 20)
                    }
                    
                    // MARK: - Activity Grid
                    VStack(alignment: .leading, spacing: 16) {
                        Text("More Activities")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                            ForEach(Array(currentActivities.dropFirst().enumerated()), id: \.element.id) { index, activity in
                                ActivityCard(activity: activity) {
                                    launchActivity(activity)
                                }
                                .opacity(animateCards ? 1.0 : 0.0)
                                .offset(y: animateCards ? 0 : 20)
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: animateCards)
                            }
                        }
                    }
                    
                    // Mystery Activity + Weekly Challenge
                    MysteryActivityCard()
                    MiniChallengeCard()
                    
                    // MARK: - Explore All Categories
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Explore All Categories")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        
                        ForEach(ActivityCategory.allCases.filter { $0 != selectedCategory }, id: \.rawValue) { category in
                            let activities = MoodActivities.recommendations(for: currentMood, category: category)
                            if let first = activities.first {
                                CompactActivityRow(activity: first, category: category) {
                                    withAnimation(.spring()) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Theme.paddingStandard)
                .padding(.bottom, Theme.screenHeight * 0.1)
            }
        }
        .sheet(item: $preStartActivity) { activity in
            ActivityPreStartSheet(activity: activity) {
                executeActivityLaunch(activity)
            }
        }
        .fullScreenCover(isPresented: $showColorSorting) { ColorSortingGame() }
        .fullScreenCover(isPresented: $showWordScramble) { WordScrambleGame() }
        .fullScreenCover(isPresented: $showPatternMatch) { PatternMatchGame() }
        .fullScreenCover(isPresented: $showTriviaQuiz) { TriviaQuizGame() }
        .fullScreenCover(isPresented: $showSlidingPuzzle) { SlidingPuzzleGame() }
        .fullScreenCover(isPresented: $showReactionTest) { ReactionTestGame() }
        .fullScreenCover(isPresented: $showNumberPath) { NumberPathGame() }
        .fullScreenCover(isPresented: $showBubblePop) { BubblePopGame() }
        .fullScreenCover(isPresented: $showMazeGame) { MazeGame() }
        .fullScreenCover(isPresented: $showSoundscape) { SoundscapeView(initialTrackName: selectedSoundscapeActivity?.name) }
        .fullScreenCover(item: $activeSessionActivity) { activity in
            ActivitySessionView(activity: activity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                animateHeader = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.4)) {
                animateCards = true
            }
        }
        .onDisappear {
            moodAudio.stop()
        }
    }
    
    private var currentActivities: [ActivityRecommendation] {
        MoodActivities.recommendations(for: currentMood, category: selectedCategory)
    }
    
    private var categoryColor: Color {
        selectedCategory.color
    }
    
    // MARK: - Activity Lifecycle
    private func launchActivity(_ activity: ActivityRecommendation) {
        HapticAgent.shared.playImpact(.medium)
        // Step 1: Show the Pre-Start Instructions
        preStartActivity = activity
    }
    
    private func executeActivityLaunch(_ activity: ActivityRecommendation) {
        let name = activity.name.lowercased()
        
        // ── Music Activities → SoundscapeView with distinct track mapping ──
        if activity.category == .music {
            selectedSoundscapeActivity = activity
            showSoundscape = true
            return
        }
        
        // ── Games ──
        if name.contains("color sorting") || name.contains("color flow") || name.contains("color match") {
            showColorSorting = true
        } else if name.contains("word scramble") || name.contains("word builder") || name.contains("word bloom") || name.contains("comfort words") || name.contains("scramble") || name.contains("word search") {
            showWordScramble = true
        } else if name.contains("pattern match") || name.contains("speed puzzle") || name.contains("pattern dash") || name.contains("flash match") || name.contains("memory blitz") || name.contains("quick match") {
            showPatternMatch = true
        } else if name.contains("trivia quiz") || name.contains("trivia") || name.contains("riddle") {
            showTriviaQuiz = true
        } else if name.contains("reaction test") || name.contains("reaction") || name.contains("zen tapper") {
            showReactionTest = true
        } else if name.contains("bubble pop") || name.contains("bubble") {
            showBubblePop = true
        } else if name.contains("number path") {
            showNumberPath = true
        } else if name.contains("maze") {
            showMazeGame = true
        }
        
        // ── Puzzles → Map to closest working engine ──
        else if name.contains("sudoku") || name.contains("sliding") || name.contains("jigsaw") || name.contains("logic grid") || name.contains("grid explorer") || name.contains("logic link") {
            showSlidingPuzzle = true
        } else if name.contains("crossword") || name.contains("word") {
            showWordScramble = true
        } else if name.contains("coloring") || name.contains("shape sorter") || name.contains("spot the difference") || name.contains("brain teaser") || name.contains("speed pattern") {
            showPatternMatch = true
        } else if name.contains("trivia sprint") {
            showTriviaQuiz = true
        } else if name.contains("bubble pop zen") || name.contains("bubble pop therapy") {
            showBubblePop = true
        } else if name.contains("color sorting calm") {
            showColorSorting = true
        }
        
        // ── Default: Health/Fitness session view ──
        else {
            activeSessionActivity = activity
        }
    }
}

// MARK: - Category Chip
struct CategoryChip: View {
    let category: ActivityCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                Text(category.rawValue)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }
            .foregroundColor(isSelected ? .white : Theme.textPrimary.opacity(0.8))
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                Group {
                    if isSelected {
                        LinearGradient(
                            colors: [category.color, category.color.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Theme.glassBackground
                    }
                }
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? Color.clear : category.color.opacity(0.2),
                        lineWidth: 1
                    )
            )
            .shadow(color: isSelected ? category.color.opacity(0.2) : .clear, radius: 6, y: 3)
        }
    }
}

// MARK: - Featured Activity Card
struct FeaturedActivityCard: View {
    let activity: ActivityRecommendation
    let action: () -> Void
    @State private var pulse = false
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                // Hero Image
                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(activity.accentColor.opacity(0.1))
                        .frame(height: 140)
                    
                    if activity.category == .health || activity.category == .fitness {
                        StickmanView(action: StickmanView.action(for: activity.category), color: activity.accentColor)
                            .scaleEffect(1.2)
                            .shadow(color: activity.accentColor.opacity(0.3), radius: 5)
                    } else {
                        Image(systemName: activity.heroImage)
                            .font(.system(size: 60))
                            .foregroundColor(activity.accentColor)
                            .shadow(color: activity.accentColor.opacity(0.3), radius: 8)
                            .scaleEffect(pulse ? 1.05 : 1.0)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(activity.category.rawValue.uppercased())
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(activity.accentColor)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(activity.duration)
                                .font(.system(.caption2, design: .rounded))
                        }
                        .foregroundColor(Theme.textSecondary)
                    }
                    
                    Text(activity.name)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(activity.description)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text("Learn More & Start")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [activity.accentColor, activity.accentColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(20)
            .background(Theme.glassBackground)
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Theme.divider, lineWidth: 1)
            )
            .shadow(color: activity.accentColor.opacity(0.1), radius: 10, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    let activity: ActivityRecommendation
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticAgent.shared.playImpact(.light)
            action()
        }) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero Image Preview
                ZStack {
                    Rectangle()
                        .fill(activity.accentColor.opacity(0.05))
                    
                    if activity.category == .health || activity.category == .fitness {
                        StickmanView(action: StickmanView.action(for: activity.category), color: activity.accentColor)
                            .scaleEffect(0.7)
                            .opacity(0.6)
                    } else {
                        Image(systemName: activity.heroImage)
                            .font(.system(size: 32))
                            .foregroundColor(activity.accentColor.opacity(0.5))
                    }
                }
                .frame(height: 80)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.name)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.system(size: 9))
                        Text(activity.duration)
                            .font(.system(size: 10, design: .rounded))
                    }
                    .foregroundColor(Theme.textSecondary)
                }
                .padding(12)
            }
            .background(Theme.glassBackground)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Theme.divider, lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Compact Activity Row
struct CompactActivityRow: View {
    let activity: ActivityRecommendation
    let category: ActivityCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            HapticAgent.shared.playImpact(.light)
            action()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(category.color.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 18))
                        .foregroundColor(category.color)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(category.rawValue)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(activity.name)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
            }
            .padding(14)
            .background(Theme.glassBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.divider, lineWidth: 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DiscoverView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
            .environmentObject(AppState())
    }
}
