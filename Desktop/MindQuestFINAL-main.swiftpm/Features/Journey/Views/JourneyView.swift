import SwiftUI
import Charts

struct JourneyView: View {
    @EnvironmentObject var appState: AppState
    @State private var animateCharts = false
    
    var body: some View {
        ZStack {
            Theme.navyGradient.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header
                    AppHeader(
                        title: "Your Journey",
                        subtitle: "Analytics & Progress"
                    )
                    
                    // Improvement Summary
                    ImprovementSummaryView()
                        .padding(.horizontal)
                    
                    // Growth Highlight of the Week
                    GrowthHighlightCard(moodHistory: appState.moodHistory)
                        .padding(.horizontal)
                    
                    // Mood Calendar
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mood Calendar")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.textPrimary)
                            .padding(.horizontal)
                        
                        MoodCalendarView()
                            .padding(.horizontal)
                    }
                    
                    // Cognitive Insights Dashboard
                    InsightDashboardView()
                        .padding(.horizontal)
                    
                    // Level Progress (Capsule Design)
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Skill Level Mastery")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(Theme.textPrimary)
                        
                        VStack(spacing: 12) {
                            ForEach(appState.activityLevels.sorted(by: { $0.key < $1.key }), id: \.key) { category, level in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(category)
                                            .font(.system(.subheadline, design: .rounded))
                                            .foregroundColor(Theme.textSecondary)
                                        Spacer()
                                        Text("Lvl \(level)")
                                            .font(.system(.caption, design: .rounded))
                                            .fontWeight(.bold)
                                            .foregroundColor(getCategoryColor(category))
                                    }
                                    
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule()
                                                .fill(Theme.textPrimary.opacity(0.12))
                                                .frame(height: 8)
                                            
                                            Capsule()
                                                .fill(
                                                    LinearGradient(
                                                        colors: [getCategoryColor(category), getCategoryColor(category).opacity(0.6)],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geo.size.width * CGFloat(min(Double(level) / 10.0, 1.0)), height: 8)
                                                .shadow(color: getCategoryColor(category).opacity(0.3), radius: 4)
                                        }
                                    }
                                    .frame(height: 8)
                                }
                                .padding(12)
                                .background(Theme.textPrimary.opacity(0.06))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .glowingCard(Theme.secondary)
                    .padding(.horizontal)
                    
                    // Mood Distribution Graph (Bar Chart)
                    if !appState.moodHistory.isEmpty {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Mood Patterns")
                                .font(Theme.titleFont)
                                .foregroundColor(Theme.textPrimary)
                            
                            Chart {
                                ForEach(moodDistributionData, id: \.mood) { item in
                                    BarMark(
                                        x: .value("Count", animateCharts ? item.count : 0),
                                        y: .value("Mood", item.mood)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [item.color, item.color.opacity(0.6)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(4)
                                    .annotation(position: .trailing) {
                                        Text("\(item.count)")
                                            .font(.caption)
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                }
                            }
                            .frame(height: CGFloat(max(moodDistributionData.count * 50, 150)))
                            .chartXAxis {
                                                                AxisMarks(values: .automatic) { _ in
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [5, 5]))
                                        .foregroundStyle(Theme.divider)
                                    AxisValueLabel()
                                        .foregroundStyle(Theme.textSecondary)
                                }
                            }
                            .chartYAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                        .foregroundStyle(Theme.textPrimary)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .modifier(PremiumCardModifier())
                        .padding(.horizontal)
                    }
                    
                    // Detailed History
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Detailed History")
                            .font(Theme.titleFont)
                            .foregroundColor(Theme.textPrimary)
                            .padding(.horizontal)
                        
                        if appState.moodHistory.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(Theme.textSecondary)
                                Text("No progress entries yet. Start by checking in on the Home screen!")
                                    .font(.subheadline)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Theme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .modifier(PremiumCardModifier())
                            .padding(.horizontal)
                        } else {
                            ForEach(appState.moodHistory) { entry in
                                PremiumHistoryCard(entry: entry)
                                    .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        .onAppear {
            HapticAgent.shared.playImpact(.soft, intensity: 0.3)
            withAnimation(.easeInOut(duration: 1.0)) {
                animateCharts = true
            }
        }
    }
    
    // Data Preparation for Charts with Colors
    private var levelData: [(emoji: String, label: String, level: Int, color: Color)] {
        [
            ("🌟", "Creative", appState.activityLevels["🌟"] ?? 0, .purple),
            ("😊", "Gratitude", appState.activityLevels["😊"] ?? 0, .orange),
            ("😌", "Zen", appState.activityLevels["😌"] ?? 0, .green),
            ("😕", "Memory", appState.activityLevels["😕"] ?? 0, .blue),
            ("😔", "Breath", appState.activityLevels["😔"] ?? 0, .cyan)
        ]
    }
    
    private var moodDistributionData: [(mood: String, count: Int, color: Color)] {
        let history = appState.moodHistory
        let counts = history.reduce(into: [String: Int]()) { dict, entry in
            dict[entry.mood, default: 0] += 1
        }
        
        let moodColors: [String: Color] = [
            "Euphorically Happy": .yellow,
            "Joyful & Positive": .green,
            "Balanced & Calm": Theme.secondary,
            "Slightly Down": .orange,
            "Deeply Stressed or Sad": .red
        ]
        
        return counts.map { (mood: $0.key, count: $0.value) }
            .sorted(by: { $0.count > $1.count })
            .map { (mood: $0.mood, count: $0.count, color: moodColors[$0.mood] ?? .gray) }
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category {
        case "🌟", "Creative": return .purple
        case "😊", "Gratitude": return .orange
        case "😌", "Zen": return .green
        case "😕", "Memory": return .blue
        case "😔", "Breath": return .cyan
        default: return Theme.secondary
        }
    }
}


struct PremiumHistoryCard: View {
    let entry: MoodEntry
    @State private var isVisible = false
    @State private var pulsate = false
    
