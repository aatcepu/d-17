import SwiftUI

struct MealHistoryView: View {
    @ObservedObject var viewModel: MealHistoryViewModel
    @State private var selectedMeal: Meal?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.meals.isEmpty {
                    EmptyStateView()
                } else {
                    List {
                        ForEach(viewModel.meals) { meal in
                            MealHistoryRow(meal: meal) {
                                selectedMeal = meal
                            }
                        }
                        .onDelete(perform: deleteMeal)
                    }
                }
            }
            .navigationTitle("Meal History")
            .sheet(item: $selectedMeal) { meal in
                MealDetailView(meal: meal)
            }
        }
    }
    
    private func deleteMeal(offsets: IndexSet) {
        viewModel.deleteMeal(at: offsets)
    }
}

struct MealHistoryRow: View {
    let meal: Meal
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            // Meal thumbnail
            if let imageData = meal.image,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(meal.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(meal.formattedCalories)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text(meal.formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    // Meal score indicator
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text("\(meal.mealScore)/100")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    // Food count
                    HStack(spacing: 4) {
                        Image(systemName: "fork.knife")
                        Text("\(meal.foods.count) items")
                            .font(.caption)
                    }
                }
            }
            .padding(.leading, 8)
        }
        .padding(.vertical, 4)
        .onTapGesture {
            onTap()
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No meals recorded yet")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("Scan your first meal to get started!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MealDetailView: View {
    let meal: Meal
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Meal header with image
                if let imageData = meal.image,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(meal.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text(meal.formattedCalories)
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    
                    Text(meal.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Meal score
                HStack {
                    Text("Meal Quality Score")
                        .font(.headline)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                        Text("\(meal.mealScore)/100")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(8)
                    .background(Color.healthScoreColor(for: meal.mealScore).opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Macros breakdown
                VStack(alignment: .leading, spacing: 10) {
                    Text("Macronutrients")
                        .font(.headline)
                    
                    HStack {
                        MacroDetailItem(title: "Protein", value: meal.totalProtein, goal: Constants.dailyProteinGoal, color: .proteinColor)
                        MacroDetailItem(title: "Carbs", value: meal.totalCarbs, goal: Constants.dailyCarbGoal, color: .carbColor)
                        MacroDetailItem(title: "Fat", value: meal.totalFat, goal: Constants.dailyFatGoal, color: .fatColor)
                    }
                }
                .padding(.horizontal)
                
                // Food items
                Text("Food Items (\(meal.foods.count))")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(meal.foods) { food in
                    FoodItemDetailRow(food: food)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct MacroDetailItem: View {
    let title: String
    let value: Double
    let goal: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(Int(value))g")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: min(1.0, value/goal))
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 0.8, anchor: .center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Constants.cardBackgroundColor)
        .cornerRadius(10)
    }
}

struct FoodItemDetailRow: View {
    let food: FoodItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                
                HStack {
                    Text("Cal: \(food.displayCalories)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Pro: \(food.displayProtein)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Carbs: \(food.displayCarbs)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Fat: \(food.displayFat)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Portion: \(food.portionEstimate.displayWeight)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Confidence: \(Int(food.confidence * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Constants.cardBackgroundColor)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct MealHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        MealHistoryView(viewModel: MealHistoryViewModel())
    }
}