import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showSafetyAlert = false
    

    private let tips = [
        "Start low, go slow. Especially with unfamiliar varieties.",
        "Set and setting matter. A comfortable, safe environment can shape your entire experience.",
        "Having a trusted sitter present is one of the most important safety practices.",
        "Integration is as important as the experience itself. Take time to reflect.",
        "Stay hydrated, but don't overdo it. Small sips of water are better than large amounts.",
        "Thoroughly research any substance before an experience, and consult a healthcare provider when possible. Preparation is a core harm-reduction practice.",
        "Let someone you trust know about your plans. A safety contact can make all the difference.",
        "Your mindset matters. Take time to set a clear intention before any experience.",
        "Journal your experiences afterward. Reflection is a powerful tool for integration.",
        "Mixing substances significantly increases risk. When in doubt, keep it simple.",
        "Research potential interactions with any medications you're taking.",
        "Physical comfort matters. Prepare your space with blankets, water, and calming music.",
        "If anxiety arises, grounding techniques can help: slow your breathing, change your environment, and focus on something familiar. If distress persists or escalates, call the Fireside Project at (623) 473-7433 or dial 988.",
        "Integration is as important as the experience itself. Give yourself time to process."
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
                        Text("Welcome to TripTalk")
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.ttPrimary, Color.ttGlow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .multilineTextAlignment(.center)

                        Text("Your guide to informed, safer experiences")
                            .font(.subheadline)
                            .foregroundStyle(Color.ttTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                    // MARK: - Featured Variety Spotlight
                    if let featured = appState.strains.isEmpty ? nil : appState.strains[Calendar.current.component(.day, from: Date()) % appState.strains.count] {
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
                                        .lineLimit(3)

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
                                    .pressEffect()
                                    .padding(.top, 4)
                                }
                                .padding(20)
                            }
                        }
                        .darkGlassCardElevated(glowColor: featured.parentSubstance.color)
                        .padding(.horizontal)
                        .animateIn(delay: 0.1)
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
                    .animateIn(delay: 0.2)

                    // MARK: - Quick Links
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Links")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .tracking(0.8)
                            .padding(.horizontal)

                        HStack(spacing: 0) {
                            Spacer()
                            quickLink(icon: "leaf.fill", label: "Varieties", color: .ttBody) {
                                appState.selectedTab = 2
                            }
                            Spacer()
                            quickLink(icon: "building.2.fill", label: "Services", color: .blue) {
                                appState.selectedTab = 4
                            }
                            Spacer()
                            quickLink(icon: "shield.fill", label: "Safety", color: .orange) {
                                showSafetyAlert = true
                            }
                            Spacer()
                            quickLink(icon: "person.3.fill", label: "Community", color: .ttVisual) {
                                appState.selectedTab = 1
                            }
                            Spacer()
                        }
                    }
                    .animateIn(delay: 0.3)

                    // MARK: - Recent Trip Reports
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Trip Reports")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .tracking(0.8)
                            .padding(.horizontal)

                        ForEach(Array(appState.tripReports.sorted(by: { $0.date > $1.date }).prefix(3).enumerated()), id: \.element.id) { index, report in
                            if let strain = appState.strains.first(where: { $0.id == report.strainId }) {
                                NavigationLink(value: strain) {
                                    TripReportCard(report: report, strainName: strain.name)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                                .animateIn(delay: 0.3 + Double(index) * 0.05)
                            } else {
                                TripReportCard(report: report, strainName: "")
                                    .padding(.horizontal)
                                    .animateIn(delay: 0.3 + Double(index) * 0.05)
                            }
                        }
                    }

                    // MARK: - Community Stats
                    HStack(spacing: 0) {
                        Spacer()
                        Text("\(appState.tripReports.count) trip reports • \(appState.strains.count) varieties • Growing daily")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .darkGlassCard()
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    Text("TripTalk provides educational information only. This is not medical, legal, or therapeutic advice. Always consult qualified professionals. If you're in crisis, call 988 or text HOME to 741741.")
                        .font(.caption2)
                        .foregroundStyle(Color.ttTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, 90)
                }
            }
            .refreshable {
                try? await Task.sleep(for: .seconds(0.8))
            }
            .background { GradientBackground() }
            .navigationTitle("Home")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Strain.self) { strain in
                StrainDetailView(strain: strain)
            }
            .alert("Crisis Resources", isPresented: $showSafetyAlert) {
                Button("Call 988 Suicide & Crisis Lifeline") {
                    if let url = URL(string: "tel:988") { UIApplication.shared.open(url) }
                }
                Button("Visit firesideproject.org") {
                    if let url = URL(string: "https://firesideproject.org") { UIApplication.shared.open(url) }
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text("If you or someone you know is in crisis:\n\n• 988 Suicide & Crisis Lifeline\n• Fireside Project Psychedelic Peer Support: (623) 473-7433")
            }
        }
    }

    @ViewBuilder
    private func quickLink(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
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
        .buttonStyle(.plain)
    }
}
