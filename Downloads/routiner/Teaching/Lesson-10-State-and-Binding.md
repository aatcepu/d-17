# Lesson 10 — `@State` and `@Binding`

**File we'll work in:** `routiner/Views/Home/CalendarStripView.swift`
**Prerequisite:** [Lesson 09](Lesson-09-Views-and-Stacks.md)

---

## 1. Topic

### The puzzle

Views are structs. Structs are value types (lesson 2). So how does a view change
anything about itself?

```swift
struct CounterView: View {
    var count = 0                      // just a normal property

    var body: some View {
        Button("Tapped \(count) times") {
            count += 1                 // ❌ Cannot assign to property: self is immutable
        }
    }
}
```

Exactly the wall from lesson 3. And `mutating` isn't available here — `body` is
computed by SwiftUI, not called by you.

### `@State` — storage that lives outside the struct

```swift
struct CounterView: View {
    @State private var count = 0       // ✅

    var body: some View {
        Button("Tapped \(count) times") {
            count += 1                 // works
        }
    }
}
```

`@State` tells SwiftUI: *"keep this value for me, somewhere that survives the
struct being rebuilt."* Two things follow:

1. You can change it, even though the view is a struct.
2. **Changing it redraws the view automatically.** You never call anything to
   refresh — that's the whole model.

> Views get thrown away and recreated constantly. `@State` is the only reason a
> value survives that. It lives in SwiftUI's storage, not in your struct.

**Always mark `@State` as `private`.** It's this view's own business; nobody
outside should reach in.

### `@Binding` — a two-way connection to someone else's state

`@State` is ownership. But what if a child view needs to *change* the parent's
value?

Passing it normally gives the child a **copy** (lesson 2 again) — changes go
nowhere:

```swift
struct Parent: View {
    @State private var date = Date()

    var body: some View {
        ChildView(selectedDate: date)   // a copy. Child changes are lost.
    }
}
```

`@Binding` is a *reference* to the parent's storage:

```swift
struct ChildView: View {
    @Binding var selectedDate: Date     // not mine — I'm borrowing the parent's

    var body: some View {
        Button("Today") { selectedDate = Date() }   // updates the PARENT
    }
}
```

And the parent passes it with a **`$`**:

```swift
ChildView(selectedDate: $date)          // $ = "a binding to this, not a copy"
```

### The `$` rule, in one line

| You write | You get |
|---|---|
| `date` | the value itself (`Date`) |
| `$date` | a two-way binding to it (`Binding<Date>`) |

`TextField("Name", text: $customTitle)` is the same idea — the text field needs
to *write back* what the user typed, so it needs a binding.

### Who owns what?

The rule that prevents most beginner state bugs:

> **`@State` where the value is born. `@Binding` everywhere it's borrowed.**

Exactly one view owns each piece of state. Everyone else gets a binding.

### The real code

`HomeView` owns the selected date:

```swift
@State private var selectedDate = Calendar.current.startOfDay(for: Date())
```

and lends it to the calendar strip:

```swift
CalendarStripView(selectedDate: $selectedDate)
```

`CalendarStripView` borrows it:

```swift
@Binding var selectedDate: Date
```

so when a day box is tapped:

```swift
Button {
    selectedDate = calendar.startOfDay(for: date)
}
```

...it writes into `HomeView`'s storage. `HomeView` redraws, the section header
changes from "Today" to the date, and the child redraws with the new highlight —
from one assignment.

**Note the `startOfDay`.** Dates carry a time down to the nanosecond, so two
`Date()` values are essentially never equal. Pinning everything to midnight is
what makes "is this the selected day?" comparisons work at all.

---

## 2. Practical

> **Goal:** own some state, then lend it to a child view.

**Step 1.** In `HomeView.swift`, add a piece of state at the top:

```swift
@State private var isShowingCompleted = true
```

**Step 2.** In `habitsSection`, filter the list with it (lesson 6):

```swift
ForEach(viewModel.habits.filter { isShowingCompleted || !$0.isDoneToday }) { habit in
```

**Step 3.** Add a toggle to the section header. Inside the `HStack` that holds
`Text("Habits")`, replace the `Text(isViewingToday ? ...)` line with:

```swift
Button(isShowingCompleted ? "Hide done" : "Show all") {
    isShowingCompleted.toggle()
}
.font(.subheadline)
```

**Step 4.** ⌘R. Tick a habit, then tap **Hide done** — it disappears. Tap
**Show all** — it's back. You wrote no refresh code; changing `@State` did it.

**Step 5.** Now practise `@Binding`. Create
`Views/Home/HabitFilterToggle.swift`:

```swift
import SwiftUI

struct HabitFilterToggle: View {
    @Binding var isShowingCompleted: Bool

    var body: some View {
        Button {
            isShowingCompleted.toggle()
        } label: {
            Label(
                isShowingCompleted ? "Hide done" : "Show all",
                systemImage: isShowingCompleted ? "eye.slash" : "eye"
            )
            .font(.subheadline)
        }
    }
}
```

**Step 6.** Swap the inline button for it, passing a binding with `$`:

```swift
HabitFilterToggle(isShowingCompleted: $isShowingCompleted)
```

⌘R. Identical behaviour — but the button now lives in its own reusable file, and
still controls `HomeView`'s state.

**Step 7.** Break it deliberately. In `HabitFilterToggle`, change `@Binding var`
to `@State private var`. It compiles (once you remove the argument), but tapping
does nothing to the list — the child is now toggling its *own* private copy. Put
it back.

That failure is the whole lesson. Make sure everyone sees it.

---

## 3. Questions

**Q1.** Why can't a plain `var` in a View be changed from a button action?

<details><summary>Answer</summary>

Views are structs — value types — and SwiftUI creates and discards them
constantly. A plain property has nowhere durable to live and can't be mutated
from `body`. `@State` moves the storage into SwiftUI, outside the struct.
</details>

**Q2.** What are the two things `@State` does?

<details><summary>Answer</summary>

1. Stores the value outside the struct so it survives redraws and can be
   changed.
2. Redraws the view automatically whenever it changes.
</details>

**Q3.** What's the difference between `date` and `$date`?

<details><summary>Answer</summary>

`date` is the value. `$date` is a two-way **binding** to it — a connection that
lets another view read *and write* the original storage.
</details>

**Q4.** When do you use `@Binding` instead of `@State`?

<details><summary>Answer</summary>

When the view doesn't own the value — it was handed down from a parent and the
child needs to change it. `@State` where the value is born; `@Binding` where
it's borrowed.
</details>

**Q5.** In step 7, why did the toggle stop working when `@Binding` became
`@State`?

<details><summary>Answer</summary>

`@State` gave the child its own separate storage. Tapping flipped the child's
private copy, which nothing else was watching, so `HomeView`'s value — and
therefore the filtered list — never changed.
</details>

**Q6.** Why does `CalendarStripView` normalise dates with `startOfDay`?

<details><summary>Answer</summary>

A `Date` includes the time to sub-second precision, so two dates on the same day
are almost never equal. Pinning them to midnight makes comparisons and stable
list identity work.
</details>

---

**Next lesson:** [11 — Lists with `ForEach`](Lesson-11-ForEach-and-Lists.md)
