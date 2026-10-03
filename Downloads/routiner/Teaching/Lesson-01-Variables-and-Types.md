# Lesson 01 — Variables, Constants & Types

**File we'll work in:** `routiner/Models/Habit.swift`
**Prerequisite:** none. This is day one.

---

## 1. Topic

### A variable is a labelled box

When an app needs to remember something — a habit's name, how many days a
streak has run — it puts that value in a box and writes a label on it.

Swift has two kinds of box:

```swift
var streak = 4      // var = variable. You can change what's inside.
let id = UUID()     // let = constant. Once set, it's sealed forever.
```

Try to change a `let` and the app won't even build:

```swift
let title = "Walk"
title = "Swim"      // ❌ Cannot assign to value: 'title' is a 'let' constant
```

That looks like Swift being annoying. It isn't — it's Swift catching a bug at
build time instead of letting it happen to a user. If a value should never
change, saying so out loud means it *can't* change by accident.

> **Teach this rule:** always start with `let`. Only change it to `var` when the
> compiler complains that you need to. Most values genuinely never change, and
> code full of `var` is code where anything could be modified from anywhere.

### Every box has a type

A box that holds text can't suddenly hold a number. The **type** is what kind of
value is allowed in:

| Type | Holds | Example from this app |
|---|---|---|
| `String` | Text | `"Drink the water"` |
| `Int` | Whole number | `4` (the streak) |
| `Bool` | True or false | `false` (is it done today?) |
| `Double` | Decimal number | `0.75` (progress percentage) |

### Type inference — Swift guesses, and it's good at it

You rarely write the type down. Swift reads the starting value and works it out:

```swift
var streak = 4              // Swift infers Int
var title = "Walk"          // Swift infers String
var isDoneToday = false     // Swift infers Bool
```

You *can* be explicit, and sometimes you must — when there's no starting value
to infer from:

```swift
var streak: Int = 4         // same thing, written out
var errorMessage: String?   // no starting value, so the type is required
```

### Now open the real code

Open `routiner/Models/Habit.swift` and look at lines 15–35. Every property is
one of the four types above:

```swift
var title: String        // e.g. "Drink the water"
var subtitle: String     // e.g. "500/2000 ML"
var icon: String         // an SF Symbol name, e.g. "drop.fill"
var tintColorName: String
var streak: Int          // how many days in a row
var isDoneToday: Bool    // ticked off today?
```

Ask the room: *why is `streak` an `Int` and not a `String`?*
Because you'll want to do arithmetic on it — `streak + 1`. You can't add 1 to
the text `"4"`.

---

## 2. Practical

> **Goal:** add a new piece of data to a habit and watch it flow to the screen.

**Step 1.** Open `routiner/Models/Habit.swift`. Below `var isDoneToday: Bool`,
add a new property:

```swift
var isFavourite: Bool
```

**Step 2.** Press ⌘B. **It will fail.** Read the error — Swift says the calls
that create a `Habit` are now missing an argument. That's the type system doing
its job: you added a required piece of data, so every habit must supply it.

**Step 3.** Fix the sample data further down the same file. Add
`isFavourite: true` to the first habit and `isFavourite: false` to the rest:

```swift
Habit(title: "Drink the water", subtitle: "500/2000 ML", icon: "drop.fill",
      tintColorName: "blue", streak: 4, isDoneToday: false, isFavourite: true),
```

Do the same for `popularPresets` (all `false`).

**Step 4.** ⌘B until it builds clean.

**Step 5.** Now show it on screen. Open `routiner/Views/Home/HabitRowView.swift`
and find the `Text(habit.title)` line. Change it to:

```swift
Text(habit.isFavourite ? "⭐️ \(habit.title)" : habit.title)
```

**Step 6.** ⌘R. "Drink the water" now has a star.

**Stretch (for anyone who finishes early):** change `isFavourite` from `var` to
`let`. Does it still build? *(Yes — nothing changes it yet.)* Now make the star
tappable... and discover why it needs to be `var`. That's lesson 3.

---

## 3. Questions

Ask these aloud. Answers are folded away so you can project this file safely.

**Q1.** What's the difference between `let` and `var`?

<details><summary>Answer</summary>

`var` can be reassigned after it's created; `let` cannot. `let` is a promise to
the compiler — and to the next person reading the code — that this value is
fixed.
</details>

**Q2.** Look at `let id = UUID()` in `Habit.swift`. Why is the id a `let` and
the title a `var`?

<details><summary>Answer</summary>

A habit's identity must never change — that's how the app tells one habit from
another in a list. The title is something the user might rename, so it has to be
changeable.

*(Note: in the current code the id is actually a `var`, for a reason covered in
lesson 14 — saving to disk. Good spot if a student catches it.)*
</details>

**Q3.** What type would Swift infer for each of these?

```swift
var a = 10
var b = 10.5
var c = "10"
var d = true
```

<details><summary>Answer</summary>

`Int`, `Double`, `String`, `Bool`. Point out `c` — quotes make it text, even
though it looks like a number.
</details>

**Q4.** This line doesn't compile. Why?

```swift
var streak = 4
streak = "four"
```

<details><summary>Answer</summary>

`streak` was inferred as `Int` when it was created, and its type is fixed for
life. You can put a different *number* in the box, never a different *kind* of
thing.
</details>

**Q5.** Why does Swift make you declare the type here, when it doesn't usually?

```swift
var errorMessage: String?
```

<details><summary>Answer</summary>

There's no starting value, so there's nothing for Swift to infer from. No
value means you must say what kind of value it will eventually hold.
</details>

---

**Next lesson:** [02 — Structs](Lesson-02-Structs.md) — where those properties
actually live.
