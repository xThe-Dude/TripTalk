import Foundation
import Supabase

struct TripReportRepository {
    private let client = SupabaseManager.client

    func fetchForStrain(_ strainId: UUID) async throws -> [DBTripReport] {
        try await client.from("trip_reports")
            .select()
            .eq("strain_id", value: strainId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value
    }

    func create(_ report: TripReportInsert) async throws -> DBTripReport {
        try await client.from("trip_reports")
            .insert(report)
            .single()
            .execute()
            .value
    }
}
