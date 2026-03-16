import Foundation

// MARK: - Database Row Types (match Supabase snake_case via .convertFromSnakeCase)

struct DBProfile: Codable {
    let id: UUID
    let displayName: String
    let avatarUrl: String?
    let bio: String?
    let experienceLevel: String?
    let joinedAt: Date
    let isBanned: Bool
    let reportCount: Int
}

struct DBStrain: Codable {
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
    let createdAt: Date
    let updatedAt: Date
}

struct DBReview: Codable {
    let id: UUID
    let authorId: UUID
    let strainId: UUID?
    let serviceId: UUID?
    let rating: Int
    let title: String
    let body: String
    let tags: [String]
    let helpfulCount: Int
    let isReported: Bool
    let isRemoved: Bool
    let removedReason: String?
    let createdAt: Date
    let updatedAt: Date
}

struct DBTripReport: Codable {
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
    let isReported: Bool
    let isRemoved: Bool
    let removedReason: String?
    let createdAt: Date
}

struct DBServiceCenter: Codable {
    let id: UUID
    let name: String
    let city: String
    let state: String
    let address: String
    let about: String
    let offerings: [String]
    let isVerified: Bool
    let latitude: Double?
    let longitude: Double?
    let websiteUrl: String?
    let phone: String?
    let imageSymbol: String
    let isPublished: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct DBBookmark: Codable {
    let id: UUID
    let userId: UUID
    let strainId: UUID
    let createdAt: Date
}

// MARK: - Insert Types

struct ReviewInsert: Codable {
    let authorId: UUID
    let strainId: UUID?
    let serviceId: UUID?
    let rating: Int
    let title: String
    let body: String
    let tags: [String]
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
}

struct ContentReportInsert: Codable {
    let reporterId: UUID
    let reviewId: UUID?
    let tripReportId: UUID?
    let reason: String
    let details: String?
}

struct CrisisTapInsert: Codable {
    let resource: String
}

struct ProfileUpdate: Codable {
    let displayName: String?
    let bio: String?
    let avatarUrl: String?
    let experienceLevel: String?
}

// MARK: - Converters

extension DBStrain {
    func toStrain() -> Strain {
        Strain(
            id: id,
            name: name,
            parentSubstance: SubstanceType(rawValue: mapSubstanceRaw(parentSubstance)) ?? .other,
            species: species,
            potency: mapPotency(potency),
            description: description,
            commonEffects: commonEffects.compactMap { matchEffect($0) },
            bodyFeel: bodyFeel.compactMap { BodyFeel(rawValue: $0.capitalized) },
            emotionalProfile: emotionalProfile.compactMap { EmotionalTag(rawValue: $0.capitalized) },
            onset: onset,
            duration: duration,
            difficulty: mapDifficulty(difficulty),
            averageRating: 0,
            reviewCount: 0,
            communityPhotoCount: 0
        )
    }

    private func mapSubstanceRaw(_ s: String) -> String {
        switch s {
        case "psilocybin": return "Psilocybin"
        case "ayahuasca": return "Ayahuasca"
        case "mescaline": return "Mescaline"
        case "ketamine": return "Ketamine"
        default: return "Other"
        }
    }

    private func mapPotency(_ s: String) -> Potency {
        switch s {
        case "mild": return .mild
        case "moderate": return .moderate
        case "strong": return .strong
        case "very_strong": return .veryStrong
        default: return .moderate
        }
    }

    private func mapDifficulty(_ s: String) -> Difficulty {
        switch s {
        case "beginner": return .beginner
        case "intermediate": return .intermediate
        case "experienced": return .experienced
        default: return .intermediate
        }
    }

    private func matchEffect(_ s: String) -> EffectTag? {
        // Try direct match first
        if let tag = EffectTag(rawValue: s) { return tag }
        // Try capitalized
        if let tag = EffectTag(rawValue: s.capitalized) { return tag }
        // Try mapping common DB values
        let lower = s.lowercased()
        for tag in EffectTag.allCases {
            if tag.rawValue.lowercased() == lower { return tag }
        }
        return nil
    }
}

extension DBReview {
    func toReview() -> Review {
        Review(
            id: id,
            authorName: "Community Member",
            rating: rating,
            title: title,
            body: body,
            tags: tags.compactMap { EffectTag(rawValue: $0) },
            date: createdAt,
            substanceID: strainId,
            serviceID: serviceId,
            helpfulCount: helpfulCount,
            isReported: isReported
        )
    }
}

extension DBTripReport {
    func toTripReport() -> TripReport {
        TripReport(
            id: id,
            strainId: strainId,
            rating: rating,
            setting: TripSetting(rawValue: setting.capitalized) ?? .home,
            intention: intention ?? "",
            experienceTypes: experienceTypes.compactMap { ExperienceType(rawValue: $0.capitalized) },
            visualIntensity: visualIntensity,
            bodyIntensity: bodyIntensity,
            emotionalIntensity: emotionalIntensity,
            moods: moods.compactMap { MoodTag(rawValue: $0.capitalized) },
            highlights: highlights,
            safetyNotes: safetyNotes ?? "",
            wouldRepeat: wouldRepeat,
            authorName: "Community Member",
            date: createdAt
        )
    }
}

extension DBServiceCenter {
    func toServiceCenter() -> ServiceCenter {
        ServiceCenter(
            id: id,
            name: name,
            city: city,
            state: state,
            address: address,
            about: about,
            offerings: offerings,
            isVerified: isVerified,
            averageRating: 0,
            reviewCount: 0,
            distanceMiles: 0,
            imageSymbol: imageSymbol
        )
    }
}
