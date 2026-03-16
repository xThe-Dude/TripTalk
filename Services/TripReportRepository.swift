import Foundation

struct TripReportRepository {
    private let client = SupabaseClient.shared

    func fetchForStrain(_ strainId: UUID) async throws -> [TripReport] {
        let dbReports: [DBTripReport] = try await client.get("trip_reports", query: [
            "strain_id": "eq.\(strainId.uuidString)",
            "is_removed": "eq.false",
            "order": "created_at.desc",
            "select": "*"
        ])
        return dbReports.map { $0.toTripReport() }
    }

    func create(_ insert: TripReportInsert) async throws {
        let _ = try await client.post("trip_reports", body: insert)
    }
}
