import SwiftUI

struct SubstanceDetailView: View {
    @Environment(AppState.self) private var appState
    let substance: Substance
    @State private var showWriteReview = false
    @State private var bookmarkBounce = false

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
                    .frame(height: 240)
                    VStack(spacing: 8) {
                        Image(systemName: substance.imageSymbol)
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.9))
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
                    FlowLayout(spacing: 6) {
                        ForEach(substance.effects) { effect in
                            TagChip(text: effect.rawValue, color: effectColor(for: effect.rawValue))
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
                                LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
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
                    Button {
                        appState.toggleSavedSubstance(substance.id)
                        Haptics.medium()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                            bookmarkBounce = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            bookmarkBounce = false
                        }
                    } label: {
                        Image(systemName: appState.savedSubstanceIDs.contains(substance.id) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(Color.ttPrimary)
                            .scaleEffect(bookmarkBounce ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: bookmarkBounce)
                    }
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
        case .legal: return .green
        case .decriminalized: return Color.ttAccent
        case .medicalOnly: return .blue
        case .illegal: return .red
        case .underReview: return .orange
        }
    }

    private func effectColor(for effectName: String) -> Color {
        let lower = effectName.lowercased()
        let visualKeywords = ["visual", "color", "geometric", "pattern", "fractal", "hallucin", "distortion", "trails", "synesthesia"]
        let bodyKeywords = ["body", "tingling", "warmth", "nausea", "energy", "sedat", "relax", "heavy", "light"]
        let emotionalKeywords = ["euphori", "empathy", "love", "anxiety", "fear", "joy", "bliss", "peace", "connect"]
        let spiritualKeywords = ["spirit", "transcend", "ego", "mystical", "cosmic", "unity", "dissolv"]

        if visualKeywords.contains(where: { lower.contains($0) }) { return .ttVisual }
        if bodyKeywords.contains(where: { lower.contains($0) }) { return .ttBody }
        if emotionalKeywords.contains(where: { lower.contains($0) }) { return .ttEmotional }
        if spiritualKeywords.contains(where: { lower.contains($0) }) { return .ttSpiritual }
        return .ttGlow
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
