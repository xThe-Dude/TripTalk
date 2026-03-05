import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            List {
                // User header
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        VStack(alignment: .leading) {
                            Text("Explorer")
                                .font(.system(.title3, design: .serif, weight: .bold))
                            Text("Fort Collins, CO")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Saved Strains
                Section("Saved Strains") {
                    if appState.savedStrainIDs.isEmpty {
                        Text("No saved strains yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.strains.filter { appState.savedStrainIDs.contains($0.id) }) { strain in
                            NavigationLink(value: strain) {
                                HStack {
                                    Image(systemName: strain.parentSubstance.icon)
                                        .foregroundStyle(strain.parentSubstance.color)
                                    Text(strain.name)
                                    Spacer()
                                    HStack(spacing: 2) {
                                        ForEach(1...4, id: \.self) { i in
                                            Circle()
                                                .fill(i <= strain.potency.level ? strain.potency.color : Color(.systemGray4))
                                                .frame(width: 6, height: 6)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // My Trip Reports
                Section("My Trip Reports") {
                    if appState.userTripReports.isEmpty {
                        Text("No trip reports written yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.userTripReports) { report in
                            let strainName = appState.strains.first(where: { $0.id == report.strainId })?.name ?? "Unknown"
                            VStack(alignment: .leading, spacing: 4) {
                                Text(strainName)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                RatingStars(rating: Double(report.rating), size: 10)
                            }
                        }
                    }
                }

                // Saved Substances (legacy)
                Section("Saved Substances") {
                    if appState.savedSubstanceIDs.isEmpty {
                        Text("No saved substances yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.substances.filter { appState.savedSubstanceIDs.contains($0.id) }) { substance in
                            NavigationLink(value: substance) {
                                Label(substance.name, systemImage: substance.imageSymbol)
                            }
                        }
                    }
                }

                Section("Saved Services") {
                    if appState.savedServiceIDs.isEmpty {
                        Text("No saved services yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.services.filter { appState.savedServiceIDs.contains($0.id) }) { service in
                            NavigationLink(value: service) {
                                Label(service.name, systemImage: service.imageSymbol)
                            }
                        }
                    }
                }

                Section("My Reviews") {
                    if appState.userReviews.isEmpty {
                        Text("No reviews written yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.userReviews) { review in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(review.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                RatingStars(rating: Double(review.rating), size: 10)
                            }
                        }
                    }
                }

                // Settings
                Section("Settings") {
                    Picker("Jurisdiction", selection: $state.selectedJurisdiction) {
                        ForEach(Jurisdiction.allCases) { j in
                            Text(j.rawValue).tag(j)
                        }
                    }
                }

                Section {
                    Link(destination: URL(string: "https://example.com/guidelines")!) {
                        Label("Community Guidelines", systemImage: "doc.text")
                    }
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    Link(destination: URL(string: "https://example.com/terms")!) {
                        Label("Terms of Service", systemImage: "doc.plaintext")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "ageVerified")
                    } label: {
                        Label("Reset Age Verification", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Profile")
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
