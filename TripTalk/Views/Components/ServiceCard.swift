import SwiftUI

struct ServiceCard: View {
    let service: ServiceCenter

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: service.imageSymbol)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(colors: [.teal, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(service.name)
                            .font(.system(.headline, design: .serif))
                            .foregroundStyle(Color.ttPrimary)
                            .lineLimit(1)
                        if service.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    HStack(spacing: 4) {
                        Text(service.locationString)
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                        Text("\(service.distanceMiles)mi")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                        Spacer()
                        RatingStars(rating: service.averageRating, size: 10)
                        Text(String(format: "%.1f", service.averageRating))
                            .font(.caption2)
                            .foregroundStyle(Color.ttSecondary)
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(service.offerings.prefix(3), id: \.self) { offering in
                        TagChip(text: offering)
                    }
                }
            }
        }
        .darkGlassCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(service.name), \(service.locationString), \(service.distanceMiles) miles away, rated \(String(format: "%.1f", service.averageRating)) stars\(service.isVerified ? ", verified" : "")")
    }
}
