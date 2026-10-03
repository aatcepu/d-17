import SwiftUI

struct ActivitySelectionView: View {
    @Binding var selectedActivities: [String]
    @State private var flippedActivity: String? = nil
    
    let activities = [
        ("Work", "briefcase.fill", "It’s okay to feel pressured. You’re learning and growing every day."),
        ("Family", "person.2.fill", "Your connections matter. You’re doing your best, and that’s enough."),
        ("Friends", "person.3.fill", "You are valued more than you realize."),
        ("Exercise", "figure.run", "Movement is medicine. Be proud of taking care of yourself."),
        ("Sleep", "bed.double.fill", "Rest is productive. Let your body heal."),
        ("Food", "fork.knife", "Nourish yourself with kindness and good energy."),
        ("Relax", "cup.and.saucer.fill", "You deserve this time to just be."),
        ("Hobby", "paintbrush.fill", "Creativity is your soul speaking. Enjoy the process."),
        ("Outdoors", "sun.max.fill", "Nature grounds us. Breathe in the fresh air."),
        ("School", "graduationcap.fill", "Progress over perfection. Keep moving forward."),
        ("Music", "music.note", "Let the rhythm soothe your mind and soul."),
        ("Travel", "airplane", "Every journey brings new perspectives.")
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("What influenced your mood?")
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(activities, id: \.0) { activity in
                    FlipActivityCard(
                        activityName: activity.0,
                        iconName: activity.1,
                        message: activity.2,
                        isSelected: selectedActivities.contains(activity.0),
                        isFlipped: flippedActivity == activity.0,
                        onTap: {
                            SoundManager.shared.playTapSound(enabled: true)
                            // Flip logic
                            if flippedActivity == activity.0 {
                                flippedActivity = nil
                            } else {
                                flippedActivity = activity.0
                            }
                            
                            // Selection logic (optional, but requested behavior is to tap card to flip and probably select it if they are tapping it)
                            toggleActivity(activity.0)
                        }
                    )
                }
            }
        }
        .padding(24)
        .background(Theme.glassBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Theme.divider, lineWidth: 1)
        )
    }
    
    private func toggleActivity(_ activity: String) {
        if let index = selectedActivities.firstIndex(of: activity) {
            selectedActivities.remove(at: index)
        } else {
            selectedActivities.append(activity)
        }
    }
}

struct FlipActivityCard: View {
    let activityName: String
    let iconName: String
    let message: String
    let isSelected: Bool
    let isFlipped: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack {
            // BACK SIDE
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Theme.secondary.opacity(0.15))
                
                Text(message)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(Theme.secondary)
                    .multilineTextAlignment(.center)
                    .padding(8)
            }
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Theme.secondary.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Theme.secondary.opacity(0.2), radius: 6, x: 0, y: isFlipped ? 4 : 0) // Subtle depth shadow during flip
            .opacity(isFlipped ? 1 : 0)
            .rotation3DEffect(
                .degrees(isFlipped ? 0 : 180),
                axis: (x: 0, y: 1, z: 0)
            )
            
            // FRONT SIDE
            VStack(spacing: 8) {
                Image(systemName: iconName)
                    .font(.title2)
                Text(activityName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? Theme.textPrimary : Theme.textPrimary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? Theme.secondary : Theme.glassBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Theme.secondary.opacity(0.8) : Theme.divider, lineWidth: 1)
            )
            .opacity(isFlipped ? 0 : 1)
            .rotation3DEffect(
                .degrees(isFlipped ? -180 : 0),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .frame(height: 80)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                onTap()
            }
        }
    }
}

struct ActivitySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ActivitySelectionView(selectedActivities: .constant(["Work", "Exercise"]))
            .padding()
    }
}
