//
//  ToDoAppApp.swift
//  ToDoApp
//
//  Created by Student on 14/12/2025.
//

import SwiftUI
import SwiftData

@main
struct ToDoAppApp: App {
    var body: some Scene {
        WindowGroup {
            Notes()
                .modelContainer(for: Listt.self)
        }
    }
}
