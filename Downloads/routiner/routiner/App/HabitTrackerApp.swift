import SwiftUI

// MARK: - What is this file?
// This is the entry point of the whole app — the very first thing that runs.
// Every SwiftUI app needs exactly one type marked `@main` conforming to `App`.
// Its job here: decide whether to show Onboarding or the main app, apply the
// user's appearance preference, and show it all inside a window.

@main
struct HabitTrackerApp: App {
    // Reads the same flag that LoginView.swift writes to. Because it's
    // @AppStorage (backed by UserDefaults), this value survives the app
    // being closed and reopened — so a returning user skips onboarding.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    // The Dark Mode switch in Settings writes to this key. Reading it HERE, at
    // the root, is what makes that switch actually do something.
    //
    // Previously SettingsView happily saved this value and absolutely nothing
    // read it back — the toggle animated, persisted across launches, and had
    // no effect whatsoever on the app's appearance.
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false

    var body: some Scene {
        // WindowGroup represents the app's window (on iPhone, effectively
        // just "the screen").
        WindowGroup {
            // `Group` exists purely to give the if/else a single view to hang
            // the modifier on. `.preferredColorScheme` is a VIEW modifier, so
            // it belongs in here — applying it to the WindowGroup itself
            // doesn't compile, because a Scene isn't a View.
            Group {
                if hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView()
                }
            }
            // `.dark` forces dark mode; `nil` means "follow whatever the system
            // is set to". Deliberately NOT `.light` — forcing light mode on
            // someone whose phone is in dark mode would be worse than leaving
            // it alone.
            .preferredColorScheme(darkModeEnabled ? .dark : nil)
        }
    }
}
