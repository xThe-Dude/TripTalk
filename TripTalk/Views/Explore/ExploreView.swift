import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var selectedSegment: ExploreSegment = .all

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Segmented control
                    Picker("Category", selection: $selectedSegment) {
                        ForEach(ExploreSegment.allCases) { seg in
                            Text(seg.rawValue).tag(seg)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Trending
                    if selectedSegment == .all || selectedSegment == .substances {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Trending")
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(appState.substances.prefix(4)) { substance in
                                        NavigationLink(value: substance) {
                                            TrendingCard(substance: substance)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Near You
                    if selectedSegment == .all || selectedSegment == .services {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Near You")
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .padding(.horizontal)

                            ForEach(appState.services.prefix(2)) { service in
                                NavigationLink(value: service) {
                                    ServiceCard(service: service)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }

                    // New Reviews
                    if selectedSegment == .all || selectedSegment == .articles {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Recent Reviews")
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .padding(.horizontal)

                            ForEach(appState.reviews.prefix(3)) { review in
                                ReviewCard(review: review)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search substances, services...")
            .navigationDestination(for: Substance.self) { substance in
                SubstanceDetailView(substance: substance)
            }
            .navigationDestination(for: ServiceCenter.self) { service in
                ServiceDetailView(service: service)
            }
        }
    }
}

struct TrendingCard: View {
    let substance: Substance

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: substance.imageSymbol)
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(substance.name)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", substance.averageRating))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 110)
        .padding(10)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
