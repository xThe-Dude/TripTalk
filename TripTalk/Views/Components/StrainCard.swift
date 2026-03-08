import SwiftUI

struct StrainCard: View {
    let strain: Strain

    var body: some View {
        HStack(spacing: 0) {
            // Accent bar left edge
            RoundedRectangle(cornerRadius: 1)
                .fill(strain.parentSubstance.color)
                .frame(width: 2)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: strain.parentSubstance.icon)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .background(
                            LinearGradient(colors: [strain.parentSubstance.color, strain.parentSubstance.color.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(strain.name)
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.ttPrimary)
                            .lineLimit(1)

                        HStack(spacing: 6) {
                            Text(strain.parentSubstance.rawValue)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(strain.parentSubstance.color.opacity(0.15))
                                .foregroundStyle(strain.parentSubstance.color)
                                .clipShape(Capsule())

                            Text(strain.difficulty.rawValue)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(strain.difficulty.color.opacity(0.15))
                                .foregroundStyle(strain.difficulty.color)
                                .clipShape(Capsule())
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.ttAccent)
                            Text(String(format: "%.1f", strain.averageRating))
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.ttPrimary)
                        }
                        Text("\(strain.reviewCount) reports")
                            .font(.caption2)
                            .foregroundStyle(Color.ttSecondary)
                    }
                }

                HStack(spacing: 3) {
                    Text("Potency")
                        .font(.caption2)
                        .foregroundStyle(Color.ttSecondary)
                    ForEach(1...4, id: \.self) { i in
                        Circle()
                            .fill(i <= strain.potency.level ? strain.potency.color : Color.white.opacity(0.15))
                            .frame(width: 8, height: 8)
                    }
                    Spacer()
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Potency: \(strain.potency.rawValue), level \(strain.potency.level) of 4")

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(strain.commonEffects.prefix(3)) { effect in
                            TagChip(text: effect.rawValue)
                        }
                    }
                }
            }
            .padding(.leading, 10)
        }
        .darkGlassCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(strain.name), \(strain.parentSubstance.rawValue), potency \(strain.potency.rawValue), rated \(String(format: "%.1f", strain.averageRating)) stars, \(strain.reviewCount) reports")
    }
}
