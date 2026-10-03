import SwiftUI

// MARK: - What is this file?
// The sign-in screen shown after tapping "Continue with E-mail" on
// Onboarding. We have no backend (per an earlier decision — this app is
// frontend-only), so there's nothing real to authenticate against. Instead,
// this screen exists as a clean, real-world example of CONDITIONAL
// STATEMENTS: checking form input step by step and reacting differently
// depending on what the user typed.

struct LoginView: View {
    // Two-way bound to the TextFields below — typing updates these,
    // and these could update the TextFields if we changed them in code.
    @State private var email = ""
    @State private var password = ""

    // Optional because most of the time there IS no error — nil means
    // "nothing to show". We only give it a value when validation fails.
    @State private var errorMessage: String?

    // Which field the keyboard is currently in. Lets the Return key move
    // from Email straight to Password instead of dismissing the keyboard.
    @FocusState private var focusedField: Field?
    private enum Field { case email, password }

    // Same flag OnboardingView reads. Setting it to true here is our
    // "successful login" — it makes HabitTrackerApp.swift switch the
    // whole app over to RootTabView.
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    // Lets this screen close itself (used by the "back" button below).
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.primary)
                    // A bare chevron is a ~20pt target. This brings it up to
                    // the 44pt minimum without moving it visually.
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .padding(.leading, -AppTheme.Spacing.md) // keep the glyph optically aligned
            .accessibilityLabel("Back")

            Text("Sign In")
                .font(.largeTitle.bold())

            Text("Enter your details to continue.")
                .foregroundStyle(AppTheme.secondaryText)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.emailAddress)
                // Lets iOS and the password manager recognise the field and
                // offer to fill it. Without this the user types it by hand.
                .textContentType(.emailAddress)
                .focused($focusedField, equals: .email)
                .submitLabel(.next)

            SecureField("Password", text: $password) // dots-out the text, same as a normal password field
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
                .focused($focusedField, equals: .password)
                .submitLabel(.go)

            // MARK: - The conditional statement in action
            // `if let errorMessage { ... }` is Swift's "optional binding":
            // this block ONLY runs when `errorMessage` is not nil. No crash,
            // no need to force-unwrap — if there's no error, this whole
            // View simply isn't drawn at all.
            if let errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    // Red text alone conveys "error" only to people who can
                    // see the colour; the icon carries the same meaning
                    // independently, and VoiceOver announces the change.
                    .accessibilityAddTraits(.isStaticText)
                    .transition(.opacity)
            }

            Button {
                handleSignIn()
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.primary)
                    .clipShape(Capsule())
            }
            .padding(.top, AppTheme.Spacing.sm)

            Spacer()
        }
        .padding(AppTheme.Spacing.xxl)
        .background(AppTheme.groupedBackground.ignoresSafeArea())
        // Return key behaviour: Email -> Password -> submit.
        .onSubmit {
            switch focusedField {
            case .email: focusedField = .password
            default: handleSignIn()
            }
        }
        // Clear a stale error as soon as the user starts fixing it, rather
        // than leaving "Please fill in both fields" on screen while they type.
        .onChange(of: email) { _, _ in clearError() }
        .onChange(of: password) { _, _ in clearError() }
        .animation(.easeInOut(duration: 0.2), value: errorMessage)
    }

    // MARK: - Validation logic
    // This is the actual "if / else if / else" chain the lesson is about.
    // Swift checks each condition TOP TO BOTTOM and stops at the first one
    // that's true — so order matters. We check the most basic problem
    // (empty fields) first, then more specific problems, and only fall
    // through to "else" (success) if every check above was false.
    private func handleSignIn() {
        // Trimming first means a password of five spaces isn't treated as a
        // valid six-character one, and " me@x.com " still signs in.
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if email.isEmpty || password.isEmpty {
            // `||` means "or" — true if EITHER field is empty.
            errorMessage = "Please fill in both fields."
        } else if !isValidEmail(email) {
            errorMessage = "That doesn't look like a valid email."
        } else if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
        } else {
            // Every check above failed to match, so the input is valid.
            errorMessage = nil
            focusedField = nil               // put the keyboard away
            hasCompletedOnboarding = true    // our "fake" successful login
        }
    }

    /// The old check was `email.contains("@")`, which happily accepted "@",
    /// "a@" and "@b". This asks for the three parts an address actually needs:
    /// something before the @, something after it, and a dot in the domain.
    private func isValidEmail(_ email: String) -> Bool {
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        guard parts.count == 2,
              !parts[0].isEmpty,
              let domain = parts.last,
              domain.contains("."),
              !domain.hasPrefix("."),
              !domain.hasSuffix(".")
        else { return false }
        return true
    }

    private func clearError() {
        if errorMessage != nil { errorMessage = nil }
    }
}

#Preview {
    LoginView()
}
