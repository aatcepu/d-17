//
//  ContentView.swift
//  document 2
//
//  Created by Student on 01/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Image("Image")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .frame(width:1000,height:900)
            
            VStack{
                Text("Welcome to my page")
                
                    .foregroundColor(.white)
                
                
                
                
                
            }
            .padding()
        }
    }
}
