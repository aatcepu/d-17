import SwiftUI

// MARK: - What is this file?
// The "Your Profile" screen: avatar + name + points, a pill-shaped
// Activity/Friends/Achievements switcher, and (for the Activity tab) the
// activity feed. Friends/Achievements are left as simple placeholders —
// wiring them up fully would mean more Models/ViewModels than this
// learning app needs, but the tab-switching pattern is fully real.

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()

    // Which of the 3 pill tabs is selected. An `enum` (a fixed list of named
    // options) is a much safer choice here than a raw Int or String — the
    // compiler won't let you accidentally write a 4th, nonexistent tab.
    private enum Tab: String, CaseIterable, Identifiable {
        case activity = "Activity"
        case friends = "Friends"
        case achievements = "Achievements"

        var id: Self { self }
    }
    @State private var selectedTab: Tab = .activity

    // Lets the pill highlight slide between tabs instead of blinking from one
    // to the next. A `Namespace` is how SwiftUI knows that the capsule on tab A
    // and the capsule on tab B are the SAME object moving.
    @Namespace private var tabHighlight

    var body: some View {
        NavigationStack {
            ZStack {
                // Same fix as HomeView: as a `.background` on the ScrollView
                // this stopped at the safe area and left white bands top and
                // bottom when the list bounced.
                AppTheme.groupedBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                        profileHeader
                        tabSwitcher

                        switch selectedTab {
                        case .activity:
                            ForEach(viewModel.activity) { item in
                                ActivityRowView(item: item)
                            }
                        case .friends, .achievements:
                            // A simple "nothing here yet" placeholder — this is
                            // where you'd add a Friends/Achievements Model + list
                            // later, following the exact same pattern as Activity.
                            comingSoonPlaceholder
                        }
                    }
                    .padding(AppTheme.screenPadding)
                    .animation(.snappy, value: selectedTab)
                }
            }
            .navigationTitle("Your Profile")
            .toolbar {
                // A gear icon in the top-right corner that pushes to Settings.
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.primary)
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
    }

    private var profileHeader: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Circle()
                .fill(AppTheme.primary.opacity(0.2))
                .frame(width: 56, height: 56)
                .overlay(
                    // `viewModel.initial` instead of `name.prefix(1)` inline —
                    // it handles an empty name, which would otherwise render
                    // as a blank purple disc. See ProfileViewModel.
                    Text(viewModel.initial)
                        .font(.title2.bold())
                        .foregroundStyle(AppTheme.primary)
                )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(viewModel.name)
                    .font(.headline)
                HStack(spacing: AppTheme.Spacing.xs) {
                    Image(systemName: "medal.fill")
                        .foregroundStyle(.orange)
                    // `.formatted()` gives "1,452" rather than "1452", and it
                    // uses the reader's own locale for the separator.
                    Text("\(viewModel.points.formatted()) Points")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            Spacer()
        }
        .accessibilityElement(children: .combine)
    }

    // The pill-shaped Activity / Friends / Achievements switcher.
    private var tabSwitcher: some View {
        HStack(spacing: AppTheme.Spacing.xs) {
            ForEach(Tab.allCases) { tab in
                // A real Button, not `Text` + `.onTapGesture`.
                //
                // `.onTapGesture` gives you a tap and nothing else: no pressed
                // state, no VoiceOver "button" trait, no Switch Control or
                // keyboard support. Swapping in a Button gets all of that for
                // free and costs nothing visually.
                Button {
                    selectedTab = tab
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.bold())
                        .foregroundStyle(selectedTab == tab ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(AppTheme.primary)
                                    .matchedGeometryEffect(id: "tabHighlight", in: tabHighlight)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selectedTab == tab ? [.isButton, .isSelected] : .isButton)
            }
        }
        .padding(AppTheme.Spacing.xs)
        .background(AppTheme.cardBackground)
        .clipShape(Capsule())
    }

    private var comingSoonPlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "hourglass")
                .font(.title)
            Text("Coming soon.")
                .font(.headline)
        }
        .foregroundStyle(AppTheme.secondaryText)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    ProfileView()
}
