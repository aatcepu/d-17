//
//  CircleView.swift
//  P2Swift
//
//  Created by student on 10/01/26.
//

import SwiftUI

struct CircleView: View {
    var body: some View {
        Image("parul")
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .overlay{
                Circle().stroke(.black, lineWidth: 3)
            }
            .shadow(radius: 10)
    }
}

#Preview {
    CircleView()
}
