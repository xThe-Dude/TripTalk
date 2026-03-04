import SwiftUI

struct CatalogListView: View {
    @Environment(AppState.self) private var appState
    @State private var showFilter = false

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(appState.filteredSubstances) { substance in
                        NavigationLink(value: substance) {
                            SubstanceCard(substance: substance)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Catalog")
            .searchable(text: $state.catalogSearchText, prompt: "Search substances...")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilter) {
                CatalogFilterSheet()
            }
            .navigationDestination(for: Substance.self) { substance in
                SubstanceDetailView(substance: substance)
            }
        }
    }
}
