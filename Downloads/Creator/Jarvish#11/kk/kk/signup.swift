//
//  login.swift
//  login page nishant
//
//  Created by General on 24/06/26.
//

import SwiftUI

struct login: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationStack{
            ScrollView{
                
                VStack(spacing:20){
                    
                    Text("User Login")
                        .font(Font.largeTitle)
                        .fontWeight(.semibold)
                        .frame(height: 70)
                    
                    Spacer()
                    Spacer(minLength: 100)
                    
                    Text("Please login to continue")
                        .foregroundStyle(.black)
                    
                    HStack{
                        Image(systemName: "person")
                            .foregroundStyle(.gray)
                            .padding()
                            .foregroundStyle(Color(.gray))
                        
                        Text("|")
                            .foregroundStyle(.gray)
                        
                        TextField("Enter email or phone number",text:$email)
                            .padding()
                    }.frame(width:350 , height:55)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    
                    HStack{
                        Image(systemName: "lock")
                            .foregroundStyle(.gray)
                            .padding()
                            .foregroundStyle(Color(.gray))
                        
                        Text("|")
                            .foregroundStyle(.gray)
                        
                        SecureField("Password",text:$password)
                            .padding()
                    }.frame(width:350 , height:55)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)
                    Spacer()
                    
                    
                    Button {
                        
                    }label: {
                        
                        Text("Login")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color(.black))
                            .font(.system(size:18))
                            .cornerRadius(15)
                    }
                    
                    Text("or continue with")
                        .font(Font.system(size:14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .padding()
                    
                    
                }
                
                HStack{
                    
                    Button{
                    }label:{
                        Image(.apple)
                            .resizable()
                            .frame(width:50, height:50)
                            .padding()
                    }
                    Button{
                    }label:{
                        Image(.facebook)
                            .resizable()
                            .frame(width:60, height:60)
                            .padding()
                        
                    }
                    Button{
                    }label:{
                        Image(.google)
                            .resizable()
                            .frame(width:45, height:45)
                            .padding()
                    }
                }
                
                HStack{
                    Text("Don't have an account?")
                        .font(Font.system(size:14))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.black))
                        .padding()
                    Button("Sign up"){
                        
                    }
                }
            }
        }
    }
}
#Preview {
    login()
}
