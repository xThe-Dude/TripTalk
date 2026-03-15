import SwiftUI

struct StrainDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let strain: Strain
    @State private var showWriteTripReport = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                heroSection
                statsBar
                intensitySection

                // Effects
                VStack(alignment: .leading, spacing: 8) {
                    Text("Effects")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .accessibilityAddTraits(.isHeader)
                    FlowLayout(spacing: 6) {
                        ForEach(strain.commonEffects) { effect in
                            TagChip(text: effect.rawValue, color: Color.forEffect(effect.rawValue))
                        }
                    }
                }
                .padding(.horizontal)
                .animateIn(delay: 0.2)

                // Body Feel
                VStack(alignment: .leading, spacing: 8) {
                    Text("Body Feel")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .accessibilityAddTraits(.isHeader)
                    FlowLayout(spacing: 6) {
                        ForEach(strain.bodyFeel) { feel in
                            TagChip(text: feel.rawValue, color: .ttBody)
                        }
                    }
                }
                .padding(.horizontal)
                .animateIn(delay: 0.25)

                // Emotional Profile
                VStack(alignment: .leading, spacing: 8) {
                    Text("Emotional Profile")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .accessibilityAddTraits(.isHeader)
                    FlowLayout(spacing: 6) {
                        ForEach(strain.emotionalProfile) { tag in
                            TagChip(text: tag.rawValue, color: .ttEmotional)
                        }
                    }
                }
                .padding(.horizontal)
                .animateIn(delay: 0.3)

                // About
                VStack(alignment: .leading, spacing: 6) {
                    Text("About")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .accessibilityAddTraits(.isHeader)
                    Text(strain.description)
                        .font(.body)
                        .foregroundStyle(Color.ttSecondary)
                }
                .padding(.horizontal)
                .animateIn(delay: 0.3)

                // Community Photos
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Community Photos")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .accessibilityAddTraits(.isHeader)
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
                                            .accessibilityHidden(true)
                                    }
                            }
                        }
                    }
                    .accessibilityLabel("\(strain.communityPhotoCount) community photos")
                    .accessibilityElement(children: .ignore)
                }
                .padding(.horizontal)
                .animateIn(delay: 0.3)

                // Trip Reports
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Trip Reports")
                            .font(.system(.title3, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                            .accessibilityAddTraits(.isHeader)
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

                    // TODO: implement full trip reports list view before re-enabling this button
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
                        .disabled(true)
                        .accessibilityHidden(true)
                    }

                    Button {
                        showWriteTripReport = true
                    } label: {
                        Label("Write a Trip Report", systemImage: "square.and.pencil")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.teal, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: Color.teal.opacity(0.3), radius: 10, y: 0)
                    }
                    .pressEffect()
                }
                .padding(.horizontal)

                Text("For educational purposes only. Not medical advice.")
                    .font(.caption2)
                    .foregroundStyle(Color.ttTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 12)
            }
            .padding(.bottom, 90)
        }
        .background { GradientBackground() }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationTitle(strain.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    ShareLink(item: strainShareText) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(Color.ttPrimary)
                    }
                    .accessibilityLabel("Share \(strain.name)")
                    Button {
                        appState.toggleSavedStrain(strain.id)
                        Haptics.medium()
                    } label: {
                        Image(systemName: appState.savedStrainIDs.contains(strain.id) ? "bookmark.fill" : "bookmark")
                            .foregroundStyle(Color.ttPrimary)
                            .symbolEffect(.bounce, value: appState.savedStrainIDs.contains(strain.id))
                    }
                    .accessibilityLabel(appState.savedStrainIDs.contains(strain.id) ? "Remove \(strain.name) from saved" : "Save \(strain.name)")
                    .accessibilityAddTraits(appState.savedStrainIDs.contains(strain.id) ? .isSelected : [])
                }
            }
        }
        .sheet(isPresented: $showWriteTripReport) {
            WriteTripReportView(strainId: strain.id)
        }
    }

    // MARK: - Extracted Sub-Views

    private var heroSection: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Image(strain.heroImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: 260)
                    .clipped()

                // Dark gradient overlay for text readability
                LinearGradient(
                    colors: [.clear, .clear, .black.opacity(0.4), .black.opacity(0.85)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: 260)

                VStack(spacing: 8) {
                    Text(strain.name)
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(Color.ttPrimary)
                        .shadow(color: .black.opacity(0.6), radius: 6, y: 2)
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
        }
        .frame(height: 260)
        .clipped()
        .ignoresSafeArea(edges: .top)
        .modifier(ParallaxIfMotionAllowed(reduceMotion: reduceMotion))
    }

    private var statsBar: some View {
        HStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Potency")
                    .font(.caption2)
                    .foregroundStyle(Color.ttSecondary)
                PotencyDots(level: strain.potency.level, dotSize: 10, activeColor: strain.potency.color)
                Text(strain.potency.rawValue)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(strain.potency.color)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Potency: \(strain.potency.rawValue), level \(strain.potency.level) of 4")

            Divider().frame(height: 40).overlay(Color.white.opacity(0.25)).accessibilityHidden(true)

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
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Experience level: \(strain.difficulty.rawValue)")

            Divider().frame(height: 40).overlay(Color.white.opacity(0.25)).accessibilityHidden(true)

            VStack(spacing: 4) {
                Text("Onset")
                    .font(.caption2)
                    .foregroundStyle(Color.ttSecondary)
                Image(systemName: "clock")
                    .foregroundStyle(Color.ttGlow)
                Text(strain.onset)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.ttPrimary)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Onset: \(strain.onset)")

            Divider().frame(height: 40).overlay(Color.white.opacity(0.25)).accessibilityHidden(true)

            VStack(spacing: 4) {
                Text("Duration")
                    .font(.caption2)
                    .foregroundStyle(Color.ttSecondary)
                Image(systemName: "hourglass")
                    .foregroundStyle(Color.ttGlow)
                Text(strain.duration)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.ttPrimary)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Duration: \(strain.duration)")
        }
        .darkGlassCardElevated()
        .padding(.horizontal)
        .animateIn(delay: 0.1)
    }

    @ViewBuilder
    private var intensitySection: some View {
        let intensities = appState.averageIntensities(for: strain.id)
        if intensities.visual > 0 || intensities.body > 0 || intensities.emotional > 0 {
            VStack(alignment: .leading, spacing: 10) {
                Text("Average Intensity")
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundStyle(Color.ttPrimary)
                    .accessibilityAddTraits(.isHeader)
                IntensityChartRow(label: "Visual", value: intensities.visual, color: .ttVisual)
                IntensityChartRow(label: "Body", value: intensities.body, color: .ttBody)
                IntensityChartRow(label: "Emotional", value: intensities.emotional, color: .ttEmotional)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .animateIn(delay: 0.15)
        }
    }

    private var strainShareText: String {
        "Check out \(strain.name) on TripTalk — \(strain.parentSubstance.rawValue) variety, rated \(String(format: "%.1f", strain.averageRating))⭐ with \(strain.reviewCount) community reports. A harm-reduction resource for informed experiences."
    }

}

/// Conditionally applies parallax offset when reduce motion is off.
private struct ParallaxIfMotionAllowed: ViewModifier {
    let reduceMotion: Bool

    func body(content: Content) -> some View {
        if reduceMotion {
            content
        } else {
            content.visualEffect { c, proxy in
                c.offset(y: min(0, proxy.frame(in: .scrollView).minY * 0.3))
            }
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
                        .animation(.easeOut(duration: 0.6), value: value)
                }
            }
            .frame(height: 10)
            Text(String(format: "%.1f/5", value))
                .font(.caption2)
                .foregroundStyle(Color.ttSecondary)
                .frame(width: 36, alignment: .trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) intensity: \(String(format: "%.1f", value)) out of 5")
    }
}
