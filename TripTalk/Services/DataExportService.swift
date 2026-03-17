import Foundation

/// Exports all user data as a JSON file for privacy compliance.
enum DataExportService {

    struct UserDataExport: Codable {
        let exportDate: Date
        let profile: ProfileExport?
        let reviews: [ReviewExport]
        let tripReports: [TripReportExport]
        let bookmarkedStrainIds: [UUID]
        let bookmarkedSubstanceIds: [UUID]
        let bookmarkedServiceIds: [UUID]
    }

    struct ProfileExport: Codable {
        let displayName: String
        let bio: String?
        let experienceLevel: String?
        let joinedAt: Date
    }

    struct ReviewExport: Codable {
        let id: UUID
        let rating: Int
        let title: String
        let body: String
        let tags: [String]
        let date: Date
    }

    struct TripReportExport: Codable {
        let id: UUID
        let strainId: UUID
        let rating: Int
        let setting: String
        let intention: String
        let highlights: String
        let safetyNotes: String
        let moods: [String]
        let visualIntensity: Int
        let bodyIntensity: Int
        let emotionalIntensity: Int
        let wouldRepeat: Bool
        let date: Date
    }

    @MainActor
    static func exportUserData(from appState: AppState) -> Data? {
        let profile: ProfileExport? = appState.auth.profile.map {
            ProfileExport(
                displayName: $0.displayName,
                bio: $0.bio,
                experienceLevel: $0.experienceLevel,
                joinedAt: $0.joinedAt
            )
        }

        let reviews = appState.userReviews.map {
            ReviewExport(
                id: $0.id,
                rating: $0.rating,
                title: $0.title,
                body: $0.body,
                tags: $0.tags.map(\.rawValue),
                date: $0.date
            )
        }

        let reports = appState.userTripReports.map {
            TripReportExport(
                id: $0.id,
                strainId: $0.strainId,
                rating: $0.rating,
                setting: $0.setting.rawValue,
                intention: $0.intention,
                highlights: $0.highlights,
                safetyNotes: $0.safetyNotes,
                moods: $0.moods.map(\.rawValue),
                visualIntensity: $0.visualIntensity,
                bodyIntensity: $0.bodyIntensity,
                emotionalIntensity: $0.emotionalIntensity,
                wouldRepeat: $0.wouldRepeat,
                date: $0.date
            )
        }

        let export = UserDataExport(
            exportDate: Date(),
            profile: profile,
            reviews: reviews,
            tripReports: reports,
            bookmarkedStrainIds: Array(appState.savedStrainIDs),
            bookmarkedSubstanceIds: Array(appState.savedSubstanceIDs),
            bookmarkedServiceIds: Array(appState.savedServiceIDs)
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(export)
    }

    static func exportFileURL() -> URL {
        let dateStr = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        return FileManager.default.temporaryDirectory
            .appendingPathComponent("TripTalk-Export-\(dateStr).json")
    }
}
