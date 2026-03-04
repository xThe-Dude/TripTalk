import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ExploreView()
                .tabItem {
                    Label("Explore", systemImage: "safari")
                }
            CatalogListView()
                .tabItem {
                    Label("Catalog", systemImage: "book.fill")
                }
            ServicesListView()
                .tabItem {
                    Label("Services", systemImage: "building.2.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .tint(.accentColor)
    }
}
