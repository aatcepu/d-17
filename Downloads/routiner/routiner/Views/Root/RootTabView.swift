import SwiftUI

// MARK: - What is this file?
// The bottom tab bar that wraps the whole app once onboarding is done —
// Home / Explore / Add / Activity / Profile, matching the 5-icon bar in
// the Figma design. This is the "shell" screen: it doesn't draw any real
// content itself, it just decides which full screen is currently visible.

struct RootTabView: View {

    // An enum instead of raw `.tag(0)` / `.tag(1)` integers. The compiler now
    // catches a typo like `.tag(5)` (there is no fifth case), and the code
    // below reads as `newValue == .add` instead of the meaningless `== 2`.
    private enum Tab: Hashable {
        case home, explore, add, activity, profile
    }

    @State private var selectedTab: Tab = .home
    @State private var isShowingAddHabit = false

    // The habit list is created HERE, at the root, rather than inside HomeView.
    //
    // Why it moved: the "Add Habit" sheet is presented from this view so that
    // it works from any tab, and it needs the same ViewModel that Home is
    // displaying. Whoever presents the sheet has to own the data.
    // (@StateObject = "I create and own this, keep it alive as long as I'm
    // on screen". Use @ObservedObject when the object is handed to you.)
    @StateObject private var habitList = HabitListViewModel()

    var body: some View {
        TabView(selection: addTabInterceptingSelection) {
            HomeView(viewModel: habitList)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(Tab.home)

            ComingSoonView(title: "Explore", systemImage: "safari")
                .tabItem { Label("Explore", systemImage: "safari") }
                .tag(Tab.explore)

            // A placeholder to reserve the middle tab-bar slot visually.
            // Its content is never actually shown — see the binding below.
            Color.clear
                .tabItem { Label("Add", systemImage: "plus.circle.fill") }
                .tag(Tab.add)

            ComingSoonView(title: "Activity", systemImage: "chart.line.uptrend.xyaxis")
                .tabItem { Label("Activity", systemImage: "chart.line.uptrend.xyaxis") }
                .tag(Tab.activity)

            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(Tab.profile)
        }
        .tint(AppTheme.primary)
        // The sheet lives on the TabView, NOT inside HomeView.
        //
        // This is the fix for a real bug: previously the sheet was attached to
        // HomeView, so tapping "+" while on Explore/Activity/Profile set the
        // flag to true but presented nothing (the presenting view wasn't on
        // screen). Worse, the flag STAYED true, so "+" was then dead for the
        // rest of the session — even after returning to Home.
        .sheet(isPresented: $isShowingAddHabit) {
            AddHabitSheet(viewModel: habitList)
        }
    }

    // MARK: - The "+" tab
    // The centre "+" is a BUTTON wearing a tab's clothes: it should open a
    // sheet, not navigate anywhere.
    //
    // The previous version let the selection change to the Add tab and then
    // snapped it back inside `.onChange`. That works, sort of, but the tab
    // genuinely becomes selected for one frame — you can see the highlight
    // flicker across the bar and back.
    //
    // A custom Binding is the cleaner tool. `get` reports the real tab; `set`
    // simply *declines* to store `.add`, opening the sheet instead. Selection
    // never changes, so there's nothing to flicker and nothing to restore.
    private var addTabInterceptingSelection: Binding<Tab> {
        Binding(
            get: { selectedTab },
            set: { newValue in
                if newValue == .add {
                    isShowingAddHabit = true
                } else {
                    selectedTab = newValue
                }
            }
        )
    }
}

#Preview {
    RootTabView()
}
