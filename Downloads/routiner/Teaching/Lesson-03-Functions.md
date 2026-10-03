# Lesson 03 — Functions & `mutating`

**File we'll work in:** `routiner/Models/Habit.swift`
**Prerequisite:** [Lesson 02](Lesson-02-Structs.md)

---

## 1. Topic

### A function is a named piece of work

```swift
func greet() {
    print("Hello!")
}

greet()   // call it — prints "Hello!"
```

Write it once, run it as many times as you like.

### Inputs and outputs

Functions can take values in (**parameters**) and hand a value back (**return**):

```swift
func double(number: Int) -> Int {
    return number * 2
}

let result = double(number: 5)   // 10
```

Read the signature left to right:

```
func double (number: Int) -> Int
 │      │        │     │      └─ the type it gives BACK
 │      │        │     └─ the type it takes IN
 │      │        └─ the parameter's name
 │      └─ the function's name
 └─ "I'm defining a function"
```

If a function returns nothing, there's no `->` at all. `greet()` above returns
nothing.

> **Shortcut worth showing:** when a function's body is a single expression, the
> `return` is optional. `func double(number: Int) -> Int { number * 2 }` is
> identical.

### Functions that live inside a struct

Put a function inside a struct and it can see that struct's own properties
without them being passed in:

```swift
struct Habit {
    var title: String
    var streak: Int

    func summary() -> String {
        "\(title) — \(streak) day streak"     // reads its own properties directly
    }
}

let walk = Habit(title: "Walk", streak: 12)
print(walk.summary())    // "Walk — 12 day streak"
```

A function inside a type is usually called a **method**. Same thing.

### `mutating` — the rule that trips everyone up

Try to *change* a property from inside a method and Swift refuses:

```swift
struct Habit {
    var streak: Int

    func addDay() {
        streak += 1      // ❌ Cannot assign to property: self is immutable
    }
}
```

Why? Because of lesson 2: **structs are value types**. Swift's default assumption
is that a method reads data and doesn't rearrange it. If a method *does* change
the struct, you must say so:

```swift
mutating func addDay() {
    streak += 1          // ✅ fine now
}
```

`mutating` isn't red tape. It's a label on the tin: any method without it is
guaranteed safe to call without anything changing underneath you. And it's why
this fails:

```swift
let walk = Habit(title: "Walk", streak: 12)
walk.addDay()    // ❌ Cannot use mutating member on immutable value: 'walk' is a 'let'
```

A `let` habit can't be mutated — and Swift knows `addDay()` mutates, so it stops
you. Everything connects back to lesson 1.

### The real code

Open `routiner/Models/Habit.swift`:

```swift
mutating func toggleDoneToday() {
    isDoneToday.toggle()                              // flips true <-> false

    streak = max(0, streak + (isDoneToday ? 1 : -1))
}
```

Three things to unpack:

1. **`.toggle()`** — Bool's built-in flip. Nicer than `isDoneToday = !isDoneToday`.
2. **`isDoneToday ? 1 : -1`** — the *ternary operator*. Reads as "if
   `isDoneToday` then `1` otherwise `-1`". It's an `if`/`else` squeezed into an
   expression.
3. **`max(0, ...)`** — a guard rail. Without it, un-ticking a habit already at
   zero would push the streak to **−1**, and the UI would happily display
   "−1 day streak". This is a real bug that was in this file until recently.

---

## 2. Practical

> **Goal:** write a `mutating` method and call it from a button.

**Step 1.** In `routiner/Models/Habit.swift`, add a method inside the struct,
just below `toggleDoneToday()`:

```swift
/// Wipes the streak back to zero — for when the user wants a fresh start.
mutating func resetStreak() {
    streak = 0
    isDoneToday = false
}
```

**Step 2.** Add a *non*-mutating method too, so the difference is concrete:

```swift
/// A human-readable description of the streak.
func streakDescription() -> String {
    if streak == 0 {
        "No streak yet"
    } else if streak == 1 {
        "1 day"
    } else {
        "\(streak) days"
    }
}
```

Ask the room: **why does `resetStreak` need `mutating` but `streakDescription`
doesn't?**

**Step 3.** Wire the reset up. Open
`routiner/ViewModels/HabitListViewModel.swift` and add this method next to
`toggleHabit`:

```swift
func resetStreak(id: UUID) {
    guard let index = habits.firstIndex(where: { $0.id == id }) else { return }
    habits[index].resetStreak()
}
```

**Step 4.** Add it to the long-press menu. In
`routiner/Views/Home/HabitRowView.swift`, find the `.contextMenu { ... }` block
and add a second button above the delete one:

```swift
Button {
    onResetStreak?()
} label: {
    Label("Reset Streak", systemImage: "arrow.counterclockwise")
}
```

Then add the closure property near `onDelete` at the top of the struct:

```swift
var onResetStreak: (() -> Void)? = nil
```

**Step 5.** In `routiner/Views/Home/HomeView.swift`, pass it in where
`HabitRowView` is created:

```swift
onResetStreak: { viewModel.resetStreak(id: habit.id) }
```

**Step 6.** ⌘R. Long-press "Walk" (12 day streak) → **Reset Streak**. The flame
badge disappears.

**Stretch:** use `streakDescription()` in the row instead of the bare number.

---

## 3. Questions

**Q1.** What does `-> String` mean in a function signature?

<details><summary>Answer</summary>

The function hands back a `String` when it finishes. A function with no `->`
returns nothing.
</details>

**Q2.** Why does `toggleDoneToday()` need the `mutating` keyword?

<details><summary>Answer</summary>

Because it changes the struct's own properties. Structs are value types, and
Swift requires methods that modify `self` to be marked explicitly — so you can
tell at a glance which methods change things and which only read.
</details>

**Q3.** Will this compile?

```swift
let habit = Habit(title: "Walk", subtitle: "", icon: "", tintColorName: "blue",
                  streak: 0, isDoneToday: false)
habit.toggleDoneToday()
```

<details><summary>Answer</summary>

No. `habit` is a `let`, so it can't be changed — and `toggleDoneToday()` is
`mutating`, so calling it *would* change it. Change `let` to `var` and it
compiles. This question ties lessons 1, 2 and 3 together; it's worth the time.
</details>

**Q4.** What does `isDoneToday ? 1 : -1` do?

<details><summary>Answer</summary>

It's the ternary operator: "if `isDoneToday` is true, use `1`, otherwise use
`-1`." A compact `if`/`else` that produces a value.
</details>

**Q5.** What bug does `max(0, ...)` prevent?

<details><summary>Answer</summary>

A negative streak. Un-ticking a habit subtracts 1; without the guard, a habit
sitting at 0 would drop to −1 and the app would display "−1 day streak".
`max(0, x)` returns whichever is bigger, so it never falls below zero.
</details>

---

**Next lesson:** [04 — Optionals](Lesson-04-Optionals.md) — the type that might
hold nothing at all.
