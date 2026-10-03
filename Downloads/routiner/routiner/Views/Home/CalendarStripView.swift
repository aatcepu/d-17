import SwiftUI

// MARK: - What is this file?
// The horizontally-scrolling row of day boxes at the top of Home
// ("3 SAT", "4 SUN", "5 MON"...). It's a small, self-contained View so
// HomeView.swift doesn't get cluttered with date-formatting code.

struct CalendarStripView: View {
    // A binding, not a plain value: this View doesn't own "which day is
    // selected", HomeView does. The `$` lets this child View read AND write
    // the parent's @State directly, so tapping a day here updates HomeView too.
    @Binding var selectedDate: Date

    private let calendar = Calendar.current

    /// Seven days genuinely centred on today (three back, today, three forward).
    ///
    /// Two things were wrong with the old version:
    ///
    /// 1. It used `-1...5`, which put today second from the left — the comment
    ///    claimed "centered on today", the code did something else.
    /// 2. It built its dates from a raw `Date()`, which carries the current
    ///    time down to the nanosecond. Combined with `ForEach(..., id: \.self)`
    ///    that meant every single redraw produced SEVEN BRAND-NEW IDENTITIES,
    ///    so SwiftUI threw the whole row away and rebuilt it each time instead
    ///    of reusing the boxes. `startOfDay` pins each date to midnight, so the
    ///    identities stay stable all day and the row is only rebuilt when the
    ///    day actually changes.
    private var week: [Date] {
        let today = calendar.startOfDay(for: Date())
        return (-3...3).compactMap { offset in
            calendar.date(byAdding: .day, value: offset, to: today)
        }
    }

    var body: some View {
        // ScrollViewReader lets us jump the strip so today is visible on
        // launch, rather than opening pinned to the left-most (oldest) day.
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.sm) {
                    ForEach(week, id: \.self) { date in
                        dayBox(for: date)
                            .id(date)
                    }
                }
                // A little breathing room so the first and last box aren't
                // shaved off by the edge of the screen mid-scroll.
                .padding(.horizontal, 2)
            }
            .onAppear {
                proxy.scrollTo(calendar.startOfDay(for: Date()), anchor: .center)
            }
        }
    }

    // A small helper function that builds ONE day box. Pulling repeated
    // layout code into a function like this (instead of copy-pasting it in
    // the ForEach) keeps `body` easy to scan.
    private func dayBox(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)

        return Button {
            selectedDate = calendar.startOfDay(for: date)
        } label: {
            VStack(spacing: AppTheme.Spacing.xs) {
                Text(date.formatted(.dateTime.day()))
                    .font(.headline)
                Text(date.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.caption2)
            }
            .foregroundStyle(isSelected ? .white : .primary)
            .frame(width: 48, height: 60)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous)
                    // The selected day is now FILLED, not just outlined. An
                    // outline alone is easy to miss against the card behind it.
                    .fill(isSelected ? AnyShapeStyle(AppTheme.primary) : AnyShapeStyle(AppTheme.cardBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.small, style: .continuous)
                    // `strokeBorder` draws the line entirely INSIDE the shape.
                    // The old code used `.stroke` (which straddles the edge,
                    // half in and half out) and then applied `.cornerRadius`
                    // afterwards — so the clip sliced the outer half of the
                    // border away and the "2pt" ring rendered as a patchy 1pt.
                    .strokeBorder(isToday && !isSelected ? AppTheme.primary : .clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
        // Reads as "Monday 5 August, today" instead of the two loose fragments
        // "5" and "Mon" that VoiceOver announced before.
        .accessibilityLabel(
            date.formatted(.dateTime.weekday(.wide).day().month(.wide))
                + (isToday ? ", today" : "")
        )
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

#Preview {
    CalendarStripView(selectedDate: .constant(Date()))
        .padding()
        .background(AppTheme.groupedBackground)
}
