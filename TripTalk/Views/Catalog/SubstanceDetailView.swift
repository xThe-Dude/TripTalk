import SwiftUI

struct SubstanceDetailView: View {
    @Environment(AppState.self) private var appState
    let substance: Substance
    @State private var showWriteReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero
                ZStack {
                    LinearGradient(
                        colors: [.green.opacity(0.8), .blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(spacing: 8) {
                        Image(systemName: substance.imageSymbol)
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                        Text(substance.name)
                            .font(.system(.title, design: .serif, weight: .bold))
                            .foregroundStyle(.white)
                        Text(substance.category.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .padding(.vertical, 30)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)

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
                .padding(.horizontal)

                // About
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    Text(substance.about)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Effects
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effects")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    FlowLayout(spacing: 6) {
                        ForEach(substance.effects) { effect in
                            TagChip(text: effect.rawValue)
                        }
                    }
                }
                .padding(.horizontal)

                // Safety
                VStack(alignment: .leading, spacing: 8) {
                    Text("Safety Notes")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    ForEach(substance.safetyNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                            Text(note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal)

                // Reviews
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Reviews")
                            .font(.system(.title3, design: .serif, weight: .bold))
                        Spacer()
                        RatingStars(rating: substance.averageRating)
                        Text("(\(substance.reviewCount))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                                LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(substance.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.toggleSavedSubstance(substance.id)
                } label: {
                    Image(systemName: appState.savedSubstanceIDs.contains(substance.id) ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(substanceID: substance.id)
        }
    }

    private func jurisdictionColor(_ status: JurisdictionStatus) -> Color {
        switch status {
        case .legal: return .green
        case .decriminalized: return .yellow
        case .medicalOnly: return .blue
        case .illegal: return .red
        case .underReview: return .orange
        }
    }
}

// Simple flow layout for tag clouds
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
