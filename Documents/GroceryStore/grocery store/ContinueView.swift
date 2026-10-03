//
//  ContinueView.swift
//  grocery store
//
//  Created by Student on 11/07/26.
//

import SwiftUI
import CountryPickerView
import iPhoneKit

struct ContinueView: View {
    @State private var phoneNumber = ""
    @State private var selectedCountry = Country.defaultCountry
    var body: some View {
        NavigationStack{
            ZStack{
                Image("vegetables")
                    .padding(.bottom,550)
                
                VStack{
                    Text("Get your groceries \n with nector")
                        .font(.system(size:30))
                        .fontWeight(.bold)
                        .padding(.trailing, 90)
                    
                  
                    PhoneField(
                                   phoneNumber: $phoneNumber,
                                   selectedCountry: $selectedCountry,
                                   title: "Mobile Phone",
                                   placeholder: "Enter phone number",
                                   accentColor: .color
                               )
                    .padding()
                
                    Text("Or continue with social media")
                        .foregroundStyle(.gray)
                    
                    NavigationLink(destination: loginView()){
                        Image("Group6795")
                        Text("Continue with Google")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .frame(width:350, height:70)
                    .background(.blue)
                    .cornerRadius(20)
                    .padding()
                        
                            NavigationLink(destination: loginView()){
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
}

#Preview {
    ContinueView()
}

