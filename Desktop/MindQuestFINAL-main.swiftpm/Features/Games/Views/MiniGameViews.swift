import SwiftUI

// MARK: - Color Sorting Game
struct ColorSortingGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var bubbles: [ColorBubble] = []
    @State private var score = 0
    @State private var targetColor: Color = .red
    @State private var gameOver = false
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    
    private let colors: [(Color, String)] = [
        (.red, "Red"), (.blue, "Blue"), (.green, "Green"),
        (.orange, "Orange"), (.purple, "Purple"), (.pink, "Pink")
    ]
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                AppHeader(
                    title: "Color Sort",
                    subtitle: "Score: \(score)",
                    showBackButton: true,
                    backAction: { dismiss() },
                    trailingView: Text("\(timeRemaining)s")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(timeRemaining <= 10 ? .red : Theme.secondary)
                        .asAnyView()
                )
                
                // Target
                VStack(spacing: 8) {
                    Text("Tap all the")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                    Circle()
                        .fill(targetColor)
                        .frame(width: 40, height: 40)
                        .shadow(color: targetColor.opacity(0.5), radius: 8)
                    Text("bubbles!")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
                
                if gameOver {
                    VStack(spacing: 16) {
                        Text("🎉")
                            .font(.system(size: 60))
                        Text("Great Job!")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        Text("Score: \(score)")
                            .font(.system(.title2, design: .rounded))
                            .foregroundColor(Theme.secondary)
                        
                        Button(action: { resetGame() }) {
                            Text("Play Again")
                                .fontWeight(.bold)
                                .foregroundColor(Theme.deepBlack)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Theme.secondary)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.top, 40)
                } else {
                    // Bubble Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
                        ForEach(bubbles) { bubble in
                            Circle()
                                .fill(bubble.color)
                                .frame(height: 60)
                                .shadow(color: bubble.color.opacity(0.4), radius: 5)
                                .scaleEffect(bubble.tapped ? 0.01 : 1.0)
                                .opacity(bubble.tapped ? 0 : 1)
                                .onTapGesture {
                                    tapBubble(bubble)
                                }
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear { resetGame() }
        .onDisappear { timer?.invalidate() }
    }
    
    private func resetGame() {
        score = 0
        timeRemaining = 30
        gameOver = false
        generateBubbles()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { t in
            if timeRemaining > 0 {
                timeRemaining -= 1
                if timeRemaining <= 3 && timeRemaining > 0 {
                    HapticAgent.shared.countdownTick()
                }
            } else {
                t.invalidate()
                HapticAgent.shared.celebrateSuccess()
                EngagementAgent.shared.logPuzzleComplete()
                withAnimation { gameOver = true }
            }
        }
    }
    
    private func generateBubbles() {
        let (color, _) = colors.randomElement()!
        targetColor = color
        
        bubbles = (0..<16).map { i in
            let isTarget = i < 6
            return ColorBubble(
                color: isTarget ? color : colors.filter { $0.0 != color }.randomElement()!.0,
                isTarget: isTarget,
                tapped: false
            )
        }.shuffled()
    }
    
    private func tapBubble(_ bubble: ColorBubble) {
        guard let index = bubbles.firstIndex(where: { $0.id == bubble.id }) else { return }
        
        if bubble.isTarget {
            HapticAgent.shared.playImpact(.light)
            withAnimation(.spring(response: 0.3)) {
                bubbles[index].tapped = true
                score += 10
            }
            
            if bubbles.filter({ $0.isTarget && !$0.tapped }).isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    generateBubbles()
                }
            }
        } else {
            HapticAgent.shared.gentleWarning()
            score = max(0, score - 5)
        }
    }
}

struct ColorBubble: Identifiable {
    let id = UUID()
    let color: Color
    let isTarget: Bool
    var tapped: Bool
}

