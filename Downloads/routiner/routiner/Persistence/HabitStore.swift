import Foundation

// MARK: - What is this file?
// Saving and loading the habit list.
//
// Before this existed, every habit you created vanished the moment the app was
// closed — which, for a HABIT TRACKER, is a fairly serious problem: a "12 day
// streak" that resets on every launch isn't tracking anything.
//
// Why a separate type instead of putting this in the ViewModel?
// The ViewModel's job is "what are the habits and how do they change". Storage
// is a different job ("where do the bytes live"). Keeping them apart means you
// can swap UserDefaults for a real database, or iCloud, or a server, by
// editing only this file — the ViewModel and every View stay untouched.

/// Anything that can persist a list of habits. Programming to a protocol like
/// this is what lets tests swap in a fake store that never touches the disk.
protocol HabitStoring {
    func load() -> [Habit]?
    func save(_ habits: [Habit])
}

/// The real implementation, backed by `UserDefaults`.
///
/// UserDefaults is meant for small amounts of data, which a habit list
/// comfortably is. For thousands of records you'd reach for SwiftData or
/// a file in the Documents directory instead.
struct HabitStore: HabitStoring {

    private let key = "saved_habits_v1"
    private let defaults: UserDefaults

    // Injecting UserDefaults (rather than always using `.standard`) means a
    // test can hand in a throwaway suite and not pollute the real app's data.
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    /// Returns the saved habits, or `nil` if this is a first launch or the
    /// saved data can't be read.
    func load() -> [Habit]? {
        guard let data = defaults.data(forKey: key) else {
            return nil // nothing saved yet — a genuine first launch
        }

        do {
            return try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            // The saved blob exists but doesn't fit our current `Habit` shape —
            // usually because the Model changed between app versions.
            //
            // We deliberately do NOT crash and do NOT silently wipe the key:
            // we log it and return nil, so the app falls back to sample data
            // and the bad blob is overwritten on the next save.
            print("⚠️ HabitStore: could not decode saved habits — \(error)")
            return nil
        }
    }

    func save(_ habits: [Habit]) {
        do {
            let data = try JSONEncoder().encode(habits)
            defaults.set(data, forKey: key)
        } catch {
            print("⚠️ HabitStore: could not encode habits — \(error)")
        }
    }
}
