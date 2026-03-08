import SwiftUI

struct ReviewCard: View {
    let review: Review
    var onHelpful: (() -> Void)? = nil
    var onReport: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(review.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(review.date, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                RatingStars(rating: Double(review.rating), size: 12)
            }

            Text(review.title)
                .font(.system(.subheadline, design: .serif, weight: .semibold))

            Text(review.body)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if !review.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(review.tags.prefix(3)) { tag in
                            TagChip(text: tag.rawValue)
                        }
                    }
                }
            }

            HStack(spacing: 16) {
                Button {
                    onHelpful?()
                } label: {
                    Label("\(review.helpfulCount)", systemImage: "hand.thumbsup")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    onReport?()
                } label: {
                    Label("Report", systemImage: "flag")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
    }
}