// MARK: - Word Scramble Game
struct WordScrambleGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentWord = ""
    @State private var scrambledLetters: [ScrambleLetter] = []
    @State private var userInput: [ScrambleLetter] = []
    @State private var score = 0
    @State private var wordIndex = 0
    @State private var showResult = false
    @State private var isCorrect = false
    
    private let words = [
        "RELAX", "SLEEP", "WATER", "SMILE", "PEACE",
        "HEART", "DREAM", "LIGHT", "BLOOM", "CALM",
        "FOCUS", "BRAVE", "HAPPY", "FRESH", "CLEAR"
    ]
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                AppHeader(
                    title: "Word Scramble",
                    subtitle: "Score: \(score)",
                    showBackButton: true,
                    backAction: { dismiss() },
                    trailingView: Text("\(wordIndex + 1)/\(min(words.count, 10))")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Theme.secondary)
                        .asAnyView()
                )
                
                Text("Unscramble the Word")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                // User input slots
                HStack(spacing: 8) {
                    ForEach(0..<currentWord.count, id: \.self) { i in
                        ZStack {
                            RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                                .fill(Theme.glassBackground)
                                .frame(width: 44, height: 52)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                                        .stroke(Theme.puzzles.opacity(0.4), lineWidth: 1.5)
                                )
                            
                            if i < userInput.count {
                                Text(userInput[i].letter)
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }
                        .onTapGesture {
                            if i < userInput.count {
                                removeLetterAt(i)
                            }
                        }
                    }
                }
                
                // Scrambled letters
                HStack(spacing: 8) {
                    ForEach(scrambledLetters) { letter in
                        if !letter.used {
                            Button(action: { addLetter(letter) }) {
                                Text(letter.letter)
                                    .font(.system(.title2, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(Theme.textPrimary)
                                    .frame(width: 44, height: 52)
                                    .background(Theme.puzzles.opacity(0.2))
                                    .cornerRadius(Theme.cornerRadiusSmall)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cornerRadiusSmall)
                                            .stroke(Theme.puzzles.opacity(0.5), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(SubtleTapButtonStyle())
                        } else {
                            Text("")
                                .frame(width: 44, height: 52)
                                .background(Color.clear)
                        }
                    }
                }
                
                if showResult {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(isCorrect ? "Correct! +10" : "The word was: \(currentWord)")
                    }
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(isCorrect ? .green : .red)
                    .transition(.scale.combined(with: .opacity))
                }
                
                HStack(spacing: 16) {
                    Button(action: { shuffleLetters() }) {
                        HStack {
                            Image(systemName: "shuffle")
                            Text("Shuffle")
                        }
                        .foregroundColor(Theme.puzzles)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Theme.puzzles.opacity(0.15))
                        .cornerRadius(10)
                    }
                    
                    if userInput.count == currentWord.count {
                        Button(action: { checkAnswer() }) {
                            HStack {
                                Image(systemName: "checkmark")
                                Text("Check")
                            }
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Theme.puzzles)
                            .cornerRadius(10)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear { loadWord() }
    }
    
    private func loadWord() {
        guard wordIndex < words.count else { return }
        currentWord = words[wordIndex]
        showResult = false
        userInput = []
        scrambledLetters = currentWord.map { ScrambleLetter(letter: String($0), used: false) }.shuffled()
        
        // Make sure it's actually scrambled
        while scrambledLetters.map({ $0.letter }).joined() == currentWord && currentWord.count > 1 {
            scrambledLetters.shuffle()
        }
    }
    
    private func addLetter(_ letter: ScrambleLetter) {
        guard userInput.count < currentWord.count else { return }
        HapticAgent.shared.playImpact(.light, intensity: 0.5)
        if let index = scrambledLetters.firstIndex(where: { $0.id == letter.id }) {
            scrambledLetters[index].used = true
            userInput.append(letter)
        }
    }
    
    private func removeLetterAt(_ index: Int) {
        let letter = userInput.remove(at: index)
        if let scrambleIndex = scrambledLetters.firstIndex(where: { $0.id == letter.id }) {
            scrambledLetters[scrambleIndex].used = false
        }
    }
    
    private func shuffleLetters() {
        let unusedLetters = scrambledLetters.filter { !$0.used }
        let usedLetters = scrambledLetters.filter { $0.used }
        scrambledLetters = unusedLetters.shuffled() + usedLetters
    }
    
    private func checkAnswer() {
        let answer = userInput.map { $0.letter }.joined()
        isCorrect = answer == currentWord
        if isCorrect {
            score += 10
            HapticAgent.shared.celebrateSuccess()
            EngagementAgent.shared.logPuzzleComplete()
        } else {
            HapticAgent.shared.gentleWarning()
        }
        
        withAnimation(.spring()) {
            showResult = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            wordIndex += 1
            if wordIndex < min(words.count, 10) {
                loadWord()
            }
        }
    }
}

struct ScrambleLetter: Identifiable {
    let id = UUID()
    let letter: String
    var used: Bool
}

// MARK: - Pattern Match Game
struct PatternMatchGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var pattern: [Int] = []
    @State private var userPattern: [Int] = []
    @State private var isShowingPattern = false
    @State private var activeCell = -1
    @State private var level = 1
    @State private var score = 0
    @State private var gameOver = false
    
    private let gridColors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .cyan, .pink, .mint]
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                AppHeader(
                    title: "Pattern Match",
                    subtitle: "Level \(level) • Score: \(score)",
                    showBackButton: true,
                    backAction: { dismiss() },
                    trailingView: Text(isShowingPattern ? "Watch..." : "Your turn!")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(isShowingPattern ? Theme.accent : Theme.secondary)
                        .asAnyView()
                )
                
                if gameOver {
                    VStack(spacing: 16) {
                        Text("🧠")
                            .font(.system(size: 60))
                        Text("Great Memory!")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        Text("You reached Level \(level) with \(score) points")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Theme.textSecondary)
                        
                        Button(action: { resetGame() }) {
                            Text("Try Again")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Theme.secondary)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                } else {
                    // Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(0..<9, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    activeCell == index
                                    ? gridColors[index]
                                    : gridColors[index].opacity(0.2)
                                )
                                .frame(height: 90)
                                .shadow(
                                    color: activeCell == index ? gridColors[index].opacity(0.5) : .clear,
                                    radius: 10
                                )
                                .scaleEffect(activeCell == index ? 1.05 : 1.0)
                                .onTapGesture {
                                    if !isShowingPattern && !gameOver {
                                        tapCell(index)
                                    }
                                }
                                .animation(.spring(response: 0.2), value: activeCell)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
        .onAppear { resetGame() }
    }
    
    private func resetGame() {
        level = 1
        score = 0
        gameOver = false
        startNewRound()
    }
    
    private func startNewRound() {
        let patternLength = level + 2
        pattern = (0..<patternLength).map { _ in Int.random(in: 0..<9) }
        userPattern = []
        showPattern()
    }
    
    private func showPattern() {
        isShowingPattern = true
        activeCell = -1
        
        for (i, cell) in pattern.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                withAnimation { activeCell = cell }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation { activeCell = -1 }
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(pattern.count) * 0.6 + 0.3) {
            isShowingPattern = false
        }
    }
    
    private func tapCell(_ index: Int) {
        withAnimation(.spring(response: 0.2)) { activeCell = index }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation { activeCell = -1 }
        }
        
        userPattern.append(index)
        let step = userPattern.count - 1
        
        if userPattern[step] != pattern[step] {
            withAnimation { gameOver = true }
            return
        }
        
        if userPattern.count == pattern.count {
            score += level * 10
            level += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                startNewRound()
            }
        }
    }
}

