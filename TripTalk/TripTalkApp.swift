import SwiftUI

@main
struct TripTalkApp: App {
    @AppStorage("ageVerified") private var ageVerified = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("guest_mode") private var guestMode = false
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
                if !ageVerified {
                    AgeGateView()
                } else if showOnboarding == true {
                    OnboardingView(onComplete: {
                        hasSeenOnboarding = true
                        withAnimation {
                            showOnboarding = false
                        }
                    })
                } else if !appState.auth.isAuthenticated && !guestMode {
                    SignInView(
                        onContinueAsGuest: {
                            guestMode = true
                        },
                        onSignedIn: {
                            // Auth state already set — view will update
                        }
                    )
                    .environment(appState)
                } else {
                    ContentView()
                        .environment(appState)
                }

                if showLaunch {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.dark)
            .onOpenURL { url in
                guard let destination = DeepLinkHandler.parse(url) else { return }

                // Auth callbacks must be handled regardless of auth state
                if case .authCallback(let accessToken, let refreshToken) = destination {
                    Task {
                        await appState.auth.handleAuthCallback(accessToken: accessToken, refreshToken: refreshToken)
                        guestMode = false
                    }
                    return
                }

                guard ageVerified, appState.auth.isAuthenticated || guestMode else { return }
                switch destination {
                case .strain(let id):
                    appState.selectedTab = 2 // Catalog
                    appState.deepLinkStrainId = id
                case .service(let id):
                    appState.selectedTab = 4 // Services
                    appState.deepLinkServiceId = id
                case .crisis:
                    appState.showCrisisSheet = true
                case .home:
                    appState.selectedTab = 0
                case .substance, .authCallback:
                    break
                }
            }
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
