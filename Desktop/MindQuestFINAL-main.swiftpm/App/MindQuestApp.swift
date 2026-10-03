import SwiftUI

@main
struct MyApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .onAppear {
                    Task {
                        let _ = await notificationManager.requestPermission()
                    }
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                notificationManager.clearBadge()
            }
        }
    }
}
