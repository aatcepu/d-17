//
//  ContentView.swift
//  TaskFlow
//
//  Created by Student on 03/12/2025.
//

import SwiftUI
import SwiftData

struct NotesApp: View {
    //Used to perform CRUD Operation
    @Environment(\.modelContext)
        private var modelContext
    @Query private var Lists: [Listt]
    
    @State private var title: String = ""
    @State private var isAlertShowing:Bool = false
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(Lists)
                {
                    Lists in
                    Text(Lists.title)
                        .font(.title)
                        .fontWeight(.light)
                        .padding(.vertical, 1)
                    
                }
            }
                             
            .navigationTitle("TaskFlow")
            .toolbar {
                ToolbarItem(placement:
                        .topBarTrailing){
                            Button{
                                isAlertShowing.toggle()
                            } label:{
                                Image(systemName:
                                        "plus")
                                .imageScale(.large)
                            }
                        }
            }
            .alert("Create a new list", isPresented:$isAlertShowing){
                TextField("Enter a List",text:$title)
                Button(){
                    modelContext.insert(Listt(title: title))
                }label:{
                    Text("Save")
                    
                }
                .disabled(title.isEmpty)
            }
        
            .overlay {
                if Lists.isEmpty{
                    ContentUnavailableView("Lists are not Available",systemImage:"heart.circle",description: Text("No List yet, Add one to get Start"))

                }
            }
        }
    }
}



#Preview("Second List"){
    
    let container = try! ModelContainer(for: Listt.self, configurations: ModelConfiguration (isStoredInMemoryOnly: true))
    
    let ctx = container.mainContext
    ctx.insert(Listt(title: "Swift Coding Club"))
    ctx.insert(Listt(title: "College"))
    ctx.insert(Listt(title: "Machine Learning"))
    ctx.insert(Listt(title: "QR"))
    ctx.insert(Listt(title: "MERN Stack"))
    ctx.insert(Listt(title: "Self Study"))
    ctx.insert(Listt(title: "CD"))
    ctx.insert(Listt(title: "Sleep"))


    return NotesApp()
        .modelContainer(container)
}

#Preview {
    NotesApp()
        .modelContainer(for: Listt.self, inMemory: true)
}


