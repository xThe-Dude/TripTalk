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
                            LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    HStack(spacing: 4) {
                        Text(service.name)
                            .font(.system(.title2, design: .serif, weight: .bold))
                        if service.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                        }
                    }

                    HStack {
                        RatingStars(rating: service.averageRating)
                        Text(String(format: "%.1f", service.averageRating))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text("(\(service.reviewCount) reviews)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()

                // Location
                VStack(alignment: .leading, spacing: 6) {
                    Label(service.address, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                    Label("\(service.distanceMiles) miles away", systemImage: "car.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.3), lineWidth: 0.5))
                .padding(.horizontal)

                // About
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    Text(service.about)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Offerings
                VStack(alignment: .leading, spacing: 8) {
                    Text("Offerings")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    ForEach(service.offerings, id: \.self) { offering in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.subheadline)
                            Text(offering)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(.horizontal)

                // Reviews
                VStack(alignment: .leading, spacing: 8) {
                    Text("Reviews")
                        .font(.system(.title3, design: .serif, weight: .bold))

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
                                LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
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
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .navigationTitle(service.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.toggleSavedService(service.id)
                } label: {
                    Image(systemName: appState.savedServiceIDs.contains(service.id) ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .sheet(isPresented: $showWriteReview) {
            WriteReviewView(serviceID: service.id)
        }
    }
}
