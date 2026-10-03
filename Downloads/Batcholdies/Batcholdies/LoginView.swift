//
//  LoginView.swift
//  Batcholdies
//
//  Created by Teacher on 11/09/26.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        VStack(spacing: 30){
            Text("Login here")
                .foregroundStyle(.color)
                .bold()
                .font(.system(size: 30, design: .serif))
            Text("Welcome back you’ve \n been missed!")
                .bold()
                .multilineTextAlignment(.center)
                .foregroundStyle(.black)
            
            HStack(spacing: 20){
                Image(systemName: "person.fill")
                    .padding(.leading, 20)
                TextField("Email", text: $email)
                
            }
            .frame(width: 350, height: 60)
            .background(.color.opacity(0.1))
            .cornerRadius(15)
            
            HStack(spacing: 20){
                Image(systemName: "key.fill")
                    .padding(.leading, 20)
                SecureField("password", text: $password)
            }
            .frame(width: 350, height: 60)
            .background(.color.opacity(0.1))
            .cornerRadius(15)
        Text("Forgot Password ?")
                .foregroundStyle(.color)
                .bold()
                .padding(.leading, 200)
            Text("Login")
                .frame(width: 350, height : 60)
                .background(.color)
                .foregroundStyle(.white)
                .bold()
                .cornerRadius(10)
                .shadow(radius: 20)
        }
        .padding(.bottom, 300)
        
        
        
    }
}

#Preview {
    LoginView()
}
