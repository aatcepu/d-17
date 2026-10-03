//
//  register.swift
//  healthlifestyle
//
//  Created by Student on 15/09/26.
//

import SwiftUI

struct register: View {
    @State private var email: String = ""
    @State private var password = ""
    @State private var cnfpass = ""
    var body: some View {
        NavigationStack{
            VStack(spacing: 26){
                Text("Create Account")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.color)
                Text("Create an account so you can explore all the\n existing jobs")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 15, weight: .semibold))
                
                HStack{
                    Image(systemName: "person.fill")
                        .padding(.leading, 20)
                    TextField("Email", text: $email)
                }
                .frame(width: 350, height: 60)
                .background(.color.opacity(0.1))
                .cornerRadius(15)
                
                HStack{
                    Image(systemName: "key.shield.fill")
                        .padding(.leading, 20)
                    SecureField("Password", text: $password)
                }
                .frame(width: 350, height: 60)
                .background(.color.opacity(0.1))
                .cornerRadius(15)
                
                HStack{
                    Image(systemName: "key.shield.fill")
                        .padding(.leading, 20)
                    SecureField("Confirm Password", text: $cnfpass)
                }
                .frame(width: 350, height: 60)
                .background(.color.opacity(0.1))
                .cornerRadius(15)
                
                Text("Sign up")
                    .frame(width: 350, height: 50)
                    .background(.color)
                    .cornerRadius(15)
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
                    .font(.system(size: 17, weight: .semibold))
                
                NavigationLink(destination: loginpage()){
                    Text("Already have an account")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.black)
                }
                
                Text("Or continue with")
                    .foregroundStyle(.color)
                    .font(.system(size: 15, weight: .semibold))
                
                HStack(spacing: 20){
                    Image("google")
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                    Image("facebook")
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                    Image("apple")
                        .padding()
                        .background(.gray.opacity(0.2))
                        .cornerRadius(15)
                }
            }
        }
    }
}

#Preview {
    register()
}
