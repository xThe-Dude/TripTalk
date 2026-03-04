import Foundation

struct ServiceCenter: Identifiable, Hashable {
    let id: UUID
    let name: String
    let city: String
    let state: String
    let address: String
    let about: String
    let offerings: [String]
    let isVerified: Bool
    let averageRating: Double
    let reviewCount: Int
    let distanceMiles: Int
    let imageSymbol: String

    init(id: UUID = UUID(), name: String, city: String, state: String, address: String, about: String, offerings: [String], isVerified: Bool, averageRating: Double, reviewCount: Int, distanceMiles: Int, imageSymbol: String) {
        self.id = id
        self.name = name
        self.city = city
        self.state = state
        self.address = address
        self.about = about
        self.offerings = offerings
        self.isVerified = isVerified
        self.averageRating = averageRating
        self.reviewCount = reviewCount
        self.distanceMiles = distanceMiles
        self.imageSymbol = imageSymbol
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ServiceCenter, rhs: ServiceCenter) -> Bool { lhs.id == rhs.id }

    var locationString: String { "\(city), \(state)" }
}
