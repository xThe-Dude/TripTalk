import Foundation

/// Client-side block list. Blocked users' content is filtered out locally.
/// No server-side table needed for v1 — stored in UserDefaults.
@Observable
@MainActor
class BlockService {
    static let shared = BlockService()

    private let storageKey = "blocked_user_ids"
    var blockedUserIDs: Set<UUID> = []

    private init() {
        load()
    }

    func isBlocked(_ userId: UUID) -> Bool {
        blockedUserIDs.contains(userId)
    }

    func block(_ userId: UUID) {
        blockedUserIDs.insert(userId)
        save()
    }

    func unblock(_ userId: UUID) {
        blockedUserIDs.remove(userId)
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) else { return }
        blockedUserIDs = ids
    }

    private func save() {
        if let data = try? JSONEncoder().encode(blockedUserIDs) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
