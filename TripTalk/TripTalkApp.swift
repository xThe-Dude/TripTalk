import SwiftUI

@main
struct TripTalkApp: App {
    @AppStorage("ageVerified") private var ageVerified = false
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if ageVerified {
                ContentView()
                    .environment(appState)
                    .preferredColorScheme(.dark)
            } else {
                AgeGateView()
                    .preferredColorScheme(.dark)
            }
        }
    }
}
