import SwiftUI

struct PremiumCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(24)
            .background(
                ZStack {
                    Theme.glassBackground
                    
                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [Color.white.opacity(0.1), Color.clear],
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
                            colors: [Color.white.opacity(0.3), Theme.divider.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

extension View {
    func premiumCardStyle() -> some View {
        self.modifier(PremiumCardModifier())
    }
}

struct PremiumDataRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18, weight: .bold))
            }
            
            Text(title)
                .foregroundColor(Theme.textSecondary)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .foregroundColor(Theme.textPrimary)
        }
    }
}
