//
//  CustomView.swift
//  Pet
//
//  Created by Student on 27/01/2026.
//

import SwiftUI
import SwiftData

struct CustomView: View {
    var icon: String
    var title: String
    var description: String
    var body: some View {
        ContentUnavailableView{
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 96)
            Text(title)
                .font(.title)
                
        }description: {
            Text(description)
        }
        .foregroundStyle(.tertiary)
    }
}

#Preview {
    CustomView(
        icon: "cat.circle", title: "no photo", description: "Add a photo to get started"
    )
}

