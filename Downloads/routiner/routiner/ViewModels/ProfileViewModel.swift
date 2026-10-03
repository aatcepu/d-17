import Foundation

// MARK: - What is this file?
// The ViewModel for the Profile screen. Holds the signed-in user's basic
// info and their activity feed. Since we have no backend, this is just
// hard-coded sample state — swap this out for real network calls later
// without ever touching ProfileView.swift.
//
// See HabitListViewModel.swift for why this is `@MainActor final`.

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var name: String = "Mert Kahveci"
    @Published var points: Int = 1452
    @Published var activity: [ActivityItem] = ActivityItem.sampleData

    /// The single letter shown in the avatar circle.
    ///
    /// This lives here rather than in the View because it has an edge case
    /// worth naming: if `name` were ever empty, `String(name.prefix(1))` gives
    /// an empty string and the avatar renders as a blank purple disc. The
    /// fallback keeps the circle looking deliberate no matter what.
    var initial: String {
        let first = name.trimmingCharacters(in: .whitespaces).first
        return first.map { String($0).uppercased() } ?? "?"
    }
}
