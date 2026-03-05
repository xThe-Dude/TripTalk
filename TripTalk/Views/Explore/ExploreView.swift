import SwiftUI

struct ExploreView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Popular Strains
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Popular Strains")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(appState.strains.sorted(by: { $0.reviewCount > $1.reviewCount }).prefix(6)) { strain in
                                    NavigationLink(value: strain) {
                                        MiniStrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Beginner Friendly
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Beginner Friendly")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(appState.strains.filter { $0.difficulty == .beginner }) { strain in
                                    NavigationLink(value: strain) {
                                        MiniStrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Most Visual
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Most Visual")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(appState.strains.filter { $0.commonEffects.contains(.visualDistortions) }.sorted(by: { $0.averageRating > $1.averageRating }).prefix(6)) { strain in
                                    NavigationLink(value: strain) {
                                        MiniStrainCard(strain: strain)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    // Near You (services)
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

                    // Recent Trip Reports
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Recent Trip Reports")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .padding(.horizontal)

                        ForEach(appState.tripReports.sorted(by: { $0.date > $1.date }).prefix(4)) { report in
                            let strainName = appState.strains.first(where: { $0.id == report.strainId })?.name ?? ""
                            TripReportCard(report: report, strainName: strainName)
                                .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Explore")
            .searchable(text: $searchText, prompt: "Search strains, services...")
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
}

struct MiniStrainCard: View {
    let strain: Strain

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: strain.parentSubstance.icon)
                .font(.title)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    LinearGradient(colors: [strain.parentSubstance.color, .blue.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(strain.name)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            // Potency dots
            HStack(spacing: 2) {
                ForEach(1...4, id: \.self) { i in
                    Circle()
                        .fill(i <= strain.potency.level ? strain.potency.color : Color(.systemGray4))
                        .frame(width: 5, height: 5)
                }
            }

            HStack(spacing: 2) {
                Image(systemName: "star.fill")
                    .font(.system(size: 9))
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", strain.averageRating))
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
