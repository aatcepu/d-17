//
//  ContentView.swift
//  2501011010024
//
//  Created by Student on 13/02/2026.
//

import SwiftUI

struct ContentView: View {
    @State private var enrollment: String = " "
    @State private var password: String = " "
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack{
                    Image(._9AD40997840B448CA496103C1E7D193645005C)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 300)
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Text("Student management system")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .foregroundStyle(.gray)
                    
                    TextField("Enrollment number",text: $enrollment)
                        .frame(width: 330, height: 60)
                        .padding(.horizontal)
                        .background(Color(hue:1.0, saturation:0.0,brightness:0.932))
                        .cornerRadius(20)
                    
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    
                    Button {
                    } label : {
                        Text("Log in")
                            .frame(width: 350, height: 60)
                            .font(.system(size:20))
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                            .background(Color.blue)
                            .cornerRadius(20)
                        
                        Spacer()
                        Spacer()
                        Spacer()
                        HStack{
                            Text("Log in")
                                .foregroundStyle(.gray)
                            
                            Image(.E_0_FDD_576_D_398_40_E_4_B_9_C_9_594_DD_2_E_149_FD)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 60)
                            
                        }
                         .frame(width: 280, height: 60)
                        .background(Color(hue:1.0,saturation:0.0,brightness: 0.932))
                        .cornerRadius(20)
                    }
                }
            }
        }
    }
    
    #Preview {
        ContentView()
    }
