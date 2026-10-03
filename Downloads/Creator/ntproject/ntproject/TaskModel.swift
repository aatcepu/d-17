import Foundation

// Identifiable: Required so SwiftUI can uniquely identify each task in a list.
// Equatable: Required to check if two tasks are the same (useful for searching/deleting).
struct Task: Identifiable, Equatable {
    // A unique ID is essential for tracking tasks.
    let id = UUID()
    
    // The text description of the task.
    var title: String
    
    // Tracks whether the task has been completed.
    var isCompleted: Bool = false
}