// MARK: - Trivia Quiz Game
struct TriviaQuizGame: View {
    @Environment(\.dismiss) var dismiss
    @State private var questionIndex = 0
    @State private var score = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showExplanation = false
    
    private let questions: [(question: String, answers: [String], correct: Int, explanation: String)] = [
        ("How many cups of water should you drink daily?", ["4 cups", "6 cups", "8 cups", "12 cups"], 2, "8 cups (about 2 liters) is the general daily recommendation."),
        ("Which activity best reduces cortisol (stress hormone)?", ["Intense cardio", "Deep breathing", "Watching TV", "Eating sugar"], 1, "Deep breathing activates the parasympathetic nervous system."),
        ("How many hours of sleep do adults typically need?", ["5-6 hours", "7-9 hours", "10-12 hours", "4-5 hours"], 1, "Most adults need 7-9 hours of quality sleep per night."),
        ("What neurotransmitter is associated with happiness?", ["Cortisol", "Adrenaline", "Serotonin", "Insulin"], 2, "Serotonin is often called the 'feel-good' neurotransmitter."),
        ("Which color is most calming to the mind?", ["Red", "Yellow", "Blue", "Orange"], 2, "Blue tones are associated with calmness and tranquility."),
        ("What is 'mindfulness' primarily about?", ["Planning ahead", "Present moment awareness", "Remembering the past", "Multitasking"], 1, "Mindfulness means paying attention to the present moment."),
        ("Exercise releases which 'feel-good' chemicals?", ["Melatonin", "Endorphins", "Histamines", "Bile acids"], 1, "Endorphins are natural painkillers that boost mood."),
        ("What percentage of the brain is water?", ["50%", "60%", "73%", "90%"], 2, "The brain is about 73% water — stay hydrated!"),
    ]
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                AppHeader(
                    title: "Trivia Quiz",
                    subtitle: "Score: \(score)",
                    showBackButton: true,
                    backAction: { dismiss() },
                    trailingView: Text("\(questionIndex + 1)/\(questions.count)")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(Theme.textPrimary)
                        .asAnyView()
                )
                
