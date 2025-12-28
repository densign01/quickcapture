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