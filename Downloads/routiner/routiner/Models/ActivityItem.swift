import Foundation

// MARK: - What is this file?
// Another plain-data Model, this time for the rows on the Profile screen's
// "Activity" tab (e.g. "112 points earned! Today, 12:34 PM").

struct ActivityItem: Identifiable {
    let id = UUID()

    var title: String        // e.g. "112 points earned!"
    var timeAgo: String       // e.g. "Today, 12:34 PM"
    var isPositive: Bool     // true = green up-arrow, false = red down-arrow
}

extension ActivityItem {
    static let sampleData: [ActivityItem] = [
        ActivityItem(title: "112 points earned!", timeAgo: "Today, 12:34 PM", isPositive: true),
        ActivityItem(title: "62 points earned!", timeAgo: "Today, 07:12 AM", isPositive: true),
        ActivityItem(title: "Weekly winning streak is broken!", timeAgo: "Yesterday, 16:14 PM", isPositive: false),
        ActivityItem(title: "96 points earned!", timeAgo: "11 Jun, 17:45 PM", isPositive: true)
    ]
}
