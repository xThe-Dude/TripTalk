import SwiftUI

struct ServiceDetailView: View {
    @Environment(AppState.self) private var appState
    let service: ServiceCenter
    @State private var showWriteReview = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Immersive hero section
                ZStack {
                    LinearGradient(
                        colors: [.teal.opacity(0.8), Color(red: 0.05, green: 0.12, blue: 0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 220)
                    VStack(spacing: 8) {
                        Image(systemName: service.imageSymbol)
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.9))

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
                    .padding(.vertical, 30)
                }
                .ignoresSafeArea(edges: .top)

                // Location
                VStack(alignment: .leading, spacing: 6) {
                    Label(service.address, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(Color.ttPrimary)
                    Label("\(service.distanceMiles) miles away", systemImage: "car.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.ttSecondary)
                }
                .darkGlassCardElevated()
                .padding(.horizontal)

                // About
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .tracking(0.5)
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
                        .tracking(0.5)
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
                        .tracking(0.5)

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
                            .shadow(color: Color.teal.opacity(0.4), radius: 12, y: 4)
                    }
                    .pressEffect()
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
                HStack(spacing: 12) {
                    ShareLink(item: serviceShareText) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.ttPrimary)
                    }
                    Button {
                        appState.toggleSavedService(service.id)
                        Haptics.medium()
                    } label: {
                        Image(systemName: appState.savedServiceIDs.contains(service.id) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(Color.ttPrimary)
                    }
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(serviceID: service.id)
        }
    }

    private var serviceShareText: String {
        "Check out \(service.name) on TripTalk — \(service.locationString), rated \(String(format: "%.1f", service.averageRating))⭐\(service.isVerified ? " (Verified)" : ""). Find licensed psychedelic service centers near you."
    }
}
