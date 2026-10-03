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
        ScrollView{
            
       
        VStack(spacing: 20){
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
           
            
            Image("banner")
               
            
            HStack{
                Text("Exclusive Offers")
                    .font(.system(size:20))
                   Spacer()
                
                Text("See all")
                    .foregroundStyle(.green)
                    .font(.system(size:20))
                 
                
            }
            .frame(width: 350)
            .padding()
            
            HStack{
                FunctionView()
                FunctionView()
            }
            HStack{
                FunctionView()
                FunctionView()
            }
        }
   
    }
    }
}
#Preview {
    HomeScreenView()
}
