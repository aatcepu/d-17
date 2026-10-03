//
//  ContentView.swift
//  Talk
//
//  Created by Student on 29/06/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    var body: some View {
        HStack{
            Image(systemName: "envelope")
                .padding()
                .foregroundStyle(.gray)
            TextField("Email", text: $email)
        }
        .frame(width: 350,height: 55)
        .background(Color(.systemGray6))
        .cornerRadius(25)
        .shadow(radius: 20)
        HStack{
            Image(systemName: "key")
                .padding()
                .foregroundStyle(.gray)
            TextField("Password", text: $password)
        }
        .frame(width: 350,height: 55)
        .background(Color(.systemGray6))
        .cornerRadius(25)
        .shadow(radius: 20)
        
        .padding()
    }
}

#Preview {
    ContentView()
}
