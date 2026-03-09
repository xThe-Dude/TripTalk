import SwiftUI

struct ServicesListView: View {
    @Environment(AppState.self) private var appState
    @State private var showFilter = false

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // Custom search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.ttSecondary)
                        TextField("Search service centers...", text: $state.servicesSearchText)
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    .padding(.horizontal)
                    .padding(.bottom, 8)

                    Text("Showing services near you")
                        .font(.caption)
                        .foregroundStyle(Color.ttSecondary)
                        .padding(.horizontal)

                    Text("Service centers shown are for demonstration purposes. Verify all information independently before visiting.")
                        .font(.caption2)
                        .foregroundStyle(Color.ttTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 4)

                    if appState.filteredServices.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "No Results",
                            subtitle: "Try adjusting your filters or search terms"
                        )
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(Array(appState.filteredServices.enumerated()), id: \.element.id) { index, service in
                                NavigationLink(value: service) {
                                    ServiceCard(service: service)
                                }
                                .buttonStyle(.plain)
                                .animateIn(delay: min(Double(index) * 0.03, 0.3))
                            }
                        }
                        .padding(.horizontal)
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
            .navigationTitle("Services")
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
                ServicesFilterSheet()
            }
            .navigationDestination(for: ServiceCenter.self) { service in
                ServiceDetailView(service: service)
            }
        }
    }
}
