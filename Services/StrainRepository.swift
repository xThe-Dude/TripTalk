import Foundation

struct StrainRepository {
    private let client = SupabaseClient.shared

    func fetchAll() async throws -> [Strain] {
        let dbStrains: [DBStrain] = try await client.get("strains", query: [
            "is_published": "eq.true",
            "order": "name.asc",
            "select": "*"
        ])
        return dbStrains.map { $0.toStrain() }
    }

    func fetchBySubstance(_ type: SubstanceType) async throws -> [Strain] {
        let dbValue = type.rawValue.lowercased()
        let dbStrains: [DBStrain] = try await client.get("strains", query: [
            "is_published": "eq.true",
            "parent_substance": "eq.\(dbValue)",
            "order": "name.asc",
            "select": "*"
        ])
        return dbStrains.map { $0.toStrain() }
    }
}
