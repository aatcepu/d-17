import SwiftUI

struct FloatingEmotionCluster: View {
    @State private var currentIndex = 0
    @State private var showFinale = false
    @State private var animate = false
    
    // Emojis representing the journey of emotions
    // Flow: Peaceful -> Happy -> Tired -> Stressed -> Calm (Integration)
    let emotionSequence = ["😌", "😊", "😴", "🤯", "🥰"]
    let finaleEmojis = ["🌟", "✨", "💫"] // Ambient sparkles for finale
    
    var body: some View {
        ZStack {
            // Central Glow (Breathing)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [currentColor.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 10,
                        endRadius: 120
                    )
                )
                .frame(width: 220, height: 220)
                .scaleEffect(animate ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: animate)
            
            // 1. Sequential Emotion Display
            if !showFinale {
                ForEach(0..<emotionSequence.count, id: \.self) { index in
                    if index == currentIndex {
                        Text(emotionSequence[index])
                            .font(.system(size: 80))
                            .shadow(color: currentColor.opacity(0.6), radius: 20, x: 0, y: 0)
                            .scaleEffect(animate ? 1.05 : 0.95)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .scale(scale: 0.8)),
                                removal: .opacity.combined(with: .scale(scale: 1.2))
                            ))
                            .id("emoji-\(index)") // Force redraw for transition
                    }
                }
            }
            
            // 2. Integration Finale (Softly Merged Expressions)
            if showFinale {
                ZStack {
                    // Central "Balanced" Icon
                    Text("🧘")
                        .font(.system(size: 90))
                        .shadow(color: .white.opacity(0.8), radius: 30, x: 0, y: 0)
                        .scaleEffect(animate ? 1.1 : 1.0)
                    
                    // Orbiting Emotions (Previous states integrated)
                    ForEach(0..<emotionSequence.count, id: \.self) { index in
                        Text(emotionSequence[index])
                            .font(.system(size: 30))
                            .opacity(0.6)
                            .offset(y: -70)
                            .rotationEffect(.degrees(Double(index) * (360.0 / Double(emotionSequence.count))))
                            .rotationEffect(.degrees(animate ? 360 : 0))
                            .animation(.linear(duration: 20).repeatForever(autoreverses: false), value: animate)
                    }
                }
                .transition(.opacity.animation(.easeInOut(duration: 1.5)))
            }
        }
        .frame(width: 200, height: 200)
        .onAppear {
            startAnimationCycle()
            animate = true
        }
    }
    
    // Dynamic color based on current emotion
    private var currentColor: Color {
        if showFinale { return .white }
        switch currentIndex {
        case 0: return .mint // Peaceful
        case 1: return .yellow // Happy
        case 2: return .indigo // Tired
        case 3: return .red // Stressed
        case 4: return .pink // Calm/Love
        default: return .blue
        }
    }
    
    private func startAnimationCycle() {
        // Cycle through emotions every 1.2 seconds
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            withAnimation(.easeInOut(duration: 1.0)) {
                if currentIndex < emotionSequence.count - 1 {
                    currentIndex += 1
                } else {
                    timer.invalidate()
                    // Trigger Finale
                    withAnimation(.easeInOut(duration: 2.0)) {
                        showFinale = true
                    }
                }
            }
        }
    }
}

struct FloatingEmotionCluster_Previews: PreviewProvider {
    static var previews: some View {
        FloatingEmotionCluster()
            .background(Color.black)
    }
}
