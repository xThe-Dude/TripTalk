import SwiftUI

@main
struct TripTalkApp: App {
    @AppStorage("ageVerified") private var ageVerified = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var appState = AppState()
    @State private var showLaunch = true
    @State private var showOnboarding: Bool?

    var body: some Scene {
        WindowGroup {
            ZStack {
                if ageVerified {
                    ContentView()
                        .environment(appState)
                } else if showOnboarding == false {
                    AgeGateView()
                } else if showOnboarding == true {
                    OnboardingView(onComplete: {
                        hasSeenOnboarding = true
                        withAnimation {
                            showOnboarding = false
                        }
                    })
                }

                if showLaunch {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                showOnboarding = !hasSeenOnboarding
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunch = false
                    }
                }
            }
        }
    }
}
