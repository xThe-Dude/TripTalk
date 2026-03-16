import Foundation

struct ServiceRepository {
    private let client = SupabaseClient.shared

    func fetchAll() async throws -> [ServiceCenter] {
        let dbServices: [DBServiceCenter] = try await client.get("service_centers", query: [
            "is_published": "eq.true",
            "order": "name.asc",
            "select": "*"
        ])
        return dbServices.map { $0.toServiceCenter() }
    }
}
