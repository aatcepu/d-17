//
//  ContentView.swift
//  Demoapp
//
//  Created by Student on 02/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            
            
            ZStack{ 
                Image("pic")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea() //upper and end areas where the battery life should be displayed will be ignored
                VStack{
                    Text("Welcome")
                        .bold()
                        .font(Font.largeTitle.bold())
                    //                    .background(.white)
                        .italic()
                        .background(.white)
                        .cornerRadius(20)
                    //                    .background(.color)
                    Text("Let's Discover Aesthetics")
                        .font(.system(size: 25, design: .serif))
                        .italic()
                        .foregroundStyle(.white)
                    NavigationLink(destination: newpage()){
                        Text("Click me")
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: 100, height: 30)
                            .background(.blue)
                            .cornerRadius(20)
                    }
                }
                
            }
            //        VStack{
            //            Text("Synon Jena")
            //
            //                .padding(.bottom, 50)
            //            //top bottom leading trailing
            //            Text("university")
            //            Image("pic")
            //                .resizable()
            //                .scaledToFit()
            //                .frame(width: 300, height: 300)
            //        }
            //        .bold()
            //        .underline() //for applying multiple modifiers to entire VStack
            //        .bold()
            //        .italic()
            //        .foregroundStyle(.blue)
            //        //these are called text modifiers
            //        .font(.system(size: 35, design: .serif))
        }
    }
}

#Preview {
    ContentView()
}
