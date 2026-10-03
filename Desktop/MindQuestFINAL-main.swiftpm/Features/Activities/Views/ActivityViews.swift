import SwiftUI

struct ActivityPlayerView: View {
    let moodEmoji: String
    @ObservedObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showLevelUp = false
    
    var currentLevel: Int {
        appState.activityLevels[moodEmoji] ?? 1
    }
    
    private var activityName: String {
        title // Using the existing 'title' property for the activity name
    }
    
    private var isLevelUp: Bool {
        showLevelUp // Using the existing 'showLevelUp' state for level up status
    }
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            // Dynamic Island Simulation
            DynamicIslandSimulation(
                title: activityName,
                subtitle: isLevelUp ? "Level Up!" : "Session Active",
                icon: "timer",
                isVisible: Binding<Bool>.constant(true)
            )
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(Theme.textPrimary.opacity(0.5))
                    }
                    Spacer()
                    VStack {
                        Text(title)
                            .font(.headline)
                        Text("Level \(currentLevel)")
                            .font(.caption)
                            .foregroundColor(Theme.secondary)
                    }
                    Spacer()
                    Image(systemName: icon)
                        .foregroundColor(Theme.secondary)
                }
                .padding()
                
                Spacer()
                
                // Active Game/Exercise
                content
                
                Spacer()
            }
            
            if showLevelUp {
                LevelUpOverlay(level: currentLevel) {
                    withAnimation { showLevelUp = false }
                    dismiss()
                    
                    // Auto-navigate to Discover Tab upon completion
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        appState.selectedTab = 1
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch moodEmoji {
        case "🌟": DrawingCanvas(level: currentLevel) { complete() }
        case "😊": GratitudeExercise(level: currentLevel) { complete() }
        case "😌": ZenGarden(level: currentLevel) { complete() }
        case "😕": MemoryMatchGame(level: currentLevel) { complete() }
        case "😔": BreathingAnchor(level: currentLevel) { complete() }
        default: Text("Coming Soon")
        }
    }
    
    private func complete() {
        let levelFinished = currentLevel
        appState.completeLevel(for: moodEmoji)
        
        // Haptic + XP reward
        HapticAgent.shared.celebrateSuccess()
        EngagementAgent.shared.logWorkoutComplete()
        
        // Record activity completion in history
        appState.addHistoryEntry(
            text: "Completed \(title) activity.",
            mood: "Progress",
            emoji: moodEmoji,
            level: levelFinished
        )
        
        withAnimation { showLevelUp = true }
    }
    
    private var title: String {
        switch moodEmoji {
        case "🌟": return "Creative Explosion"
        case "😊": return "Gratitude Gallery"
        case "😌": return "Zen Zen Garden"
        case "😕": return "Memory Match"
        case "😔": return "Breathing Anchor"
        default: return "Activity"
        }
    }
    
    private var icon: String {
        switch moodEmoji {
        case "🌟": return "paintbrush.fill"
        case "😊": return "sun.max.fill"
        case "😌": return "leaf.fill"
        case "😕": return "puzzlepiece.fill"
        case "😔": return "wind"
        default: return "star.fill"
        }
    }
}

struct LevelUpOverlay: View {
    let level: Int
    var onDismiss: () -> Void
    @State private var burstActive = false
    
    var body: some View {
        ZStack {
            Theme.background.opacity(0.95).ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    RadialBurstOverlay(isActive: $burstActive, color: .yellow)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow, radius: 20)
                        .floatingIdle(amplitude: 3, duration: 2)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { burstActive = true }
                    HapticAgent.shared.celebrateMilestone()
                }
                
                Text("LEVEL UP!")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                
                Text("You've completed Level \(level-1)!")
                    .font(.headline)
                    .foregroundColor(Theme.textSecondary)
                
