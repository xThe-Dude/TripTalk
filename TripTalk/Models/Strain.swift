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

    var heroImageName: String {
        switch name {
        case "Golden Teachers": return "golden_teachers"
        case "Albino Penis Envy": return "albino_penis_envy"
        case "B+": return "b_plus"
        case "Liberty Caps": return "liberty_caps"
        case "Blue Meanie": return "blue_meanie"
        case "Mazatec": return "mazatec"
        case "Caapi + Chacruna": return "caapi_chacruna"
        case "Caapi + Mimosa": return "caapi_mimosa"
        case "San Pedro": return "san_pedro"
        case "Peyote": return "peyote"
        case "Peruvian Torch": return "peruvian_torch"
        case "IV Infusion": return "ketamine_iv"
        case "Sublingual Troche": return "ketamine_troche"
        case "Nasal Spray (Spravato)": return "ketamine_spravato"
        case "Intramuscular": return "ketamine_im"
        default: return "golden_teachers"
        }
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Strain, rhs: Strain) -> Bool { lhs.id == rhs.id }
}
