import SwiftUI

struct ServiceDetailView: View {
    @Environment(AppState.self) private var appState
    let service: ServiceCenter
    @State private var showWriteReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: service.imageSymbol)
                        .font(.system(size: 44))
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(
                            LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    HStack(spacing: 4) {
                        Text(service.name)
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                        if service.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                        }
                    }

                    HStack {
                        RatingStars(rating: service.averageRating)
                        Text(String(format: "%.1f", service.averageRating))
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                        Text("(\(service.reviewCount) reviews)")
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()

                // Location
                VStack(alignment: .leading, spacing: 6) {
                    Label(service.address, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(Color.ttPrimary)
                    Label("\(service.distanceMiles) miles away", systemImage: "car.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.ttSecondary)
                }
                .darkGlassCard()
                .padding(.horizontal)

                // About
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                    Text(service.about)
                        .font(.body)
                        .foregroundStyle(Color.ttSecondary)
                }
                .padding(.horizontal)

                // Offerings
                VStack(alignment: .leading, spacing: 8) {
                    Text("Offerings")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                    ForEach(service.offerings, id: \.self) { offering in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.subheadline)
                            Text(offering)
                                .font(.subheadline)
                                .foregroundStyle(Color.ttPrimary)
                        }
                    }
                }
                .padding(.horizontal)

                // Reviews
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reviews")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)

                    ForEach(appState.reviewsFor(service: service.id).prefix(3)) { review in
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
                                LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background { GradientBackground() }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.toggleSavedService(service.id)
                } label: {
                    Image(systemName: appState.savedServiceIDs.contains(service.id) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Color.ttPrimary)
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(serviceID: service.id)
        }
    }
}
