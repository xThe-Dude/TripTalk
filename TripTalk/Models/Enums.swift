import Foundation

enum SubstanceCategory: String, CaseIterable, Identifiable, Codable {
    case psychedelic = "Psychedelic"
    case empathogen = "Empathogen"
    case dissociative = "Dissociative"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .psychedelic: return "sparkles"
        case .empathogen: return "heart.fill"
        case .dissociative: return "cloud.fill"
        }
    }
}

enum JurisdictionStatus: String, CaseIterable, Identifiable, Codable {
    case legal = "Legal"
    case decriminalized = "Decriminalized"
    case medicalOnly = "Medical Only"
    case illegal = "Illegal"
    case underReview = "Under Review"

    var id: String { rawValue }

    var color: String {
        switch self {
        case .legal: return "green"
        case .decriminalized: return "yellow"
        case .medicalOnly: return "blue"
        case .illegal: return "red"
        case .underReview: return "orange"
        }
    }
}

enum Jurisdiction: String, CaseIterable, Identifiable, Codable {
    case colorado = "Colorado"
    case oregon = "Oregon"
    case california = "California"
    case national = "United States"

    var id: String { rawValue }
}

enum EffectTag: String, CaseIterable, Identifiable, Codable {
    case euphoria = "Euphoria"
    case visualDistortions = "Visual Distortions"
    case introspection = "Introspection"
    case empathy = "Empathy"
    case relaxation = "Relaxation"
    case energizing = "Energizing"
    case spiritualExperience = "Spiritual Experience"
    case bodyHigh = "Body High"
    case creativity = "Creativity"
    case emotionalRelease = "Emotional Release"
    case dissolution = "Ego Dissolution"
    case synesthesia = "Synesthesia"
    case nausea = "Nausea"
    case anxiety = "Anxiety"
    case dissociation = "Dissociation"

    var id: String { rawValue }
}

enum ReviewSortOption: String, CaseIterable, Identifiable {
    case recent = "Most Recent"
    case highest = "Highest Rated"
    case lowest = "Lowest Rated"

    var id: String { rawValue }
}

enum ExploreSegment: String, CaseIterable, Identifiable {
    case all = "All"
    case substances = "Substances"
    case services = "Services"
    case articles = "Articles"

    var id: String { rawValue }
}
