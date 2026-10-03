//
//  swiftorg.swift
//  studyapp
//
//  Created by Student on 27/09/26.
//

import SwiftUI

struct swiftorg: View {
    var body: some View
    {
        
        NavigationStack{
            
            VStack{
                List{
                    Section("Unit 1"){
                        Text("1.1 Introduction to Swift programming")
                        Text("1.2 Constant Variable, And Data types ")
                        Text("1.3 Control flow and functions")
                        Text("1.4 Error handling")
                        
                    }
                    Section("Unit 2- Basic of swift UI"){
                        Text("2.1 Introduction to Swift UI")
                        Text("2.2 Building a user interface")
                        Text("What is MVVM Architrcture")
                        
                    }
                    Section("Unit 3- Projects"){
                        Text("3.1 Introduction to Xcode")
                        Text("3.2 start project")
                        Text("3.3 make a commerce app")
                    }
                }
            }
        }
                    
        
        
            }
}

#Preview {
    swiftorg()
}
