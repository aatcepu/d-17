import Foundation

class NutritionDBLoader: ObservableObject {
    private var nutritionDatabase: [String: NutritionFacts] = [:]
    
    init() {
        loadNutritionDatabase()
    }
    
    private func loadNutritionDatabase() {
        // In a real implementation, we would load from a JSON file
        // For now, we'll populate with sample data
        
        // Sample nutrition data for common foods
        nutritionDatabase = [
            "apple": NutritionFacts(
                calories: 52,
                protein: 0.3,
                carbs: 13.8,
                fat: 0.2,
                fiber: 2.4,
                sugar: 10.4
            ),
            "banana": NutritionFacts(
                calories: 89,
                protein: 1.1,
                carbs: 22.8,
                fat: 0.3,
                fiber: 2.6,
                sugar: 12.2
            ),
            "orange": NutritionFacts(
                calories: 47,
                protein: 0.9,
                carbs: 11.8,
                fat: 0.1,
                fiber: 2.4,
                sugar: 9.4
            ),
            "bread slice": NutritionFacts(
                calories: 79,
                protein: 2.7,
                carbs: 14.6,
                fat: 1.0,
                fiber: 0.6,
                sugar: 1.4
            ),
            "chicken breast": NutritionFacts(
                calories: 165,
                protein: 31.0,
                carbs: 0,
                fat: 3.6,
                fiber: 0,
                sugar: 0
            ),
            "rice": NutritionFacts(
                calories: 130,
                protein: 2.7,
                carbs: 28.2,
                fat: 0.3,
                fiber: 0.4,
                sugar: 0.1
            ),
            "broccoli": NutritionFacts(
                calories: 34,
                protein: 2.8,
                carbs: 6.6,
                fat: 0.4,
                fiber: 2.6,
                sugar: 1.2
            ),
            "carrot": NutritionFacts(
                calories: 41,
                protein: 0.9,
                carbs: 9.6,
                fat: 0.2,
                fiber: 2.8,
                sugar: 4.7
            ),
            "potato": NutritionFacts(
                calories: 77,
                protein: 2.0,
                carbs: 17.0,
                fat: 0.1,
                fiber: 2.2,
                sugar: 0.8
            ),
            "cheese": NutritionFacts(
                calories: 402,
                protein: 25.0,
                carbs: 1.3,
                fat: 33.0,
                fiber: 0,
                sugar: 0.5
            ),
            "egg": NutritionFacts(
                calories: 155,
                protein: 13.0,
                carbs: 1.1,
                fat: 11.0,
                fiber: 0,
                sugar: 1.1
            )
        ]
    }
    
    func getNutritionFacts(for foodName: String) -> NutritionFacts? {
        // Try exact match first
        if let nutrition = nutritionDatabase[foodName.lowercased()] {
            return nutrition
        }
        
        // Try partial match
        for (dbName, facts) in nutritionDatabase {
            if foodName.lowercased().contains(dbName) || dbName.contains(foodName.lowercased()) {
                return facts
            }
        }
        
        return nil
    }
    
    func getAllFoodNames() -> [String] {
        return Array(nutritionDatabase.keys).sorted()
    }
    
    func addCustomFood(named name: String, with nutritionFacts: NutritionFacts) {
        nutritionDatabase[name.lowercased()] = nutritionFacts
    }
    
    func updateFood(named name: String, with nutritionFacts: NutritionFacts) {
        nutritionDatabase[name.lowercased()] = nutritionFacts
    }
    
    func searchFoods(query: String) -> [String] {
        let lowerQuery = query.lowercased()
        return nutritionDatabase.keys.filter { $0.contains(lowerQuery) }.sorted()
    }
    
    func loadFromFile(named fileName: String) {
        // This would load nutrition data from a JSON file
        // Implementation would involve reading the file and parsing JSON
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Could not find file: \(fileName).json")
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            // Parse JSON and populate nutritionDatabase
            // This is a simplified representation
        } catch {
            print("Error loading nutrition database: \(error)")
        }
    }
    
    func saveToFile(named fileName: String) {
        // This would save the nutrition database to a JSON file
        do {
            // Convert nutritionDatabase to JSON and save to file
            // This is a simplified representation
        } catch {
            print("Error saving nutrition database: \(error)")
        }
    }
}