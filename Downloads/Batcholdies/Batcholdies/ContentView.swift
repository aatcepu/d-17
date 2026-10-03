//
//  ContentView.swift
//  Batcholdies
//
//  Created by Teacher on 11/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            
        
        ZStack {
            Circle()
                .foregroundStyle(.color.opacity(0.3))
                .padding(.top, -300)
                .frame(width: 400)
//                .padding(.trailing, -300)
            VStack(spacing: 30){
                Image("Cross country race-rafiki")
                    .resizable()
                    .scaledToFit()
                
                
                Text("Discover fit \n and healthy life style")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.color)
                    .bold()
                    .font(.system(size: 35, design: .serif))
                    Text("Explore all the existing exercises based on your sports and interest")
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 50){
                    NavigationLink(destination: LoginView()){
                        
                   
                    Text("Login")
                        .foregroundStyle(.white)
                        .frame(width: 130, height: 50)
                        .background(.color)
                        .cornerRadius(10)
                        .bold()
                        
                    }
                    
                    
                        
                    Text("Register")
                        .bold()
                    
                }
                    
            }
            .padding(.bottom, 50)
            
            
        }
        .padding()
    }
}
}

#Preview {
    ContentView()
}
