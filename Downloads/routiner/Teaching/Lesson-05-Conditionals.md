# Lesson 05 — Conditionals: if / else if / else

**File we'll work in:** `routiner/Views/Onboarding/LoginView.swift`
**Prerequisite:** [Lesson 04](Lesson-04-Optionals.md)

---

## 1. Topic

### Making a decision

```swift
if password.count < 6 {
    print("Too short")
} else {
    print("Looks fine")
}
```

The thing between `if` and `{` must be a **`Bool`** — something that is either
true or false. Nothing else will do; Swift won't accept `if 1` or `if someString`
the way other languages might.

### The comparison operators

| Operator | Means | Example |
|---|---|---|
| `==` | equal to | `streak == 0` |
| `!=` | not equal to | `title != ""` |
| `<` `>` | less / greater than | `password.count < 6` |
| `<=` `>=` | less / greater than or equal | `streak >= 7` |

**`=` vs `==` is the classic beginner bug.** One `=` assigns a value; two `==`
compares. Swift catches it — an assignment isn't a Bool, so the `if` won't
compile — but it's still worth calling out explicitly.

### Combining conditions

| Operator | Means | True when |
|---|---|---|
| `&&` | and | both sides are true |
| `\|\|` | or | either side is true |
| `!` | not | flips true ↔ false |

```swift
if email.isEmpty || password.isEmpty {  // either one being empty is a problem
if streak > 0 && isDoneToday {          // both must hold
if !email.contains("@") {               // "does NOT contain"
```

### The chain — and why order matters

```swift
if a {
    // runs if a
} else if b {
    // runs only if a was false AND b is true
} else {
    // runs only if everything above was false
}
```

Swift checks **top to bottom and stops at the first true one**. At most one
block ever runs. This means the *order you write the checks in is part of the
logic*, not a style choice.

### The real code

`LoginView.handleSignIn()` is a textbook chain:

```swift
private func handleSignIn() {
    let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

    if email.isEmpty || password.isEmpty {
        errorMessage = "Please fill in both fields."
    } else if !isValidEmail(email) {
        errorMessage = "That doesn't look like a valid email."
    } else if password.count < 6 {
        errorMessage = "Password must be at least 6 characters."
    } else {
        errorMessage = nil
        focusedField = nil
        hasCompletedOnboarding = true      // our "fake" successful login
    }
}
```

Walk the room through *why it's in this order*:

- **Empty first.** If the fields are blank, "that doesn't look like a valid
  email" is a confusing thing to say. Check the most basic problem first.
- **Format next.** Now we know there's text, we can ask whether it's shaped like
  an email.
- **Length last.** The most specific complaint goes last.
- **`else` = success.** We only get here because every check above failed to
  find a problem. That's a nice property: the happy path needs no condition of
  its own.

Flip the first two branches and the app starts giving unhelpful advice. Same
code, wrong order, worse product.

### `switch` — when you're checking one value against many

An `if` chain comparing the *same thing* over and over is better as a `switch`:

```swift
switch selectedTab {
case .activity:
    // the feed
case .friends, .achievements:      // one case, two matches
    comingSoonPlaceholder
}
```

Swift requires a `switch` to be **exhaustive** — every possible value handled,
or a `default:`. Add a fourth tab to the enum and every switch over it stops
compiling until you say what should happen. That's a feature: the compiler
hands you a to-do list.

---

## 2. Practical

> **Goal:** extend a validation chain and see order matter.

**Step 1.** Run the app. If you've already signed in, delete it from the
Simulator (long-press the icon → Remove App) so onboarding shows again.

**Step 2.** Try each failure in turn — empty fields, `hello`, `a@b.com` with a
3-character password — and read the message each time.

**Step 3.** Add a new rule. In `handleSignIn()`, insert a branch **before** the
`else`:

```swift
} else if password.lowercased() == "password" {
    errorMessage = "Come on. Pick a real password."
} else {
```

⌘R and try `a@b.com` / `password`.

**Step 4.** Now break it deliberately. Move that new branch to the **very top**
of the chain, above the empty check. Run again with both fields blank.

The message is still "Please fill in both fields" — because an empty password
isn't equal to `"password"`, so the new first branch is false and the chain moves
on. Ask: **what would happen if the rule were `password.count < 8` instead, put
at the top?** *(An empty form would say "password too short" rather than "fill in
both fields" — technically true, unhelpful.)* Move it back.

**Step 5.** Look at `isValidEmail(_:)` at the bottom of the file. It replaced a
single `email.contains("@")` check, which accepted `"@"`, `"a@"` and `"@b"` as
valid addresses. Read the `guard` and identify all four conditions it requires.

**Stretch:** make the Sign In button `.disabled()` when either field is empty,
so the first branch becomes unreachable. Is that better UX? *(Discuss — a
disabled button with no explanation can be its own kind of confusing.)*

---

## 3. Questions

**Q1.** What must the value between `if` and `{` be?

<details><summary>Answer</summary>

A `Bool` — exactly true or false. Swift won't accept a number or a string there.
</details>

**Q2.** What's the difference between `=` and `==`?

<details><summary>Answer</summary>

`=` assigns a value to a variable. `==` compares two values and produces a
`Bool`. Only `==` belongs in an `if`.
</details>

**Q3.** In an `if / else if / else` chain, how many blocks can run?

<details><summary>Answer</summary>

Exactly one, at most. Swift tests top to bottom and stops at the first true
condition — everything after it is skipped.
</details>

**Q4.** Why is the empty-fields check first in `handleSignIn()`?

<details><summary>Answer</summary>

So the user gets the most relevant message. If the fields are blank, telling
them their email is malformed is confusing — there's no email to malform. Check
the broadest problem first, narrow down from there.
</details>

**Q5.** When would you reach for `switch` over an `if` chain?

<details><summary>Answer</summary>

When you're testing one value against several possibilities — especially an
enum. It reads better, and the compiler enforces that every case is handled, so
adding a new case forces you to update the logic instead of silently falling
through.
</details>

---

**Next lesson:** [06 — Arrays & Loops](Lesson-06-Arrays-and-Loops.md)
