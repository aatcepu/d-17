# Lesson 02 — Structs: your first custom type

**File we'll work in:** `routiner/Models/ActivityItem.swift`
**Prerequisite:** [Lesson 01](Lesson-01-Variables-and-Types.md)

---

## 1. Topic

### The problem structs solve

Last lesson we stored one habit's data in loose variables:

```swift
var title = "Walk"
var streak = 12
var isDoneToday = true
```

Now store a *second* habit. And a third.

```swift
var title2 = "Swim"
var streak2 = 0
// ...this is already a disaster
```

The three values belong together — they describe **one thing**. A `struct` lets
you say so, by inventing a brand-new type:

```swift
struct Habit {
    var title: String
    var streak: Int
    var isDoneToday: Bool
}
```

You've just taught Swift a new word. `Habit` is now a type, exactly as real as
`String` or `Int`.

### Making one (an "instance")

The struct is the **blueprint**. An instance is an actual thing built from it:

```swift
let walk = Habit(title: "Walk", streak: 12, isDoneToday: true)
let swim = Habit(title: "Swim", streak: 0, isDoneToday: false)
```

Notice you never wrote that `init`. Swift generates a **memberwise initialiser**
for every struct — one parameter per property, in declaration order, free.

Read values back with a dot:

```swift
print(walk.title)    // Walk
print(walk.streak)   // 12
```

### Structs are value types — this is the big idea

When you assign a struct to something else, Swift makes a **copy**. The two are
completely independent:

```swift
var a = Habit(title: "Walk", streak: 12, isDoneToday: true)
var b = a          // b is a COPY, not a shortcut to a
b.title = "Run"

print(a.title)     // "Walk"  ← unchanged
print(b.title)     // "Run"
```

This is why SwiftUI leans so heavily on structs. Nothing can reach across your
app and quietly mutate your data from somewhere else — if you're holding a
struct, you're holding *your own* copy. Whole categories of bug simply don't
exist.

> **Analogy for the room:** a struct is a photocopy, not a shared Google Doc.
> Scribbling on your copy doesn't change anyone else's.

### The real code

Open `routiner/Models/ActivityItem.swift` — it's the smallest struct in the app:

```swift
struct ActivityItem: Identifiable {
    let id = UUID()

    var title: String        // "112 points earned!"
    var timeAgo: String      // "Today, 12:34 PM"
    var isPositive: Bool     // green up-arrow or red down-arrow
}
```

Three properties, one job: describe one row in the Profile activity feed.

Ignore `: Identifiable` for now — that's lesson 8.

### Where the sample data comes from

Scroll down and you'll see:

```swift
extension ActivityItem {
    static let sampleData: [ActivityItem] = [
        ActivityItem(title: "112 points earned!", timeAgo: "Today, 12:34 PM", isPositive: true),
        // ...
    ]
}
```

Two new words:

- **`extension`** — add things to a type in a separate block. Keeps the struct
  itself clean and focused on *what an ActivityItem is*.
- **`static`** — this belongs to the *type*, not to any one instance. You write
  `ActivityItem.sampleData`, not `someItem.sampleData`. It's shared, and there's
  exactly one of it.

---

## 2. Practical

> **Goal:** design a struct from scratch, then display it.

**Step 1.** Create a new file. Right-click the `Models` folder → **New File** →
**Swift File** → name it `Achievement.swift`.

**Step 2.** Write the struct. The Profile screen has an "Achievements" tab
that's currently empty — this is the data it will one day need:

```swift
import Foundation

struct Achievement: Identifiable {
    let id = UUID()

    var title: String       // "First Week Done"
    var detail: String      // "Completed 7 days in a row"
    var icon: String        // an SF Symbol name, e.g. "trophy.fill"
    var isUnlocked: Bool
}
```

**Step 3.** Add sample data in an extension, following the exact pattern from
`ActivityItem.swift`:

```swift
extension Achievement {
    static let sampleData: [Achievement] = [
        Achievement(title: "First Step", detail: "Created your first habit",
                    icon: "figure.walk", isUnlocked: true),
        Achievement(title: "One Week", detail: "A 7 day streak",
                    icon: "flame.fill", isUnlocked: true),
        Achievement(title: "Century", detail: "100 habits completed",
                    icon: "trophy.fill", isUnlocked: false)
    ]
}
```

**Step 4.** Prove it works. Open `routiner/App/HabitTrackerApp.swift` and add
this line inside `var body: some Scene {`, above `WindowGroup`:

```swift
let _ = print("Achievements: \(Achievement.sampleData.count)")
```

⌘R and look at the console at the bottom of Xcode. It prints `Achievements: 3`.

**Step 5.** Delete that print line before moving on.

**Stretch:** add a `points: Int` property to `Achievement`. Notice Xcode
immediately flags all three sample entries as errors — the memberwise
initialiser changed the moment you added a property.

---

## 3. Questions

**Q1.** What is the difference between a struct and an instance of that struct?

<details><summary>Answer</summary>

The struct is the blueprint — a description of what properties exist. An
instance is one actual object built from that blueprint, with real values in it.
One `Habit` struct; three habits on the Home screen.
</details>

**Q2.** You never wrote an `init` for `Achievement`, yet
`Achievement(title:detail:icon:isUnlocked:)` works. Why?

<details><summary>Answer</summary>

Swift automatically generates a **memberwise initialiser** for structs — one
parameter per stored property, in the order they're declared.
</details>

**Q3.** What does this print, and why?

```swift
var a = Habit(title: "Walk", streak: 12, isDoneToday: true)
var b = a
b.streak = 99
print(a.streak)
```

<details><summary>Answer</summary>

`12`. Structs are **value types** — `b = a` copied the data. Changing `b` can't
touch `a`. This is the single most important idea in the lesson; if only one
thing survives, make it this.
</details>

**Q4.** Why is `sampleData` marked `static`?

<details><summary>Answer</summary>

Because it belongs to the type as a whole, not to any individual item. It would
make no sense for every `ActivityItem` to carry around its own copy of the full
list. You access it as `ActivityItem.sampleData`.
</details>

**Q5.** Why is the sample data put in an `extension` instead of inside the
struct's own braces?

<details><summary>Answer</summary>

Organisation. The struct body answers "what *is* an ActivityItem"; the extension
holds extra conveniences. It works identically either way — this is about
keeping the definition readable, which matters more than it sounds.
</details>

---

**Next lesson:** [03 — Functions & `mutating`](Lesson-03-Functions.md) — making
a struct *do* something, not just hold data.
