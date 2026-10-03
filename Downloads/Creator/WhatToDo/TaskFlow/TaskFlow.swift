//
//  TaskFlow.swift
//  TaskFlow
//
//  Created by Student on 03/12/2025.
//

import SwiftUI
import SwiftData

@main
struct TaskFlow: App {
    var body: some Scene {
        WindowGroup {
            NotesApp()
                .modelContainer(for: Listt.self)   //Container Created
        }
    }
}
