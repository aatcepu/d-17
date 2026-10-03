//
//  ContentView.swift
//  Talkative
//
//  Created by Student on 30/06/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    var body: some View {
        NavigationStack{
            ZStack{
                Color.gray.opacity(0.10).ignoresSafeArea()
                VStack(spacing: 20){
                    Text("Sign In")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .offset(x: 0, y: 0)
                    Button {
                        
                    }label: {
                        HStack {
                            Image(.apple)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 27)
                            Text("Sign-In With Apple")
                                .font(.system(size: 23))
                                .foregroundStyle(.black)
                        }
                        .frame(width: 350, height: 60)
                        .background(Color(.systemGray6))
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.1) , radius: 12, x:5, y: 15)
                    }
                    Button {
                        
                    }label :{
                        HStack {
                            Image(.google)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 27, height: 27)
                            Text("Sign-In With Apple")
                                .font(.system(size: 23))
                                .foregroundStyle(.color1)
                        }
                        .frame(width: 350, height: 60)
                        .background(Color(.systemGray6))
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.1) , radius: 12, x:5, y: 15)
                    }
                    
                    .padding(.bottom)
                    .padding(.bottom)
                    
                    Text("Or get a link email to you")
                    //.fontWeight(.semibold)
                        .foregroundStyle(.gray)
                        .padding()
                    
                    TextField("Work Email Address ", text: $email)
                        .padding()
                        .frame(width: 350, height: 60)
                        .background(Color(.white))
                        .cornerRadius(30)
                        .shadow(radius: 50)
                    Button{
                        
                    }label: {
                        Text("Email me single link")
                            .foregroundStyle(.white)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .frame(width: 350, height: 60)
                            .background(.color1)
                            .cornerRadius(30)
                    }
                    .padding(.bottom)
                    .padding(.bottom)
                    Divider()
                    
                    Text("You are completely safe")
                    Button{
                        
                    }label: {
                        Text("Read our Terms and Conditions")
                            .foregroundStyle(.color1)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
