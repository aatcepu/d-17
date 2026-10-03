import Foundation
import Combine

class MealHistoryViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadSampleMeals()
    }
    
    func saveMeal(_ meal: Meal) {
        meals.insert(meal, at: 0) // Add to the beginning of the list
        sortMealsByDate()
    }
    
    func deleteMeal(at indexSet: IndexSet) {
        meals.remove(atOffsets: indexSet)
    }
    
    func getMeal(withId id: UUID) -> Meal? {
        return meals.first { $0.id == id }
    }
    
    func updateMeal(_ meal: Meal) {
        if let index = meals.firstIndex(where: { $0.id == meal.id }) {
            meals[index] = meal
        }
    }
    
    private func sortMealsByDate() {
        meals.sort { $0.date > $1.date } // Sort by date descending (newest first)
    }
    
    private func loadSampleMeals() {
        // Load sample meals for demonstration purposes
        let sampleMeals = [
            Meal(
                name: "Breakfast",
                date: Date().addingTimeInterval(-8*3600), // 8 hours ago
                foods: [
                    FoodItem(
                        name: "Oatmeal",
                        confidence: 0.89,
                        nutritionFacts: NutritionFacts(
                            calories: 147,
                            protein: 5.0,
                            carbs: 25.0,
                            fat: 2.5,
                            fiber: 4.0,
                            sugar: 0.4
                        ),
                        portionEstimate: PortionEstimate(weightInGrams: 240, multiplier: 2.4)
                    ),
                    FoodItem(
                        name: "Blueberries",
                        confidence: 0.91,
                        nutritionFacts: NutritionFacts(
                            calories: 84,
                            protein: 1.1,
                            carbs: 21.4,
                            fat: 0.3,
                            fiber: 3.6,
                            sugar: 15.4
                        ),
                        portionEstimate: PortionEstimate(weightInGrams: 148, multiplier: 1.48)
                    )
                ]
            ),
            Meal(
                name: "Lunch",
                date: Date().addingTimeInterval(-3*3600), // 3 hours ago
                foods: [
                    FoodItem(
                        name: "Grilled Chicken Salad",
                        confidence: 0.85,
                        nutritionFacts: NutritionFacts(
                            calories: 320,
                            protein: 30.0,
                            carbs: 12.0,
                            fat: 18.0,
                            fiber: 5.0,
                            sugar: 6.0
                        ),
                        portionEstimate: PortionEstimate(weightInGrams: 350, multiplier: 3.5)
                    ),
                    FoodItem(
                        name: "Avocado",
                        confidence: 0.78,
                        nutritionFacts: NutritionFacts(
                            calories: 234,
                            protein: 3.0,
                            carbs: 12.0,
                            fat: 21.0,
                            fiber: 10.0,
                            sugar: 0.7
                        ),
                        portionEstimate: PortionEstimate(weightInGrams: 200, multiplier: 2.0)
                    )
                ]
            )
        ]
        
        meals = sampleMeals
        sortMealsByDate()
    }
    
    func getMealsForToday() -> [Meal] {
        let calendar = Calendar.current
        return meals.filter { calendar.isDateInToday($0.date) }
    }
    
    func getMealsForDate(_ date: Date) -> [Meal] {
        let calendar = Calendar.current
        return meals.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func getTotalNutrition(for date: Date) -> NutritionFacts {
        let dailyMeals = getMealsForDate(date)
        var totalNutrition = NutritionFacts()
        
        for meal in dailyMeals {
            totalNutrition.calories += meal.totalCalories
            totalNutrition.protein += meal.totalProtein
            totalNutrition.carbs += meal.totalCarbs
            totalNutrition.fat += meal.totalFat
            totalNutrition.fiber += meal.foods.reduce(0) { $0 + $1.nutritionFacts.fiber }
            totalNutrition.sugar += meal.foods.reduce(0) { $0 + $1.nutritionFacts.sugar }
        }
        
        return totalNutrition
    }
}