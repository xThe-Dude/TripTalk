import Foundation

extension DBStrain {
    func toStrain() -> Strain {
        Strain(
            id: id,
            name: name,
            parentSubstance: SubstanceType(rawValue: parentSubstance.capitalized) ?? .other,
            species: species,
            potency: mapPotency(potency),
            description: description,
            commonEffects: commonEffects.compactMap { EffectTag(rawValue: $0) },
            bodyFeel: bodyFeel.compactMap { BodyFeel(rawValue: $0) },
            emotionalProfile: emotionalProfile.compactMap { EmotionalTag(rawValue: $0) },
            onset: onset,
            duration: duration,
            difficulty: mapDifficulty(difficulty),
            averageRating: 0, // TODO: join with strain_stats
            reviewCount: 0,
            communityPhotoCount: 0
        )
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
}
