import SwiftUI

@main
struct MyApp: App {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @StateObject private var scanResultManager = ScanResultManager() // Create a single instance

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(scanResultManager) // Inject as environment object
            } else {
                OnboardingView()
                    .environmentObject(scanResultManager) // Inject as environment object
            }
        }
    }
}
