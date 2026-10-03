//
//  ContentView.swift
//  Login17
//
//  Created by Student on 08/01/2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Welcome to SwiftUI")
                .font(.system(size: 30, weight: .bold))
            
            Spacer()
            Button {
                
            }
            label: {
                Text("Login")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .cornerRadius(30)
                }
            Text("OR")
            
            Button {
                
            }
            label: {
                Text("Facebook Login")
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(30)
                }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
