import SwiftUI

@Observable
class AppState {
    var substances: [Substance] = MockData.substances
    var services: [ServiceCenter] = MockData.services
    var reviews: [Review] = MockData.reviews
    var strains: [Strain] = MockData.strains
    var tripReports: [TripReport] = MockData.tripReports

    var savedSubstanceIDs: Set<UUID> = []
    var savedServiceIDs: Set<UUID> = []
    var savedStrainIDs: Set<UUID> = []
    var userReviews: [Review] = []
    var userTripReports: [TripReport] = []

    var selectedJurisdiction: Jurisdiction = .colorado

    // Catalog filters
    var catalogSearchText: String = ""
    var catalogCategoryFilter: SubstanceCategory? = nil
    var catalogEffectFilter: EffectTag? = nil
    var catalogSubstanceTypeFilter: SubstanceType? = nil
    var catalogPotencyFilter: Potency? = nil
    var catalogDifficultyFilter: Difficulty? = nil

    // Services filters
    var servicesSearchText: String = ""
    var servicesOfferingFilter: String? = nil

    // Reviews
    var reviewSortOption: ReviewSortOption = .recent

    var filteredSubstances: [Substance] {
        var result = substances
        if !catalogSearchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(catalogSearchText) }
        }
        if let cat = catalogCategoryFilter {
            result = result.filter { $0.category == cat }
        }
        if let effect = catalogEffectFilter {
            result = result.filter { $0.effects.contains(effect) }
        }
        return result
    }

    var filteredStrains: [Strain] {
        var result = strains
        if !catalogSearchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(catalogSearchText) }
        }
        if let st = catalogSubstanceTypeFilter {
            result = result.filter { $0.parentSubstance == st }
        }
        if let p = catalogPotencyFilter {
            result = result.filter { $0.potency == p }
        }
        if let d = catalogDifficultyFilter {
            result = result.filter { $0.difficulty == d }
        }
        if let effect = catalogEffectFilter {
            result = result.filter { $0.commonEffects.contains(effect) }
        }
        return result
    }

    var filteredServices: [ServiceCenter] {
        var result = services
        if !servicesSearchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(servicesSearchText) || $0.city.localizedCaseInsensitiveContains(servicesSearchText) }
        }
        return result
    }

    var sortedReviews: [Review] {
        switch reviewSortOption {
        case .recent: return reviews.sorted { $0.date > $1.date }
        case .highest: return reviews.sorted { $0.rating > $1.rating }
        case .lowest: return reviews.sorted { $0.rating < $1.rating }
        }
    }

    func toggleSavedSubstance(_ id: UUID) {
        if savedSubstanceIDs.contains(id) { savedSubstanceIDs.remove(id) }
        else { savedSubstanceIDs.insert(id) }
    }

    func toggleSavedService(_ id: UUID) {
        if savedServiceIDs.contains(id) { savedServiceIDs.remove(id) }
        else { savedServiceIDs.insert(id) }
    }

    func toggleSavedStrain(_ id: UUID) {
        if savedStrainIDs.contains(id) { savedStrainIDs.remove(id) }
        else { savedStrainIDs.insert(id) }
    }

    func reviewsFor(substance id: UUID) -> [Review] {
        reviews.filter { $0.substanceID == id }.sorted { $0.date > $1.date }
    }

    func reviewsFor(service id: UUID) -> [Review] {
        reviews.filter { $0.serviceID == id }.sorted { $0.date > $1.date }
    }

    func tripReportsFor(strain id: UUID) -> [TripReport] {
        tripReports.filter { $0.strainId == id }.sorted { $0.date > $1.date }
    }

    func strainsFor(substanceType: SubstanceType) -> [Strain] {
        strains.filter { $0.parentSubstance == substanceType }
    }

    func averageIntensities(for strainId: UUID) -> (visual: Double, body: Double, emotional: Double) {
        let reports = tripReportsFor(strain: strainId)
        guard !reports.isEmpty else { return (0, 0, 0) }
        let count = Double(reports.count)
        return (
            reports.map { Double($0.visualIntensity) }.reduce(0, +) / count,
            reports.map { Double($0.bodyIntensity) }.reduce(0, +) / count,
            reports.map { Double($0.emotionalIntensity) }.reduce(0, +) / count
        )
    }

    func addReview(_ review: Review) {
        reviews.insert(review, at: 0)
        userReviews.insert(review, at: 0)
    }

    func addTripReport(_ report: TripReport) {
        tripReports.insert(report, at: 0)
        userTripReports.insert(report, at: 0)
    }

    func toggleHelpful(_ reviewID: UUID) {
        if let idx = reviews.firstIndex(where: { $0.id == reviewID }) {
            reviews[idx].helpfulCount += 1
        }
    }

    func reportReview(_ reviewID: UUID) {
        if let idx = reviews.firstIndex(where: { $0.id == reviewID }) {
            reviews[idx].isReported = true
        }
    }

    func resetCatalogFilters() {
        catalogSubstanceTypeFilter = nil
        catalogPotencyFilter = nil
        catalogDifficultyFilter = nil
        catalogEffectFilter = nil
        catalogSearchText = ""
    }
}
