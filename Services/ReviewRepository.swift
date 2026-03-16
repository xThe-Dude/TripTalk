import Foundation

struct ReviewRepository {
    private let client = SupabaseClient.shared

    func fetchForStrain(_ strainId: UUID) async throws -> [Review] {
        let dbReviews: [DBReview] = try await client.get("reviews", query: [
            "strain_id": "eq.\(strainId.uuidString)",
            "is_removed": "eq.false",
            "order": "created_at.desc",
            "select": "*"
        ])
        return dbReviews.map { $0.toReview() }
    }

    func fetchForService(_ serviceId: UUID) async throws -> [Review] {
        let dbReviews: [DBReview] = try await client.get("reviews", query: [
            "service_id": "eq.\(serviceId.uuidString)",
            "is_removed": "eq.false",
            "order": "created_at.desc",
            "select": "*"
        ])
        return dbReviews.map { $0.toReview() }
    }

    func fetchAll() async throws -> [Review] {
        let dbReviews: [DBReview] = try await client.get("reviews", query: [
            "is_removed": "eq.false",
            "order": "created_at.desc",
            "limit": "50",
            "select": "*"
        ])
        return dbReviews.map { $0.toReview() }
    }

    func create(_ insert: ReviewInsert) async throws {
        let _ = try await client.post("reviews", body: insert)
    }

    func markHelpful(_ reviewId: UUID) async throws {
        try await client.rpc("increment_helpful", params: ["p_review_id": reviewId.uuidString])
    }
}
