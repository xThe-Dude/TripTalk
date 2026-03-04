import Foundation

struct Substance: Identifiable, Hashable {
    let id: UUID
    let name: String
    let category: SubstanceCategory
    let about: String
    let effects: [EffectTag]
    let safetyNotes: [String]
    let jurisdictionStatuses: [Jurisdiction: JurisdictionStatus]
    let averageRating: Double
    let reviewCount: Int
    let imageSymbol: String

    init(id: UUID = UUID(), name: String, category: SubstanceCategory, about: String, effects: [EffectTag], safetyNotes: [String], jurisdictionStatuses: [Jurisdiction: JurisdictionStatus], averageRating: Double, reviewCount: Int, imageSymbol: String) {
        self.id = id
        self.name = name
        self.category = category
        self.about = about
        self.effects = effects
        self.safetyNotes = safetyNotes
        self.jurisdictionStatuses = jurisdictionStatuses
        self.averageRating = averageRating
        self.reviewCount = reviewCount
        self.imageSymbol = imageSymbol
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Substance, rhs: Substance) -> Bool { lhs.id == rhs.id }

    func statusFor(_ jurisdiction: Jurisdiction) -> JurisdictionStatus {
        jurisdictionStatuses[jurisdiction] ?? .illegal
    }
}
