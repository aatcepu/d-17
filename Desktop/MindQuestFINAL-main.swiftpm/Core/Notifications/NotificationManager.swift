import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private let notificationID = "mindquest.daily.reminder"
    
    private init() {
        Task { await checkAuthorizationStatus() }
    }
    
    // MARK: - Check current permission status
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Request permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            print("NotificationManager: Permission request failed - \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Schedule daily reminder
    func scheduleDailyReminder(at time: Date) {
        // Remove any existing reminder first
        cancelReminder()
        
        let content = UNMutableNotificationContent()
        content.title = "MindQuest 🕊️"
        content.body = "Time for your daily mood check-in! How are you feeling today?"
        content.sound = .default
        content.badge = 1
        
        // Extract hour and minute from the user's preferred time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        var triggerComponents = DateComponents()
        triggerComponents.hour = components.hour
        triggerComponents.minute = components.minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: true)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("NotificationManager: Failed to schedule - \(error.localizedDescription)")
            } else {
                print("NotificationManager: Daily reminder scheduled at \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    // MARK: - Cancel reminder
    func cancelReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])
    }
    
    // MARK: - Clear badge on launch
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
    }
}
