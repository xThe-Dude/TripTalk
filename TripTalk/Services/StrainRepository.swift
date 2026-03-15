import Foundation
import Supabase

struct StrainRepository {
    private let client = SupabaseManager.client

    func fetchAll() async throws -> [DBStrain] {
        try await client.from("strains")
            .select()
            .eq("is_published", value: true)
            .order("name")
            .execute()
            .value
    }

    func fetchBySubstance(_ type: String) async throws -> [DBStrain] {
        try await client.from("strains")
            .select()
            .eq("is_published", value: true)
            .eq("parent_substance", value: type)
            .execute()
            .value
    }
}
