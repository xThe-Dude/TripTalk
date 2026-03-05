import Foundation

struct Strain: Identifiable, Hashable {
    let id: UUID
    let name: String
    let parentSubstance: SubstanceType
    let species: String
    let potency: Potency
    let description: String
    let commonEffects: [EffectTag]
    let bodyFeel: [BodyFeel]
    let emotionalProfile: [EmotionalTag]
    let onset: String
    let duration: String
    let difficulty: Difficulty
    let averageRating: Double
    let reviewCount: Int
    let communityPhotoCount: Int

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Strain, rhs: Strain) -> Bool { lhs.id == rhs.id }
}
