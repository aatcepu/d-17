//
//  GrossApp.swift
//  Gross
//
//  Created by Student on 16/12/2025.
//
//comment trial

import SwiftUI
import SwiftData
import Foundation

@main
struct GrossApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Item.self)
        }
    }
}
