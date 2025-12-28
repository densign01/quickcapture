//
//  AppDelegate.swift
//  macOS (App)
//
//  Created by Daniel Ensign on 8/14/25.
//

import SwiftUI

@main
struct BriefApp: App {
    @StateObject private var userPreferences = UserPreferences.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userPreferences)
        }
        .windowResizability(.contentSize)
        .windowStyle(DefaultWindowStyle())
    }
}
