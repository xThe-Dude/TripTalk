import SwiftUI

struct ServicesListView: View {
    @Environment(AppState.self) private var appState
    @State private var showFilter = false

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Fort Collins • 50mi")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)

                    LazyVStack(spacing: 10) {
                        ForEach(appState.filteredServices) { service in
                            NavigationLink(value: service) {
                                ServiceCard(service: service)
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
            .navigationTitle("Services")
            .searchable(text: $state.servicesSearchText, prompt: "Search services...")
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
                ServicesFilterSheet()
            }
            .navigationDestination(for: ServiceCenter.self) { service in
                ServiceDetailView(service: service)
            }
        }
    }
}
