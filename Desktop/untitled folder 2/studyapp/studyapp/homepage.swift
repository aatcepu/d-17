//
//  homepage.swift
//  studyapp
//
//  Created by Student on 26/09/26.
//

import SwiftUI

struct homepage: View {
    @State private var GotoSwift:Bool = false
    @State private var Gotojava:Bool = false
    @State private var Gotopy:Bool = false
    
    var body: some View {
        Text("Subjects")
        NavigationStack
        {
            ScrollView
            {
                VStack(){
                    
                    Button{
                        GotoSwift = true
                        
                        
                    }label: {
                        VStack{
                            Image(.swift)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80 , height: 80)
                            Text("swift programing")
                                .foregroundStyle(.black)
                                .fontWeight(.bold)
                        }.frame(width: 350 , height: 150)
                            .background(.orange .opacity(0.20))
                            .cornerRadius(20)
                    }
                    
                    Button{
                        Gotojava = true
                        
                    }label: {
                        VStack{
                            Image(.java)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80 , height: 80)
                            Text("java programing")
                                .foregroundStyle(.black)
                                .fontWeight(.bold)
                        }.frame(width: 350 , height: 150)
                            .background(.orange .opacity(0.20))
                            .cornerRadius(20)
                    }
                    
                    Button{
                        Gotopy = true
                    }label: {
                        VStack{
                            Image(.python)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80 , height: 80)
                            Text("python programing")
                                .foregroundStyle(.black)
                                .fontWeight(.bold)
                        }.frame(width: 350 , height: 150)
                            .background(.orange .opacity(0.20))
                            .cornerRadius(20)
                    }
                    
                    
                    
                    
                    
                }
                .navigationDestination(isPresented: $GotoSwift){
                    swiftorg()
                }
                .navigationDestination(isPresented: $Gotojava   ){
                    javaprg()
                }
                .navigationDestination(isPresented: $Gotopy  ){
                    python()
                }
            }
        }
    }
}

#Preview {
    homepage()
}
