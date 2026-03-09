import Foundation

struct TripReport: Identifiable, Hashable, Codable {
    let id: UUID
    let strainId: UUID
    let rating: Int
    let setting: TripSetting
    let intention: String
    let experienceTypes: [ExperienceType]
    let visualIntensity: Int
    let bodyIntensity: Int
    let emotionalIntensity: Int
    let moods: [MoodTag]
    let highlights: String
    let safetyNotes: String
    let wouldRepeat: Bool
    let authorName: String
    let date: Date

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: TripReport, rhs: TripReport) -> Bool { lhs.id == rhs.id }
}
