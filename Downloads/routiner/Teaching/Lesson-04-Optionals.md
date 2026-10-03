# Lesson 04 — Optionals

**File we'll work in:** `routiner/Views/Onboarding/LoginView.swift`
**Prerequisite:** [Lesson 03](Lesson-03-Functions.md)

---

## 1. Topic

### The question every language has to answer

What should this hold when there is no error to show?

```swift
var errorMessage: String
```

Other languages shrug and use `null` — and then crash at runtime when you forget
to check. Swift makes "might be missing" **part of the type**:

```swift
var errorMessage: String?     // a String, OR nothing at all
```

That `?` changes everything. `String` always contains text. `String?` contains
text *or* `nil`, and Swift will not let you use it until you've dealt with that
possibility.

> **Analogy:** a `String` is a box with a shirt in it. A `String?` is a box that
> might have a shirt in it — or might be empty. You have to open it and look
> before you can wear anything.

### `nil` means "no value"

```swift
var errorMessage: String? = nil       // nothing to show
errorMessage = "Please fill in both fields."   // now there is
errorMessage = nil                    // back to nothing
```

`nil` is not `""`. An empty string is a real string that happens to be empty —
a box with a shirt of zero size. `nil` is no box contents at all.

### You can't just use it

```swift
let errorMessage: String? = "Oops"
print(errorMessage.count)    // ❌ Value of optional type 'String?' must be unwrapped
```

Swift stops you, because if it *were* `nil`, `.count` would have nothing to count.
**Unwrapping** is how you get at the value safely.

### Way 1 — `if let` (the one we use most)

```swift
if let errorMessage {
    // We only get in here if it is NOT nil.
    // Inside this block, errorMessage is a plain String.
    print(errorMessage.count)
}
```

Read it as: *"if there's something in the box, call it `errorMessage` and run
this block."* If it's `nil`, the block is skipped entirely. No crash, no check
you can forget.

The longer form `if let message = errorMessage` does the same thing with a new
name. When the name would be identical, Swift lets you drop the `= errorMessage`.

### Way 2 — `guard let` (leave early)

```swift
func showError() {
    guard let errorMessage else { return }

    // From here to the end of the function, errorMessage is a plain String.
    print(errorMessage)
}
```

`guard` is `if let` turned inside out: handle the bad case first and get out,
then write the rest of the function without nesting. You'll see it all over
this app — `HabitListViewModel.toggleHabit` opens with one.

### Way 3 — `??` (default value)

```swift
let message = errorMessage ?? "No error"
```

"Use the value if there is one, otherwise use this." Always produces a real
non-optional value.

### The one to avoid — `!`

```swift
print(errorMessage!.count)    // 💥 crashes if nil
```

The **force unwrap**. It means "trust me, there's definitely something in here",
and when you're wrong the app dies instantly. Teach students that seeing `!` in
their code is a prompt to ask "am I certain?" — the answer is usually no.

### The real code

`routiner/Views/Onboarding/LoginView.swift`:

```swift
@State private var errorMessage: String?
```

and further down, in the middle of the screen layout:

```swift
if let errorMessage {
    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
        .font(.caption)
        .foregroundStyle(.red)
}
```

This is optionals earning their keep. When there's no error, the red label isn't
hidden — **it doesn't exist**. The layout closes up as if it were never there.
One optional replaces a separate `showError` Bool that could drift out of sync
with the message itself.

---

## 2. Practical

> **Goal:** feel a force-unwrap crash, then fix it properly.

**Step 1.** Open `routiner/ViewModels/ProfileViewModel.swift`. Add this method
inside the class:

```swift
func firstActivityTitle() -> String {
    let first = activity.first    // `.first` on an array returns an Optional!
    return first!.title           // 💥 the dangerous way
}
```

Ask: **why does `.first` return an optional?** Because the array might be empty
— there'd be no first item to hand back.

**Step 2.** Make it crash. Temporarily empty the activity list:

```swift
@Published var activity: [ActivityItem] = []
```

and call the method from `ProfileView.swift`'s `profileHeader`, just above the
`HStack`:

```swift
let _ = print(viewModel.firstActivityTitle())
```

⌘R. The app crashes on launch: **"Unexpectedly found nil while unwrapping an
Optional value."** Let them sit with it — this is the single most common crash in
iOS, and seeing it deliberately is worth more than a warning about it.

**Step 3.** Fix it with `??`:

```swift
func firstActivityTitle() -> String {
    activity.first?.title ?? "No activity yet"
}
```

Two new things in one line:
- `activity.first?.title` — the **optional chain**. "If there is a first item,
  get its title; if not, the whole expression is nil."
- `?? "No activity yet"` — the fallback.

⌘R. No crash. It prints the fallback.

**Step 4.** Restore `activity` to `ActivityItem.sampleData`, re-run, and confirm
it now prints the real title.

**Step 5.** Remove the `print` line and the method.

**Stretch:** rewrite the fix using `guard let` instead of `??`. Which reads
better for a one-liner? *(`??` — but `guard` wins as soon as the function grows.)*

---

## 3. Questions

**Q1.** What's the difference between `String` and `String?`

<details><summary>Answer</summary>

`String` always contains text. `String?` is an Optional — it contains either
text or `nil`. Swift won't let you use the value inside a `String?` until you've
unwrapped it and handled the nil case.
</details>

**Q2.** Is `""` the same as `nil`?

<details><summary>Answer</summary>

No. `""` is a real, valid string that happens to have no characters. `nil` is
the absence of any string at all. A `String` can be `""`; only a `String?` can
be `nil`.
</details>

**Q3.** What happens to the surrounding layout when `errorMessage` is `nil` in
`LoginView`?

<details><summary>Answer</summary>

The `if let` block produces no view whatsoever, so the red label isn't in the
layout — the views below simply move up to fill the space. It's not hidden, it
doesn't exist.
</details>

**Q4.** Why is `!` dangerous, and when is it acceptable?

<details><summary>Answer</summary>

It skips the safety check and crashes the app if the value is `nil`. It's
acceptable only when it's genuinely impossible for the value to be nil and you
can explain why in one sentence — which is rarer than beginners think. Prefer
`if let`, `guard let`, or `??`.
</details>

**Q5.** What does `activity.first?.title ?? "No activity yet"` do, step by step?

<details><summary>Answer</summary>

1. `activity.first` gives an `ActivityItem?` — nil if the array is empty.
2. `?.title` reads the title *only if* there was an item; otherwise the whole
   expression is nil.
3. `?? "No activity yet"` substitutes the fallback if anything above was nil.

The result is a plain, guaranteed-non-nil `String`.
</details>

---

**Next lesson:** [05 — Conditionals](Lesson-05-Conditionals.md) — making
decisions in code.
