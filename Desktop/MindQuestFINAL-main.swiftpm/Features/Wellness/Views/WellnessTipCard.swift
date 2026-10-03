import SwiftUI

struct WellnessTipCard: View {
    @State private var isVisible = false
    
    private let tips = [
        ("🧘", "Breathe & Be", "Take 3 deep breaths right now. Inhale for 4 counts, hold for 4, exhale for 6."),
        ("💧", "Hydrate Your Mind", "Your brain is 75% water. Drinking a glass now can boost focus and clarity."),
        ("🌿", "Nature Break", "Even 5 minutes of looking at greenery can reduce stress by 40%."),
        ("📵", "Digital Detox", "Try 10 minutes without your phone. Let your mind wander freely."),
        ("🤗", "Gratitude Moment", "Think of 3 things that went well today, no matter how small."),
        ("🎵", "Sound Healing", "Listen to your favorite calming song. Music reduces cortisol levels naturally."),
        ("✍️", "Thought Dump", "Write down everything on your mind for 2 minutes. Don't filter, just flow."),
        ("🌅", "Sunrise Mindset", "Set one tiny intention for tomorrow. Small goals create big momentum."),
        ("🫂", "Connection Check", "Reach out to someone you care about. A simple message can brighten two days."),
        ("🧩", "Brain Play", "Do something playful for 5 minutes — doodle, hum, or solve a riddle."),
        ("🌙", "Evening Wind-Down", "Dim your lights 30 minutes before bed. Your body will thank you."),
        ("🪴", "Grow Slowly", "Progress isn't always visible. Trust that small steps accumulate."),
        ("☀️", "Light Therapy", "Spend a few minutes in natural light. It helps regulate your sleep cycle."),
        ("🎯", "One-Task Focus", "Pick one thing and give it your full attention for 15 minutes."),
        ("💜", "Self-Compassion", "Speak to yourself the way you'd speak to your best friend.")
    ]
    
    private var todaysTip: (String, String, String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return tips[(dayOfYear - 1) % tips.count]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text(todaysTip.0)
                .font(.system(size: 36))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(Theme.primary.opacity(0.12))
                )
                .overlay(
                    Circle()
                        .stroke(Theme.primary.opacity(0.2), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text("Daily Tip")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Theme.primary.opacity(0.7))
                        .textCase(.uppercase)
                        .tracking(1.5)
                    
                    Circle()
                        .fill(Theme.primary.opacity(0.4))
                        .frame(width: 4, height: 4)
                    
                    Text(todaysTip.1)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textPrimary.opacity(0.9))
                }
                
                Text(todaysTip.2)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(18)
        .background(
            ZStack {
                Theme.glassBackground
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [Theme.primary.opacity(0.1), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Theme.primary.opacity(0.25), Theme.divider.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                isVisible = true
            }
        }
    }
}

struct WellnessTipCard_Previews: PreviewProvider {
    static var previews: some View {
        WellnessTipCard()
            .padding()
            .background(Color.black)
    }
}
