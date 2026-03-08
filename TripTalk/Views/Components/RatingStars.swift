import SwiftUI

struct RatingStars: View {
    let rating: Double
    var maxRating: Int = 5
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starImage(for: index))
                    .font(.system(size: size))
                    .foregroundStyle(Color.ttAccent)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(rating, specifier: "%.1f") out of \(maxRating) stars")
    }

    private func starImage(for index: Int) -> String {
        if Double(index) <= rating { return "star.fill" }
        else if Double(index) - 0.5 <= rating { return "star.leadinghalf.filled" }
        else { return "star" }
    }
}

struct InteractiveRatingStars: View {
    @Binding var rating: Int
    var size: CGFloat = 30

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(Color.ttAccent)
                    .onTapGesture { rating = index; Haptics.light() }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(rating) out of 5 stars")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: if rating < 5 { rating += 1; Haptics.light() }
            case .decrement: if rating > 0 { rating -= 1; Haptics.light() }
            @unknown default: break
            }
        }
    }
}
