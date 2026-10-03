import SwiftUI

struct PremiumSectionCard<Content: View>: View {
    let title: String
    let icon: String
    let accentColor: Color
    let content: Content
    
    init(title: String, icon: String, accentColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(accentColor)
                    .font(.headline)
                    .shadow(color: accentColor.opacity(0.5), radius: 5, x: 0, y: 0)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            content
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .background(
            ZStack {
                Theme.glassBackground
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [accentColor.opacity(0.12), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [accentColor.opacity(0.4), Theme.divider.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct EnhancedBadgeView: View {
    let icon: String
    let name: String
    let isUnlocked: Bool
    let accentColor: Color = Theme.accent
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Outer Glow
                if isUnlocked {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 68, height: 68)
                        .blur(radius: 5)
                }
                
                // Main Circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isUnlocked ? [accentColor.opacity(0.2), accentColor.opacity(0.05)] : [Theme.glassBackground, Theme.glassBackground.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: isUnlocked ? [accentColor.opacity(0.6), accentColor.opacity(0.1)] : [Theme.divider, Theme.divider.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Icon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? accentColor : Theme.textSecondary)
                    .shadow(color: isUnlocked ? accentColor.opacity(0.5) : .clear, radius: 5, x: 0, y: 0)
            }
            .scaleEffect(isUnlocked ? 1.0 : 0.95)
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isUnlocked)
            
            Text(name)
                .font(.caption)
                .fontWeight(isUnlocked ? .medium : .regular)
                .foregroundColor(isUnlocked ? Theme.textPrimary : Theme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 70)
        }
        .grayscale(isUnlocked ? 0 : 0.8)
    }
}

struct PremiumProfileRow: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(accentColor)
                }
                
                Text(title)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(Theme.textPrimary)
        }
        .padding(.vertical, 8)
    }
}

struct PremiumToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    let accentColor: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(accentColor)
                }
                
                Text(title)
                    .foregroundColor(Theme.textSecondary)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(accentColor)
        }
        .padding(.vertical, 8)
    }
}
