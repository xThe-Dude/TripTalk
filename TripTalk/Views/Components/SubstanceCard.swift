import SwiftUI

struct SubstanceCard: View {
    let substance: Substance

    var body: some View {
        HStack(spacing: 0) {
            // Accent bar left edge
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.teal)
                .frame(width: 2)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: substance.imageSymbol)
                        .font(.title2)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(substance.name)
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.ttPrimary)
                            .lineLimit(1)
                        HStack(spacing: 4) {
                            Text(substance.category.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.teal.opacity(0.15))
                                .foregroundStyle(Color.teal)
                                .clipShape(Capsule())
                            Spacer()
                            RatingStars(rating: substance.averageRating, size: 10)
                            Text(String(format: "%.1f", substance.averageRating))
                                .font(.caption2)
                                .foregroundStyle(Color.ttSecondary)
                        }
                    }
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(substance.effects.prefix(4)) { effect in
                            TagChip(text: effect.rawValue)
                        }
                    }
                }
            }
            .padding(.leading, 10)
        }
        .darkGlassCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(substance.name), \(substance.category.rawValue), rated \(String(format: "%.1f", substance.averageRating)) stars")
    }
}