    // Derived accent color based on mood
    // Simple heuristic: if mood matches standard list, use that; otherwise fallback
    private var moodColor: Color {
        switch entry.mood {
        case "Euphorically Happy": return .yellow
        case "Joyful & Positive": return .green
        case "Balanced & Calm": return Theme.secondary
        case "Slightly Down": return .orange
        case "Deeply Stressed or Sad": return .red
        default: return Theme.secondary
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Header Row: Icon, Title, Date
            HStack(spacing: 15) {
                // Pulsing Emoji Container
                ZStack {
                    Circle()
                        .fill(moodColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                        .scaleEffect(pulsate ? 1.1 : 1.0)
                        .animation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: pulsate)
                    
                    Circle()
                        .stroke(moodColor.opacity(0.5), lineWidth: 1)
                        .frame(width: 50, height: 50)
                    
                    Text(entry.emoji)
                        .font(.title)
                        .shadow(color: moodColor.opacity(0.5), radius: 5, x: 0, y: 0)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.mood)
                        .font(.title3)
                        .bold()
                        .foregroundColor(Theme.textPrimary)
                    
                    Text(entry.date, style: .date)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Theme.textSecondary)
                }
                
                Spacer()
                
                // Level Badge if applicable
                if let level = entry.levelCompleted {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("Lvl \(level)")
                            .font(.system(size: 12, weight: .bold))
                    } // Correctly closed HStack
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Theme.accent.opacity(0.2))
                    .foregroundColor(Theme.accent)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().stroke(Theme.accent.opacity(0.5), lineWidth: 1)
                    )
                }
            }
            
            // Text Content with subtle separator
            if !entry.text.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Divider()
                        .background(Theme.divider)
                    
                    Text(entry.text)
                        .font(.body)
                        .foregroundColor(Theme.textPrimary.opacity(0.9))
                        .lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true) // Ensure text wraps properly
                        .padding(.top, 5)
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                Theme.elevatedCard
                
                // Subtle gradient based on mood
                RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                    .fill(
                        LinearGradient(
                            colors: [moodColor.opacity(0.15), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .cornerRadius(Theme.cornerRadiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadiusLarge)
                .stroke(Theme.divider, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        .overlay(
            // Gradient Border
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [moodColor.opacity(0.6), Theme.divider],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: moodColor.opacity(0.15), radius: 15, x: 0, y: 5)
        .offset(y: isVisible ? 0 : 20)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isVisible = true
            }
            pulsate = true
        }
    }
}

struct JourneyView_Previews: PreviewProvider {
    static var previews: some View {
        JourneyView()
            .environmentObject(AppState())
    }
}
