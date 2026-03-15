import Foundation
import Supabase

struct ReviewRepository {
    private let client = SupabaseManager.client

    func fetchForStrain(_ strainId: UUID) async throws -> [DBReview] {
        try await client.from("reviews")
            .select()
            .eq("strain_id", value: strainId.uuidString)
            .eq("is_reported", value: false)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func create(_ review: ReviewInsert) async throws -> DBReview {
        try await client.from("reviews")
            .insert(review)
            .single()
            .execute()
            .value
    }

    func markHelpful(_ reviewId: UUID) async throws {
        try await client.rpc(
            "increment_helpful_count",
            params: ["review_id": reviewId.uuidString]
        )
        .execute()
    }
}
