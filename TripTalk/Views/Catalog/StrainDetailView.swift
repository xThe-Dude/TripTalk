import SwiftUI

struct StrainDetailView: View {
    @Environment(AppState.self) private var appState
    let strain: Strain
    @State private var showWriteTripReport = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Hero gradient
                ZStack {
                    LinearGradient(
                        colors: [strain.parentSubstance.color.opacity(0.8), .blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    VStack(spacing: 8) {
                        Image(systemName: strain.parentSubstance.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(.white)
                        Text(strain.name)
                            .font(.system(.title, design: .serif, weight: .bold))
                            .foregroundStyle(.white)
                        Text(strain.species)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                        Text(strain.parentSubstance.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.25))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 30)
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)

                // Potency + Difficulty + Onset + Duration
                HStack(spacing: 12) {
                    // Potency
                    VStack(spacing: 4) {
                        Text("Potency")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        HStack(spacing: 3) {
                            ForEach(1...4, id: \.self) { i in
                                Circle()
                                    .fill(i <= strain.potency.level ? strain.potency.color : Color(.systemGray4))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        Text(strain.potency.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(strain.potency.color)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40)

                    // Difficulty
                    VStack(spacing: 4) {
                        Text("Level")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Image(systemName: strain.difficulty == .beginner ? "checkmark.circle.fill" : strain.difficulty == .intermediate ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(strain.difficulty.color)
                        Text(strain.difficulty.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(strain.difficulty.color)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40)

                    // Onset
                    VStack(spacing: 4) {
                        Text("Onset")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Image(systemName: "clock")
                            .foregroundStyle(.blue)
                        Text(strain.onset)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40)

                    // Duration
                    VStack(spacing: 4) {
                        Text("Duration")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Image(systemName: "hourglass")
                            .foregroundStyle(.blue)
                        Text(strain.duration)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)

                // Intensity chart
                let intensities = appState.averageIntensities(for: strain.id)
                if intensities.visual > 0 || intensities.body > 0 || intensities.emotional > 0 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Average Intensity")
                            .font(.system(.title3, design: .serif, weight: .bold))
                        IntensityChartRow(label: "Visual", value: intensities.visual, color: .purple)
                        IntensityChartRow(label: "Body", value: intensities.body, color: .green)
                        IntensityChartRow(label: "Emotional", value: intensities.emotional, color: .pink)
                    }
                    .padding(.horizontal)
                }

                // Effects
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effects")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    FlowLayout(spacing: 6) {
                        ForEach(strain.commonEffects) { effect in
                            TagChip(text: effect.rawValue)
                        }
                    }
                }
                .padding(.horizontal)

                // Body Feel
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body Feel")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    FlowLayout(spacing: 6) {
                        ForEach(strain.bodyFeel) { feel in
                            TagChip(text: feel.rawValue)
                        }
                    }
                }
                .padding(.horizontal)

                // Emotional Profile
                VStack(alignment: .leading, spacing: 8) {
                    Text("Emotional Profile")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    FlowLayout(spacing: 6) {
                        ForEach(strain.emotionalProfile) { tag in
                            TagChip(text: tag.rawValue)
                        }
                    }
                }
                .padding(.horizontal)

                // About
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.system(.title3, design: .serif, weight: .bold))
                    Text(strain.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)

                // Community Photos (mock)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Community Photos")
                            .font(.system(.title3, design: .serif, weight: .bold))
                        Spacer()
                        Text("\(strain.communityPhotoCount)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(0..<min(6, strain.communityPhotoCount), id: \.self) { i in
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            colors: [strain.parentSubstance.color.opacity(0.3 + Double(i) * 0.1), .blue.opacity(0.2 + Double(i) * 0.05)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .overlay {
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // Trip Reports
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Trip Reports")
                            .font(.system(.title3, design: .serif, weight: .bold))
                        Spacer()
                        RatingStars(rating: strain.averageRating)
                        Text("(\(strain.reviewCount))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    let reports = appState.tripReportsFor(strain: strain.id)
                    ForEach(reports.prefix(3)) { report in
                        TripReportCard(report: report)
                    }

                    if reports.count > 3 {
                        Button {
                            // See all (future)
                        } label: {
                            Text("See all \(reports.count) reports")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                    }

                    Button {
                        showWriteTripReport = true
                    } label: {
                        Label("Write a Trip Report", systemImage: "square.and.pencil")
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
        .background(Color(.systemGroupedBackground))
        .navigationTitle(strain.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.toggleSavedStrain(strain.id)
                } label: {
                    Image(systemName: appState.savedStrainIDs.contains(strain.id) ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .sheet(isPresented: $showWriteTripReport) {
            WriteTripReportView(strainId: strain.id)
        }
    }
}

struct IntensityChartRow: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .frame(width: 60, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * value / 5.0)
                }
            }
            .frame(height: 8)
            Text(String(format: "%.1f", value))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}
