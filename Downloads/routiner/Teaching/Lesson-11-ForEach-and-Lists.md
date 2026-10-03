# Lesson 11 — Lists with `ForEach`

**File we'll work in:** `routiner/Views/Home/HomeView.swift`
**Prerequisite:** [Lesson 10](Lesson-10-State-and-Binding.md)

---

## 1. Topic

### Don't write the same view three times

```swift
VStack {
    HabitRowView(habit: habits[0], onToggle: {})
    HabitRowView(habit: habits[1], onToggle: {})
    HabitRowView(habit: habits[2], onToggle: {})   // and when there are 40?
}
```

`ForEach` builds one view per item:

```swift
ForEach(viewModel.habits) { habit in
    HabitRowView(habit: habit, onToggle: { ... })
}
```

Three habits, three rows. Forty habits, forty rows. Zero habits, no rows — and
no crash.

> **Name the distinction now:** `for ... in` (lesson 6) is a *loop* that runs
> and finishes. `ForEach` is a *view* that describes a collection of views.
> They look alike and are not the same thing.

### Why `Identifiable` matters here

`ForEach` needs to tell items apart between redraws. When a habit is deleted,
it has to know *which row* left so it can animate that one and leave the others
alone.

Because `Habit` is `Identifiable` (lesson 8), this just works. For collections
without ids you must say what makes each item unique:

```swift
ForEach(week, id: \.self) { date in ... }        // the value IS the identity
ForEach(Tab.allCases) { tab in ... }             // Tab is Identifiable
```

**A warning worth teaching, because the bug is invisible:** if the id isn't
stable, SwiftUI thinks every item is brand new on every redraw and rebuilds the
whole list. `CalendarStripView` had exactly this problem — it built dates from a
raw `Date()`, which changes every nanosecond, so its seven boxes were thrown away
and rebuilt continuously. The fix was `startOfDay`. The comment in that file
spells it out.

**Never use the array index as the id** for a list that can change. Delete item
0 and every remaining item's identity shifts by one — SwiftUI concludes that
everything changed.

### `ForEach` vs `List` vs `ScrollView`

| | What you get |
|---|---|
| `ScrollView { VStack { ForEach ... } }` | Total control of appearance. Everything is built at once. |
| `List { ForEach ... }` | Free iOS styling, swipe-to-delete, separators, and rows are recycled |

`HomeView` uses the first because the design calls for custom floating cards on
a grey background. `SettingsView` uses `List`, because it *wants* to look like
iOS Settings — and gets those grouped rounded sections for free.

For very long lists, `List` wins: it only builds the rows on screen. With a few
dozen habits, either is fine.

### The real code

```swift
if viewModel.habits.isEmpty {
    emptyState
} else {
    ForEach(viewModel.habits) { habit in
        HabitRowView(
            habit: habit,
            isEditable: isViewingToday,
            onToggle: { viewModel.toggleHabit(id: habit.id) },
            onDelete: { viewModel.deleteHabit(id: habit.id) }
        )
    }
}
```

Three things to point out:

**The empty state.** Before this `if`, an empty list rendered as *nothing* — a
blank gap under the "Habits" heading with no explanation. Always design the
empty case; it's the first thing a new user sees.

**The closures.** `onToggle` hands the row a piece of code to run when tapped.
The row doesn't know what a ViewModel is — it just reports "I was tapped" and
lets the parent decide. That's what keeps `HabitRowView` reusable.

**`habit.id`, not the habit.** We pass the id to the ViewModel because the row
is holding a *copy* of the habit (lesson 2). Changing that copy would change
nothing. The ViewModel looks up the real one in its array by id.

That last point is the single most important idea connecting the language half
of this course to the SwiftUI half. Spend time on it.

---

## 2. Practical

> **Goal:** build a list, handle the empty case, and see identity break.

**Step 1.** Show the Achievements list properly. In `ProfileView.swift`, add
state to filter it:

```swift
@State private var showLockedAchievements = true
```

**Step 2.** Replace the `.achievements` case:

```swift
case .achievements:
    let shown = Achievement.sampleData.filter { showLockedAchievements || $0.isUnlocked }

    Button(showLockedAchievements ? "Hide locked" : "Show all") {
        showLockedAchievements.toggle()
    }
    .font(.subheadline)

    if shown.isEmpty {
        Text("Nothing unlocked yet — get started on a habit!")
            .font(.subheadline)
            .foregroundStyle(AppTheme.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
    } else {
        ForEach(shown) { achievement in
            AchievementRowView(achievement: achievement)
        }
    }
```

**Step 3.** ⌘R → Profile → Achievements. Toggle the filter. Rows appear and
disappear.

**Step 4.** Add the animation. Put this on the `VStack` inside the `ScrollView`:

```swift
.animation(.snappy, value: showLockedAchievements)
```

Re-run. The rows now slide instead of blinking — because `ForEach` knows exactly
which ones left, thanks to `Identifiable`.

**Step 5. Break identity on purpose.** Change the `ForEach` to use the array
index:

```swift
ForEach(shown.indices, id: \.self) { index in
    AchievementRowView(achievement: shown[index])
}
```

Toggle the filter again. The animation is wrong — rows cross-fade in place
instead of moving, because SwiftUI now believes "item 0" simply changed its
contents rather than a specific achievement being removed.

**Step 6.** Put it back to `ForEach(shown)`.

**Stretch:** make the empty state reachable — set every sample achievement to
`isUnlocked: false`, then hide locked ones.

---

## 3. Questions

**Q1.** What's the difference between `for ... in` and `ForEach`?

<details><summary>Answer</summary>

`for ... in` is a loop that executes and finishes. `ForEach` is a SwiftUI view
that *describes* one child view per item, and gets re-evaluated whenever the data
changes.
</details>

**Q2.** Why does `ForEach` need each item to be identifiable?

<details><summary>Answer</summary>

To match up items between redraws. Stable ids let it know which specific row was
added, removed or moved, so it can animate just that row instead of rebuilding
everything.
</details>

**Q3.** What goes wrong if the id isn't stable?

<details><summary>Answer</summary>

SwiftUI treats every item as brand new on each redraw, throwing away and
rebuilding the whole list. Animations break and performance suffers — and there's
no error message, so it's easy to miss. `CalendarStripView` had this bug from
building dates out of a raw `Date()`.
</details>

**Q4.** Why does the row call `viewModel.toggleHabit(id: habit.id)` rather than
just changing `habit`?

<details><summary>Answer</summary>

The row holds a **copy** of the habit — structs are value types. Modifying the
copy would change nothing on screen. Passing the id lets the ViewModel find and
change the real one in its array, which is what the whole app is watching.
</details>

**Q5.** When would you choose `List` over `ScrollView` + `VStack` + `ForEach`?

<details><summary>Answer</summary>

When you want standard iOS styling, swipe actions and separators for free, or
when the list is long enough that you need row recycling. Use the ScrollView
approach when the design needs full visual control, as the Home screen's cards do.
</details>

---

**Next lesson:** [12 — MVVM & `ObservableObject`](Lesson-12-MVVM.md)
