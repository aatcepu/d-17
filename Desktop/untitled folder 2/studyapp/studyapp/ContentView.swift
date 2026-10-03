    //
//  ContentView.swift
//  studyapp
//
//  Created by Student on 26/09/26.
//

import SwiftUI

struct ContentView: View {
    @State private var email:String = ""
    @State private var password:String = ""
    @State private var GotoHome:Bool = false
    @State private var email1 = "Sahujivk07@gmail.com"
    @State private var password1 = "sahuji77"
    var body: some View {
        NavigationStack{
            ZStack
            {
                Color.gray.opacity(0.08)
                    .ignoresSafeArea()
                Image(.html)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x:-100 , y: 300)
                    .opacity(0.08)
                Image(.java)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 200)
                    .offset(x:100 , y: 200)
                    .opacity(0.08)
                Image(.python)
                    .resizable()
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x:-100 , y: 100)
                    .opacity(0.08)
                Image(.swift)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .offset(x:-100 , y: -300)
                    .opacity(0.08)
                Image(.cpp)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height:500)
                    .offset(x:100 , y: -50)
                    .opacity(0.08)
                VStack(spacing:15){
                    Text("Programmer's Corner")
                        .font(.system(size: 25))
                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .shadow(radius: 20)
                        
                    HStack{
                        TextField("Email or phone number", text: $email)
                                .padding()
                        Image(systemName: "person.fill")

                                    .foregroundStyle(.gray)
                                    .padding()
                                  
                    }.frame(width: 350 , height: 60)
                        .background(.white)
                        .cornerRadius(15)
                        .shadow(radius: 15)
                    HStack{
                        SecureField("Password", text: $password)
                                .padding()
                        Image(systemName: "key.fill")
                                    .foregroundStyle(.gray)
                                    .padding()
                                  
                    }.frame(width: 350 , height: 60)
                        .background(.white)
                        .cornerRadius(15)
                        .shadow(radius: 15)
                    
                    
                    Button{
                        if email == email1 && password == password1{
                            GotoHome = true
                            
                        } else {
                            print("Useername or password is incorrect")
                        }
                        
                        email = ""
                        password = ""
                        
                    }label: {
                        Text("Login")
                            .font(.system(size: 20))
                            .frame(width: 350, height: 60)
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                            .background(.black)
                            .cornerRadius(15)
                    }
                    
                    HStack{
                        Text("Don't have account?")
                            .fontWeight(.semibold)
                            .foregroundStyle(.gray)
                        
                        Button{
                            
                        }label: {
                            Text("Signup")
                                .foregroundStyle(.black)
                                .fontWeight(.bold)
                        }
                    }
                }
                
            }
            .navigationDestination(isPresented:$GotoHome)
            {
                homepage()
            }
        }
    }
}

#Preview {
    ContentView()
}
