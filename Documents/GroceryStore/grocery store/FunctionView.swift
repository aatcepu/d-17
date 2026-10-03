//
//  FunctionView.swift
//  grocery store
//
//  Created by Student on 22/07/26.
//

import SwiftUI

struct FunctionView: View {
    var body: some View {
        VStack{
            Image("banana")
                .frame(width: 150, height: 100)
                .padding()
            Text("organic bananas")
                .fontWeight(.semibold)
                .font(.system(size:20))
            Text("7pcs, price")
                .foregroundStyle(.gray)
            Text("$1.99")
            HStack{
                
                Image("Rectangle")
                    .padding(.leading, 150)
                Image("Vector2")
             
                
            }
        }
    }
}

#Preview {
    FunctionView()
}