                Button(action: onDismiss) {
                    Text("Continue Journey")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

// MARK: - 🌟 Drawing Canvas (Euphoric)
struct DrawingCanvas: View {
    let level: Int
    var onComplete: () -> Void
    
    @State private var curPath = Path()
    @State private var paths: [Path] = []
    
    var goal: Int { level * 2 }
    
    var body: some View {
        VStack {
            Text("Express your euphoria through light!")
                .font(.subheadline)
                .foregroundColor(Theme.textSecondary)
            Text("Paths: \(paths.count) / \(goal)")
                .foregroundColor(Theme.secondary)
            
            Canvas { context, size in
                for path in paths {
                    context.stroke(path, with: .color(Theme.primary.opacity(0.8)), lineWidth: 4)
                }
                context.stroke(curPath, with: .color(Theme.secondary), lineWidth: 6)
            }
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if curPath.isEmpty { curPath.move(to: value.startLocation) }
                    curPath.addLine(to: value.location)
                }
                .onEnded { _ in
                    paths.append(curPath)
                    curPath = Path()
                    if paths.count >= goal { onComplete() }
                }
            )
            .background(Theme.textPrimary.opacity(0.05))
            .cornerRadius(20)
            .padding()
            
            Button("Clear Canvas") { paths.removeAll() }
                .foregroundColor(Theme.textSecondary)
        }
    }
}

// MARK: - 😊 Gratitude Exercise (Positive)
struct GratitudeExercise: View {
    let level: Int
    var onComplete: () -> Void
    
    @State private var thoughts: [String] = []
    @State private var newThought = ""
    
    var goal: Int { level + 1 }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What are you grateful for?")
                .font(.title3)
                .foregroundColor(Theme.textPrimary)
            Text("Thoughts shared: \(thoughts.count) / \(goal)")
                .font(.caption)
                .foregroundColor(Theme.secondary)
            
