//
//  LoginView.swift
//  myFirst
//
//  Created by Student on 07/07/26.
//
import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack( {
            Text("Login Page")
                .font(.largeTitle)
            Text("Weclome to Login Page")
        }
        .padding()
    }
}
#Preview {
    LoginView()
}
