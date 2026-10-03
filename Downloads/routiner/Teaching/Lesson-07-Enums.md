# Lesson 07 — Enums

**File we'll work in:** `routiner/Views/Home/HabitRowView.swift`
**Prerequisite:** [Lesson 06](Lesson-06-Arrays-and-Loops.md)

---

## 1. Topic

### The problem: strings you have to spell right

The `Habit` model stores its colour as text:

```swift
var tintColorName: String     // "blue", "purple", "green", "orange"
```

Nothing stops you writing `"blu"`, `"Blue"`, or `"banana"`. It compiles fine and
fails silently at runtime. These are called *stringly-typed* values, and they're
a reliable source of bugs.

An **enum** is a type whose values are a fixed, named list:

```swift
enum HabitTint {
    case blue, purple, green, orange
}

let tint = HabitTint.blue
let bad  = HabitTint.banana    // ❌ won't compile — no such case
```

The typo is now impossible. Autocomplete offers you the four real options, and
the compiler rejects everything else.

### Enums can have methods and computed properties

An enum isn't just a list of labels — it's a full type:

```swift
enum HabitTint {
    case blue, purple, green, orange

    var color: Color {
        switch self {
        case .blue: .blue
        case .purple: .purple
        case .green: .green
        case .orange: .orange
        }
    }
}
```

`self` is "whichever case I am". Notice the `switch` has **no `default`** — it
doesn't need one, because all four cases are covered. Add a fifth case and this
stops compiling until you handle it. That's the enum's real superpower: the
compiler gives you a to-do list every time the type grows.

### Raw values — bridging back to strings

```swift
enum HabitTint: String {
    case blue, purple, green, orange
}

HabitTint.blue.rawValue          // "blue"
HabitTint(rawValue: "purple")    // Optional(.purple)
HabitTint(rawValue: "banana")    // nil  ← no matching case
```

Declaring `: String` gives every case a text equivalent, matching its own name
unless you say otherwise. Converting *from* a raw value returns an **optional**
(lesson 4) because the text might not match anything.

### The dot shorthand

Once Swift knows the type, you can drop the enum name:

```swift
let tint: HabitTint = .blue      // Swift already knows it's a HabitTint
case .blue: ...                  // inside a switch on HabitTint
```

That leading dot confuses beginners constantly. Say it out loud: *"the type is
already known, so I only need the case name."*

### `CaseIterable` — the list of all cases

```swift
enum Tab: String, CaseIterable {
    case activity = "Activity"
    case friends = "Friends"
    case achievements = "Achievements"
}

Tab.allCases     // [.activity, .friends, .achievements]
```

Adding `CaseIterable` gets you `allCases` for free. `ProfileView` loops over it
to build the pill switcher — so adding a fourth tab makes a fourth pill appear
with no other change. Here the raw values are set explicitly because they're
shown to the user with a capital letter.

### The real code

Two enums to look at:

**`HabitTint`** in `HabitRowView.swift` — converts the model's colour name to a
real SwiftUI colour, with a safe fallback:

```swift
init(name: String) {
    self = HabitTint(rawValue: name) ?? .blue
}
```

Unrecognised name → blue, rather than a crash or an invisible habit.

**`Tab`** in `RootTabView.swift` — replaced raw `.tag(0)`, `.tag(1)` integers:

```swift
private enum Tab: Hashable {
    case home, explore, add, activity, profile
}
```

Compare `if newValue == .add` with the old `if newValue == 2`. One says what it
means; the other requires you to go and count the tabs.

---

## 2. Practical

> **Goal:** replace a stringly-typed value with an enum.

**Step 1.** Add a new case to `HabitTint` in `HabitRowView.swift`:

```swift
enum HabitTint: String {
    case blue, purple, green, orange, pink
```

**Step 2.** ⌘B. **It fails**, and the error points at the `color` switch:
*"Switch must be exhaustive."* Xcode even offers a fix-it to add the missing
case. This is the moment the lesson lands — let them see it before fixing it.

**Step 3.** Add the case:

```swift
case .pink: .pink
```

**Step 4.** Use it. In `routiner/Models/Habit.swift`, change "Water Plants" to
`tintColorName: "pink"`. ⌘R — the leaf icon is now pink.

**Step 5.** Now break it on purpose. Change it to `tintColorName: "pinkk"`.
⌘R. The icon is **blue**, not crashed and not invisible — the `?? .blue` in
`init(name:)` caught it. Ask: *would we prefer a crash here?* (Discuss: for
colours, no. For something that affects correctness, maybe.)

**Step 6.** Add a fourth tab to `ProfileView`'s `Tab` enum:

```swift
case stats = "Stats"
```

⌘B. The switch in `body` now fails to compile — the compiler is telling you
exactly what you forgot. Add `.stats` to the existing `case .friends,
.achievements:` line and re-run. A fourth pill appears automatically, because
the switcher loops over `allCases`.

**Stretch:** the real prize — make `Habit` store `var tint: HabitTint` instead of
`var tintColorName: String`, so the invalid state can't exist at all. You'll need
`HabitTint` to be `Codable` (it is, for free, once it has a `String` raw value).

---

## 3. Questions

**Q1.** What problem does an enum solve compared to using a `String`?

<details><summary>Answer</summary>

A `String` can hold any text, so typos and invalid values compile fine and fail
at runtime. An enum has a fixed set of named cases — the compiler rejects
anything that isn't one of them, and autocomplete offers the valid options.
</details>

**Q2.** Why doesn't the `switch` inside `HabitTint.color` need a `default:`?

<details><summary>Answer</summary>

Because every case is already handled, so the switch is exhaustive. Leaving
`default` off is deliberate: if someone adds a fifth case, the compiler will
force them to handle it here rather than silently falling into a default.
</details>

**Q3.** What does `HabitTint(rawValue: "banana")` return?

<details><summary>Answer</summary>

`nil`. Creating an enum from a raw value returns an Optional, because the text
might not match any case. That's why `init(name:)` uses `?? .blue`.
</details>

**Q4.** Why can you write `.blue` instead of `HabitTint.blue` in some places?

<details><summary>Answer</summary>

Because Swift already knows the expected type from the context — the property's
declared type, or the value being switched over. When the type is known, the
case name alone is enough.
</details>

**Q5.** What does `CaseIterable` give you, and where does this app use it?

<details><summary>Answer</summary>

An `allCases` array containing every case in order. `ProfileView` loops over
`Tab.allCases` to build the Activity/Friends/Achievements switcher, so adding a
case adds a pill automatically.
</details>

---

**Next lesson:** [08 — Protocols](Lesson-08-Protocols.md)
