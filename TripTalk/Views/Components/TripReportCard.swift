import SwiftUI

struct TripReportCard: View {
    let report: TripReport
    var strainName: String = ""

    var body: some View {
        HStack(spacing: 0) {
            // Accent bar left edge
            RoundedRectangle(cornerRadius: 1)
                .fill(Color.ttGlow)
                .frame(width: 2)
                .padding(.vertical, 8)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.ttSecondary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(report.authorName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.ttPrimary)
                        Text(report.date, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(Color.ttTertiary)
                    }
                    Spacer()
                    RatingStars(rating: Double(report.rating), size: 12)
                }

                if !strainName.isEmpty {
                    Text(strainName)
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundStyle(Color.ttSecondary)
                }

                HStack(spacing: 4) {
                    Label(report.setting.rawValue, systemImage: report.setting.icon)
                        .font(.caption2)
                        .foregroundStyle(Color.ttPrimary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.ttGlow.opacity(0.15))
                        .clipShape(Capsule())

                    ForEach(report.moods.prefix(2)) { mood in
                        Text(mood.rawValue)
                            .font(.caption2)
                            .foregroundStyle(Color.ttSecondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }

                HStack(spacing: 12) {
                    IntensityBar(label: "Visual", value: report.visualIntensity, color: .ttVisual)
                    IntensityBar(label: "Body", value: report.bodyIntensity, color: .ttBody)
                    IntensityBar(label: "Emotion", value: report.emotionalIntensity, color: .ttEmotional)
                }

                Text(report.highlights)
                    .font(.caption)
                    .foregroundStyle(Color.ttSecondary)
                    .lineLimit(3)

                HStack(spacing: 16) {
                    if report.wouldRepeat {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                            Text("Would repeat")
                                .font(.caption2)
                        }
                        .foregroundStyle(Color.ttBody)
                    }

                    Spacer()

                    ShareLink(item: shareText) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary)
                    }
                }
            }
            .padding(.leading, 10)
        }
        .darkGlassCard()
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(report.authorName)'s trip report, rated \(report.rating) stars, \(report.setting.rawValue) setting\(report.wouldRepeat ? ", would repeat" : "")")
    }

    private var shareText: String {
        "\(report.authorName)'s trip report\(!strainName.isEmpty ? " on \(strainName)" : "") — Rated \(report.rating)/5⭐, \(report.setting.rawValue) setting. Read more on TripTalk."
    }
}

struct IntensityBar: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.ttSecondary)
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 6)
                Capsule()
                    .fill(color)
                    .frame(height: 6)
                    .scaleEffect(x: CGFloat(value) / 5.0, anchor: .leading)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) intensity: \(value) out of 5")
    }
}
