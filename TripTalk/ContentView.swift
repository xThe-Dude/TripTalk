import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    init() {
        ContentView.configureTabBarAppearance()
    }

    /// Differentiates the static bottom navigation from scrollable content:
    /// a darker elevated surface, a champagne-gold hairline top border, and a
    /// subtle upward shadow so content reads as scrolling *under* the bar.
    static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        // Darker than the page (#090D11) so the bar sits on its own plane.
        appearance.backgroundColor = UIColor(red: 0.035, green: 0.051, blue: 0.067, alpha: 1.0)
        // Champagne-gold hairline top border.
        appearance.shadowColor = UIColor(red: 0.851, green: 0.784, blue: 0.627, alpha: 0.28)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        @Bindable var state = appState
        TabView(selection: $state.selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "safari")
                }
                .tag(1)
            CatalogListView()
                .tabItem {
                    Label("Catalog", systemImage: "book.fill")
                }
                .tag(2)
            JournalListView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
                }
                .tag(3)
            ServicesListView()
                .tabItem {
                    Label("Services", systemImage: "building.2.fill")
                }
                .tag(4)
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(5)
        }
        .animation(.easeInOut(duration: 0.2), value: appState.selectedTab)
        .tint(Color.ttAccent)
        .overlay(alignment: .bottomTrailing) {
            CrisisButton()
                .padding(.trailing, 16)
                .padding(.bottom, 90)
        }
    }
}
