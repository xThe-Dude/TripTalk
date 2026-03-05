import SwiftUI

struct StrainCard: View {
    let strain: Strain

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Substance icon
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
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        // Substance badge
                        Text(strain.parentSubstance.rawValue)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(strain.parentSubstance.color.opacity(0.15))
                            .foregroundStyle(strain.parentSubstance.color)
                            .clipShape(Capsule())

                        // Difficulty badge
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

                // Rating
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", strain.averageRating))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    Text("\(strain.reviewCount) reports")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Potency meter
            HStack(spacing: 3) {
                Text("Potency")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                ForEach(1...4, id: \.self) { i in
                    Circle()
                        .fill(i <= strain.potency.level ? strain.potency.color : Color(.systemGray4))
                        .frame(width: 8, height: 8)
                }
                Spacer()
            }

            // Effect tags
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(strain.commonEffects.prefix(3)) { effect in
                        TagChip(text: effect.rawValue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
