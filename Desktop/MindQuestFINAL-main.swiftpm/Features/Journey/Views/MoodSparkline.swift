import SwiftUI

struct MoodSparkline: View {
    let moodHistory: [MoodEntry]
    @State private var isVisible = false
    @State private var drawProgress: CGFloat = 0
    @State private var dotScales: [CGFloat] = []
    
    // Convert last 7 mood entries to numerical scores
    private var scores: [Int] {
        let recentEntries = Array(moodHistory.prefix(7)).reversed()
        return recentEntries.map { entry in
            switch entry.mood {
            case "Euphorically Happy": return 5
            case "Joyful & Positive": return 4
            case "Balanced & Calm": return 3
            case "Slightly Down": return 2
            case "Deeply Stressed or Sad": return 1
            default: return 3
            }
        }
    }
    
    private var averageScore: Double {
        guard !scores.isEmpty else { return 3.0 }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }
    
    private var trendText: String {
        if scores.count < 2 { return "Keep checking in!" }
        let recent = scores.suffix(3)
        let earlier = scores.prefix(3)
        let recentAvg = Double(recent.reduce(0, +)) / Double(recent.count)
        let earlierAvg = Double(earlier.reduce(0, +)) / Double(earlier.count)
        if recentAvg > earlierAvg + 0.3 { return "Trending up! 📈" }
        if recentAvg < earlierAvg - 0.3 { return "Be gentle with yourself 💜" }
        return "Staying steady 🌊"
    }
    
    private var trendColor: Color {
        if averageScore >= 4.0 { return Theme.secondary }
        if averageScore >= 3.0 { return Theme.tertiary }
        if averageScore >= 2.0 { return Theme.warmGlow }
        return Theme.accent
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Title Row
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.subheadline)
                        .foregroundColor(trendColor)
                    
                    Text("Mood Trend")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(Theme.textPrimary)
                }
                
                Spacer()
                
                Text("Last \(scores.count) check-ins")
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(Theme.textSecondary)
            }
            
            // Sparkline
            if scores.count >= 2 {
                GeometryReader { geo in
                    let width = geo.size.width
                    let height: CGFloat = 50
                    let stepX = width / CGFloat(scores.count - 1)
                    let minScore = 1.0
                    let maxScore = 5.0
                    
                    ZStack {
                        // Grid lines
                        ForEach(1..<5) { i in
                            let y = height - (CGFloat(i) - CGFloat(minScore)) / CGFloat(maxScore - minScore) * height
                            Path { path in
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: width, y: y))
                            }
                            .stroke(Theme.textPrimary.opacity(0.04), style: StrokeStyle(lineWidth: 0.5, dash: [4, 4]))
                        }
                        
                        // Gradient fill under line
                        Path { path in
                            for (index, score) in scores.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = height - (CGFloat(score) - CGFloat(minScore)) / CGFloat(maxScore - minScore) * height
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                            // Close the path for fill
                            path.addLine(to: CGPoint(x: CGFloat(scores.count - 1) * stepX, y: height))
                            path.addLine(to: CGPoint(x: 0, y: height))
                            path.closeSubpath()
                        }
                        .fill(
                            LinearGradient(
                                colors: [trendColor.opacity(0.2), trendColor.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        // Line (animated draw)
                        Path { path in
                            for (index, score) in scores.enumerated() {
                                let x = CGFloat(index) * stepX
                                let y = height - (CGFloat(score) - CGFloat(minScore)) / CGFloat(maxScore - minScore) * height
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .trim(from: 0, to: drawProgress)
                        .stroke(trendColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        .shadow(color: trendColor.opacity(0.4), radius: 4)
                        
                        // Dots (staggered scale-in)
                        ForEach(Array(scores.enumerated()), id: \.offset) { index, score in
                            let x = CGFloat(index) * stepX
                            let y = height - (CGFloat(score) - CGFloat(minScore)) / CGFloat(maxScore - minScore) * height
                            let isLast = index == scores.count - 1
                            
                            Circle()
                                .fill(trendColor)
                                .frame(width: isLast ? 8 : 6, height: isLast ? 8 : 6)
                                .shadow(color: trendColor.opacity(isLast ? 0.8 : 0.5), radius: isLast ? 6 : 3)
                                .scaleEffect(index < dotScales.count ? dotScales[index] : 0)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: 50)
            } else {
                Text("Check in more to see your trend")
                    .font(.caption)
                    .foregroundColor(Theme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            
            // Trend Summary
            Text(trendText)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(trendColor)
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.textPrimary.opacity(0.03))
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [trendColor.opacity(0.04), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [trendColor.opacity(0.15), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
        .onAppear {
            dotScales = Array(repeating: 0, count: scores.count)
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                isVisible = true
            }
            // Animated line draw
            withAnimation(.easeInOut(duration: 1.2).delay(0.6)) {
                drawProgress = 1.0
            }
            // Staggered dot pop-in
            for i in 0..<scores.count {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.8 + Double(i) * 0.15)) {
                    if i < dotScales.count {
                        dotScales[i] = 1.0
                    }
                }
            }
        }
    }
}

struct MoodSparkline_Previews: PreviewProvider {
    static var previews: some View {
        let mockEntries = [
            MoodEntry(date: Date(), text: "", mood: "Joyful & Positive", emoji: "😊", activities: [], levelCompleted: nil),
            MoodEntry(date: Date().addingTimeInterval(-86400), text: "", mood: "Balanced & Calm", emoji: "😌", activities: [], levelCompleted: nil),
            MoodEntry(date: Date().addingTimeInterval(-172800), text: "", mood: "Slightly Down", emoji: "😕", activities: [], levelCompleted: nil),
            MoodEntry(date: Date().addingTimeInterval(-259200), text: "", mood: "Balanced & Calm", emoji: "😌", activities: [], levelCompleted: nil),
            MoodEntry(date: Date().addingTimeInterval(-345600), text: "", mood: "Euphorically Happy", emoji: "🌟", activities: [], levelCompleted: nil),
        ]
        
        MoodSparkline(moodHistory: mockEntries)
            .padding()
            .background(Color.black)
    }
}
