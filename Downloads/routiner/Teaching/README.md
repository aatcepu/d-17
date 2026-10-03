# Teaching Swift & SwiftUI with Routiner

A 14-lesson beginner course built around **one real app** — the Routiner habit
tracker in this repository.

Students never write throwaway code in a playground. Every lesson explains one
topic, then has them change a real file in an app that runs on their phone.
By lesson 14 they haven't built a toy; they've read, understood and modified a
complete app.

---

## How each session runs

Every lesson file has the same three sections, matching the teaching pattern:

| Section | What you do | Rough time |
|---|---|---|
| **1. Topic** | You explain the concept and show the real code in this app that uses it | 15 min |
| **2. Practical** | Students make a specific change and run it | 25 min |
| **3. Questions** | You ask; answers are included for you, hidden from them | 10 min |

The questions are written to be **asked aloud**, not handed out. Answers live in
a collapsed `<details>` block — safe to show on a projector, since it stays shut
until you click it.

---

## The course map

### Part 1 — The Swift language (no UI yet)

| # | Lesson | The app file it lives in |
|---|---|---|
| 01 | [Variables, Constants & Types](Lesson-01-Variables-and-Types.md) | `Models/Habit.swift` |
| 02 | [Structs — your first custom type](Lesson-02-Structs.md) | `Models/Habit.swift` |
| 03 | [Functions & `mutating`](Lesson-03-Functions.md) | `Models/Habit.swift` |
| 04 | [Optionals](Lesson-04-Optionals.md) | `Views/Onboarding/LoginView.swift` |
| 05 | [Conditionals — if / else if / else](Lesson-05-Conditionals.md) | `Views/Onboarding/LoginView.swift` |
| 06 | [Arrays & Loops](Lesson-06-Arrays-and-Loops.md) | `ViewModels/HabitListViewModel.swift` |
| 07 | [Enums](Lesson-07-Enums.md) | `Views/Home/HabitRowView.swift` |
| 08 | [Protocols](Lesson-08-Protocols.md) | `Persistence/HabitStore.swift` |

### Part 2 — SwiftUI

| # | Lesson | The app file it lives in |
|---|---|---|
| 09 | [Your first View — stacks & modifiers](Lesson-09-Views-and-Stacks.md) | `Views/Profile/ActivityRowView.swift` |
| 10 | [`@State` and `@Binding`](Lesson-10-State-and-Binding.md) | `Views/Home/CalendarStripView.swift` |
| 11 | [Lists with `ForEach`](Lesson-11-ForEach-and-Lists.md) | `Views/Home/HomeView.swift` |
| 12 | [MVVM & `ObservableObject`](Lesson-12-MVVM.md) | `ViewModels/HabitListViewModel.swift` |
| 13 | [Navigation — tabs, stacks & sheets](Lesson-13-Navigation.md) | `Views/Root/RootTabView.swift` |
| 14 | [Saving data](Lesson-14-Persistence.md) | `Persistence/HabitStore.swift` |

---

## Before lesson 1 — set the room up

**Every student needs:** a Mac, Xcode installed, and this project folder.

**Run the app on the Simulator, not a physical iPhone.** Running on a real
device requires the Xcode version to be newer than the phone's iOS version, and
that mismatch produces a confusing "the data couldn't be read because it is
missing" error that will eat your lesson. The Simulator has no such constraint.

To run:

```bash
open routiner.xcodeproj
```

Then pick **iPhone 16 Pro** from the device menu at the top and press ⌘R.

Teach them these three shortcuts on day one and repeat them every week:

| Shortcut | What it does |
|---|---|
| ⌘R | Run the app |
| ⌘B | Build only (check for errors without running) |
| ⌘⇧K | Clean — the first thing to try when Xcode is being irrational |

---

## A note on the code comments

Every file in `routiner/` is already commented in a teaching voice — each one
opens with a `// MARK: - What is this file?` block explaining its job in plain
English. Students can read the app on their own between sessions, and the
comments answer the "but *why* is it written this way?" question that a
reference manual never does.

If you change the code, keep that style. It's the actual textbook.

---

## Recovering a broken project

Beginners will break things. The two most common:

**"Expressions are not allowed at the top level" / hundreds of errors suddenly**
They pasted text (or a chat message) into a `.swift` file. Swift is trying to
compile English. Find the file with the errors, delete the pasted text, ⌘B.

**"Invalid redeclaration of ..." or "'main' attribute can only apply to one type"**
They duplicated a file. There must be exactly **one** `@main` in the whole
project. Check with:

```bash
grep -rl "@main" routiner/
```

That should print exactly one path: `routiner/App/HabitTrackerApp.swift`.
