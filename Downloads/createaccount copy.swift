//
//  createaccount.swift
//  Talkative
//
//  Created by Student on 30/06/2026.
//

import SwiftUI

struct createaccount: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false
    var body: some View {
        NavigationStack{
            VStack(spacing: 20){
                
                Text("Login")
                    .font(.system(size: 35))
                    .fontWeight(.semibold)
                
                HStack{
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.gray)
                        .padding()
                    
                    TextField("Email or phone", text: $email)
                        .padding()
                }.frame(width: 350, height: 60)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                
                HStack{
                    Image(systemName: "key.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.gray)
                        .padding()
                    if showPassword{
                        TextField("Show Password", text: $password)
                            .padding()
                    }else{
                        SecureField("Password", text: $password)
                            .padding()
                    }
                    
                    Button{
                        showPassword.toggle()
                    }label: {
                        Image(systemName: showPassword ? "eye.slash.circle" : "eye.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                            .padding()
                    }
                }.frame(width: 350, height: 60)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                
                Button{
                    
                }label: {
                    Text("Login")
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .frame(width: 350, height: 60)
                        .background(.color1)
                        .cornerRadius(20)
                }
                
                Text("This Login credentials are secure with our platform and encrypted and never shared ")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundStyle(.gray)
            }.navigationTitle("Welcome Hi..!")
        }
    }
}

#Preview {
    createaccount()
}
