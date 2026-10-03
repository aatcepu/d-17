//
//  ContentView.swift
//  grocery store
//
//  Created by Student on 10/07/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            
        
        ZStack{ Image("onbording")
                .ignoresSafeArea()
            
            VStack{
            Image("Group")
                Text("Welcome to \n our store ")
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .font(.system (size: 50))
                    .fontWeight(.bold)
                    
                          
                Text("Get your groceries in as fast as one hour ")
                    .foregroundStyle(.gray)
                
                NavigationLink(destination: ContinueView()){
                    
                
                    Text("Get started")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .frame(width:350, height:60)
                    .background(.green)
                    .cornerRadius(20)
                    
                }
            }
            .padding(.top, 200)
        
        }
    }
}
}

#Preview {
    ContentView()
}
