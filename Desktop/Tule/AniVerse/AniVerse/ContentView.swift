//
//  ContentView.swift
//  AniVerse
//
//  Created by Student on 08/09/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            //
                Image("background")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            HStack{
                Image("One Piece")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 300)
                Image("UZUMAKI")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 300)
                    .padding()

            }
        }
    }
}

#Preview {
    ContentView()
}
