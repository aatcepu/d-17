import SwiftUI

// MARK: - What is this file?
// The Settings screen, styled like the native iOS Settings app (which is
// exactly what the Figma design is going for). `List` with `.insetGrouped`
// style gives us those rounded sections for free — no manual card drawing
// needed like on Home/Profile.

struct SettingsView: View {
    // @AppStorage automatically saves these to the device (UserDefaults)
    // and restores them next launch, so a toggle here actually "sticks" —
    // a nice tiny example of real persistence without a database.
    //
    // `darkModeEnabled` is read at the app's root (HabitTrackerApp.swift),
    // which is what makes it take effect. Until that was wired up this switch
    // saved its value diligently and changed absolutely nothing on screen.
    @AppStorage("darkModeEnabled") private var darkModeEnabled = false
    @AppStorage("soundsEnabled") private var soundsEnabled = true

    // This was `@State`, which meant it silently reset to false every time you
    // left the screen — the odd one out among three toggles that all looked
    // identical to the user.
    @AppStorage("vacationModeEnabled") private var vacationModeEnabled = false

    var body: some View {
        List {
            Section {
                NavigationLink("General") { placeholder("General settings") }

                Toggle(isOn: $darkModeEnabled) {
                    Label("Dark Mode", systemImage: "moon.fill")
                }

                NavigationLink("Security") { placeholder("Security settings") }
                NavigationLink("Notifications") { placeholder("Notification settings") }

                Toggle(isOn: $soundsEnabled) {
                    Label("Sounds", systemImage: "speaker.wave.2.fill")
                }

                Toggle(isOn: $vacationModeEnabled) {
                    Label("Vacation Mode", systemImage: "beach.umbrella.fill")
                }
            } header: {
                Text("General")
            } footer: {
                // Explains the one bit of behaviour that isn't obvious: turning
                // the switch OFF hands control back to the system rather than
                // forcing light mode.
                Text("When Dark Mode is off, Routiner follows your device's appearance setting.")
            }

            Section("About Us") {
                NavigationLink("Rate Routiner") { placeholder("App Store rating flow") }
                NavigationLink("Share with Friends") { placeholder("Share sheet") }
                NavigationLink("About Us") { placeholder("About screen") }
                NavigationLink("Support") { placeholder("Support and contact") }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// One shared placeholder instead of eight one-off `Text` views. Each
    /// destination now at least gets a title in the nav bar, so you can tell
    /// where you are after tapping through.
    private func placeholder(_ name: String) -> some View {
        ContentUnavailableView(
            name,
            systemImage: "hammer.fill",
            description: Text("This screen hasn't been built yet.")
        )
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
