import SwiftUI

struct SubstanceDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let substance: Substance
    @State private var showWriteReview = false

    private var substanceType: SubstanceType? {
        switch substance.id {
        case MockData.psilocybinID: return .psilocybin
        case MockData.ayahuascaID: return .ayahuasca
        case MockData.mescalineID: return .mescaline
        case MockData.ketamineID: return .ketamine
        default: return nil
        }
    }

    private var heroColor: Color {
        substanceType?.color ?? .teal
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Immersive hero
                ZStack {
                    LinearGradient(
                        colors: [heroColor.opacity(0.8), Color(red: 0.05, green: 0.12, blue: 0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 260)
                    VStack(spacing: 8) {
                        Image(systemName: substance.imageSymbol)
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.9))
                            .accessibilityHidden(true)
                        Text(substance.name)
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                        Text(substance.category.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                    }
                    .padding(.vertical, 30)
                }
                .ignoresSafeArea(edges: .top)
                .modifier(SubstanceParallaxIfMotionAllowed(reduceMotion: reduceMotion))

                // Jurisdiction pill
                let status = substance.statusFor(appState.selectedJurisdiction)
                HStack {
                    Image(systemName: "mappin.circle.fill")
                    Text("\(appState.selectedJurisdiction.rawValue): \(status.rawValue)")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(jurisdictionColor(status).opacity(0.15))
                .foregroundStyle(jurisdictionColor(status))
                .clipShape(Capsule())
                .darkGlassCardElevated()
                .padding(.horizontal)
                .animateIn(delay: 0.1)

                // About
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .tracking(0.5)
                        .accessibilityAddTraits(.isHeader)
                    Text(substance.about)
                        .font(.body)
                        .foregroundStyle(Color.ttSecondary)
                }
                .padding(.horizontal)
                .animateIn(delay: 0.15)

                // Effects
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effects")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .tracking(0.5)
                        .accessibilityAddTraits(.isHeader)
                    FlowLayout(spacing: 6) {
                        ForEach(substance.effects) { effect in
                            TagChip(text: effect.rawValue, color: Color.forEffect(effect.rawValue))
                        }
                    }
                }
                .padding(.horizontal)
                .animateIn(delay: 0.2)

                // Safety
                VStack(alignment: .leading, spacing: 8) {
                    Text("Safety Notes")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .tracking(0.5)
                        .accessibilityAddTraits(.isHeader)
                    ForEach(substance.safetyNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(Color.ttSecondary)
                        }
                    }
                }
                .darkGlassCard()
                .padding(.horizontal)
                .animateIn(delay: 0.25)

                // Strains
                if let st = substanceType {
                    let relatedStrains = appState.strainsFor(substanceType: st)
                    if !relatedStrains.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Varieties")
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .foregroundStyle(Color.ttPrimary)
                                .tracking(0.5)
                                .accessibilityAddTraits(.isHeader)
                            ForEach(relatedStrains) { strain in
                                NavigationLink(value: strain) {
                                    StrainCard(strain: strain)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .animateIn(delay: 0.3)
                    }
                }

                // Reviews
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Reviews")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .tracking(0.5)
                            .accessibilityAddTraits(.isHeader)
                        Spacer()
                        RatingStars(rating: substance.averageRating)
                        Text("(\(substance.reviewCount))")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                    }

                    ForEach(appState.reviewsFor(substance: substance.id).prefix(3)) { review in
                        ReviewCard(review: review)
                    }

                    Button {
                        showWriteReview = true
                    } label: {
                        Label("Write a Review", systemImage: "square.and.pencil")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.teal, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.teal.opacity(0.4), radius: 12, y: 4)
                    }
                    .pressEffect()
                }
                .padding(.horizontal)

                Text("For educational purposes only. Not medical advice.")
                    .font(.caption2)
                    .foregroundStyle(Color.ttTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
            }
            .padding(.bottom)
        }
        .background { GradientBackground() }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(substance.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    ShareLink(item: substanceShareText) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .accessibilityLabel("Share \(substance.name)")
                    Button {
                        appState.toggleSavedSubstance(substance.id)
                        Haptics.medium()
                    } label: {
                        Image(systemName: appState.savedSubstanceIDs.contains(substance.id) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(Color.ttPrimary)
                            .symbolEffect(.bounce, value: appState.savedSubstanceIDs.contains(substance.id))
                    }
                    .accessibilityLabel(appState.savedSubstanceIDs.contains(substance.id) ? "Remove \(substance.name) from saved" : "Save \(substance.name)")
                    .accessibilityAddTraits(appState.savedSubstanceIDs.contains(substance.id) ? .isSelected : [])
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(substanceID: substance.id)
        }
        .navigationDestination(for: Strain.self) { strain in
            StrainDetailView(strain: strain)
        }
    }

    private var substanceShareText: String {
        "Learn about \(substance.name) on TripTalk — \(substance.category.rawValue). Safety information, effects, and community reviews. A harm-reduction resource for informed experiences."
    }

    private func jurisdictionColor(_ status: JurisdictionStatus) -> Color {
        switch status {
        case .legal: return Color.ttBody
        case .decriminalized: return Color.ttAccent
        case .medicalOnly: return Color.ttGlow.opacity(0.9)
        case .illegal: return Color.red.opacity(0.8)
        case .underReview: return Color.orange.opacity(0.8)
        }
    }

}

private struct SubstanceParallaxIfMotionAllowed: ViewModifier {
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.visualEffect { c, proxy in
                c.offset(y: min(0, proxy.frame(in: .scrollView).minY * 0.3))
            }
        }
    }
}

// Flow layout for tag clouds
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y)
            subview.place(at: point, proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
