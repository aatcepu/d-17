# Lesson 09 — Your first View: stacks & modifiers

**File we'll work in:** `routiner/Views/Profile/ActivityRowView.swift`
**Prerequisite:** [Lesson 08](Lesson-08-Protocols.md)

---

## 1. Topic

### A View is a struct that describes what to draw

```swift
struct ActivityRowView: View {
    var body: some View {
        Text("Hello")
    }
}
```

That's it — a struct (lesson 2) conforming to a protocol (lesson 8), with one
required property: `body`.

The critical mental shift: **you don't draw anything and you don't update
anything.** You *describe* what the screen should look like for the current
data. When the data changes, SwiftUI runs your description again and works out
the difference itself. There is no "now change the label's text" code anywhere
in this app.

### The three stacks

Layout in SwiftUI is stacking boxes:

| Stack | Arranges children |
|---|---|
| `VStack` | **V**ertically, top to bottom |
| `HStack` | **H**orizontally, left to right |
| `ZStack` | Front to back, layered on top of each other |

```swift
VStack {
    Text("112 points earned!")
    Text("Today, 12:34 PM")
}
```

They nest freely, and that's how every layout gets built:

```swift
HStack {                       // row
    VStack { Text("Title"); Text("Subtitle") }   // stacked text on the left
    Spacer()                                     // shove the rest right
    Image(systemName: "arrow.up")                // icon on the right
}
```

### `Spacer()` — the invisible pusher

`Spacer()` expands to fill whatever room is available, pushing its siblings
apart. It's how you get "this on the left, that on the right" without any
coordinates. Every card in this app uses one.

### Alignment and spacing

```swift
VStack(alignment: .leading, spacing: 4) { ... }
```

- `alignment: .leading` — line children up on the left edge (`.leading` rather
  than `.left` so it flips automatically in right-to-left languages).
- `spacing: 4` — gap between children. Omit it and SwiftUI picks a default.

### Modifiers

A modifier is a method that returns a *new, changed* view:

```swift
Text("Hello")
    .font(.headline)
    .foregroundStyle(.red)
    .padding()
```

**Order matters — this is the number one source of confusion.**

```swift
Text("Hi").padding().background(.blue)   // blue extends around the padding
Text("Hi").background(.blue).padding()   // blue hugs the text, padding outside
```

Read it as a pipeline: each modifier wraps the result of everything above it.
Show both on screen side by side; it lands much faster than an explanation.

### The design system

Rather than sprinkling numbers everywhere, this app keeps them in one file,
`routiner/Theme/AppTheme.swift`:

```swift
.foregroundStyle(AppTheme.secondaryText)
.padding(AppTheme.Spacing.lg)          // 16
```

And the shared card look lives in `Theme/CardStyle.swift`, applied as
`.cardStyle()`. Change the corner radius there and **every card in the app**
changes together. That's most of what "pixel perfect" means in practice: the
same value everywhere, defined once.

### The real code

Read `ActivityRowView.swift` top to bottom. It's ~30 lines and uses everything
above: an `HStack` holding a `VStack` and an `Image`, split by a `Spacer()`,
with `.cardStyle()` on the outside.

---

## 2. Practical

> **Goal:** build a view from scratch using stacks and modifiers.

**Step 1.** Create `Views/Profile/AchievementRowView.swift`:

```swift
import SwiftUI

struct AchievementRowView: View {
    let achievement: Achievement

    var body: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundStyle(achievement.isUnlocked ? AppTheme.primary : AppTheme.secondaryText)
                .frame(width: 44, height: 44)
                .background(
                    Circle().fill(
                        (achievement.isUnlocked ? AppTheme.primary : AppTheme.secondaryText)
                            .opacity(0.15)
                    )
                )

            VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.detail)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
            }

            Spacer()

            if achievement.isUnlocked {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }
        }
        .cardStyle()
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
}

#Preview {
    VStack {
        AchievementRowView(achievement: Achievement.sampleData[0])
        AchievementRowView(achievement: Achievement.sampleData[2])
    }
    .padding()
    .background(AppTheme.groupedBackground)
}
```

**Step 2.** Open the **Canvas** (⌥⌘↩). The `#Preview` block renders live — no
need to run the app. Change a number and watch it update instantly. This is the
fastest way to teach layout; make sure everyone has it open.

**Step 3.** Experiment in the preview, one change at a time:
- Delete the `Spacer()`. Where does the checkmark go?
- Swap the outer `HStack` for a `VStack`.
- Move `.cardStyle()` above `.opacity(...)`. Any difference? Now move it to the
  very first line, before `HStack` — that won't compile. Why?

**Step 4.** Put it in the app. In `ProfileView.swift`, replace the
`comingSoonPlaceholder` for the achievements case:

```swift
case .achievements:
    ForEach(Achievement.sampleData) { achievement in
        AchievementRowView(achievement: achievement)
    }
case .friends:
    comingSoonPlaceholder
```

**Step 5.** ⌘R → Profile tab → **Achievements**. Three rows, the locked one
faded.

**Stretch:** demonstrate modifier order properly. Add these two lines somewhere
visible and compare:

```swift
Text("Padding then background").padding().background(.yellow)
Text("Background then padding").background(.yellow).padding()
```

---

## 3. Questions

**Q1.** What is the one property every SwiftUI `View` must have?

<details><summary>Answer</summary>

`body`. It returns the description of what to draw.
</details>

**Q2.** What's the difference between `VStack`, `HStack` and `ZStack`?

<details><summary>Answer</summary>

`VStack` stacks children vertically, `HStack` horizontally, `ZStack` layers them
front-to-back on top of each other.
</details>

**Q3.** What does `Spacer()` do?

<details><summary>Answer</summary>

Expands to take up all the free space in its stack, pushing the views on either
side of it apart. It's how you push something to the far edge without
coordinates.
</details>

**Q4.** Do these two produce the same result?

```swift
Text("Hi").padding().background(.blue)
Text("Hi").background(.blue).padding()
```

<details><summary>Answer</summary>

No. The first pads the text and then colours the whole padded area blue. The
second colours only the text, then adds clear padding outside the blue. Each
modifier wraps everything above it, so the order is the layout.
</details>

**Q5.** Why does this app use `AppTheme.Spacing.lg` instead of just writing `16`?

<details><summary>Answer</summary>

So every spacing value in the app comes from one place. It keeps the layout
consistent, and changing the scale means editing one line instead of hunting
through every file — which is how designs drift out of spec.
</details>

---

**Next lesson:** [10 — `@State` and `@Binding`](Lesson-10-State-and-Binding.md)
— making views react to taps.
