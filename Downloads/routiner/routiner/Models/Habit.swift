import Foundation

// MARK: - What is this file?
// This is the "M" in MVVM — the Model.
// A Model is just plain data. It does NOT know about SwiftUI, colors, buttons,
// or screens. It only describes "what a Habit IS", not "how it looks".
// Keeping it dumb like this means we could reuse this exact file in a
// completely different app (a Mac app, a widget, a watch app) with zero changes.

struct Habit: Identifiable, Codable, Equatable {

    // Identifiable is a Swift "protocol" (a contract/promise).
    // It promises: "I have a property called `id` that is unique."
    // SwiftUI needs this on anything shown in a List/ForEach so it can tell
    // habits apart (e.g. to animate the correct row when one is deleted).
    //
    // Note this is a `var`, not a `let`. It still gets a random default, so
    // nothing at the call site changes — but Swift refuses to DECODE a `let`
    // property that has a default value ("immutable property will not be
    // decoded"). Since habits are now saved to disk and read back, the id has
    // to be decodable or every habit would get a brand-new id on each launch.
    var id = UUID() // UUID() generates a random unique ID, e.g. "3F2A-91B..."

    // Basic info shown on the habit card in the Figma design.
    var title: String        // e.g. "Drink the water"
    var subtitle: String     // e.g. "500/2000 ML" — progress toward today's goal
    var icon: String         // name of an SF Symbol, e.g. "drop.fill"

    // We deliberately store a plain color NAME here, not a SwiftUI `Color`.
    // The Model shouldn't know about SwiftUI types at all — it just says
    // "this habit's theme is blue". The View decides what "blue" looks like
    // (see HabitTint in HabitRowView.swift).
    var tintColorName: String

    var streak: Int          // how many days in a row it's been completed
    var isDoneToday: Bool    // did the user already tick it off today?

    // `mutating` is required because this function CHANGES (mutates) the
    // struct's own properties. Structs are "value types" — by default their
    // functions can only read data, not write it, unless marked `mutating`.
    mutating func toggleDoneToday() {
        isDoneToday.toggle() // flips true -> false or false -> true

        // Very simple streak logic for learning purposes:
        // ticking on adds a day to the streak, un-ticking removes it.
        // (A real app would check actual calendar dates instead.)
        //
        // `max(0, ...)` is the guard rail: without it, un-ticking a habit that
        // was already at 0 would push the streak to -1, and the UI would
        // cheerfully render "-1 day streak".
        streak = max(0, streak + (isDoneToday ? 1 : -1))
    }
}

// MARK: - Sample data
// `extension` lets us add more stuff to a type in a separate, organized block.
// Here we add some starter habits so a brand-new install has something to
// display immediately, instead of opening to a blank screen.
extension Habit {
    static let sampleData: [Habit] = [
        Habit(title: "Drink the water", subtitle: "500/2000 ML", icon: "drop.fill",
              tintColorName: "blue", streak: 4, isDoneToday: false),
        Habit(title: "Walk", subtitle: "0/10000 STEPS", icon: "figure.walk",
              tintColorName: "purple", streak: 12, isDoneToday: true),
        Habit(title: "Water Plants", subtitle: "0/1 TIMES", icon: "leaf.fill",
              tintColorName: "green", streak: 0, isDoneToday: false)
    ]

    // Small starter presets the "Add Habit" sheet lets you tap instead of typing.
    // Mirrors the "Popular Habits" cards (Walk, Swim, Read) in the Figma design.
    static let popularPresets: [Habit] = [
        Habit(title: "Walk", subtitle: "10 KM", icon: "figure.walk",
              tintColorName: "orange", streak: 0, isDoneToday: false),
        Habit(title: "Swim", subtitle: "30 MIN", icon: "figure.pool.swim",
              tintColorName: "purple", streak: 0, isDoneToday: false),
        Habit(title: "Read", subtitle: "20 MIN", icon: "book.fill",
              tintColorName: "green", streak: 0, isDoneToday: false)
    ]
}
