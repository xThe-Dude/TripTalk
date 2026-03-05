import SwiftUI

// MARK: - Original Enums (kept for backward compat)

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

// MARK: - New Strain-Related Enums

enum SubstanceType: String, CaseIterable, Identifiable {
    case psilocybin = "Psilocybin"
    case ayahuasca = "Ayahuasca"
    case mescaline = "Mescaline"
    case lsd = "LSD"
    case mdma = "MDMA"
    case ketamine = "Ketamine"
    case other = "Other"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .psilocybin: return "leaf.fill"
        case .ayahuasca: return "drop.fill"
        case .mescaline: return "sun.max.fill"
        case .lsd: return "diamond.fill"
        case .mdma: return "heart.circle.fill"
        case .ketamine: return "waveform.path.ecg"
        case .other: return "sparkle"
        }
    }

    var color: Color {
        switch self {
        case .psilocybin: return .green
        case .ayahuasca: return .purple
        case .mescaline: return .orange
        case .lsd: return .blue
        case .mdma: return .pink
        case .ketamine: return .teal
        case .other: return .gray
        }
    }
}

enum Potency: String, CaseIterable, Identifiable {
    case mild = "Mild"
    case moderate = "Moderate"
    case strong = "Strong"
    case veryStrong = "Very Strong"

    var id: String { rawValue }

    var level: Int {
        switch self {
        case .mild: return 1
        case .moderate: return 2
        case .strong: return 3
        case .veryStrong: return 4
        }
    }

    var color: Color {
        switch self {
        case .mild: return .green
        case .moderate: return .yellow
        case .strong: return .orange
        case .veryStrong: return .red
        }
    }
}

enum BodyFeel: String, CaseIterable, Identifiable {
    case warm = "Warm"
    case heavy = "Heavy"
    case tingly = "Tingly"
    case light = "Light"
    case energetic = "Energetic"
    case relaxed = "Relaxed"

    var id: String { rawValue }
}

enum EmotionalTag: String, CaseIterable, Identifiable {
    case calm = "Calm"
    case giggly = "Giggly"
    case profound = "Profound"
    case anxious = "Anxious"
    case euphoric = "Euphoric"
    case loving = "Loving"
    case introspective = "Introspective"

    var id: String { rawValue }
}

enum TripSetting: String, CaseIterable, Identifiable {
    case nature = "Nature"
    case home = "Home"
    case ceremony = "Ceremony"
    case social = "Social"
    case festival = "Festival"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .nature: return "leaf.fill"
        case .home: return "house.fill"
        case .ceremony: return "flame.fill"
        case .social: return "person.3.fill"
        case .festival: return "music.note"
        }
    }
}

enum ExperienceType: String, CaseIterable, Identifiable {
    case visual = "Visual"
    case physical = "Physical"
    case emotional = "Emotional"
    case spiritual = "Spiritual"

    var id: String { rawValue }
}

enum MoodTag: String, CaseIterable, Identifiable {
    case euphoric = "Euphoric"
    case calm = "Calm"
    case anxious = "Anxious"
    case giggly = "Giggly"
    case profound = "Profound"
    case peaceful = "Peaceful"
    case energetic = "Energetic"
    case loving = "Loving"

    var id: String { rawValue }
}

enum Difficulty: String, CaseIterable, Identifiable {
    case beginner = "Beginner Friendly"
    case intermediate = "Intermediate"
    case experienced = "Experienced"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .experienced: return .red
        }
    }
}
