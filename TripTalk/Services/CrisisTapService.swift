import Foundation

struct CrisisTapService {
    private let client = SupabaseClient.shared

    /// Fire-and-forget: logs that user tapped a crisis resource.
    /// Never throws — silently fails if network is unavailable.
    func logTap(resource: String) {
        Task {
            do {
                let _ = try await client.post("crisis_taps", body: CrisisTapInsert(resource: resource))
            } catch {
                // Silently fail — never block crisis line access
            }
        }
    }
}
