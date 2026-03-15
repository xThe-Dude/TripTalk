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
                                    colors: [Color.ttGlow.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 160, height: 160)

                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(colors: [.teal, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
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
                            EmptyStateView(icon: "leaf", imageName: "empty_saved", title: "No Saved Varieties", subtitle: "Tap the bookmark icon on any variety to save it here")
                        } else {
                            ForEach(appState.strains.filter { appState.savedStrainIDs.contains($0.id) }) { strain in
                                NavigationLink(value: strain) {
                                    HStack {
                                        Image(systemName: strain.parentSubstance.icon)
                                            .foregroundStyle(strain.parentSubstance.color)
                                        Text(strain.name)
                                            .foregroundStyle(Color.ttPrimary)
                                        Spacer()
                                        PotencyDots(level: strain.potency.level, dotSize: 6, activeColor: strain.potency.color)
                                        .accessibilityElement(children: .ignore)
                                        .accessibilityLabel("Potency: \(strain.potency.rawValue), level \(strain.potency.level) of 4")
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
                            EmptyStateView(icon: "square.and.pencil", imageName: "empty_reports", title: "No Trip Reports", subtitle: "After trying a variety, share your experience from its detail page")
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
                            EmptyStateView(icon: "testtube.2", imageName: "empty_saved", title: "No Saved Substances", subtitle: "Tap the bookmark icon on any substance to save it here")
                        } else {
                            ForEach(appState.substances.filter { appState.savedSubstanceIDs.contains($0.id) }) { substance in
                                NavigationLink(value: substance) {
                                    HStack {
                                        Image(systemName: substance.imageSymbol)
                                            .foregroundStyle(Color.ttGlow)
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
                            EmptyStateView(icon: "building.2", imageName: "empty_services", title: "No Saved Services", subtitle: "Tap the bookmark icon on any service center to save it here")
                        } else {
                            ForEach(appState.services.filter { appState.savedServiceIDs.contains($0.id) }) { service in
                                NavigationLink(value: service) {
                                    HStack {
                                        Image(systemName: service.imageSymbol)
                                            .foregroundStyle(Color.ttGlow)
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
                    .animateIn(delay: 0.35)

                    // My Reviews
                    profileSection("My Reviews") {
                        if appState.userReviews.isEmpty {
                            EmptyStateView(icon: "text.bubble", imageName: "empty_reviews", title: "No Reviews Yet", subtitle: "Leave a review from any substance or service detail page")
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
                    .animateIn(delay: 0.35)

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
                            .onChange(of: appState.selectedJurisdiction) {
                                appState.updateJurisdiction(appState.selectedJurisdiction)
                            }
                        }
                    }
                    .animateIn(delay: 0.4)

                    // Links
                    profileSection("Info") {
                        Link(destination: URL(string: "https://xthe-dude.github.io/TripTalk/support.html")!) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color.ttGlow)
                                Text("Community Guidelines")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                        Link(destination: URL(string: "https://xthe-dude.github.io/TripTalk/privacy.html")!) {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .foregroundStyle(Color.ttGlow)
                                Text("Privacy Policy")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                        Link(destination: URL(string: "https://xthe-dude.github.io/TripTalk/terms.html")!) {
                            HStack {
                                Image(systemName: "doc.plaintext")
                                    .foregroundStyle(Color.ttGlow)
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
                    .animateIn(delay: 0.4)

                    // Crisis Resources
                    profileSection("Crisis Resources") {
                        VStack(alignment: .leading, spacing: 8) {
                            Link(destination: URL(string: "tel:988")!) {
                                HStack {
                                    Image(systemName: "phone.circle.fill")
                                        .foregroundStyle(.green)
                                    VStack(alignment: .leading) {
                                        Text("988 Suicide & Crisis Lifeline")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.ttPrimary)
                                        Text("Call or text 988")
                                            .font(.caption)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.ttTertiary)
                                }
                            }
                            Divider().overlay(Color.white.opacity(0.05))
                            Link(destination: URL(string: "tel:6234737433")!) {
                                HStack {
                                    Image(systemName: "heart.circle.fill")
                                        .foregroundStyle(Color.ttVisual)
                                    VStack(alignment: .leading) {
                                        Text("Fireside Project")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.ttPrimary)
                                        Text("Psychedelic peer support: (623) 473-7433")
                                            .font(.caption)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.ttTertiary)
                                }
                            }
                        }
                    }
                    .animateIn(delay: 0.4)

                    // About
                    profileSection("About") {
                        HStack {
                            Text("Version")
                                .foregroundStyle(Color.ttPrimary)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundStyle(Color.ttSecondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .animateIn(delay: 0.4)

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
                .padding(.top)
                .padding(.bottom, 90)
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
                .foregroundStyle(Color.ttPrimary)
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
