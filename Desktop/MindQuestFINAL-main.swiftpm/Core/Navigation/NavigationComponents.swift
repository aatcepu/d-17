import SwiftUI

struct AppHeader: View {
    let title: String
    var subtitle: String? = nil
    var showBackButton: Bool = false
    var backAction: (() -> Void)? = nil
    var trailingView: AnyView? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if showBackButton {
                Button(action: {
                    if let action = backAction {
                        action()
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Theme.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(Theme.glassBackground)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.divider, lineWidth: 0.5))
                }
                .transition(.scale.combined(with: .opacity))
                .accessibilityLabel("Back")
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            Spacer()
            
            if let trailingView = trailingView {
                trailingView
            }
        }
        .padding(.horizontal, Theme.paddingStandard)
        .frame(height: Theme.headerHeight)
        .background(
            Color.clear
        )
    }
}

// Custom Back Button for sub-navigation screens
struct CustomBackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .fontWeight(.bold)
                Text("Back")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
            }
            .foregroundColor(Theme.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Theme.glassBackground)
            .cornerRadius(12)
        }
    }
}

extension View {
    func asAnyView() -> AnyView {
        AnyView(self)
    }
}
