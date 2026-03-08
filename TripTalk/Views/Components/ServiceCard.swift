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
                        LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(service.name)
                            .font(.system(.headline, design: .serif))
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
                            .foregroundStyle(.secondary)
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(service.distanceMiles)mi")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        RatingStars(rating: service.averageRating, size: 10)
                        Text(String(format: "%.1f", service.averageRating))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
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
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
    }
}
