# Lesson 06 — Arrays & Loops

**File we'll work in:** `routiner/ViewModels/HabitListViewModel.swift`
**Prerequisite:** [Lesson 05](Lesson-05-Conditionals.md)

---

## 1. Topic

### An array is an ordered list

```swift
var habits: [Habit] = []          // empty list of Habits
let names = ["Walk", "Swim", "Read"]
```

The square brackets are the type: `[Habit]` means "an array of Habit". You
already met one — `Habit.sampleData` is a `[Habit]`.

### The essentials

```swift
names.count            // 3
names.isEmpty          // false
names[0]               // "Walk"  ← counting starts at ZERO
names.first            // Optional("Walk")  ← see lesson 4
habits.append(newHabit)          // add to the end
habits.removeAll { $0.streak == 0 }   // remove everything matching
```

> **Warn them now:** `names[3]` on a 3-item array **crashes**. Valid indexes are
> `0` to `count - 1`. This is why `.first` returns an optional instead — it can't
> crash.

### Looping

```swift
for habit in habits {
    print(habit.title)
}
```

No index, no off-by-one, no crash. Reach for this by default.

### The powerful trio: filter, map, reduce

These replace loops you'd otherwise write by hand, and they read like sentences.

**`filter`** — keep the items matching a rule:

```swift
let done = habits.filter { $0.isDoneToday }      // only the completed ones
```

**`map`** — transform every item into something else:

```swift
let titles = habits.map { $0.title }             // [Habit] -> [String]
```

**`reduce`** — collapse the whole array to one value:

```swift
let totalStreak = habits.reduce(0) { $0 + $1.streak }
```

### What is `$0`?

Inside those braces you're writing a small unnamed function — a **closure** —
that runs once per item. `$0` is shorthand for "the item this time round".
These three are identical:

```swift
habits.filter { habit in habit.isDoneToday }    // named parameter
habits.filter { $0.isDoneToday }                // shorthand
habits.filter(\.isDoneToday)                    // key path — shortest of all
```

Show all three. Students will meet all three in real code, including in this app.

### The real code

`HabitListViewModel.swift`:

```swift
var completedCount: Int {
    habits.filter(\.isDoneToday).count
}

var progressPercent: Double {
    guard !habits.isEmpty else { return 0 }
    return Double(completedCount) / Double(habits.count)
}
```

Two things worth pausing on:

**The `guard`.** If `habits` is empty, `count` is `0`, and `0 / 0` in floating
point is `nan` ("not a number"). Feed `nan` to the progress ring and it draws
*nothing* — a blank circle with no error and no clue why. The guard is a
one-line fix for a genuinely baffling bug.

**`Double(...)`.** `completedCount` and `count` are both `Int`, and `Int`
division throws away the remainder — `1 / 3` is `0`, not `0.333`. Converting to
`Double` first is what makes the percentage work at all.

These are both computed properties (lesson 2's `static` cousin): they store
nothing and recalculate on demand, so they can never disagree with `habits`.

---

## 2. Practical

> **Goal:** use `filter`, `map` and `reduce` on real app data.

**Step 1.** In `HabitListViewModel.swift`, add these three computed properties
below `progressPercent`:

```swift
/// Every habit that has never been completed.
var neverStarted: [Habit] {
    habits.filter { $0.streak == 0 }
}

/// Just the names, for a summary line.
var allTitles: [String] {
    habits.map(\.title)
}

/// Every streak added together.
var totalStreakDays: Int {
    habits.reduce(0) { runningTotal, habit in
        runningTotal + habit.streak
    }
}
```

**Step 2.** Show `totalStreakDays` on screen. In
`routiner/Views/Home/HomeView.swift`, find `habitsSection` and add this just
below the `Text("Habits")` line's enclosing `HStack`:

```swift
Text("\(viewModel.totalStreakDays) total streak days across \(viewModel.habits.count) habits")
    .font(.caption)
    .foregroundStyle(AppTheme.secondaryText)
```

**Step 3.** ⌘R. With the default data it reads **16 total streak days**
(4 + 12 + 0).

**Step 4.** Tap the **+** on a habit and watch the number climb. The computed
property recalculates every time — you never told it to.

**Step 5.** Prove the empty-array guard matters. Long-press each habit → Delete,
until the list is empty. The progress ring shows **0%**, not a blank. Now
temporarily delete the `guard` line from `progressPercent`, re-run, delete all
habits again, and watch the ring vanish entirely.

Put the guard back.

**Stretch:** write `longestStreak` using `reduce`, then find the one-word
version. *(`habits.map(\.streak).max()` — returns an optional, because an empty
array has no maximum.)*

---

## 3. Questions

**Q1.** What does `[Habit]` mean?

<details><summary>Answer</summary>

An array of `Habit` values — an ordered list where every element is a `Habit`.
</details>

**Q2.** `names` has 3 items. What does `names[3]` do?

<details><summary>Answer</summary>

Crashes — "Index out of range". Valid indexes run `0` to `count - 1`, so `0`,
`1`, `2`. This is exactly why `.first` and `.last` return optionals instead of
crashing.
</details>

**Q3.** What's the difference between `filter` and `map`?

<details><summary>Answer</summary>

`filter` keeps or discards items — same type out, possibly fewer of them.
`map` transforms every item — same *number* out, possibly a different type
(`[Habit]` → `[String]`).
</details>

**Q4.** What is `$0`?

<details><summary>Answer</summary>

Shorthand for the first parameter of the closure — the current item on this pass
through the array. `habits.filter { $0.isDoneToday }` reads as "keep each habit
where *that habit's* `isDoneToday` is true".
</details>

**Q5.** Why does `progressPercent` guard against an empty array?

<details><summary>Answer</summary>

Dividing by zero produces `nan` in floating-point maths. `nan` fed into
SwiftUI's `trim(from:to:)` draws nothing at all, so the progress ring silently
disappears with no error message. Returning `0` early avoids it.
</details>

**Q6.** Why are the values wrapped in `Double(...)` before dividing?

<details><summary>Answer</summary>

Both are `Int`s, and integer division discards the fraction — `1 / 3` is `0`.
Converting to `Double` first keeps the decimal, so 1 of 3 gives `0.333`.
</details>

---

**Next lesson:** [07 — Enums](Lesson-07-Enums.md)
