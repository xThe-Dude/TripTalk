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
    var averageRating: Double
    var reviewCount: Int
    var communityPhotoCount: Int

    var heroImageName: String {
        switch name {
        // Original strains
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
        // New psilocybin strains
        case "Penis Envy": return "penis_envy"
        case "AA+": return "aa_plus"
        case "African Transkei": return "african_transkei"
        case "Alacabenzi": return "alacabenzi"
        case "Amazon": return "amazon"
        case "Avery's Albino": return "averys_albino"
        case "Ecuadorian": return "ecuadorian"
        case "Enigma": return "enigma"
        case "Hillbilly": return "hillbilly"
        case "Jack Frost": return "jack_frost"
        case "Jedi Mind Fuck": return "jedi_mind_fuck"
        case "Koh Samui Super Strain": return "koh_samui_super_strain"
        case "Malabar Coast": return "malabar_coast"
        case "Orissa India": return "orissa_india"
        case "PES Hawaiian": return "pes_hawaiian"
        case "PF Classic": return "pf_classic"
        case "Tidal Wave": return "tidal_wave"
        case "Thai Elephant Dung": return "thai_elephant_dung"
        case "Texas Yellow Cap": return "texas_yellow_cap"
        case "White Rabbit": return "white_rabbit"
        case "APE Revert": return "ape_revert"
        case "Blue Magnolia": return "blue_magnolia"
        case "Stargazer": return "stargazer"
        case "Golden Halo": return "golden_halo"
        case "Trinity": return "trinity"
        case "Corumba Brazil": return "corumba_brazil"
        case "Mexican": return "mexican"
        case "Melmak": return "melmak"
        case "Great White Monster": return "great_white_monster"
        case "Rusty Whyte": return "rusty_whyte"
        case "Natal Super Strength": return "natal_super_strength"
        default: return "golden_teachers"
        }
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Strain, rhs: Strain) -> Bool { lhs.id == rhs.id }
}
