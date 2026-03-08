import SwiftUI

struct CatalogListView: View {
    @Environment(AppState.self) private var appState
    @State private var showFilter = false

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Substance type horizontal scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            SubstanceTypePill(type: nil, isSelected: appState.catalogSubstanceTypeFilter == nil) {
                                appState.catalogSubstanceTypeFilter = nil
                            }
                            ForEach(SubstanceType.allCases) { type in
                                SubstanceTypePill(type: type, isSelected: appState.catalogSubstanceTypeFilter == type) {
                                    appState.catalogSubstanceTypeFilter = (appState.catalogSubstanceTypeFilter == type) ? nil : type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Strain grid
                    LazyVStack(spacing: 10) {
                        ForEach(appState.filteredStrains) { strain in
                            NavigationLink(value: strain) {
                                StrainCard(strain: strain)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background { GradientBackground() }
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .navigationTitle("Catalog")
            .searchable(text: $state.catalogSearchText, prompt: "Search strains...")
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
            .navigationDestination(for: Strain.self) { strain in
                StrainDetailView(strain: strain)
            }
            .navigationDestination(for: Substance.self) { substance in
                SubstanceDetailView(substance: substance)
            }
        }
    }
}

struct SubstanceTypePill: View {
    let type: SubstanceType?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let type {
                    Image(systemName: type.icon)
                        .font(.caption2)
                }
                Text(type?.rawValue ?? "All")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? (type?.color ?? Color.accentColor) : Color(.systemGray5))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}
