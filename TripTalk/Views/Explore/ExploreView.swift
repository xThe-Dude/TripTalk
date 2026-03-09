import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Custom search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.ttSecondary)
                        TextField("Search varieties, services...", text: $searchText)
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .padding(12)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 0.5))
                    .padding(.horizontal)

                    if !searchText.isEmpty {
                        // Search results
                        let filtered = appState.strains.filter {
                            $0.name.localizedCaseInsensitiveContains(searchText) ||
                            $0.parentSubstance.rawValue.localizedCaseInsensitiveContains(searchText)
                        }
                        if filtered.isEmpty {
                            EmptyStateView(icon: "magnifyingglass", title: "No Results", subtitle: "Try a different search term")
                                .padding(.top, 40)
                        } else {
                            LazyVStack(spacing: 10) {
                                ForEach(filtered) { strain in
                                    NavigationLink(value: strain) {
                                        StrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                    // Popular Varieties
                    sectionView("Popular Varieties") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(appState.strains.sorted(by: { $0.reviewCount > $1.reviewCount }).prefix(6).enumerated()), id: \.element.id) { index, strain in
                                    NavigationLink(value: strain) {
                                        MiniStrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                    .animateIn(delay: 0.1 + Double(index) * 0.03)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .animateIn(delay: 0.1)

                    // Beginner Friendly
                    sectionView("Beginner Friendly") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(appState.strains.filter { $0.difficulty == .beginner }.enumerated()), id: \.element.id) { index, strain in
                                    NavigationLink(value: strain) {
                                        MiniStrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                    .animateIn(delay: 0.1 + Double(index) * 0.03)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .animateIn(delay: 0.2)

                    // Most Visual
                    sectionView("Most Visual") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(appState.strains.filter { $0.commonEffects.contains(.visualDistortions) }.sorted(by: { $0.averageRating > $1.averageRating }).prefix(6).enumerated()), id: \.element.id) { index, strain in
                                    NavigationLink(value: strain) {
                                        MiniStrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                    .animateIn(delay: 0.1 + Double(index) * 0.03)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .animateIn(delay: 0.3)

                    // Near You
                    sectionView("Near You") {
                        VStack(spacing: 10) {
                            ForEach(appState.services.prefix(2)) { service in
                                NavigationLink(value: service) {
                                    ServiceCard(service: service)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                    }
                    .animateIn(delay: 0.4)

                    // Recent Trip Reports
                    sectionView("Recent Trip Reports") {
                        VStack(spacing: 10) {
                            ForEach(appState.tripReports.sorted(by: { $0.date > $1.date }).prefix(4)) { report in
                                if let strain = appState.strains.first(where: { $0.id == report.strainId }) {
                                    NavigationLink(value: strain) {
                                        TripReportCard(report: report, strainName: strain.name)
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                } else {
                                    TripReportCard(report: report, strainName: "")
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    } // end else (no search)
                }
                .padding(.vertical)
            }
            .refreshable {
                try? await Task.sleep(for: .seconds(0.5))
            }
            .background { GradientBackground() }
            .navigationTitle("Explore")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Strain.self) { strain in
                StrainDetailView(strain: strain)
            }
            .navigationDestination(for: Substance.self) { substance in
                SubstanceDetailView(substance: substance)
            }
            .navigationDestination(for: ServiceCenter.self) { service in
                ServiceDetailView(service: service)
            }
        }
    }

    @ViewBuilder
    private func sectionView<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(Color.ttPrimary)
                .tracking(0.5)
                .padding(.horizontal)
            content()
        }
    }
}

struct MiniStrainCard: View {
    let strain: Strain

    var body: some View {
        VStack(spacing: 0) {
            // Image-forward top area
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [strain.parentSubstance.color, strain.parentSubstance.color.opacity(0.4), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 100)

                // Subtle glow behind icon
                Circle()
                    .fill(strain.parentSubstance.color.opacity(0.25))
                    .frame(width: 50, height: 50)
                    .blur(radius: 15)
                    .padding(.bottom, 28)

                Image(systemName: strain.parentSubstance.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(.white.opacity(0.9))
                    .padding(.bottom, 28)

                // Name overlaid
                Text(strain.name)
                    .font(.system(.caption, design: .serif, weight: .bold))
                    .foregroundStyle(Color.ttPrimary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 6)
                    .padding(.bottom, 4)
            }

            // Bottom info
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(1...4, id: \.self) { i in
                        Circle()
                            .fill(i <= strain.potency.level ? strain.potency.color : Color.white.opacity(0.15))
                            .frame(width: 5, height: 5)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Potency: \(strain.potency.rawValue), level \(strain.potency.level) of 4")

                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.ttAccent)
                    Text(String(format: "%.1f", strain.averageRating))
                        .font(.caption2)
                        .foregroundStyle(Color.ttSecondary)
                }
            }
            .padding(.vertical, 6)
        }
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.07))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(strain.name), rated \(String(format: "%.1f", strain.averageRating)) stars")
    }
}
