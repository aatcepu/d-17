import SwiftUI

struct CelebrationEffect: View {
    @State private var particles: [CelebrationParticle] = []
    @State private var isActive = false
    
    let emojis = ["🌸", "🌼", "🌻", "✨", "🎊", "💜", "🍭", "💎"]
    
    var body: some View {
        ZStack {
            ForEach(particles) { particle in
                Text(particle.emoji)
                    .font(.system(size: particle.size))
                    .position(x: particle.x, y: particle.y)
                    .opacity(particle.opacity)
            }
        }
        .allowsHitTesting(false)
        .onAppear {
            HapticAgent.shared.celebrateMilestone()
            generateParticles()
        }
    }
    
    private func generateParticles() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        for i in 0..<25 {
            let delay = Double(i) * 0.08
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let particle = CelebrationParticle(
                    emoji: emojis.randomElement()!,
                    x: CGFloat.random(in: 20...(screenWidth - 20)),
                    y: -50,
                    size: CGFloat.random(in: 18...36),
                    opacity: 1.0
                )
                particles.append(particle)
                
                let index = particles.count - 1
                
                // Animate upward with drift
                withAnimation(.easeOut(duration: Double.random(in: 2.5...4.0))) {
                    if index < particles.count {
                        particles[index].y = screenHeight + 100
                        particles[index].x += CGFloat.random(in: -40...40)
                        particles[index].opacity = 0
                    }
                }
            }
        }
    }
}

struct CelebrationParticle: Identifiable {
    let id = UUID()
    let emoji: String
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double
}

struct CelebrationEffect_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CelebrationEffect()
        }
    }
}
