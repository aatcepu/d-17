# Lesson 08 — Protocols

**File we'll work in:** `routiner/Persistence/HabitStore.swift`
**Prerequisite:** [Lesson 07](Lesson-07-Enums.md)

---

## 1. Topic

### A protocol is a contract

It lists what a type must have, without saying how:

```swift
protocol Identifiable {
    var id: ID { get }      // "you must have an id"
}
```

A type that signs the contract is said to **conform** to it:

```swift
struct Habit: Identifiable {
    var id = UUID()         // ✅ contract fulfilled
    var title: String
}
```

Miss a requirement and it won't compile. The protocol says *what*; the type
decides *how*.

> **Analogy:** a protocol is a job description. "Must be able to drive" doesn't
> say which car. Anyone who can drive qualifies, however they learned.

### Why bother? Because code can then demand a capability, not a type

```swift
func printAll<T: Identifiable>(_ items: [T]) { ... }
```

That works with `[Habit]`, `[ActivityItem]`, or any type invented next year —
as long as it has an `id`. You write the function once.

This is exactly how SwiftUI's `ForEach` works. It doesn't know what a `Habit`
is and never will. It only requires "something with a stable id", so it can tell
which row is which when the list changes.

### The protocols already in this app

| Protocol | The promise | Where |
|---|---|---|
| `Identifiable` | "I have a unique `id`" | `Habit`, `ActivityItem` |
| `Equatable` | "Two of me can be compared with `==`" | `Habit` |
| `Codable` | "I can be converted to data and back" | `Habit` |
| `Hashable` | "I can be a dictionary key / Set member" | `RootTabView.Tab` |
| `CaseIterable` | "You can list all my cases" | `ProfileView.Tab` |
| `ObservableObject` | "SwiftUI can watch me for changes" | the ViewModels |
| `View` | "I can draw myself" | every screen in the app |

### Free conformance — Swift writes the code for you

For several of these, you write the name and Swift synthesises the
implementation:

```swift
struct Habit: Identifiable, Codable, Equatable {
    // No extra code needed. Swift generates:
    //  - == (compares every property)
    //  - encode/decode (converts to and from JSON)
}
```

`Codable` is the one that feels like magic. Adding that single word is what lets
`HabitStore` turn a `[Habit]` into JSON and write it to disk.

### Writing your own protocol

The app defines one:

```swift
protocol HabitStoring {
    func load() -> [Habit]?
    func save(_ habits: [Habit])
}

struct HabitStore: HabitStoring { ... }    // the real one, uses UserDefaults
```

And the ViewModel asks for the *protocol*, not the concrete type:

```swift
private let store: HabitStoring

init(store: HabitStoring = HabitStore()) {
    self.store = store
}
```

That's **dependency injection**, and it buys two things:

1. **Testing.** A test can pass in a fake store that keeps everything in memory
   and never touches the disk — fast, and it can't corrupt real data.
2. **Change.** Swap UserDefaults for SwiftData, a file, or a server by writing
   one new type. The ViewModel and every View stay untouched, because they only
   ever knew about the contract.

The `= HabitStore()` default means normal code still just writes
`HabitListViewModel()` and gets the real thing.

### Adding conformance later, with an extension

You don't have to declare everything up front:

```swift
struct Achievement {
    let id = UUID()
    var title: String
}

extension Achievement: Identifiable {}    // conform after the fact
```

You can even do this to types you didn't write, including Apple's.

---

## 2. Practical

> **Goal:** write a protocol, then write a second type that conforms to it.

**Step 1.** Create `Models/Achievement.swift` if you haven't already (lesson 2),
and make it `Codable`:

```swift
struct Achievement: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var detail: String
    var icon: String
    var isUnlocked: Bool
}
```

Ask: **how much code did `Codable` and `Equatable` cost you?** *(One word each.)*

**Step 2.** Prove `Equatable` works. Add this temporarily in
`HabitTrackerApp.swift`:

```swift
let _ = print(Achievement.sampleData[0] == Achievement.sampleData[0])
```

It prints `true`. Now compare `[0] == [1]` — `false`. Swift generated a `==`
that compares every property, including the `id`.

**Step 3.** Now the real exercise — a fake store for testing. Create
`Persistence/InMemoryHabitStore.swift`:

```swift
import Foundation

/// A HabitStoring that keeps everything in memory. Nothing touches the disk,
/// so tests are fast and can't corrupt the user's real saved habits.
final class InMemoryHabitStore: HabitStoring {
    private var storage: [Habit]?

    /// How many times save() was called — handy for asserting in a test.
    private(set) var saveCount = 0

    init(initial: [Habit]? = nil) {
        self.storage = initial
    }

    func load() -> [Habit]? {
        storage
    }

    func save(_ habits: [Habit]) {
        storage = habits
        saveCount += 1
    }
}
```

**Step 4.** Use it. In `RootTabView.swift`, temporarily change:

```swift
@StateObject private var habitList = HabitListViewModel(store: InMemoryHabitStore())
```

⌘R. Add a habit, force-quit the app (⌘⇧H twice in the Simulator, swipe up),
relaunch. **The habit is gone** — you swapped the app's entire storage layer by
changing one word, and nothing else in the app noticed.

**Step 5.** Change it back to `HabitListViewModel()` and confirm habits survive
a relaunch again.

**Stretch:** give `InMemoryHabitStore` a `shouldFailToLoad` flag that makes
`load()` return `nil`, and use it to check the app falls back to sample data
gracefully.

---

## 3. Questions

**Q1.** In one sentence, what is a protocol?

<details><summary>Answer</summary>

A contract listing what a type must provide, without specifying how it provides
it.
</details>

**Q2.** Why does `ForEach` require `Identifiable`?

<details><summary>Answer</summary>

So it can tell items apart across redraws. With stable ids it knows which row was
added, removed or moved, and can animate just that row instead of rebuilding the
whole list.
</details>

**Q3.** How much code do you write to make `Habit` conform to `Codable`?

<details><summary>Answer</summary>

Just the word `Codable`. Swift synthesises the encoding and decoding for you, as
long as every property is itself Codable.
</details>

**Q4.** Why does `HabitListViewModel` accept a `HabitStoring` instead of a
`HabitStore`?

<details><summary>Answer</summary>

So any conforming type can be supplied — a real UserDefaults-backed store in the
app, a fake in-memory one in tests. It also means swapping the storage technology
later requires no change to the ViewModel or any View.
</details>

**Q5.** What's the practical difference between a protocol and a struct?

<details><summary>Answer</summary>

A struct is a concrete thing you can create instances of and that holds real
data. A protocol holds no data and can't be instantiated — it only describes
requirements that other types promise to meet.
</details>

---

**Next lesson:** [09 — Your first View](Lesson-09-Views-and-Stacks.md) — Part 2
begins, and we finally start drawing.
