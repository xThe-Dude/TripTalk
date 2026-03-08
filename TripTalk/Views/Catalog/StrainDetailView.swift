import SwiftUI

struct StrainDetailView: View {
    @Environment(AppState.self) private var appState
    let strain: Strain
    @State private var showWriteTripReport = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Immersive hero — edge to edge
                ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [strain.parentSubstance.color.opacity(0.9), Color(red: 0.05, green: 0.12, blue: 0.22)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 260)

                    VStack(spacing: 8) {
                        Image(systemName: strain.parentSubstance.icon)
                            .font(.system(size: 50))
                            .foregroundStyle(.white.opacity(0.9))
                        Text(strain.name)
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                        Text(strain.species)
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                        Text(strain.parentSubstance.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.15))
                            .clipShape(Capsule())
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .padding(.bottom, 30)
                }
                .ignoresSafeArea(edges: .top)

                // Potency + Difficulty + Onset + Duration
                HStack(spacing: 12) {
                    VStack(spacing: 4) {
                        Text("Potency")
                            .font(.caption2)
                            .foregroundStyle(Color.ttSecondary)
                        HStack(spacing: 3) {
                            ForEach(1...4, id: \.self) { i in
                                Circle()
                                    .fill(i <= strain.potency.level ? strain.potency.color : Color.white.opacity(0.15))
                                    .frame(width: 10, height: 10)
                            }
                        }
                        Text(strain.potency.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(strain.potency.color)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40).overlay(Color.white.opacity(0.15))

                    VStack(spacing: 4) {
                        Text("Level")
                            .font(.caption2)
                            .foregroundStyle(Color.ttSecondary)
                        Image(systemName: strain.difficulty == .beginner ? "checkmark.circle.fill" : strain.difficulty == .intermediate ? "exclamationmark.circle.fill" : "exclamationmark.triangle.fill")
                            .foregroundStyle(strain.difficulty.color)
                        Text(strain.difficulty.rawValue)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(strain.difficulty.color)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40).overlay(Color.white.opacity(0.15))

                    VStack(spacing: 4) {
                        Text("Onset")
                            .font(.caption2)
                            .foregroundStyle(Color.ttSecondary)
                        Image(systemName: "clock")
                            .foregroundStyle(Color.teal)
                        Text(strain.onset)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .frame(maxWidth: .infinity)

                    Divider().frame(height: 40).overlay(Color.white.opacity(0.15))

                    VStack(spacing: 4) {
                        Text("Duration")
                            .font(.caption2)
                            .foregroundStyle(Color.ttSecondary)
                        Image(systemName: "hourglass")
                            .foregroundStyle(Color.teal)
                        Text(strain.duration)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .darkGlassCard()
                .padding(.horizontal)

                // Intensity chart
                let intensities = appState.averageIntensities(for: strain.id)
                if intensities.visual > 0 || intensities.body > 0 || intensities.emotional > 0 {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Average Intensity")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
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
                        .foregroundStyle(Color.ttPrimary)
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
                        .foregroundStyle(Color.ttPrimary)
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
                        .foregroundStyle(Color.ttPrimary)
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
                        .foregroundStyle(Color.ttPrimary)
                    Text(strain.description)
                        .font(.body)
                        .foregroundStyle(Color.ttSecondary)
                }
                .padding(.horizontal)

                // Community Photos
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Community Photos")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                        Spacer()
                        Text("\(strain.communityPhotoCount)")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
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
                                            .foregroundStyle(Color.ttSecondary)
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
                            .foregroundStyle(Color.ttPrimary)
                        Spacer()
                        RatingStars(rating: strain.averageRating)
                        Text("(\(strain.reviewCount))")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                    }

                    let reports = appState.tripReportsFor(strain: strain.id)
                    ForEach(reports.prefix(3)) { report in
                        TripReportCard(report: report)
                    }

                    if reports.count > 3 {
                        Button {
                        } label: {
                            Text("See all \(reports.count) reports")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.ttAccent)
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
                                LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
        .background { GradientBackground() }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(strain.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    appState.toggleSavedStrain(strain.id)
                } label: {
                    Image(systemName: appState.savedStrainIDs.contains(strain.id) ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(Color.ttPrimary)
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
                .foregroundStyle(Color.ttSecondary)
                .frame(width: 60, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * value / 5.0)
                }
            }
            .frame(height: 8)
            Text(String(format: "%.1f", value))
                .font(.caption2)
                .foregroundStyle(Color.ttSecondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}
