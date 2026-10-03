//
//  ContentView.swift
//  ToDoApp
//
//  Created by Student on 14/12/2025.
//

import SwiftUI
import SwiftData

struct Notes: View {
    
        //crud perform
        @Environment(\.modelContext)
        private var modelContext
        
        @Query private var lists: [Listt]
        @State private var title:String = ""
    @State private var isAlertShowing: Bool = false
    var body: some View {
        NavigationStack {
            List {
                ForEach(lists){
                    list in
                    Text(list.title)
                        .swipeActions{
                                    Buttonsir("Delete", role: .destructive){
                                                        modelContext.delete(list)
                                                    }
                                                }
                        
                        }
            }
            .navigationTitle("Notes")
            .toolbar{
                ToolbarItem(placement: .topBarTrailing)
                {
                    Button{
                        isAlertShowing.toggle()
                    }label:{
                        Image(systemName: "plus.circle.fill")
                }
                }
            }
            .alert("Create a new list", isPresented: $isAlertShowing){
                            TextField("Enter a list",text: $title )
                            
                            Button(){
                                modelContext.insert(Listt(title: title))
                                title = ""
                            }label: {
                                Text("Save")
                            }
                            .disabled(title.isEmpty)
                        }
            .overlay{
                if lists.isEmpty{
                    ContentUnavailableView("My lists are not available",
                                           systemImage:"plus.circle.fill",description:Text("Tap the plus icon to  create the new list"))
                }
            }
        }
    }
}

#Preview("DEMO List"){
    
    do {
        let container = try! ModelContainer(
            for: Listt.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        let ctx = container.mainContext
        ctx.insert(Listt(title: "Privacy Policy"))
        ctx.insert(Listt(title: "Forbbiden Secret Policies"))
        ctx.insert(Listt(title: "Parul's Dark Policy"))
        ctx.insert(Listt(title: "Yagnik Bhaiii!"))
        ctx.insert(Listt(title: "MacBook Pro"))
        
        // Return the view for this preview
        return Notes()
            .modelContainer(container)
    } catch {
        fatalError("Failed to create a ModelContainer: \(error)")
    }
}

#Preview("Main List") {
    Notes()
        .modelContainer(for: Listt.self, inMemory: true)
}
