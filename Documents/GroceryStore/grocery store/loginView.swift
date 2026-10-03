//
//  loginView.swift
//  grocery store
//
//  Created by Student on 13/07/26.
//

import SwiftUI

struct loginView: View {
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        NavigationStack{
            VStack(spacing: 10){
                Image("Group2")
                    .frame(width: 60, height: 60)
                    .offset(y: -60)
                
                Text("Log in")
                    .font(.system(size:30))
                    .fontWeight(.semibold)
                    .padding()
                HStack{
                    Image(systemName: "person.fill")
                        .padding()
                    TextField("Enter your email", text :$email)
                        .padding()
                }
                .frame(width:350)
                .background(.gray.opacity(0.4))
                .cornerRadius(20)
                
                HStack{
                    Image(systemName: "key.shield.fill")
                        .padding()
                    TextField("Enter your password", text :$password)
                        .padding()
                    Image(systemName: "eye.slash.fill")
                        .padding()
                    
                }
                .frame(width:350)
                .background(.gray.opacity(0.4))
                .cornerRadius(20)
                
                Text("Forgot password?")
                    .padding(.leading, 180)
                
                NavigationLink(destination: HomeScreenView()){
                    Text("Log in")
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)
                        .frame(width: 340, height: 30)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(20)
                }
                
                HStack{
                    Text("Don't have an account?")
                    
                    NavigationLink(destination: SignupView()){
                        Text("Sign up.")
                            .foregroundStyle(Color.green)
                     }
                  }
               }
            }
        }
    }
#Preview {
    loginView()
}
