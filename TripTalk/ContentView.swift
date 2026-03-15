import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

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
            ReviewsFeedView()
                .tabItem {
                    Label("Reviews", systemImage: "text.bubble")
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
    }
}
