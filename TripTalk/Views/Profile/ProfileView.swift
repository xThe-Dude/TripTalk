import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Premium avatar area with glow
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.teal.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 160, height: 160)

                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                    }

                    VStack(spacing: 4) {
                        Text("Explorer")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                        Text("Fort Collins, CO")
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                    }
                    .animateIn(delay: 0.1)

                    // Saved Strains
                    profileSection("Saved Varieties") {
                        if appState.savedStrainIDs.isEmpty {
                            EmptyStateView(icon: "leaf", title: "No Saved Varieties", subtitle: "Browse the catalog and bookmark varieties you're interested in")
                        } else {
                            ForEach(appState.strains.filter { appState.savedStrainIDs.contains($0.id) }) { strain in
                                NavigationLink(value: strain) {
                                    HStack {
                                        Image(systemName: strain.parentSubstance.icon)
                                            .foregroundStyle(strain.parentSubstance.color)
                                        Text(strain.name)
                                            .foregroundStyle(Color.ttPrimary)
                                        Spacer()
                                        HStack(spacing: 2) {
                                            ForEach(1...4, id: \.self) { i in
                                                Circle()
                                                    .fill(i <= strain.potency.level ? strain.potency.color : Color.white.opacity(0.15))
                                                    .frame(width: 6, height: 6)
                                            }
                                        }
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .animateIn(delay: 0.2)

                    // My Trip Reports
                    profileSection("My Trip Reports") {
                        if appState.userTripReports.isEmpty {
                            EmptyStateView(icon: "square.and.pencil", title: "No Trip Reports", subtitle: "Share your experiences to help the community")
                        } else {
                            ForEach(appState.userTripReports) { report in
                                let strainName = appState.strains.first(where: { $0.id == report.strainId })?.name ?? "Unknown"
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(strainName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.ttPrimary)
                                    RatingStars(rating: Double(report.rating), size: 10)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .animateIn(delay: 0.3)

                    // Saved Substances
                    profileSection("Saved Substances") {
                        if appState.savedSubstanceIDs.isEmpty {
                            EmptyStateView(icon: "testtube.2", title: "No Saved Substances", subtitle: "Explore substances and save the ones you want to learn about")
                        } else {
                            ForEach(appState.substances.filter { appState.savedSubstanceIDs.contains($0.id) }) { substance in
                                NavigationLink(value: substance) {
                                    HStack {
                                        Image(systemName: substance.imageSymbol)
                                            .foregroundStyle(Color.teal)
                                        Text(substance.name)
                                            .foregroundStyle(Color.ttPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .animateIn(delay: 0.4)

                    // Saved Services
                    profileSection("Saved Services") {
                        if appState.savedServiceIDs.isEmpty {
                            EmptyStateView(icon: "building.2", title: "No Saved Services", subtitle: "Find licensed service centers near you")
                        } else {
                            ForEach(appState.services.filter { appState.savedServiceIDs.contains($0.id) }) { service in
                                NavigationLink(value: service) {
                                    HStack {
                                        Image(systemName: service.imageSymbol)
                                            .foregroundStyle(Color.teal)
                                        Text(service.name)
                                            .foregroundStyle(Color.ttPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .animateIn(delay: 0.5)

                    // My Reviews
                    profileSection("My Reviews") {
                        if appState.userReviews.isEmpty {
                            EmptyStateView(icon: "text.bubble", title: "No Reviews Yet", subtitle: "Share your thoughts on substances and services")
                        } else {
                            ForEach(appState.userReviews) { review in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(review.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.ttPrimary)
                                    RatingStars(rating: Double(review.rating), size: 10)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .animateIn(delay: 0.6)

                    // Settings
                    profileSection("Settings") {
                        HStack {
                            Text("Jurisdiction")
                                .foregroundStyle(Color.ttPrimary)
                            Spacer()
                            Picker("", selection: $state.selectedJurisdiction) {
                                ForEach(Jurisdiction.allCases) { j in
                                    Text(j.rawValue).tag(j)
                                }
                            }
                            .tint(Color.ttAccent)
                        }
                    }
                    .animateIn(delay: 0.7)

                    // Links
                    profileSection("Info") {
                        Link(destination: URL(string: "https://example.com/guidelines")!) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color.teal)
                                Text("Community Guidelines")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                        Link(destination: URL(string: "https://example.com/privacy")!) {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .foregroundStyle(Color.teal)
                                Text("Privacy Policy")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                        Link(destination: URL(string: "https://example.com/terms")!) {
                            HStack {
                                Image(systemName: "doc.plaintext")
                                    .foregroundStyle(Color.teal)
                                Text("Terms of Service")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .animateIn(delay: 0.8)

                    // Reset
                    Button(role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "ageVerified")
                    } label: {
                        Label("Reset Age Verification", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 0.5))
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background { GradientBackground() }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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

    @ViewBuilder
    private func profileSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.title3, design: .serif, weight: .bold))
                .foregroundStyle(Color.ttSectionHeader)
                .tracking(0.5)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 4) {
                content()
            }
            .darkGlassCard()
            .padding(.horizontal)
        }
    }
}