                if questionIndex < questions.count {
                    let q = questions[questionIndex]
                    
                    VStack(spacing: 20) {
                        Text(q.question)
                            .font(.system(.title3, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        VStack(spacing: 14) {
                            ForEach(0..<q.answers.count, id: \.self) { i in
                                Button(action: { selectAnswer(i) }) {
                                    HStack {
                                        Text(q.answers[i])
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                            .foregroundColor(Theme.textPrimary)
                                        Spacer()
                                        
                                        if let selected = selectedAnswer {
                                            if i == q.correct {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            } else if i == selected {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                            }
                                        }
                                    }
                                    .padding(18)
                                    .background(answerBackground(i, q.correct))
                                    .cornerRadius(Theme.cornerRadiusMedium)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: Theme.cornerRadiusMedium)
                                            .stroke(answerBorder(i, q.correct), lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(SubtleTapButtonStyle())
                                .disabled(selectedAnswer != nil)
                            }
                        }
                        .padding(.horizontal)
                        
                        if showExplanation {
                            Text(q.explanation)
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Theme.secondary)
                                .padding()
                                .background(Theme.secondary.opacity(0.1))
                                .cornerRadius(12)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                } else {
                    // Final score
                    VStack(spacing: 16) {
                        Text(score > questions.count / 2 * 10 ? "🏆" : "📚")
                            .font(.system(size: 60))
                        Text("Quiz Complete!")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(Theme.textPrimary)
                        Text("\(score) / \(questions.count * 10) points")
                            .font(.system(.title3, design: .rounded))
                            .foregroundColor(Theme.secondary)
                        
                        Button(action: { dismiss() }) {
                            Text("Done")
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Theme.secondary)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 20)
        }
    }
    
    private func selectAnswer(_ index: Int) {
        let q = questions[questionIndex]
        selectedAnswer = index
        if index == q.correct { score += 10 }
        
        withAnimation(.spring()) { showExplanation = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                selectedAnswer = nil
                showExplanation = false
                questionIndex += 1
            }
        }
    }
    
    private func answerBackground(_ index: Int, _ correct: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Theme.glassBackground
        }
        if index == correct { return Color.green.opacity(0.2) }
        if index == selected { return Color.red.opacity(0.2) }
        return Theme.glassBackground.opacity(0.6)
    }
    
    private func answerBorder(_ index: Int, _ correct: Int) -> Color {
        guard let selected = selectedAnswer else {
            return Theme.divider
        }
        if index == correct { return Color.green.opacity(0.6) }
        if index == selected { return Color.red.opacity(0.6) }
        return Theme.divider.opacity(0.5)
    }
}
