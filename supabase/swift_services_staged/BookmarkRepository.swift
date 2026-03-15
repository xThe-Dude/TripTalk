import Foundation
import Supabase

struct BookmarkRepository {
    private let client = SupabaseManager.client

    func fetchAll(userId: UUID) async throws -> [DBBookmark] {
        try await client.from("bookmarks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func toggle(userId: UUID, strainId: UUID) async throws {
        let existing: [DBBookmark] = try await client.from("bookmarks")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("strain_id", value: strainId.uuidString)
            .execute()
            .value

        if existing.isEmpty {
            let insert = ["user_id": userId.uuidString, "strain_id": strainId.uuidString]
            try await client.from("bookmarks")
                .insert(insert)
                .execute()
        } else {
            try await client.from("bookmarks")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("strain_id", value: strainId.uuidString)
                .execute()
        }
    }
}
