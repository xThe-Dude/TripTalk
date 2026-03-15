import Foundation
import Supabase

struct StorageService {
    private let client = SupabaseManager.client

    func uploadAvatar(userId: UUID, imageData: Data) async throws -> String {
        let path = "\(userId.uuidString)/avatar.jpg"
        try await client.storage
            .from("avatars")
            .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg", upsert: true))
        return client.storage.from("avatars").getPublicURL(path: path).absoluteString
    }

    func uploadCommunityPhoto(strainId: UUID, userId: UUID, imageData: Data) async throws -> String {
        let fileName = "\(UUID().uuidString).jpg"
        let path = "\(strainId.uuidString)/\(fileName)"
        try await client.storage
            .from("community-photos")
            .upload(path, data: imageData, options: FileOptions(contentType: "image/jpeg"))
        return client.storage.from("community-photos").getPublicURL(path: path).absoluteString
    }
}
