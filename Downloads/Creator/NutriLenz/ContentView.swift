import SwiftUI

struct ContentView: View {
    @StateObject private var mealHistoryVM = MealHistoryViewModel()
    @StateObject private var dashboardVM = DashboardViewModel(mealHistoryViewModel: mealHistoryVM)
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                CameraView()
                    .navigationTitle("Scan")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "camera")
                Text("Scan")
            }
            .tag(0)
            
            NavigationView {
                DailySummaryView(viewModel: dashboardVM)
                    .navigationTitle("Today")
            }
            .tabItem {
                Image(systemName: "chart.bar.doc.horizontal")
                Text("Today")
            }
            .tag(1)
            
            NavigationView {
                MealHistoryView(viewModel: mealHistoryVM)
                    .navigationTitle("History")
            }
            .tabItem {
                Image(systemName: "clock")
                Text("History")
            }
            .tag(2)
            
            NavigationView {
                SettingsView()
                    .navigationTitle("Settings")
            }
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(3)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}