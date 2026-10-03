import SwiftUI

struct ContentView: View {
    
    // @State: Holds the array of Task objects.
    // This is the core application state. Changes here automatically update the UI.
    @State private var tasks: [Task] = [
        Task(title: "Finish SwiftUI Project", isCompleted: false),
        Task(title: "Buy Groceries", isCompleted: true),
        Task(title: "Walk the Dog", isCompleted: false)
    ]
    
    // @State: Holds the text currently being typed in the Add Task field.
    @State private var newTaskTitle: String = ""
    
    // @FocusState: Manages which UI element currently has keyboard focus (for dismissing the keyboard).
    @FocusState private var isInputActive: Bool
    
    // --- 💻 COMPUTED PROPERTIES for Organized Data ---
    
    // Tasks that are not yet completed (for the main list)
    var incompleteTasks: [Task] {
        tasks.filter { !$0.isCompleted }
    }
    
    // Tasks that are completed (for a separate section or display)
    var completedTasks: [Task] {
        tasks.filter { $0.isCompleted }
    }
    // --- 📱 VIEW BODY (The User Interface) ---
    
    var body: some View {
        // Use a NavigationView to provide a title bar and context
        NavigationView {
            
            // Use List for efficient display and built-in list features like swipe-to-delete
            List {
                
                // --- 1. Add New Task Section ---
                Section {
                    HStack {
                        // Text Field for input 
                        TextField("What needs to be done?", text: $newTaskTitle)
                            .focused($isInputActive) // Bind to FocusState
                            .onSubmit {
                                // Submitting the text (e.g., hitting return key) calls the function
                                addTask()
                            }
                        
                        // Add Button
                        Button(action: addTask) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color.blue)
                        }
                        // Disable button if input is empty
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                // --- 2. Incomplete Tasks Section ---
                Section("Pending Tasks (\(incompleteTasks.count))") {
                    
                    // Display tasks that are not complete
                    ForEach(incompleteTasks) { task in
                        // Use the TaskRow View to display the task details
                        TaskRow(task: task, toggleCompletion: toggleCompletion)
                    }
                    // Enable swipe-to-delete functionality
                    .onDelete(perform: deleteTask)
                }
                
                // --- 3. Completed Tasks Section ---
                Section("Completed Tasks (\(completedTasks.count))") {
                    
                    // Display tasks that ARE complete
                    ForEach(completedTasks) { task in
                        TaskRow(task: task, toggleCompletion: toggleCompletion)
                    }
                    // Enable swipe-to-delete functionality
                    .onDelete(perform: deleteCompletedTask)
                }
                
            } // End List
            .navigationTitle("To-Do List 📝")
            .toolbar {
                // Toolbar item to enable editing/deleting tasks in the list
                EditButton()
            }
            // Tap outside the keyboard to dismiss it
            .onTapGesture {
                isInputActive = false
            }
            
        } // End NavigationView
    }
    
    // --- 🗄️ FUNCTIONS TO MANAGE STATE ---
    
    // Function to add a new task to the list
    func addTask() {
        // Ensure the title is not just empty space
        let title = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        
        // 1. Create a new Task object
        let newTask = Task(title: title)
        
        // 2. Insert the new task at the beginning of the list
        tasks.insert(newTask, at: 0)
        
        // 3. Reset the input field
        newTaskTitle = ""
        
        // 4. Dismiss the keyboard
        isInputActive = false
    }
    
    // Function to toggle the isCompleted status of a task
    func toggleCompletion(task: Task) {
        // 1. Find the index of the task in the main 'tasks' array
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            // 2. Toggle the boolean value directly
            tasks[index].isCompleted.toggle()
        }
    }
    
    // Function to delete tasks from the 'incompleteTasks' section
    func deleteTask(at offsets: IndexSet) {
        // Convert the indices from the smaller 'incompleteTasks' array to the main 'tasks' array
        let tasksToDelete = offsets.map { incompleteTasks[$0] }
        tasksToDelete.forEach { taskToDelete in
            if let index = tasks.firstIndex(where: { $0.id == taskToDelete.id }) {
                tasks.remove(at: index)
            }
        }
    }

    // Function to delete tasks from the 'completedTasks' section
    func deleteCompletedTask(at offsets: IndexSet) {
        // Convert the indices from the smaller 'completedTasks' array to the main 'tasks' array
        let tasksToDelete = offsets.map { completedTasks[$0] }
        tasksToDelete.forEach { taskToDelete in
            if let index = tasks.firstIndex(where: { $0.id == taskToDelete.id }) {
                tasks.remove(at: index)
            }
        }
    }
}


// --- 3. Custom Row View (For UI Clarity) ---

// We create a separate struct for the row to keep the main ContentView clean.
struct TaskRow: View {
    
    // The task data passed into the row
    let task: Task
    // A closure (function block) to be executed when the row is tapped
    let toggleCompletion: (Task) -> Void
    
    var body: some View {
        HStack {
            // Checkmark Icon
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.isCompleted ? .green : .gray)
            
            // Task Title
            Text(task.title)
                // Apply strikethrough if the task is completed
                .strikethrough(task.isCompleted, color: .gray)
                .foregroundColor(task.isCompleted ? .gray : .primary)
            
            Spacer() // Pushes content to the sides
        }
        // Action to perform when the entire row is tapped
        .onTapGesture {
            toggleCompletion(task)
        }
    }
}

// --- Preview Provider ---
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
