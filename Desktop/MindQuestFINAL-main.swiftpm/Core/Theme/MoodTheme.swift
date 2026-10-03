import SwiftUI

@MainActor
struct MoodTheme {
    static func color(for mood: String) -> Color {
        switch mood {
        case "Euphorically Happy": return .yellow
        case "Joyful & Positive": return .green
        case "Balanced & Calm": return Theme.secondary
        case "Slightly Down": return .orange
        case "Deeply Stressed or Sad": return .red
        default: return .gray
        }
    }
    
    static func gradient(for mood: String) -> LinearGradient {
        let baseColor = color(for: mood)
        return LinearGradient(
            colors: [baseColor.opacity(0.6), baseColor.opacity(0.1)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    static func icon(for mood: String) -> String {
        switch mood {
        case "Euphorically Happy": return "sun.max.fill"
        case "Joyful & Positive": return "face.smiling.fill"
        case "Balanced & Calm": return "leaf.fill"
        case "Slightly Down": return "cloud.fill"
        case "Deeply Stressed or Sad": return "cloud.rain.fill"
        default: return "circle.fill"
        }
    }
}
