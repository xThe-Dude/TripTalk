import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState

    private let tips = [
        "Start low, go slow. Especially with unfamiliar varieties.",
        "Set and setting matter. A comfortable, safe environment can shape your entire experience.",
        "Having a trusted sitter present is one of the most important safety practices.",
        "Integration is as important as the experience itself. Take time to reflect."
    ]

    private var tipOfTheDay: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return tips[dayOfYear % tips.count]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Welcome Header
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.ttAccent.opacity(0.7))

                        Text("Welcome to TripTalk")
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .multilineTextAlignment(.center)

                        Text("Your guide to informed experiences")
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                    // MARK: - Featured Variety Spotlight
                    if let featured = appState.strains.first {
                        VStack(alignment: .leading, spacing: 0) {
                            ZStack(alignment: .bottomLeading) {
                                LinearGradient(
                                    colors: [featured.parentSubstance.color.opacity(0.9), featured.parentSubstance.color.opacity(0.3), Color(red: 0.05, green: 0.12, blue: 0.22)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 200)

                                Image(systemName: featured.parentSubstance.icon)
                                    .font(.system(size: 80))
                                    .foregroundStyle(.white.opacity(0.12))
                                    .offset(x: 200, y: -30)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Featured Variety")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .textCase(.uppercase)
                                        .foregroundStyle(Color.ttAccent)
                                        .tracking(1.2)

                                    Text(featured.name)
                                        .font(.system(.title, design: .serif, weight: .bold))
                                        .foregroundStyle(Color.ttPrimary)

                                    Text(featured.description)
                                        .font(.caption)
                                        .foregroundStyle(Color.ttSecondary)
                                        .lineLimit(2)

                                    NavigationLink(value: featured) {
                                        Text("Learn more")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.ttAccent.opacity(0.8))
                                            .clipShape(Capsule())
                                            .shadow(color: Color.ttAccent.opacity(0.3), radius: 8, y: 0)
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(20)
                            }
                        }
                        .darkGlassCardElevated(glowColor: featured.parentSubstance.color)
                        .padding(.horizontal)
                    }

                    // MARK: - Harm Reduction Tip
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Image(systemName: "shield.checkered")
                                .font(.title3)
                                .foregroundStyle(Color.ttAccent)
                            Text("Tip of the Day")
                                .font(.system(.headline, design: .serif))
                                .foregroundStyle(Color.ttPrimary)
                        }

                        Text(tipOfTheDay)
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .darkGlassCard()
                    .padding(.horizontal)

                    // MARK: - Quick Links
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Links")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .tracking(0.8)
                            .padding(.horizontal)

                        HStack(spacing: 0) {
                            Spacer()
                            quickLink(icon: "leaf.fill", label: "Varieties", color: .green)
                            Spacer()
                            quickLink(icon: "building.2.fill", label: "Services", color: .blue)
                            Spacer()
                            quickLink(icon: "shield.fill", label: "Safety", color: .orange)
                            Spacer()
                            quickLink(icon: "person.3.fill", label: "Community", color: .purple)
                            Spacer()
                        }
                    }

                    // MARK: - Recent Trip Reports
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Trip Reports")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .tracking(0.8)
                            .padding(.horizontal)

                        ForEach(appState.tripReports.sorted(by: { $0.date > $1.date }).prefix(3)) { report in
                            let strainName = appState.strains.first(where: { $0.id == report.strainId })?.name ?? ""
                            TripReportCard(report: report, strainName: strainName)
                                .padding(.horizontal)
                        }
                    }

                    // MARK: - Community Stats
                    HStack(spacing: 0) {
                        Spacer()
                        Text("12.4k trip reports • 847 varieties reviewed • Growing daily")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .darkGlassCard()
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .background { GradientBackground() }
            .navigationTitle("Home")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Strain.self) { strain in
                StrainDetailView(strain: strain)
            }
        }
    }

    @ViewBuilder
    private func quickLink(icon: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                // Glow behind
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 58, height: 58)
                    .blur(radius: 8)

                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)
                    .overlay(
                        Circle()
                            .stroke(color.opacity(0.3), lineWidth: 0.5)
                    )

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.ttSecondary)
        }
    }
}
