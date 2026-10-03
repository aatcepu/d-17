//
//  ContinueView.swift
//  grocery store
//
//  Created by Student on 11/07/26.
//

import SwiftUI
import CountryPickerView

struct ContinueView: View {
    var body: some View {
        ZStack{
                        Image("vegetables")
                .padding(.bottom,550)
            
            VStack{
                Text("Get your groceries \n with nector")
                    .font(.system(size:30))
                    .fontWeight(.bold)

                Text("Or continue with social media")
                    .foregroundStyle(.gray)
                
                HStack{
                    Image("Group6795")
                    Text("Continue with Google")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        
                    
                }
                .frame(width:350, height:70)
                .background(.blue)
                .cornerRadius(20)
                
                HStack{
                    Image("Vector")
                    Text("Continue with Facebook")
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        
                    
                }
                .frame(width:350, height:70)
                .background(.custom)
                .cornerRadius(20)
                
                
                
            }
            .padding(.top,350)
        }
    }
}

#Preview {
    ContinueView()
}

