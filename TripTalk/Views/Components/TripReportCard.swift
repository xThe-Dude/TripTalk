import SwiftUI

struct TripReportCard: View {
    let report: TripReport
    var strainName: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 1) {
                    Text(report.authorName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(report.date, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                RatingStars(rating: Double(report.rating), size: 12)
            }

            if !strainName.isEmpty {
                Text(strainName)
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundStyle(.secondary)
            }

            // Setting + mood pills
            HStack(spacing: 4) {
                Label(report.setting.rawValue, systemImage: report.setting.icon)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())

                ForEach(report.moods.prefix(2)) { mood in
                    Text(mood.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }

            // Intensity bars
            HStack(spacing: 12) {
                IntensityBar(label: "Visual", value: report.visualIntensity, color: .purple)
                IntensityBar(label: "Body", value: report.bodyIntensity, color: .green)
                IntensityBar(label: "Emotion", value: report.emotionalIntensity, color: .pink)
            }

            Text(report.highlights)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(3)

            if report.wouldRepeat {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.trianglehead.2.counterclockwise")
                        .font(.caption2)
                    Text("Would repeat")
                        .font(.caption2)
                }
                .foregroundStyle(.green)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct IntensityBar: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 5.0)
                }
            }
            .frame(height: 4)
        }
    }
}
