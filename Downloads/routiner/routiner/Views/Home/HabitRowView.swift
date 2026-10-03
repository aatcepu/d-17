import SwiftUI

// MARK: - What is this file?
// Draws ONE habit card/row (like one "Drink the water" card in the Figma
// design). Splitting it out of HomeView keeps that file short and lets us
// reuse this exact row anywhere else in the app later.

struct HabitRowView: View {

    // The data this row needs to draw itself. It does NOT own this data —
    // it's just handed a Habit to display ("passed in" from the parent view).
    let habit: Habit

    /// False when the user is looking at a day other than today, where
    /// checking a habit off would be meaningless (see HomeView).
    var isEditable: Bool = true

    // Closures (small chunks of code passed around like values) that run when
    // the user acts on this row. The parent view decides what actually happens
    // (it will call the ViewModel) — this row just reports "I was tapped".
    let onToggle: () -> Void
    var onDelete: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) { // HStack = lay children out left-to-right

            // Icon in a soft coloured circle, matching the Figma cards.
            Image(systemName: habit.icon)
                // Without an explicit size, SF Symbols render at the inherited
                // body size and each glyph optically fills its box differently —
                // so "drop.fill" and "figure.walk" came out visibly different
                // sizes, and the column of icons looked ragged.
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint.color)
                .frame(width: AppTheme.iconBubbleSize, height: AppTheme.iconBubbleSize)
                .background(Circle().fill(tint.color.opacity(0.15)))

            // VStack = lay children out top-to-bottom.
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(habit.title)
                    .font(.headline)

                HStack(spacing: AppTheme.Spacing.sm) {
                    Text(habit.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)

                    // The Model has tracked `streak` all along and no screen
                    // ever showed it — the number was computed, saved, and
                    // then thrown away. This is the payoff for the user.
                    if habit.streak > 0 {
                        Label("\(habit.streak)", systemImage: "flame.fill")
                            .font(.caption2.bold())
                            .foregroundStyle(.orange)
                    }
                }
            }

            Spacer(minLength: AppTheme.Spacing.sm) // pushes everything after it to the far right

            // Tapping this button calls the closure passed in from the parent.
            // This row NEVER edits `habit` itself — it just asks the parent to.
            Button(action: onToggle) {
                Image(systemName: habit.isDoneToday ? "checkmark.circle.fill" : "plus.circle")
                    .font(.title2)
                    .foregroundStyle(habit.isDoneToday ? Color.green : AppTheme.primary)
                    // Grows the tappable area to Apple's 44pt minimum without
                    // changing how the icon looks. The bare icon was ~22pt —
                    // half the recommended target, and easy to miss.
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!isEditable)
            .opacity(isEditable ? 1 : 0.4)
        }
        .cardStyle()
        // MARK: - Accessibility
        // Merge the row into one VoiceOver element so it reads as a single
        // sentence, and expose the checkbox as a proper toggle rather than
        // an unlabelled button.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityValue(habit.isDoneToday ? "Completed" : "Not completed")
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isEditable ? "Double tap to toggle today's completion" : "")
        .accessibilityAction { if isEditable { onToggle() } }
        // Long-press to delete. Previously a habit added by a mis-tap was
        // permanent — there was no removal path anywhere in the app.
        .contextMenu {
            if let onDelete {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete Habit", systemImage: "trash")
                }
            }
        }
    }

    private var accessibilityDescription: String {
        var parts = [habit.title, habit.subtitle]
        if habit.streak > 0 {
            parts.append("\(habit.streak) day streak")
        }
        return parts.joined(separator: ", ")
    }

    // The Model only stores a colour NAME ("blue", "purple"...), on purpose —
    // see the comment in Habit.swift. This is where that name finally turns
    // into an actual SwiftUI `Color`, right at the point it's drawn.
    private var tint: HabitTint {
        HabitTint(name: habit.tintColorName)
    }
}

// MARK: - HabitTint
// Pulled out of the view so the mapping lives in exactly one place. When the
// Explore or Activity tab eventually needs to draw a habit, it uses this too —
// rather than copy-pasting a second `switch` that slowly drifts out of sync.
enum HabitTint: String {
    case blue, purple, green, orange

    init(name: String) {
        // `?? .blue` handles a name the app doesn't recognise — e.g. data
        // saved by a newer version of the app that added a colour.
        self = HabitTint(rawValue: name) ?? .blue
    }

    var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .green: .green
        case .orange: .orange
        }
    }
}

// MARK: - Preview
// This lets Xcode show a live mini-preview of JUST this row, without
// running the whole app — handy while designing a single piece of UI.
#Preview {
    VStack(spacing: 12) {
        HabitRowView(habit: Habit.sampleData[0], onToggle: {})
        HabitRowView(habit: Habit.sampleData[1], onToggle: {})
    }
    .padding()
    .background(AppTheme.groupedBackground)
}
