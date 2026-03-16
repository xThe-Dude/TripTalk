import Foundation

struct BookmarkRepository {
    private let client = SupabaseClient.shared

    func fetchAll(userId: UUID) async throws -> Set<UUID> {
        let bookmarks: [DBBookmark] = try await client.get("bookmarks", query: [
            "user_id": "eq.\(userId.uuidString)",
            "select": "id,user_id,strain_id,created_at"
        ])
        return Set(bookmarks.map(\.strainId))
    }

    func add(userId: UUID, strainId: UUID) async throws {
        struct BookmarkInsert: Codable {
            let userId: UUID
            let strainId: UUID
        }
        let _ = try await client.post("bookmarks", body: BookmarkInsert(userId: userId, strainId: strainId))
    }

    func remove(userId: UUID, strainId: UUID) async throws {
        try await client.delete("bookmarks", query: [
            "user_id": "eq.\(userId.uuidString)",
            "strain_id": "eq.\(strainId.uuidString)"
        ])
    }
}
