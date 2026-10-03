//
//  HomeScreenView.swift
//  grocery store
//
//  Created by Student on 22/07/26.
//

import SwiftUI

struct HomeScreenView: View {
    @State private var store = ""
    var body: some View {
        VStack{
            VStack{
                Image("Group2")
                    .resizable()
                    .scaledToFit()
                    .frame(width:50, height: 50)
            }
            HStack{
                Image(systemName: "magnifyingglass")
                    .padding()
                TextField("Search Store", text: $store)
                
            }
            .frame(width: 370, height: 50)
            .background(.gray)
            .cornerRadius(15)
            .opacity(0.3)
            .padding(.bottom,540)
            
            Image("banner")
                .offset(y: -530)
            
            HStack{
                Text("Exclusive Offers")
                    .font(.system(size:20))
                    .offset(x: -80, y: -510)
                
                Text("See all")
                    .foregroundStyle(.green)
                    .font(.system(size:20))
                    .offset(x: 80, y: -510)
                
            }
        }
        .padding(.top, 30)
    }
}
#Preview {
    HomeScreenView()
}
