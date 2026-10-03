import SwiftUI

struct DetectionResultView: View {
    let detectionResult: DetectionResult
    let capturedImage: UIImage
    let onSave: (Meal) -> Void
    
    @State private var showingAdjustView = false
    @State private var adjustedFoods: [FoodItem] = []
    @State private var mealName = "My Meal"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Captured image
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Overall stats
                VStack(alignment: .center, spacing: 10) {
                    Text("Nutrition Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        StatCard(value: "\(Int(detectionResult.totalCalories))", unit: "CAL", color: .red)
                        StatCard(value: detectionResult.detectedItems.count.formattedString, unit: "ITEMS", color: .blue)
                        StatCard(value: "\(detectionResult.mealScore)", unit: "SCORE", color: .green)
                    }
                    
                    HStack(spacing: 15) {
                        MacroBar(label: "Protein", value: detectionResult.totalProtein, goal: 50, color: .proteinColor)
                        MacroBar(label: "Carbs", value: detectionResult.totalCarbs, goal: 250, color: .carbColor)
                        MacroBar(label: "Fat", value: detectionResult.totalFat, goal: 70, color: .fatColor)
                    }
                }
                .padding()
                .background(Constants.cardBackgroundColor)
                .cornerRadius(15)
                .padding(.horizontal)
                
                // Detected foods
                Text("Detected Foods (\(detectionResult.detectionCount))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                ForEach(detectionResult.detectedItems) { food in
                    FoodItemRow(food: food) {
                        // Show adjustment view for this food
                        adjustedFoods = detectionResult.detectedItems
                        showingAdjustView = true
                    }
                }
                
                // Save button
                Button(action: {
                    let meal = Meal(
                        name: mealName,
                        foods: detectionResult.detectedItems,
                        image: capturedImage.toData()
                    )
                    onSave(meal)
                }) {
                    Text("Save Meal")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Constants.primaryColor)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAdjustView) {
            AdjustPortionView(
                foods: $adjustedFoods,
                onSave: { updatedFoods in
                    // In a real implementation, we would update the detection result
                    print("Updated foods: \(updatedFoods.count)")
                }
            )
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StatCard: View {
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(unit)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(width: 80, height: 80)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(color, lineWidth: 2)
        )
        .background(RoundedRectangle(cornerRadius: 10).fill(color.opacity(0.1)))
    }
}

struct MacroBar: View {
    let label: String
    let value: Double
    let goal: Double
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(Int(value))g")
                .font(.caption)
                .fontWeight(.bold)
            
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)
                
                Capsule()
                    .fill(color)
                    .frame(width: max(5, min(100, (value / goal) * 100)), height: 10)
            }
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FoodItemRow: View {
    let food: FoodItem
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text(food.name)
                        .font(.headline)
                    Spacer()
                    Text(String(format: "%.0f%%", food.confidence * 100))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
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
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Multiplier: \(food.portionEstimate.displayMultiplier)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Constants.cardBackgroundColor)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

extension Int {
    var formattedString: String {
        return String(self)
    }
}

struct DetectionResultView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleFood = FoodItem(
            name: "Apple",
            confidence: 0.92,
            nutritionFacts: NutritionFacts(
                calories: 52,
                protein: 0.3,
                carbs: 13.8,
                fat: 0.2,
                fiber: 2.4,
                sugar: 10.4
            ),
            portionEstimate: PortionEstimate(weightInGrams: 182, multiplier: 1.82)
        )
        
        let detectionResult = DetectionResult(
            detectedItems: [sampleFood],
            confidenceThreshold: 0.5,
            processingTime: 1.2
        )
        
        let sampleImage = UIImage(systemName: "applelogo") ?? UIImage()
        
        return NavigationView {
            DetectionResultView(
                detectionResult: detectionResult,
                capturedImage: sampleImage
            ) { _ in }
        }
    }
}