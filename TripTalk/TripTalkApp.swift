import SwiftUI

@main
struct TripTalkApp: App {
    @AppStorage("ageVerified") private var ageVerified = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var appState = AppState()
    @State private var showLaunch = true
    @State private var showOnboarding: Bool?

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        appearance.backgroundColor = UIColor(white: 0, alpha: 0.45)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

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
                Task {
                    try? await Task.sleep(for: .seconds(1.8))
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunch = false
                    }
                }
            }
        }
    }
}
