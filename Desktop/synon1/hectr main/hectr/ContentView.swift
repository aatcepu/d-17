//
//  ContentView.swift
//  hectr
//
//  Created by Student on 07/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
        ZStack{
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .frame(height: 900)
            VStack(spacing: 20){
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55,height: 60)
                    .padding(.top, 200)
                Text("Welcome \nTo our store")
                    .foregroundColor(.white)
                    .font(.system(size: 35, weight: .semibold))
                    .multilineTextAlignment(.center)
                //                Text("to our store")
                //                    .font(.largeTitle)
                //                    .fontWeight(.bold)
                //                    .foregroundColor(.white)
                Text("Get your Groceries as fast as one hour")
                    .foregroundStyle(.gray)
                NavigationLink(destination: signin()){
                    Text("Get Started")
                        .foregroundStyle(.white)
                        .frame(width: 250, height: 50)
                        .background(.green)
                        .cornerRadius(10)
                }
            }
        }
        }
    }
}

#Preview {
    ContentView()
}
