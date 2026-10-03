import SwiftUI

struct AdjustPortionView: View {
    @Binding var foods: [FoodItem]
    let onSave: ([FoodItem]) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<foods.count, id: \.self) { index in
                    FoodAdjustmentRow(
                        food: foods[index],
                        onUpdate: { updatedFood in
                            foods[index] = updatedFood
                        }
                    )
                }
            }
            .navigationTitle("Adjust Portions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(foods)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct FoodAdjustmentRow: View {
    let food: FoodItem
    let onUpdate: (FoodItem) -> Void
    
    @State private var selectedPortionSize = PortionEstimate.PortionSize.medium
    @State private var weightAmount: Double = 100
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(food.name)
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.0f%%", food.confidence * 100))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Portion Size")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Picker("Portion Size", selection: $selectedPortionSize) {
                    ForEach(PortionEstimate.PortionSize.allCases, id: \.self) { size in
                        Text(size.displayName).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: selectedPortionSize) { size in
                    updatePortionEstimate()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Weight (grams)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Slider(value: $weightAmount, in: 25...300, step: 5) { _ in
                        updatePortionEstimate()
                    }
                    
                    Text("\(Int(weightAmount))g")
                        .frame(width: 50, alignment: .trailing)
                }
            }
            
            // Updated nutrition facts based on portion
            HStack {
                VStack(alignment: .leading) {
                    Text("Updated Nutrition:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Calories: \(Int(calculateUpdatedCalories()))")
                        .font(.caption)
                    
                    HStack {
                        Text("Pro: \(calculateUpdatedProtein().twoDecimalPlaceString)g")
                        Text("Carbs: \(calculateUpdatedCarbs().twoDecimalPlaceString)g")
                        Text("Fat: \(calculateUpdatedFat().twoDecimalPlaceString)g")
                    }
                    .font(.caption)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Constants.cardBackgroundColor)
        .cornerRadius(10)
        .onAppear {
            selectedPortionSize = food.portionEstimate.size
            weightAmount = food.portionEstimate.weightInGrams
        }
    }
    
    private func updatePortionEstimate() {
        let multiplier = weightAmount / Constants.defaultPortionBaseWeight
        
        let updatedPortion = PortionEstimate(
            size: selectedPortionSize,
            weightInGrams: weightAmount,
            multiplier: multiplier
        )
        
        var updatedFood = food
        updatedFood.portionEstimate = updatedPortion
        
        // Update nutrition facts based on the new multiplier
        var updatedNutrition = food.nutritionFacts
        updatedNutrition.calories = food.nutritionFacts.calories * multiplier
        updatedNutrition.protein = food.nutritionFacts.protein * multiplier
        updatedNutrition.carbs = food.nutritionFacts.carbs * multiplier
        updatedNutrition.fat = food.nutritionFacts.fat * multiplier
        updatedNutrition.fiber = food.nutritionFacts.fiber * multiplier
        updatedNutrition.sugar = food.nutritionFacts.sugar * multiplier
        
        updatedFood.nutritionFacts = updatedNutrition
        
        onUpdate(updatedFood)
    }
    
    private func calculateUpdatedCalories() -> Double {
        return food.nutritionFacts.calories * (weightAmount / Constants.defaultPortionBaseWeight)
    }
    
    private func calculateUpdatedProtein() -> Double {
        return food.nutritionFacts.protein * (weightAmount / Constants.defaultPortionBaseWeight)
    }
    
    private func calculateUpdatedCarbs() -> Double {
        return food.nutritionFacts.carbs * (weightAmount / Constants.defaultPortionBaseWeight)
    }
    
    private func calculateUpdatedFat() -> Double {
        return food.nutritionFacts.fat * (weightAmount / Constants.defaultPortionBaseWeight)
    }
}

struct AdjustPortionView_Previews: PreviewProvider {
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
        
        @State var foods = [sampleFood]
        
        return AdjustPortionView(foods: $foods) { _ in }
    }
}