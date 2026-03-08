import SwiftUI

struct ReviewCard: View {
    let review: Review
    var onHelpful: (() -> Void)? = nil
    var onReport: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 0) {
            // Accent bar left edge
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.teal)
                .frame(width: 2)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.ttSecondary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(review.authorName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.ttPrimary)
                        Text(review.date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(Color.ttTertiary)
                    }
                    Spacer()
                    RatingStars(rating: Double(review.rating), size: 12)
                }

                Text(review.title)
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundStyle(Color.ttPrimary)

                Text(review.body)
                    .font(.caption)
                    .foregroundStyle(Color.ttSecondary)
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
                            .foregroundStyle(onHelpful != nil ? Color.teal : Color.ttSecondary)
                    }

                    Button {
                        onReport?()
                    } label: {
                        Label("Report", systemImage: "flag")
                            .font(.caption)
                            .foregroundStyle(onReport != nil ? Color.orange.opacity(0.7) : Color.ttSecondary)
                    }

                    Spacer()
                }
            }
            .padding(.leading, 10)
        }
        .darkGlassCard()
    }
}
