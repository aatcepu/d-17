//
//  ContentView.swift
//  healthlifestyle
//
//  Created by Student on 11/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            ZStack{
                Circle()
                    .foregroundStyle(.color.opacity(0.4))
                    .frame(width: 600, height: 340)
                    .padding(.bottom, 250)
                
                
                VStack(spacing: 30){
                    Image("lifestyle")
                        .resizable()
                        .scaledToFit()
                    Text("Discover fit\n and healthy life style")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundStyle(.color)
                    Text("Explore all the existing exercises based on your\n sports and interest")
                        .multilineTextAlignment(.center)
                    HStack(spacing: 30){
                        NavigationLink(destination: loginpage()){
                            Text("Login")
                                .font(Font.system(size: 18))
                                .foregroundStyle(.white)
                                .frame(width: 100, height: 50)
                                .background(.color)
                                .cornerRadius(10)
                                .bold()
                        }
                        NavigationLink(destination: register()){
                            Text("Sign up")
                                .font(Font.system(size: 18))
                                .foregroundStyle(.white)
                                .frame(width: 100, height: 50)
                                .background(.color)
                                .cornerRadius(10)
                                .bold()
                        }
                    }
                }
                
            }
            .padding(.bottom, 100)
        }
    }
}

#Preview {
    ContentView()
}
