import Foundation

// MARK: - What is this file?
// This is the "VM" in MVVM — the ViewModel for the Home screen.
// Its job: hold the app's state (the list of habits) and the LOGIC for
// changing that state (toggle done, add a habit, delete one). The View
// (HomeView) just calls these functions and displays whatever this class
// gives it.
//
// Why bother separating this from the View at all?
// - The View file stays small and just describes layout (easy to read).
// - This class can be tested on its own, without launching any UI.
// - If tomorrow you swap SwiftUI for something else, this logic still works.

// `@MainActor` says "every property and function in here is touched on the
// main thread". UI state must only ever change on the main thread, and this
// one annotation gets the compiler to enforce that for us instead of leaving
// it to luck — the kind of bug that otherwise only shows up on a slow device.
//
// `final` means "nobody may subclass this". It's the right default: it
// documents intent and lets the compiler call methods directly instead of
// going through a lookup table.
//
// `ObservableObject` is a protocol that lets SwiftUI "watch" this class.
// Whenever a `@Published` property below changes, every View that's
// watching this object automatically redraws itself. That's the magic glue
// between ViewModel and View in SwiftUI.
@MainActor
final class HabitListViewModel: ObservableObject {

    // @Published = "announce it to SwiftUI whenever this changes".
    @Published var habits: [Habit] = [] {
        // `didSet` runs every single time `habits` changes, no matter WHICH
        // function did the changing. That's why saving lives here rather than
        // being pasted at the end of toggle/add/delete — one place, impossible
        // to forget when you add a fourth mutation later.
        didSet { store.save(habits) }
    }

    // The thing that knows how to read/write habits to disk. Declared as the
    // PROTOCOL (`HabitStoring`), not the concrete `HabitStore`, so a test can
    // pass in a fake that keeps everything in memory.
    private let store: HabitStoring

    init(store: HabitStoring = HabitStore()) {
        self.store = store

        // On a genuine first launch there's nothing saved, so seed the app
        // with the sample habits. On every later launch we restore what the
        // user actually had — including their real streaks.
        //
        // Note this assigns to the backing property directly via `habits`,
        // which triggers `didSet` and immediately writes the seed data back.
        // That's intentional: it means the very first launch is saved too.
        self.habits = store.load() ?? Habit.sampleData
    }

    // MARK: - Derived values
    // "Computed properties" — they have no storage of their own, they just
    // calculate a value on demand from `habits`. Keeping these here (rather
    // than doing the arithmetic inline in the View) means the banner on Home
    // and any future widget always agree on what "progress" means.

    var completedCount: Int {
        habits.filter(\.isDoneToday).count
    }

    var progressPercent: Double {
        // Dividing by zero would produce `nan`, and `nan` fed into SwiftUI's
        // `trim(from:to:)` draws nothing at all — a blank ring with no clue why.
        guard !habits.isEmpty else { return 0 }
        return Double(completedCount) / Double(habits.count)
    }

    /// The headline on the progress banner. This used to be the hard-coded
    /// string "Your daily goals almost done! 🔥", which cheerfully claimed you
    /// were almost finished when you'd completed nothing at all.
    var progressHeadline: String {
        switch completedCount {
        case 0 where habits.isEmpty: "Add your first habit to get started"
        case 0:                      "Let's get started on today's goals 💪"
        case habits.count:           "All done for today! Nice work 🎉"
        default:                     "Your daily goals are underway 🔥"
        }
    }

    // MARK: - Actions

    // Called when the user taps a habit row's checkbox.
    // We take the habit's `id` (not the habit itself) because arrays don't
    // let us edit a copy in place — we have to find the real one by id first.
    func toggleHabit(id: UUID) {
        // firstIndex(where:) scans the array and returns the position (Int)
        // of the first item whose id matches. `guard let` safely unwraps
        // that position, or exits the function early if none was found.
        guard let index = habits.firstIndex(where: { $0.id == id }) else { return }

        habits[index].toggleDoneToday() // reuse the logic we wrote on Habit itself
    }

    // Called when the user taps one of the "Popular Habits" preset cards.
    func addPreset(_ preset: Habit) {
        // Give it a fresh id/streak so it behaves like a brand-new habit,
        // instead of literally reusing the preset's own id.
        var newHabit = preset
        newHabit.id = UUID()
        newHabit.streak = 0
        newHabit.isDoneToday = false
        habits.append(newHabit)
    }

    /// Called when the user types a name and taps "Add".
    ///
    /// Returns `true` only if a habit was actually created. The old version
    /// returned nothing, so the sheet closed itself even when the title was
    /// blank and the habit was silently discarded — the user was told
    /// "success" by the sheet disappearing, while nothing had happened.
    @discardableResult
    func addCustomHabit(title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }

        habits.append(
            Habit(title: trimmed, subtitle: "0/1 TIMES", icon: "star.fill",
                  tintColorName: "blue", streak: 0, isDoneToday: false)
        )
        return true
    }

    /// Removes a habit. Previously there was no way at all to get rid of one —
    /// a preset added by a mis-tap was permanent.
    func deleteHabit(id: UUID) {
        habits.removeAll { $0.id == id }
    }
}
