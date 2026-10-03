import SwiftUI

struct QuizQuestion {
    let text: String
    let subtitle: String
    let icon: String
    let options: [QuizOption]
}

struct QuizOption {
    let text: String
    let emoji: String
    let value: Int
}

struct MoodQuizCard: View {
    @Binding var isAnalyzing: Bool
    var onCompletion: (Int) -> Void
    
    @State private var currentQuestionIndex = 0
    @State private var totalScore = 0
    @State private var animateGradient = false
    @State private var transitionOpacity: Double = 1.0
    @State private var selectedOptionIndex: Int? = nil
    @State private var emojiBounceTrigger = false
    
    let questions = [
        QuizQuestion(text: "How did you feel waking up?", subtitle: "Your morning energy", icon: "sunrise.fill", options: [
            QuizOption(text: "Drained", emoji: "😩", value: 1),
            QuizOption(text: "Sleepy", emoji: "😴", value: 2),
            QuizOption(text: "Refreshed", emoji: "😊", value: 3),
            QuizOption(text: "Excited", emoji: "🤩", value: 4)
        ]),
        QuizQuestion(text: "What's your energy level?", subtitle: "Right now, in this moment", icon: "bolt.fill", options: [
            QuizOption(text: "Very Low", emoji: "🪫", value: 1),
            QuizOption(text: "Moderate", emoji: "⚡", value: 2),
            QuizOption(text: "Good", emoji: "💪", value: 3),
            QuizOption(text: "Surging", emoji: "🔥", value: 4)
        ]),
        QuizQuestion(text: "How focused are you?", subtitle: "Your concentration level", icon: "eye.fill", options: [
            QuizOption(text: "Not at all", emoji: "🌫️", value: 1),
            QuizOption(text: "Distracted", emoji: "🦋", value: 2),
            QuizOption(text: "Focused", emoji: "🎯", value: 3),
            QuizOption(text: "In Flow", emoji: "🧠", value: 4)
        ]),
        QuizQuestion(text: "Describe your mind.", subtitle: "Your mental clarity", icon: "brain.head.profile", options: [
            QuizOption(text: "Overwhelmed", emoji: "🌪️", value: 1),
            QuizOption(text: "A bit noisy", emoji: "💭", value: 2),
            QuizOption(text: "Calm", emoji: "🧘", value: 3),
            QuizOption(text: "Crystal Clear", emoji: "💎", value: 4)
        ]),
        QuizQuestion(text: "How does your body feel?", subtitle: "Your physical state", icon: "figure.mind.and.body", options: [
            QuizOption(text: "Tense", emoji: "😤", value: 1),
            QuizOption(text: "Restless", emoji: "🫨", value: 2),
            QuizOption(text: "Comfortable", emoji: "😌", value: 3),
            QuizOption(text: "Full of Life", emoji: "✨", value: 4)
        ])
    ]
    
    private var currentQuestion: QuizQuestion {
        questions[currentQuestionIndex]
    }
    
    private var progress: CGFloat {
        CGFloat(currentQuestionIndex + 1) / CGFloat(questions.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar (Full Width)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.divider)
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Theme.secondary, Theme.primary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 4)
                        .shadow(color: Theme.secondary.opacity(0.5), radius: 6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // Question Header
            VStack(spacing: 12) {
                HStack {
                    Text("Question \(currentQuestionIndex + 1)")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.secondary)
                    
                    Text("of \(questions.count)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                    
                    Spacer()
                    
                    Image(systemName: currentQuestion.icon)
                        .font(.title3)
                        .foregroundColor(Theme.secondary.opacity(0.6))
                        .shadow(color: Theme.secondary.opacity(0.3), radius: 5)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(currentQuestion.text)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(currentQuestion.subtitle)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .opacity(transitionOpacity)
            
            Spacer().frame(height: 24)
            
            // Options
            VStack(spacing: 12) {
                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        selectOption(option, at: index)
                    }) {
                        HStack(spacing: 16) {
                            Text(option.emoji)
                                .font(.title2)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(selectedOptionIndex == index ? Theme.secondary.opacity(0.2) : Theme.glassBackground)
                                )
                                .scaleEffect(selectedOptionIndex == index ? 1.2 : 1.0)
                                .animation(MotionAgent.bouncy, value: selectedOptionIndex)
                            
                            Text(option.text)
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.medium)
                                .foregroundColor(Theme.textPrimary)
                            
                            Spacer()
                            
                            if selectedOptionIndex == index {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Theme.secondary)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedOptionIndex == index ? Theme.secondary.opacity(0.1) : Theme.glassBackground)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    selectedOptionIndex == index ? Theme.secondary.opacity(0.4) : Theme.divider,
                                    lineWidth: 1
                                )
                        )
                        .scaleEffect(selectedOptionIndex == index ? 1.02 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedOptionIndex)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(selectedOptionIndex != nil)
                }
            }
            .padding(.horizontal, 24)
            .opacity(transitionOpacity)
            
            Spacer().frame(height: 24)
            
            // Loading overlay
            if isAnalyzing {
                VStack(spacing: 15) {
                    ProgressView()
                        .tint(Theme.secondary)
                        .scaleEffect(1.5)
                    Text("Decoding your mood...")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                }
                .padding(.vertical, 30)
            }
        }
        .background(
            ZStack {
                Theme.cardBackground
                
                // Subtle accent glow at the top
                RadialGradient(
                    colors: [Theme.secondary.opacity(0.06), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 350
                )
            }
        )
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(
                    LinearGradient(
                        colors: [Theme.textPrimary.opacity(0.15), Theme.divider],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.4), radius: 25, x: 0, y: 12)
    }
    
    private func selectOption(_ option: QuizOption, at index: Int) {
        HapticAgent.shared.playImpact(.light)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedOptionIndex = index
        }
        
        // Brief pause to show selection, then advance
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.2)) {
                transitionOpacity = 0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                totalScore += option.value
                selectedOptionIndex = nil
                
                if currentQuestionIndex < questions.count - 1 {
                    currentQuestionIndex += 1
                    withAnimation(.easeOut(duration: 0.3)) {
                        transitionOpacity = 1.0
                    }
                } else {
                    // Quiz Complete
                    HapticAgent.shared.celebrateSuccess()
                    EngagementAgent.shared.logMoodCheckIn()
                    AchievementAgent.shared.checkAndUnlock(.firstCheckIn)
                    AchievementAgent.shared.checkTimeBasedAchievements()
                    isAnalyzing = true
                    onCompletion(totalScore)
                }
            }
        }
    }
}

struct MoodQuizCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            MoodQuizCard(isAnalyzing: .constant(false), onCompletion: { _ in })
                .padding()
        }
    }
}
