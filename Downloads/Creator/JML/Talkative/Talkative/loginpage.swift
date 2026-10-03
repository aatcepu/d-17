//
//  loginpage.swift
//  Talkative
//
//  Created by Student on 30/06/2026.
//

import SwiftUI

struct loginpage: View {
    @State private var moveToNext: Bool = false
    var body: some View {
        NavigationStack{
            
            ZStack{
                Color.gray.opacity(0.10).ignoresSafeArea()
                VStack(spacing: 20){
                    Image(.image1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                    
                    Button{
                        moveToNext = true
                    }label: {
                        Text("Get Started")
                            .foregroundStyle(.white)
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .frame(width: 300, height: 55 )
                            .background(.color1)
                            .cornerRadius(30)
                        
                    }
                    
                    Button{

                    }label: {
                        Text("Login")
                            .foregroundStyle(.color1)
                            .font(.system(size: 25))
                            .fontWeight(.semibold)
                            .frame(width: 300, height: 55)
                            .background(Color(.white))
                            .cornerRadius(30)
                        }
                    
                    HStack{
                        Text("No Account?")
                        Button{
                            moveToNext = true
                        }label: {
                            Text("Sign-In")
                                .foregroundStyle(.color1)
                        }
                        .navigationDestination(isPresented: $moveToNext){
                            ContentView()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    loginpage()
}
