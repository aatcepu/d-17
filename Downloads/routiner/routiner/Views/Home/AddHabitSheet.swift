import SwiftUI

// MARK: - What is this file?
// The screen that slides up from the bottom (a "sheet") when the user taps
// the big "+" tab, matching the "New Good Habit" card in the Figma design.
// It offers a few ready-made presets, or a text field to create a custom one.

struct AddHabitSheet: View {
    // The ViewModel that actually owns the habits array. This sheet doesn't
    // keep its own copy of the data — it just calls functions on the same
    // shared ViewModel that HomeView is watching, so adding a habit here
    // instantly shows up in the Home list too.
    @ObservedObject var viewModel: HabitListViewModel

    // dismiss lets this View close itself, e.g. after successfully adding
    // a custom habit. It's provided automatically by SwiftUI's environment.
    @Environment(\.dismiss) private var dismiss

    @State private var customTitle = ""

    // @FocusState drives the keyboard. Putting the cursor in the field as the
    // sheet opens saves the user a tap — they came here to type.
    @FocusState private var isTitleFocused: Bool

    /// A habit needs a real name. Computing this once keeps the "Add" button's
    /// enabled state and the actual save decision from ever disagreeing.
    private var trimmedTitle: String {
        customTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canAdd: Bool { !trimmedTitle.isEmpty }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.xl) {
                Text("Popular Habits")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)

                // A horizontal row of preset cards, e.g. Walk / Swim / Read.
                HStack(spacing: AppTheme.Spacing.md) {
                    ForEach(Habit.popularPresets) { preset in
                        presetCard(preset)
                    }
                }

                Divider().padding(.vertical, AppTheme.Spacing.sm)

                Text("Or create your own")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.secondaryText)

                HStack(spacing: AppTheme.Spacing.md) {
                    TextField("Habit name", text: $customTitle)
                        .textFieldStyle(.roundedBorder)
                        .focused($isTitleFocused)
                        // Names are proper nouns-ish ("Drink water"), and
                        // autocorrect fighting the user mid-word is worse than
                        // no autocorrect at all for a short free-text field.
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.sentences)
                        // Turns the keyboard's return key into "Done" and
                        // wires it to the same action as the button.
                        .submitLabel(.done)
                        .onSubmit(addCustomHabit)

                    Button("Add", action: addCustomHabit)
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primary)
                        // THE FIX: the button used to be tappable with an empty
                        // field. Tapping it called a ViewModel function that
                        // silently rejected the blank title — and then the sheet
                        // dismissed anyway, so the user watched it close and
                        // reasonably assumed a habit had been created.
                        .disabled(!canAdd)
                }

                Spacer()
            }
            .padding(AppTheme.screenPadding)
            .navigationTitle("New Good Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // A visible way out. Swipe-to-dismiss alone is undiscoverable,
                // and it isn't available at all when VoiceOver is running.
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { isTitleFocused = false }
        }
        // Sized to its content rather than covering the whole screen, so Home
        // stays partly visible behind it — the sheet is a quick side-trip.
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    /// Adds the typed habit, and closes the sheet ONLY if one was really added.
    private func addCustomHabit() {
        // `addCustomHabit` now reports whether it actually created anything.
        guard viewModel.addCustomHabit(title: customTitle) else { return }
        dismiss()
    }

    // One tappable preset card. Tapping it adds the habit immediately and
    // closes the sheet — no extra typing needed for the quick-add path.
    private func presetCard(_ preset: Habit) -> some View {
        Button {
            viewModel.addPreset(preset)
            dismiss()
        } label: {
            VStack(spacing: AppTheme.Spacing.sm) {
                Image(systemName: preset.icon)
                    .font(.title2)
                    .foregroundStyle(HabitTint(name: preset.tintColorName).color)
                    // Fixes ragged rows: without a fixed height, a tall glyph
                    // like "figure.pool.swim" pushed its card's text down
                    // relative to the neighbouring cards.
                    .frame(height: 28)

                Text(preset.title)
                    .font(.caption.bold())
                    .foregroundStyle(.primary)

                Text(preset.subtitle)
                    .font(.caption2)
                    .foregroundStyle(AppTheme.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .cardStyle(padding: AppTheme.Spacing.md)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add \(preset.title), \(preset.subtitle)")
    }
}

#Preview {
    AddHabitSheet(viewModel: HabitListViewModel())
}
