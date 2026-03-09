import SwiftUI

struct CatalogListView: View {
    @Environment(AppState.self) private var appState
    @State private var showFilter = false
    @State private var searchText = ""

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Custom search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.ttSecondary)
                        TextField("Search varieties...", text: $state.catalogSearchText)
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    .padding(.horizontal)

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

                    if appState.filteredStrains.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            imageName: "empty_search",
                            title: "No Results",
                            subtitle: "Try adjusting your filters or search terms"
                        )
                        .padding(.top, 40)
                    } else {
                        let grouped = Dictionary(grouping: appState.filteredStrains, by: \.parentSubstance)
                        let orderedTypes = SubstanceType.allCases.filter { grouped[$0] != nil }
                        LazyVStack(spacing: 10) {
                            ForEach(orderedTypes) { type in
                                // Category header banner
                                ZStack(alignment: .bottomLeading) {
                                    Image(type.categoryImageName)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 80)
                                        .clipped()
                                    LinearGradient(
                                        colors: [.clear, .black.opacity(0.6)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    HStack(spacing: 6) {
                                        Image(systemName: type.icon)
                                            .font(.caption)
                                            .foregroundStyle(type.color)
                                        Text(type.rawValue)
                                            .font(.system(.subheadline, design: .serif, weight: .bold))
                                            .foregroundStyle(.white)
                                    }
                                    .padding(.horizontal, 14)
                                    .padding(.bottom, 10)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .padding(.horizontal)

                                ForEach(Array((grouped[type] ?? []).enumerated()), id: \.element.id) { index, strain in
                                    NavigationLink(value: strain) {
                                        StrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                    .animateIn(delay: min(Double(index) * 0.03, 0.3))
                                }
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                try? await Task.sleep(for: .seconds(0.8))
            }
            .background { GradientBackground() }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationTitle("Catalog")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .foregroundStyle(Color.ttPrimary)
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
            .background(isSelected ? (type?.color ?? Color.ttGlow) : Color.white.opacity(0.08))
            .foregroundStyle(isSelected ? .white : Color.ttSecondary)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.white.opacity(isSelected ? 0 : 0.1), lineWidth: 0.5))
        }
    }
}
