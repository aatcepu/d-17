//
//  ContentView.swift
//  Gross
//
//  Created by Student on 16/12/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    // Used to perform CRUD operations
     @Environment(\.modelContext) private var modelContext
     
    @Query(filter: #Predicate<Item> { $0.isInCart == true })
    private var items: [Item]
    

//     @Query private var items: [Item]
    // State variables
        @State private var title: String = ""
        @State private var isAlertShowing: Bool = false
    @State private var isShowingCart: Bool = false

    
    var body: some View {
        NavigationStack{
            
            List{
                ForEach(items) { item in

                    HStack {
                        Text(item.title)

                        Spacer()

                        Button("Remove") {
                            item.isInCart = false
                        }
                        
                    }
                    HStack {
                        Button("-") {
                            if item.quantity > 1 {
                                item.quantity -= 1
                            }
                        }

                        Text("\(item.quantity)")
                            .padding(.horizontal)

                        Button("+") {
                            item.quantity += 1
                        }
                    }
                    
                }


            }
            
            .navigationTitle("Grocery list")
            // Toolbar Button
                       .toolbar {
                           ToolbarItem(placement: .topBarTrailing) {
                               Button {
                                   isAlertShowing.toggle()
                               } label: {
                                   Image(systemName: "carrot.fill")
                                       .imageScale(.large)
                               }
                           }
                           ToolbarItem(placement: .bottomBar) {
                               Button("Checkout") {
                                   for item in items {
                                       item.isInCart = false
                                   }
                               }
                           }
                       }
            // Alert to add item
                       .alert("Add Grocery Item", isPresented: $isAlertShowing) {
                           TextField("Enter item name", text: $title)
                           
                           Button("Save") {
                               modelContext.insert(Item(title: title))
                               title = ""
                           }
                           .disabled(title.isEmpty)
                       }
            
            .overlay{
                        if items.isEmpty {
                                    ContentUnavailableView(
                                        "Empty cart",
                                        systemImage: "plus.circle.fill",
                                        description: Text("Add some items")
                                    )
                                }
                        }
            
        }
    }
    
}
@MainActor
let previewContainer: ModelContainer = {
    let container = try! ModelContainer(
        for: Item.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    let context = container.mainContext

    // Manually adding items to CART
    context.insert(Item(title: "Milk", isInCart: true))
    context.insert(Item(title: "Bread", isInCart: true))
    context.insert(Item(title: "Eggs", isInCart: true))

    return container
}()
#Preview("Second list"){
    ContentView()
           .modelContainer(previewContainer)
           
}
#Preview("First list") {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
