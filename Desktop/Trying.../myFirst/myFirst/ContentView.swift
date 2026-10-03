//
//  ContentView.swift
//  myFirst
//
//  Created by Student on 07/07/26.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)

                Text("Hello, world!")

                Text("Welcome to new World!")

                // Login and Sign Up buttons
                HStack(spacing: 10) {
                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        print("Sign Up tapped")
                    }) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.top, 350)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
