import SwiftUI

// MARK: - What is this file?
// The main screen — the "Hi, Mert" screen with the calendar strip, the
// daily-goal progress banner, and the habit list. This file should mostly
// describe LAYOUT ("what goes where"); the actual logic (toggling habits,
// calculating progress) lives in HabitListViewModel, which this screen just
// displays.

struct HomeView: View {

    // @ObservedObject, not @StateObject: this screen no longer CREATES the
    // ViewModel, it's handed the one RootTabView owns. (Rule of thumb:
    // @StateObject where the object is born, @ObservedObject everywhere it's
    // passed to.) This is what lets the Add-Habit sheet — presented way up in
    // RootTabView — add to the very same list this screen is showing.
    @ObservedObject var viewModel: HabitListViewModel

    // Normalised to midnight so it can be compared against the calendar
    // strip's dates without the time-of-day getting in the way.
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    /// Is the user looking at today, or scrolled back to another day?
    private var isViewingToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var body: some View {
        NavigationStack {
            // The background lives in a ZStack behind the ScrollView rather
            // than as a `.background` on it. Applied to the ScrollView, the
            // colour stopped at the safe area, so the notch strip and the
            // rubber-band area at the bottom of a bounce both flashed white.
            ZStack {
                AppTheme.groupedBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                        header

                        CalendarStripView(selectedDate: $selectedDate)

                        progressBanner

                        habitsSection
                    }
                    .padding(AppTheme.screenPadding)
                }
            }
            // `.navigationBarHidden(true)` has been deprecated since iOS 16.
            // This is the current spelling, and it's more precise: it says
            // which bar, in which context.
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    // MARK: - Pieces of the layout
    // Small chunks pulled into computed properties. This is a common SwiftUI
    // trick: it keeps `body` readable by giving each chunk a descriptive name,
    // without creating a whole separate file for it.

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text("Hi, Mert 👋")
                    .font(.title2.bold())
                Text("Let's make habits together!")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            // Icon-only controls are invisible to VoiceOver unless you name
            // them — without the label this reads out as just "button".
            Button {
                // Notifications aren't built yet; the bell is decorative for now.
            } label: {
                Image(systemName: "bell.fill")
                    .font(.title3)
                    .foregroundStyle(.primary)
            }
            .accessibilityLabel("Notifications")
        }
    }

    private var progressBanner: some View {
        HStack(spacing: AppTheme.Spacing.lg) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                // The headline now comes from the ViewModel and reflects real
                // progress. It used to be the hard-coded string "Your daily
                // goals almost done!", which claimed you were nearly finished
                // even when you'd completed nothing.
                Text(viewModel.progressHeadline)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(viewModel.completedCount) of \(viewModel.habits.count) completed")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.85))
            }

            Spacer(minLength: 0)

            progressRing
        }
        .padding(AppTheme.Spacing.lg)
        .background(
            LinearGradient(colors: [AppTheme.gradientTop, AppTheme.gradientBottom],
                           startPoint: .leading, endPoint: .trailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.large, style: .continuous))
        // One accessibility element for the whole banner. Otherwise VoiceOver
        // stops on the headline, the count, and the ring's "40%" separately.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(viewModel.progressHeadline). \(viewModel.completedCount) of \(viewModel.habits.count) habits completed."
        )
    }

    // A simple ring built from two overlapping circles: a light background
    // track, and a foreground arc trimmed to the current progress percentage.
    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.3), lineWidth: 5)

            Circle()
                // trim(from:to:) only draws part of the circle's outline —
                // "to: 0.25" draws just the first quarter of it, for example.
                .trim(from: 0, to: viewModel.progressPercent)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90)) // start the arc from the top

            Text("\(Int(viewModel.progressPercent * 100))%")
                .font(.caption2.bold())
                .foregroundStyle(.white)
        }
        .frame(width: AppTheme.iconBubbleSize, height: AppTheme.iconBubbleSize)
        // Without this the ring snaps between values; now it sweeps.
        .animation(.easeInOut(duration: 0.35), value: viewModel.progressPercent)
    }

    private var habitsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            HStack {
                Text("Habits")
                    .font(.title3.bold())
                Spacer()
                Text(isViewingToday ? "Today" : selectedDate.formatted(.dateTime.day().month(.wide)))
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            // Picking a past day used to look like it worked, but ticking a
            // habit there silently edited TODAY's record — the app has no
            // per-day history yet. Saying so plainly beats quietly lying.
            if !isViewingToday {
                Text("Habit history isn't tracked yet — you can only check off today's habits.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if viewModel.habits.isEmpty {
                emptyState
            } else {
                // ForEach loops over the ViewModel's habits array and creates
                // one HabitRowView per habit. Habit conforms to Identifiable,
                // so SwiftUI can tell rows apart automatically.
                ForEach(viewModel.habits) { habit in
                    HabitRowView(
                        habit: habit,
                        isEditable: isViewingToday,
                        onToggle: {
                            // This closure runs when the row's checkbox is tapped.
                            // Notice: the View doesn't change the habit itself,
                            // it just tells the ViewModel to do it.
                            viewModel.toggleHabit(id: habit.id)
                        },
                        onDelete: { viewModel.deleteHabit(id: habit.id) }
                    )
                }
            }
        }
        // Rows slide into place instead of appearing instantly when one is
        // added or deleted.
        .animation(.snappy, value: viewModel.habits)
    }

    // An empty list used to render as simply nothing at all — a blank space
    // under the "Habits" heading with no explanation and no way forward.
    private var emptyState: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "sparkles")
                .font(.title)
                .foregroundStyle(AppTheme.primary)
            Text("No habits yet")
                .font(.headline)
            Text("Tap the + button below to add your first one.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.Spacing.xxl)
        .cardStyle()
    }
}

#Preview {
    HomeView(viewModel: HabitListViewModel())
}
