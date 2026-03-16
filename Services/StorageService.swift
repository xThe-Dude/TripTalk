import Foundation

struct StorageService {
    private let client = SupabaseClient.shared

    func uploadAvatar(userId: UUID, imageData: Data) async throws -> String {
        let path = "\(userId.uuidString)/avatar.jpg"
        return try await client.uploadFile(bucket: "avatars", path: path, data: imageData)
    }

    func uploadCommunityPhoto(userId: UUID, strainId: UUID, imageData: Data) async throws -> String {
        let fileName = "\(UUID().uuidString).jpg"
        let path = "\(userId.uuidString)/\(fileName)"
        return try await client.uploadFile(bucket: "community-photos", path: path, data: imageData)
    }
}
