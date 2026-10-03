//
//  SwiftUIView.swift
//  document 2
//
//  Created by Student on 01/09/26.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        ZStack {
            Image("Image")
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
                .frame(width:1000,height:900)
            
            VStack(spacing:29){
                Text("Welcome to our page")
                    .foregroundColor(.white)
                    .font(.system(size: 30,weight:.bold))
                    .padding(.bottom, 39)
                             
                Text("lets order fresh food in less time")
                    .foregroundColor(.green)
                    .font(.system(size:20,weight:.bold))
                
                Text("START")
                    .foregroundColor(.white)
                    .font(.system(size:30,weight:.bold))
                    .padding(.vertical,30)
                    .padding(.horizontal,75)
                    .background(Color.green)
                    .cornerRadius(20)
               
                
                
                
                
                
                
                
                
                
            }.padding(.top,300)
        }
    }
}
#Preview {
    SwiftUIView()
}
