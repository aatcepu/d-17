//
//  ContentView.swift
//  Pet
//
//  Created by Student on 27/01/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @Query private var pets: [Pet]
    var body: some View {
        let layout = [
            GridItem(.flexible(minimum: 120)),
            GridItem(.flexible(minimum: 120))
        ]
        
        NavigationStack{
            ScrollView{
                LazyVGrid(columns: layout){
                    GridRow{
                        ForEach(pets){
                            pet in
                            NavigationLink(destination: EmptyView()){
                                VStack{
                                    
                                    if let imageData = pet.photo{
                                        if let image = UIImage(data: imageData){
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFit()
                                                .clipShape(
                                                    RoundedRectangle(cornerRadius:8,
                                                                     style: .circular))
                                        }
        
                                    }else{
                                        Image(systemName: "pawprint.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(40)
                                            .foregroundStyle(.quaternary)
                                    }
                                    
                                    Spacer()
                                    Text(pet.name)
                                        .font(.title.weight(.light))
                                        .padding(.vertical)
                                    Spacer()
                                        
                                }
                                .frame(minWidth: 0,  maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius:8, style: .circular))
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle(pets.isEmpty ? "" : "Paws")
            .overlay{
                if pets.isEmpty {
                    CustomView(icon: "dog.circle", title: "No pets", description: "Add new pet")
                }
            }
            }
        }
    }


#Preview("No data") {
        ContentView()
            .modelContainer(for: Pet.self, inMemory: true)
    
}
#Preview("Sample data"){
    ContentView()
        .modelContainer(Pet.preview)
}
