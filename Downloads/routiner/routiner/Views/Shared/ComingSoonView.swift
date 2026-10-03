import SwiftUI

// MARK: - What is this file?
// A tiny reusable placeholder screen. The Figma design has 5 tabs (Home,
// Explore, Add, Activity, Profile) but this learning app only fully builds
// Home and Profile. Rather than skip the tab bar entirely, we show a
// friendly placeholder for Explore/Activity — so the navigation structure
// still matches the real design, and it's obvious where you'd plug in a
// real screen later (just swap this View out in RootTabView.swift).

struct ComingSoonView: View {
    let title: String
    let systemImage: String

    var body: some View {
        NavigationStack {
            ZStack {
                // Without this the placeholder sat on the default system
                // background while every other tab used the app's grouped
                // grey — switching tabs produced a visible colour jump.
                AppTheme.groupedBackground
                    .ignoresSafeArea()

                // ContentUnavailableView is Apple's built-in "there's nothing
                // here" layout. Using it instead of a hand-rolled VStack means
                // the spacing, weights and Dynamic Type behaviour match every
                // other empty state in iOS for free.
                ContentUnavailableView(
                    "\(title) is coming soon",
                    systemImage: systemImage,
                    description: Text("We're still building this one. Check back later!")
                )
            }
            .navigationTitle(title)
        }
    }
}

#Preview {
    ComingSoonView(title: "Explore", systemImage: "safari")
}
