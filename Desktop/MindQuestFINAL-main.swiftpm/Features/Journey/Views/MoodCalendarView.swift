import SwiftUI

struct MoodCalendarView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDate: Date? = nil
    @State private var displayMonth = Date()
    @State private var animateIn = false
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 16) {
            // Month Navigation
            HStack {
                Button(action: {
                    HapticAgent.shared.playImpact(.light)
                    changeMonth(-1)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                Text(monthString)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                
                Spacer()
                
                Button(action: {
                    HapticAgent.shared.playImpact(.light)
                    changeMonth(1)
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Theme.textSecondary)
                }
            }
            
            // Month Stats
            if !monthMoods.isEmpty {
                HStack(spacing: 16) {
                    MonthStat(label: "Check-ins", value: "\(monthMoods.count)", color: Theme.primary)
                    
                    let topMoodSvg = moodSvg(for: topMoodEmoji)
                    MonthStat(label: "Top Mood", value: topMoodEmoji == "—" ? "—" : topMoodSvg.icon, color: Theme.secondary, isIcon: topMoodEmoji != "—", iconColor: topMoodSvg.color)
                    
                    MonthStat(label: "Days Active", value: "\(activeDaysCount)", color: Theme.accent)
                }
            }
            
            // Day Headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(Theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 6) {
                // Leading empty cells
                ForEach(0..<leadingEmptyCells, id: \.self) { _ in
                    Color.clear.frame(height: 40)
                }
                
                // Day cells
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = dateFor(day: day)
                    let entry = appState.dominantMood(for: date)
                    let isToday = calendar.isDateInToday(date)
                    let isSelected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
                    
                    Button(action: { withAnimation(.spring()) { selectedDate = date } }) {
                        ZStack {
                            if isToday {
                                Circle()
                                    .stroke(Theme.secondary.opacity(0.4), lineWidth: 1.5)
                                    .frame(width: 36, height: 36)
                            }
                            
                            if isSelected {
                                Circle()
                                    .fill(Theme.primary.opacity(0.2))
                                    .frame(width: 36, height: 36)
                            }
                            
                            if let entry = entry {
                                VStack(spacing: 1) {
                                    let svg = moodSvg(for: entry.emoji)
                                    Image(systemName: svg.icon)
                                        .font(.system(size: 14))
                                        .foregroundColor(svg.color)
                                        .opacity(0.9)
                                    Text("\(day)")
                                        .font(.system(size: 8, weight: .medium, design: .rounded))
                                        .foregroundColor(Theme.textSecondary)
                                }
                            } else {
                                Text("\(day)")
                                    .font(.system(size: 12, design: .rounded))
                                    .foregroundColor(isFutureDate(date) ? .gray.opacity(0.3) : .gray.opacity(0.6))
                            }
                        }
                        .frame(height: 40)
                    }
                    .disabled(isFutureDate(date))
                    .opacity(animateIn ? 1 : 0)
                    .animation(.spring().delay(Double(day) * 0.02), value: animateIn)
                }
            }
            
            // Selected Day Detail
            if let date = selectedDate {
                let entries = appState.moodEntries(for: date)
                if !entries.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(detailDateString(date))
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(Theme.textPrimary)
                        
                        ForEach(entries) { entry in
                            HStack(spacing: 10) {
                                let svg = moodSvg(for: entry.emoji)
                                Image(systemName: svg.icon)
                                    .font(.title3)
                                    .foregroundColor(svg.color)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.mood)
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Theme.textPrimary)
                                    
                                    Text(timeString(entry.date))
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                if !entry.activities.isEmpty {
                                    HStack(spacing: 2) {
                                        ForEach(entry.activities.prefix(3), id: \.self) { activity in
                                            Text(activity)
                                                .font(.caption2)
                                        }
                                    }
                                }
                            }
                            .padding(10)
                            .background(Theme.glassBackground)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.top, 8)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        .padding(18)
        .background(Theme.glassBackground)
        .cornerRadius(22)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Theme.primary.opacity(0.12), lineWidth: 1)
        )
        .onAppear {
            withAnimation(.spring().delay(0.2)) { animateIn = true }
        }
    }
    
    // MARK: - Helpers
    private var monthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayMonth)
    }
    
    private var leadingEmptyCells: Int {
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayMonth))!
        return calendar.component(.weekday, from: firstDay) - 1
    }
    
    private var daysInMonth: Int {
        calendar.range(of: .day, in: .month, for: displayMonth)!.count
    }
    
    private func dateFor(day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: displayMonth)
        components.day = day
        return calendar.date(from: components)!
    }
    
    private func isFutureDate(_ date: Date) -> Bool {
        date > Date()
    }
    
    private var monthMoods: [MoodEntry] {
        let components = calendar.dateComponents([.year, .month], from: displayMonth)
        return appState.moodHistory.filter {
            let c = calendar.dateComponents([.year, .month], from: $0.date)
            return c.year == components.year && c.month == components.month
        }
    }
    
    private var topMoodEmoji: String {
        var counts: [String: Int] = [:]
        for entry in monthMoods { counts[entry.emoji, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key ?? "—"
    }
    
    private var activeDaysCount: Int {
        Set(monthMoods.map { calendar.dateComponents([.year, .month, .day], from: $0.date) }).count
    }
    
    private func changeMonth(_ offset: Int) {
        withAnimation(.spring()) {
            animateIn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            displayMonth = calendar.date(byAdding: .month, value: offset, to: displayMonth)!
            selectedDate = nil
            withAnimation(.spring()) { animateIn = true }
        }
    }
    
    private func detailDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func moodSvg(for emoji: String) -> (icon: String, color: Color) {
        switch emoji {
        case "🌟": return ("sparkles", .yellow)
        case "😊": return ("sun.max.fill", .orange)
        case "😌": return ("leaf.fill", .green)
        case "😕": return ("cloud.fill", .gray)
        case "😔": return ("cloud.heavyrain.fill", .blue)
        default: return ("circle.fill", Theme.textPrimary)
        }
    }
}

// MARK: - Month Stat
struct MonthStat: View {
    let label: String
    let value: String
    let color: Color
    var isIcon: Bool = false
    var iconColor: Color? = nil
    
    var body: some View {
        VStack(spacing: 4) {
            if isIcon {
                Image(systemName: value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor ?? color)
            } else {
                Text(value)
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(color)
            }
            Text(label)
                .font(.system(size: 9, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.15))
        .cornerRadius(12)
    }
}
