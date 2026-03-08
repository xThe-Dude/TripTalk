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
    }
}
