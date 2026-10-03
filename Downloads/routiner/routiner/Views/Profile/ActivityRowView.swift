import SwiftUI

// MARK: - What is this file?
// One row in the Profile screen's activity feed, e.g.
// "112 points earned! · Today, 12:34 PM" with a green up arrow.
// Same idea as HabitRowView: a small, reusable, "dumb" View that just
// displays whatever ActivityItem it's handed.

struct ActivityRowView: View {
    let item: ActivityItem

    /// Green for gains, red for losses — computed once so the icon, the
    /// arrow and the ring can't drift apart.
    private var accent: Color {
        item.isPositive ? .green : .red
    }

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(item.title)
                    .font(.subheadline.bold())
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.timeAgo)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer(minLength: AppTheme.Spacing.sm)

            Image(systemName: item.isPositive ? "arrow.up" : "arrow.down")
                .font(.caption.bold())
                .foregroundStyle(accent)
                .frame(width: 28, height: 28)
                // `.stroke` on a Circle straddles the edge; `strokeBorder`
                // keeps the full 1pt line inside the frame, so the ring is an
                // even weight all the way round instead of looking pinched.
                .background(Circle().strokeBorder(accent, lineWidth: 1))
        }
        .cardStyle()
        // One element, one sentence. Otherwise VoiceOver reads the title, then
        // the timestamp, then stops on a nameless image.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(item.title) \(item.timeAgo)")
    }
}

#Preview {
    VStack(spacing: 12) {
        ActivityRowView(item: ActivityItem.sampleData[0])
        ActivityRowView(item: ActivityItem.sampleData[2])
    }
    .padding()
    .background(AppTheme.groupedBackground)
}
