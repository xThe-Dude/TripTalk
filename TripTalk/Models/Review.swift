import Foundation

struct Review: Identifiable, Hashable, Codable {
    let id: UUID
    let authorName: String
    let rating: Int
    let title: String
    let body: String
    let tags: [EffectTag]
    let date: Date
    let substanceID: UUID?
    let serviceID: UUID?
    var helpfulCount: Int
    var isReported: Bool

    init(id: UUID = UUID(), authorName: String, rating: Int, title: String, body: String, tags: [EffectTag] = [], date: Date = Date(), substanceID: UUID? = nil, serviceID: UUID? = nil, helpfulCount: Int = 0, isReported: Bool = false) {
        self.id = id
        self.authorName = authorName
        self.rating = rating
        self.title = title
        self.body = body
        self.tags = tags
        self.date = date
        self.substanceID = substanceID
        self.serviceID = serviceID
        self.helpfulCount = helpfulCount
        self.isReported = isReported
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Review, rhs: Review) -> Bool { lhs.id == rhs.id }
}
