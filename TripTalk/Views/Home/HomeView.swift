import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showSafetyAlert = false
    @State private var showCrisisSheet  = false
    @State private var journalEntries: [JournalEntry] = []

    private let tips = [
        "Unfamiliar substances carry unpredictable risks. Research thoroughly and consult a healthcare provider before any experience.",
        "Set and setting matter. A comfortable, safe environment can shape your entire experience.",
        "Having a trusted sitter present is one of the most important safety practices.",
        "Integration is as important as the experience itself. Take time to reflect.",
        "Stay hydrated, but don't overdo it. Small sips of water are better than large amounts.",
        "Thoroughly research any substance before an experience, and consult a healthcare provider when possible. Preparation is a core harm-reduction practice.",
        "Let someone you trust know about your plans. A safety contact can make all the difference.",
        "Mental health professionals emphasize that mindset and emotional state significantly influence psychedelic outcomes.",
        "Clinicians recommend post-experience reflection as part of integration. Consider working with a therapist.",
        "Mixing substances significantly increases risk. When in doubt, keep it simple.",
        "Research potential interactions with any medications you're taking.",
        "Environment plays a documented role in psychedelic experiences. Research on set and setting is available through MAPS and Johns Hopkins.",
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
                VStack(alignment: .leading, spacing: TTDesign.spacingXL) {

                    // MARK: 1 — Welcome header
                    welcomeHeader

                    // MARK: 2 — "Now" hero card (most-recent journal entry or empty state)
                    nowSection
                        .padding(.horizontal, TTDesign.spacingLG)
                        .revealOnScroll(delay: 0.05)

                    // MARK: 3 — Crisis affordance (always-visible inline chip)
                    crisisAffordance
                        .padding(.horizontal, TTDesign.spacingLG)
                        .revealOnScroll(delay: 0.1)

                    // MARK: 4 — Substance Spotlight
                    spotlightSection
                        .revealOnScroll(delay: 0.15)

                    // MARK: 5 — Tip of the Day
                    tipSection
                        .revealOnScroll(delay: 0.2)

                    // MARK: 6 — Quick Links
                    quickLinksSection
                        .revealOnScroll(delay: 0.25)

                    // MARK: 7 — Recent Trip Reports (with empty state)
                    tripReportsSection

                    // MARK: 8 — Community Stats
                    statsSection
                        .revealOnScroll(delay: 0.4)

                    // MARK: 9 — Disclaimer
                    disclaimerSection
                }
            }
            .onAppear { loadJournalEntries() }
            .refreshable {
                loadJournalEntries()
            }
            .background { GradientBackground() }
            .navigationTitle("Home")
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationDestination(for: Strain.self) { strain in
                StrainDetailView(strain: strain)
            }
            .sheet(isPresented: $showCrisisSheet) {
                CrisisSheet()
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
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

    // MARK: - Welcome Header

    @ViewBuilder
    private var welcomeHeader: some View {
        VStack(spacing: TTDesign.spacingXS) {
            Text("TripTalk")
                .font(.ttPageHead)
                .foregroundStyle(Color.ttPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text("Informed, safer experiences")
                .font(.ttMetadata)
                .foregroundStyle(Color.ttTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, TTDesign.spacingXL)
        .padding(.horizontal, TTDesign.spacingLG)
    }

    // MARK: - Now Section

    @ViewBuilder
    private var nowSection: some View {
        if let latest = journalEntries.first {
            // Active/recent journal entry — hero summary
            let entryTitle: String = latest.substanceName.isEmpty ? "Untitled journey" : latest.substanceName
            let snippet: String = {
                let intent = latest.intention.trimmingCharacters(in: .whitespacesAndNewlines)
                let high   = latest.highlights.trimmingCharacters(in: .whitespacesAndNewlines)
                if !intent.isEmpty { return intent }
                if !high.isEmpty   { return high }
                return "Tap to continue your reflection."
            }()

            VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
                Text("NOW")
                    .font(.ttEyebrow)
                    .foregroundStyle(Color.ttAccent)
                    .tracking(1.2)

                Text(entryTitle)
                    .font(.ttSection)
                    .foregroundStyle(Color.ttPrimary)
                    .lineLimit(1)

                Text(snippet)
                    .font(.ttBody)
                    .foregroundStyle(Color.ttSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .center) {
                    Text(latest.createdAt, style: .relative)
                        .font(.ttCaption)
                        .foregroundStyle(Color.ttTertiary)

                    Spacer()

                    Button {
                        TTMotion.selectionHaptic()
                        appState.go(to: .journal)
                    } label: {
                        HStack(spacing: TTDesign.spacingXS) {
                            Text("Continue journey")
                                .font(.ttEyebrow)
                            Image(systemName: "arrow.right")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, TTDesign.spacingMD)
                        .padding(.vertical, TTDesign.spacingSM)
                        .background(Color.ttGlow.opacity(0.8))
                        .clipShape(Capsule())
                        .shadow(color: Color.ttGlow.opacity(0.25), radius: 8, y: 0)
                    }
                    .pressEffect()
                }
            }
            .darkGlassCardElevated(glowColor: .ttGlow)
        } else {
            // Empty state — invite first entry
            VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
                Text("NOW")
                    .font(.ttEyebrow)
                    .foregroundStyle(Color.ttAccent)
                    .tracking(1.2)

                VStack(spacing: TTDesign.spacingMD) {
                    Image(systemName: "book.closed")
                        .font(.ttIconMd)
                        .foregroundStyle(Color.ttAccent.opacity(0.7))

                    VStack(spacing: TTDesign.spacingXS) {
                        Text("Your journey starts here.")
                            .font(.ttCardTitle)
                            .foregroundStyle(Color.ttPrimary)
                            .multilineTextAlignment(.center)

                        Text("Capture your first reflection — voice or text.")
                            .font(.ttBody)
                            .foregroundStyle(Color.ttSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Button {
                        TTMotion.selectionHaptic()
                        appState.go(to: .journal)
                    } label: {
                        Text("Start a Journal Entry")
                            .font(.ttEyebrow)
                            .foregroundStyle(.white)
                            .padding(.horizontal, TTDesign.spacingXL)
                            .padding(.vertical, TTDesign.spacingMD)
                            .background(Color.ttAccent.opacity(0.85))
                            .clipShape(Capsule())
                            .shadow(color: Color.ttAccent.opacity(0.3), radius: 8, y: 0)
                    }
                    .pressEffect()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, TTDesign.spacingXS)
            }
            .darkGlassCardElevated(glowColor: .ttAccent)
        }
    }

    // MARK: - Crisis Affordance

    @ViewBuilder
    private var crisisAffordance: some View {
        Button { showCrisisSheet = true } label: {
            HStack(spacing: TTDesign.spacingSM) {
                Image(systemName: "heart.text.square.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.red)

                Text("Need support? Resources are available 24/7.")
                    .font(.ttCaption.weight(.medium))
                    .foregroundStyle(Color.ttPrimary)

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.ttSecondary)
            }
            .padding(.horizontal, TTDesign.spacingMD)
            .padding(.vertical, TTDesign.spacingSM)
            .background(
                RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                    .fill(Color.red.opacity(0.10))
                    .overlay(
                        RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                            .stroke(Color.red.opacity(0.30), lineWidth: TTDesign.hairlineWidth)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Crisis support resources, available 24/7")
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Substance Spotlight

    @ViewBuilder
    private var spotlightSection: some View {
        if appState.strains.isEmpty {
            // Loading or truly empty catalog
            if appState.isLoadingFromServer {
                HStack(spacing: TTDesign.spacingSM) {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(Color.ttSecondary)
                    Text("Loading substance catalog…")
                        .font(.ttBody)
                        .foregroundStyle(Color.ttSecondary)
                    Spacer()
                }
                .padding(TTDesign.spacingLG)
                .darkGlassCard()
                .padding(.horizontal, TTDesign.spacingLG)
            } else {
                VStack(spacing: TTDesign.spacingMD) {
                    Image(systemName: "leaf")
                        .font(.ttIconMd)
                        .foregroundStyle(Color.ttBody.opacity(0.6))

                    Text("Catalog not loaded")
                        .font(.ttCardTitle)
                        .foregroundStyle(Color.ttPrimary)

                    Text("Substance data will appear here once your connection is established.")
                        .font(.ttBody)
                        .foregroundStyle(Color.ttSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(TTDesign.spacingXL)
                .frame(maxWidth: .infinity)
                .darkGlassCard()
                .padding(.horizontal, TTDesign.spacingLG)
            }
        } else {
            let featured = appState.strains[Calendar.current.component(.day, from: Date()) % appState.strains.count]
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    LinearGradient(
                        colors: [
                            featured.parentSubstance.color.opacity(0.8),
                            featured.parentSubstance.color.opacity(0.25),
                            Color(red: 0.055, green: 0.078, blue: 0.098)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 200)

                    Image(systemName: featured.parentSubstance.icon)
                        .font(.ttIconHero)
                        .foregroundStyle(.white.opacity(0.12))
                        .offset(x: 200, y: -30)

                    VStack(alignment: .leading, spacing: TTDesign.spacingSM) {
                        Text("Substance Spotlight")
                            .font(.ttEyebrow)
                            .foregroundStyle(Color.ttAccent)
                            .tracking(1.2)

                        Text(featured.name)
                            .font(.ttSection)
                            .foregroundStyle(Color.ttPrimary)

                        Text(featured.description)
                            .font(.ttCaption)
                            .foregroundStyle(Color.ttSecondary)
                            .lineLimit(3)

                        NavigationLink(value: featured) {
                            Text("Learn more")
                                .font(.ttCaption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, TTDesign.spacingLG)
                                .padding(.vertical, TTDesign.spacingSM)
                                .background(Color.ttAccent.opacity(0.8))
                                .clipShape(Capsule())
                                .shadow(color: Color.ttAccent.opacity(0.3), radius: 8, y: 0)
                        }
                        .pressEffect()
                        .padding(.top, TTDesign.spacingXS)
                    }
                    .padding(TTDesign.spacingXL)
                }
            }
            .darkGlassCardElevated(glowColor: featured.parentSubstance.color)
            .padding(.horizontal, TTDesign.spacingLG)
        }
    }

    // MARK: - Tip of the Day

    @ViewBuilder
    private var tipSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            HStack(spacing: TTDesign.spacingSM) {
                Image(systemName: "shield.checkered")
                    .font(.title3)
                    .foregroundStyle(Color.ttAccent)
                Text("Tip of the Day")
                    .font(.ttCardTitle)
                    .foregroundStyle(Color.ttPrimary)
            }
            Text(tipOfTheDay)
                .font(.ttBody)
                .foregroundStyle(Color.ttSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .darkGlassCard()
        .padding(.horizontal, TTDesign.spacingLG)
    }

    // MARK: - Quick Links

    @ViewBuilder
    private var quickLinksSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            Text("Quick Links")
                .font(.ttCardTitle)
                .foregroundStyle(Color.ttPrimary)
                .tracking(0.8)
                .padding(.horizontal, TTDesign.spacingLG)
                .accessibilityAddTraits(.isHeader)

            HStack(spacing: 0) {
                Spacer()
                quickLink(icon: "leaf.fill", label: "Varieties", color: .ttBody) {
                    appState.go(to: .catalog)
                }
                Spacer()
                quickLink(icon: "building.2.fill", label: "Services", color: .blue) {
                    appState.go(to: .services)
                }
                Spacer()
                quickLink(icon: "shield.fill", label: "Safety", color: .orange) {
                    showSafetyAlert = true
                }
                Spacer()
                quickLink(icon: "person.3.fill", label: "Community", color: .ttVisual) {
                    appState.go(to: .explore)
                }
                Spacer()
            }
        }
    }

    // MARK: - Recent Trip Reports

    @ViewBuilder
    private var tripReportsSection: some View {
        let sorted = Array(appState.tripReports.sorted { $0.date > $1.date }.prefix(3))
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            Text("Recent Trip Reports")
                .font(.ttCardTitle)
                .foregroundStyle(Color.ttPrimary)
                .tracking(0.8)
                .accessibilityAddTraits(.isHeader)
                .padding(.horizontal, TTDesign.spacingLG)
                .revealOnScroll(delay: 0.3)

            if appState.tripReports.isEmpty {
                if appState.isLoadingFromServer {
                    HStack(spacing: TTDesign.spacingSM) {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(Color.ttSecondary)
                        Text("Loading community reports…")
                            .font(.ttBody)
                            .foregroundStyle(Color.ttSecondary)
                        Spacer()
                    }
                    .padding(TTDesign.spacingLG)
                    .darkGlassCard()
                    .padding(.horizontal, TTDesign.spacingLG)
                    .revealOnScroll(delay: 0.35)
                } else {
                    VStack(spacing: TTDesign.spacingMD) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.ttIconMd)
                            .foregroundStyle(Color.ttSecondary.opacity(0.6))

                        Text("No trip reports yet")
                            .font(.ttCardTitle)
                            .foregroundStyle(Color.ttPrimary)

                        Text("Community reports appear here as members share their experiences.")
                            .font(.ttBody)
                            .foregroundStyle(Color.ttSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(TTDesign.spacingXL)
                    .frame(maxWidth: .infinity)
                    .darkGlassCard()
                    .padding(.horizontal, TTDesign.spacingLG)
                    .revealOnScroll(delay: 0.35)
                }
            } else {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { index, report in
                    if let strain = appState.strains.first(where: { $0.id == report.strainId }) {
                        NavigationLink(value: strain) {
                            TripReportCard(
                                report: report,
                                strainName: strain.name,
                                onReport: { reason in appState.reportTripReport(report.id, reason: reason) }
                            )
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, TTDesign.spacingLG)
                        .revealOnScroll(delay: 0.3 + Double(index) * 0.05)
                    } else {
                        TripReportCard(
                            report: report,
                            strainName: "",
                            onReport: { reason in appState.reportTripReport(report.id, reason: reason) }
                        )
                        .padding(.horizontal, TTDesign.spacingLG)
                        .revealOnScroll(delay: 0.3 + Double(index) * 0.05)
                    }
                }
            }
        }
    }

    // MARK: - Community Stats

    @ViewBuilder
    private var statsSection: some View {
        HStack(spacing: 0) {
            Spacer()
            Text("\(appState.tripReports.count) trip reports · \(appState.strains.count) varieties · Growing daily")
                .font(.ttCaption)
                .foregroundStyle(Color.ttSecondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .darkGlassCard()
        .padding(.horizontal, TTDesign.spacingLG)
    }

    // MARK: - Disclaimer

    @ViewBuilder
    private var disclaimerSection: some View {
        VStack(spacing: TTDesign.spacingXS) {
            Text("TripTalk provides educational information only. This is not medical, legal, or therapeutic advice. Always consult qualified professionals.")
                .font(.ttCaption)
                .foregroundStyle(Color.ttTertiary)
                .multilineTextAlignment(.center)
            HStack(spacing: TTDesign.spacingXS) {
                Text("If you're in crisis, call")
                    .font(.ttCaption)
                    .foregroundStyle(Color.ttTertiary)
                Link("988", destination: URL(string: "tel:988")!)
                    .font(.caption2.bold())
                Text("or text HOME to")
                    .font(.ttCaption)
                    .foregroundStyle(Color.ttTertiary)
                Link("741741", destination: URL(string: "sms:741741&body=HOME")!)
                    .font(.caption2.bold())
            }
        }
        .padding(.horizontal, TTDesign.spacingXXL)
        .padding(.top, TTDesign.spacingLG)
        .padding(.bottom, 90)
    }

    // MARK: - Quick Link Component

    // Note: `color` is intentionally ignored — quick links use a single monochrome
    // thin-line treatment (editorial field-guide aesthetic) rather than colorful glowing
    // circles. Signature preserved so existing call sites remain unchanged.
    @ViewBuilder
    private func quickLink(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: TTDesign.spacingSM) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.03))
                        .frame(width: 52, height: 52)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
                        )

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(Color.ttAccent)
                }
                Text(label)
                    .font(.ttCaption)
                    .foregroundStyle(Color.ttSecondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Data

    private func loadJournalEntries() {
        journalEntries = (try? appState.journal.fetchAll()) ?? []
    }
}