            HStack {
                TextField("Add a happy thought...", text: $newThought)
                    .textFieldStyle(.roundedBorder)
                Button(action: {
                    if !newThought.isEmpty {
                        withAnimation { thoughts.insert(newThought, at: 0) }
                        newThought = ""
                        if thoughts.count >= goal { onComplete() }
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.secondary)
                }
            }
            .padding(.horizontal)
            
            ScrollView {
                VStack {
                    ForEach(thoughts, id: \.self) { thought in
                        Text(thought)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Theme.textPrimary)
                            .background(Theme.textPrimary.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - 😌 Zen Garden (Calm)
struct ZenGarden: View {
    let level: Int
    var onComplete: () -> Void
    
    @State private var stones: [CGPoint] = []
    var goal: Int { level * 3 }
    
    var body: some View {
        VStack {
            Text("Tap to place calming stones in your garden")
                .foregroundColor(Theme.textSecondary)
            Text("Stones: \(stones.count) / \(goal)")
                .foregroundColor(Theme.secondary)
            
            ZStack {
                Theme.textPrimary.opacity(0.05)
                    .onTapGesture { location in
                        if stones.count < goal {
                            withAnimation(.spring()) {
                                stones.append(location)
                            }
                            if stones.count >= goal {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    onComplete()
                                }
                            }
                        }
                    }
                
                ForEach(0..<stones.count, id: \.self) { i in
                    Circle()
                        .fill(Theme.secondary.opacity(0.6))
                        .frame(width: 40, height: 40)
                        .position(stones[i])
                        .shadow(color: Theme.secondary, radius: 5)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 400)
            .cornerRadius(20)
            .padding()
            
            Button("Reset Garden") { stones.removeAll() }
                .foregroundColor(Theme.textSecondary)
        }
    }
}

// MARK: - 😕 Memory Match (Down)
struct MemoryMatchGame: View {
    let level: Int
    var onComplete: () -> Void
    
    @State private var cards: [String]
    @State private var flipped: [Int] = []
    @State private var matched: Set<Int> = []
    
    init(level: Int, onComplete: @escaping () -> Void) {
        self.level = level
        self.onComplete = onComplete
        
        let symbols = ["❤️", "💎", "🌈", "🔥", "🍀", "🌓", "🎈", "🔑"]
        // Select pairs based on level. Starting with 3 pairs, max 8.
        let pairCount = min(2 + level, 8)
        let selection = Array(symbols.prefix(pairCount))
        let deck = (selection + selection).shuffled()
        _cards = State(initialValue: deck)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Focus on matching the symbols")
                .foregroundColor(Theme.textSecondary)
            Text("Pairs found: \(matched.count/2) / \(cards.count/2)")
                .foregroundColor(Theme.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                ForEach(0..<cards.count, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(matched.contains(index) ? Color.green.opacity(0.3) : (flipped.contains(index) ? Theme.primary : Theme.textPrimary.opacity(0.1)))
                            .frame(height: 100)
                        
                        if flipped.contains(index) || matched.contains(index) {
                            Text(cards[index])
                                .font(.title)
                        } else {
                            Image(systemName: "questionmark")
                                .foregroundColor(Theme.textPrimary.opacity(0.2))
                        }
                    }
                    .onTapGesture {
                        flip(index)
                    }
                }
            }
            .padding()
        }
    }
    
    private func flip(_ index: Int) {
        if flipped.count < 2 && !flipped.contains(index) && !matched.contains(index) {
            HapticAgent.shared.playImpact(.light, intensity: 0.5)
            flipped.append(index)
            if flipped.count == 2 {
                if cards[flipped[0]] == cards[flipped[1]] {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        HapticAgent.shared.celebrateSuccess()
                        matched.insert(flipped[0])
                        matched.insert(flipped[1])
                        flipped.removeAll()
                        if matched.count == cards.count {
                            onComplete()
                        }
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        HapticAgent.shared.playNotification(.warning)
                        flipped.removeAll()
                    }
                }
            }
        }
    }
}

// MARK: - 😔 Breathing Anchor (Stressed)
struct BreathingAnchor: View {
    let level: Int
    var onComplete: () -> Void
    
    @State private var isInhaling = false
    @State private var timerText = "Ready?"
    @State private var cyclesCompleted = 0
    var goal: Int { 2 + level }
    
    var body: some View {
        VStack(spacing: 50) {
            Text("Cycles: \(cyclesCompleted) / \(goal)")
                .foregroundColor(Theme.secondary)
            
            ZStack {
                Circle()
                    .stroke(Theme.secondary.opacity(0.2), lineWidth: 2)
                    .frame(width: 250, height: 250)
                
                // Ripple overlay
                BreathingOrbOverlay(isInhaling: isInhaling, color: Theme.secondary)
                    .frame(width: 250, height: 250)
                
                Circle()
                    .fill(Theme.secondary.opacity(0.3))
                    .frame(width: isInhaling ? 220 : 80, height: isInhaling ? 220 : 80)
                    .animation(.easeInOut(duration: 4).repeatForever(autoreverses: true), value: isInhaling)
                
                Text(timerText)
                    .font(.headline)
                    .foregroundColor(Theme.textPrimary)
            }
            .onAppear {
                isInhaling = true
                animateText()
            }
            
            Text("Follow the circle to steady your breath")
                .foregroundColor(Theme.textSecondary)
        }
    }
    
    private func animateText() {
        timerText = "Inhale"
        HapticAgent.shared.breathingPulse()
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { timer in
            if timerText == "Inhale" {
                timerText = "Exhale"
                HapticAgent.shared.breathingPulse()
            } else {
                timerText = "Inhale"
                HapticAgent.shared.breathingPulse()
                cyclesCompleted += 1
                if cyclesCompleted >= goal {
                    timer.invalidate()
                    HapticAgent.shared.celebrateSuccess()
                    let breathCount = UserDefaults.standard.integer(forKey: "total_breathing_sessions") + 1
                    UserDefaults.standard.set(breathCount, forKey: "total_breathing_sessions")
                    if breathCount >= 5 { AchievementAgent.shared.checkAndUnlock(.zenMaster) }
                    onComplete()
                }
            }
        }
    }
}
