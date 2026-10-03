import SwiftUI
import Charts

struct DailySummaryView: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var selectedDate = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with date selector
                HStack {
                    Text("Today's Summary")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .frame(width: 150)
                }
                .padding(.horizontal)
                
                // Main metrics cards
                VStack(spacing: 15) {
                    // Calories card
                    MetricCard(
                        title: "Calories",
                        currentValue: viewModel.dailySummary.totalCalories,
                        goalValue: Constants.dailyCalorieGoal,
                        unit: "kcal",
                        color: .red
                    )
                    
                    // Macros card
                    HStack(spacing: 15) {
                        MacroCard(title: "Protein", value: viewModel.dailySummary.totalProtein, goal: Constants.dailyProteinGoal, unit: "g", color: .proteinColor)
                        MacroCard(title: "Carbs", value: viewModel.dailySummary.totalCarbs, goal: Constants.dailyCarbGoal, unit: "g", color: .carbColor)
                        MacroCard(title: "Fat", value: viewModel.dailySummary.totalFat, goal: Constants.dailyFatGoal, unit: "g", color: .fatColor)
                    }
                    
                    // Health metrics
                    HStack(spacing: 15) {
                        HealthMetricCard(title: "Hydration", value: viewModel.hydrationIndex, unit: "%", color: .blue)
                        HealthMetricCard(title: "Meal Score", value: viewModel.mealQualityScore, unit: "", color: .healthScoreColor(for: viewModel.mealQualityScore))
                        HealthMetricCard(title: "Balance", value: viewModel.balanceMeter, unit: "%", color: .green)
                    }
                }
                .padding(.horizontal)
                
                // Macronutrient distribution chart
                VStack(alignment: .leading) {
                    Text("Macronutrient Distribution")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart {
                        BarMark(
                            x: .value("Nutrient", "Protein"),
                            y: .value("Calories", viewModel.dailySummary.totalProtein * 4)
                        )
                        .foregroundStyle(.red)
                        
                        BarMark(
                            x: .value("Nutrient", "Carbs"),
                            y: .value("Calories", viewModel.dailySummary.totalCarbs * 4)
                        )
                        .foregroundStyle(.blue)
                        
                        BarMark(
                            x: .value("Nutrient", "Fat"),
                            y: .value("Calories", viewModel.dailySummary.totalFat * 9)
                        )
                        .foregroundStyle(.yellow)
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Weekly trend chart
                VStack(alignment: .leading) {
                    Text("Weekly Trend")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Chart(viewModel.weeklyData) { data in
                        LineMark(
                            x: .value("Day", data.weekday),
                            y: .value("Calories", data.calories)
                        )
                        .foregroundStyle(.blue)
                        .symbol(Circle().stroke())
                    }
                    .frame(height: 200)
                    .padding(.horizontal)
                }
                
                // Meal timeline
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Meals")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(0..<5) { _ in
                        MealTimelineRow(time: "12:30 PM", mealName: "Lunch", calories: 420, icon: " fork.knife")
                    }
                }
            }
            .padding(.top)
        }
        .refreshable {
            viewModel.refreshData()
        }
        .onAppear {
            viewModel.refreshData()
        }
    }
}

struct MetricCard: View {
    let title: String
    let currentValue: Double
    let goalValue: Double
    let unit: String
    let color: Color
    
    var progress: Double {
        return min(1.0, currentValue / goalValue)
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 20)
                .cornerRadius(10)
            
            Rectangle()
                .fill(color)
                .frame(width: max(5, CGFloat(progress) * 300), height: 20)
                .cornerRadius(10)
                .animation(.easeInOut(duration: 0.3), value: progress)
        }
        .overlay(
            HStack {
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                Text("\(Int(currentValue))/\(Int(goalValue)) \(unit)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal)
        )
        .frame(height: 60)
        .background(Constants.cardBackgroundColor)
        .cornerRadius(15)
    }
}

struct MacroCard: View {
    let title: String
    let value: Double
    let goal: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(Int(value))/\(Int(goal))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: min(1.0, value/goal))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Constants.cardBackgroundColor)
        .cornerRadius(10)
    }
}

struct HealthMetricCard: View {
    let title: String
    let value: Int
    let unit: String
    let color: Color
    
    var body: some View {
        VStack {
            Text("\(value)\(unit)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Constants.cardBackgroundColor)
        .cornerRadius(10)
    }
}

struct MealTimelineRow: View {
    let time: String
    let mealName: String
    let calories: Int
    let icon: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(time)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Text(mealName)
                    .font(.headline)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(calories) kcal")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Label("Good Balance", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Constants.cardBackgroundColor)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct DailySummaryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DailySummaryView(viewModel: DashboardViewModel(mealHistoryViewModel: MealHistoryViewModel()))
        }
    }
}