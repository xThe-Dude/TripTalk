import Foundation

struct DBProfile: Codable, Identifiable {
    let id: UUID
    var displayName: String
    var avatarUrl: String?
    var bio: String?
    var experienceLevel: String?
    let joinedAt: Date
    var isBanned: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case bio
        case experienceLevel = "experience_level"
        case joinedAt = "joined_at"
        case isBanned = "is_banned"
    }
}

struct DBStrain: Codable, Identifiable {
    let id: UUID
    let name: String
    let parentSubstance: String
    let species: String
    let potency: String
    let description: String
    let commonEffects: [String]
    let bodyFeel: [String]
    let emotionalProfile: [String]
    let onset: String
    let duration: String
    let difficulty: String
    let heroImageUrl: String?
    let isPublished: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, species, potency, description, onset, duration, difficulty
        case parentSubstance = "parent_substance"
        case commonEffects = "common_effects"
        case bodyFeel = "body_feel"
        case emotionalProfile = "emotional_profile"
        case heroImageUrl = "hero_image_url"
        case isPublished = "is_published"
    }
}

struct DBReview: Codable, Identifiable {
    let id: UUID
    let authorId: UUID
    let strainId: UUID?
    let serviceId: UUID?
    let rating: Int
    let title: String
    let body: String
    let tags: [String]
    var helpfulCount: Int
    var isReported: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, rating, title, body, tags
        case authorId = "author_id"
        case strainId = "strain_id"
        case serviceId = "service_id"
        case helpfulCount = "helpful_count"
        case isReported = "is_reported"
        case createdAt = "created_at"
    }
}

struct DBTripReport: Codable, Identifiable {
    let id: UUID
    let authorId: UUID
    let strainId: UUID
    let rating: Int
    let setting: String
    let intention: String?
    let experienceTypes: [String]
    let visualIntensity: Int
    let bodyIntensity: Int
    let emotionalIntensity: Int
    let moods: [String]
    let highlights: String
    let safetyNotes: String?
    let wouldRepeat: Bool
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, rating, setting, intention, highlights, moods
        case authorId = "author_id"
        case strainId = "strain_id"
        case experienceTypes = "experience_types"
        case visualIntensity = "visual_intensity"
        case bodyIntensity = "body_intensity"
        case emotionalIntensity = "emotional_intensity"
        case safetyNotes = "safety_notes"
        case wouldRepeat = "would_repeat"
        case createdAt = "created_at"
    }
}

struct DBBookmark: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let strainId: UUID
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case strainId = "strain_id"
        case createdAt = "created_at"
    }
}

// Insert structs (for creating new records)
struct ReviewInsert: Codable {
    let authorId: UUID
    let strainId: UUID?
    let serviceId: UUID?
    let rating: Int
    let title: String
    let body: String
    let tags: [String]

    enum CodingKeys: String, CodingKey {
        case rating, title, body, tags
        case authorId = "author_id"
        case strainId = "strain_id"
        case serviceId = "service_id"
    }
}

struct TripReportInsert: Codable {
    let authorId: UUID
    let strainId: UUID
    let rating: Int
    let setting: String
    let intention: String?
    let experienceTypes: [String]
    let visualIntensity: Int
    let bodyIntensity: Int
    let emotionalIntensity: Int
    let moods: [String]
    let highlights: String
    let safetyNotes: String?
    let wouldRepeat: Bool

    enum CodingKeys: String, CodingKey {
        case rating, setting, intention, highlights, moods
        case authorId = "author_id"
        case strainId = "strain_id"
        case experienceTypes = "experience_types"
        case visualIntensity = "visual_intensity"
        case bodyIntensity = "body_intensity"
        case emotionalIntensity = "emotional_intensity"
        case safetyNotes = "safety_notes"
        case wouldRepeat = "would_repeat"
    }
}
