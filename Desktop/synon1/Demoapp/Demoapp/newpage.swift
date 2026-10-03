//
//  newpage.swift
//  Demoapp
//
//  Created by Student on 03/09/26.
//

import SwiftUI

struct newpage: View {
    var body: some View {
        ZStack{
            Image("bg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                Text("Anime Posters")
                    .bold()
                    .italic()
                HStack{
                    Image("d")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                    
                    Image("dn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 200)
                }
                HStack{
                    Image("jjk")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 220)
                    Image("kl")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 210)
                }
                HStack{
                    Image("op")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140)
                    Image("yn")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 140, height: 205)
                }
            }
        }
    }
}

#Preview {
    newpage()
}
