import SwiftUI

struct PremiumResultCard: View {
    let title: String
    let subtitle: String?
    let content: String?
    let icon: String
    let accentColor: Color
    var isQuest: Bool = false
    var action: (() -> Void)? = nil
    var actionText: String? = nil
    
    var body: some View {
        let cardContent = VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(accentColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(accentColor.opacity(0.1))
                    )
                    .overlay(
                        Circle()
                            .stroke(accentColor.opacity(0.3), lineWidth: 1)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Theme.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                
                Spacer()
                
                if isQuest {
                    Image(systemName: "crown.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                        .padding(6)
                        .background(Color.yellow.opacity(0.2))
                        .clipShape(Circle())
                }
            }
            
            // Content
            if let content = content {
                Text(content)
                    .font(.body)
                    .foregroundColor(Theme.textPrimary.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Action Button (if present)
            if let action = action, let actionText = actionText {
                Button(action: {
                    SoundManager.shared.playTapSound(enabled: true)
                    action()
                }) {
                    HStack {
                        Text(actionText)
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(Theme.deepBlack)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [accentColor, accentColor.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(SubtleTapButtonStyle())
                .padding(.top, 8)
            }
        }
        .padding(24)
        .background(
            ZStack {
                // Glass Background
                Theme.glassBackground
                
                // Spotlight Gradient
                RadialGradient(
                    colors: [accentColor.opacity(0.18), .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 300
                )
            }
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [accentColor.opacity(0.5), Theme.divider.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)

        if action != nil && actionText == nil {
            Button(action: {
                SoundManager.shared.playTapSound(enabled: true)
                action?()
            }) {
                cardContent
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            cardContent
        }
    }
}

struct PremiumResultCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PremiumResultCard(
                title: "AI Analysis",
                subtitle: "Predicted Mood",
                content: "You seem to be in high spirits! Keep riding this wave of positivity.",
                icon: "brain.head.profile",
                accentColor: .blue
            )
            
            PremiumResultCard(
                title: "Today's Quest",
                subtitle: "Creative Explosion",
                content: "Turn your energy into art! Spend 5 minutes sketching whatever comes to mind.",
                icon: "paintbrush.fill",
                accentColor: .purple,
                isQuest: true,
                action: {},
                actionText: "Start Quest"
            )
        }
        .padding()
        .background(Color.black)
    }
}
