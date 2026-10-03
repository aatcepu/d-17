//
//  ContentView.swift
//  classroom
//
//  Created by Student on 11/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack{
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(height: 880)
            Text("Welcome to Classroom\n Join over 10.000 learners over the world")
                .foregroundStyle(.white)
                .font(.system(size: 30, weight: .semibold))
                .multilineTextAlignment(.center)
            
        }
    }
}

#Preview {
    ContentView()
}
