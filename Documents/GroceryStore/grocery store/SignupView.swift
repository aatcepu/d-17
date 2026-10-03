//
//  SignupView.swift
//  grocery store
//
//  Created by Student on 22/07/26.
//

import SwiftUI

struct SignupView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        NavigationStack{
        VStack(spacing: 10){
            Image("Group2")
                .frame(width: 60, height: 60)
                .offset(y: -60)
            
            Text("Sign Up")
                .font(.system(size:30))
                .fontWeight(.semibold)
                .padding()
            
            HStack{
                TextField("Enter your Username", text :$username)
                    .padding()
            }
            .frame(width:350)
            .background(.gray.opacity(0.3))
            .cornerRadius(20)
            
            HStack{
                TextField("Enter your Email", text: $email)
                    .padding()
            }
            .frame(width:350)
            .background(.gray.opacity(0.3))
            .cornerRadius(20)
            
            HStack{
                SecureField("Enter your password", text :$password)
                    .padding()
                Image(systemName: "eye.slash.fill")
                    .padding()
                
            }
            .frame(width:350)
            .background(.gray.opacity(0.3))
            .cornerRadius(20)
            
            Text("Forgot password?")
                .padding(.leading, 180)
            
            
            NavigationLink(destination: HomeScreenView()){
                Text("Sign Up")
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.white)
                    .frame(width: 340, height: 30)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(20)
            }
            
            HStack{
                Text("Already have an account?")
                
                NavigationLink(destination: loginView()){
                    Text("Login.")
                        .foregroundStyle(Color.green)
                  }
               }
            }
        }
    }
}

#Preview {
    SignupView()
}
