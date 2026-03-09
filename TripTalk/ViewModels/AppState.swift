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
    var selectedTab: Int = 0

    // MARK: - Persistence Keys
    private let savedStrainIDsKey = "savedStrainIDs"
    private let savedSubstanceIDsKey = "savedSubstanceIDs"
    private let savedServiceIDsKey = "savedServiceIDs"
    private let userTripReportsKey = "userTripReports"
    private let userReviewsKey = "userReviews"
    private let jurisdictionKey = "selectedJurisdiction"

    init() {
        loadPersistedData()
    }

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
        if let offering = servicesOfferingFilter {
            result = result.filter { $0.offerings.contains(offering) }
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
        saveSubstanceIDs()
    }

    func toggleSavedService(_ id: UUID) {
        if savedServiceIDs.contains(id) { savedServiceIDs.remove(id) }
        else { savedServiceIDs.insert(id) }
        saveServiceIDs()
    }

    func toggleSavedStrain(_ id: UUID) {
        if savedStrainIDs.contains(id) { savedStrainIDs.remove(id) }
        else { savedStrainIDs.insert(id) }
        saveStrainIDs()
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
        saveReviews()
    }

    func addTripReport(_ report: TripReport) {
        tripReports.insert(report, at: 0)
        userTripReports.insert(report, at: 0)
        saveTripReports()
    }

    func updateJurisdiction(_ jurisdiction: Jurisdiction) {
        selectedJurisdiction = jurisdiction
        saveJurisdiction()
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

    // MARK: - Persistence

    private func loadPersistedData() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: savedStrainIDsKey),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            savedStrainIDs = ids
        }
        if let data = defaults.data(forKey: savedSubstanceIDsKey),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            savedSubstanceIDs = ids
        }
        if let data = defaults.data(forKey: savedServiceIDsKey),
           let ids = try? JSONDecoder().decode(Set<UUID>.self, from: data) {
            savedServiceIDs = ids
        }
        if let data = defaults.data(forKey: userTripReportsKey),
           let reports = try? JSONDecoder().decode([TripReport].self, from: data) {
            userTripReports = reports
            let existingReportIds = Set(tripReports.map { $0.id })
            for report in reports where !existingReportIds.contains(report.id) {
                tripReports.append(report)
            }
        }
        if let data = defaults.data(forKey: userReviewsKey),
           let loadedReviews = try? JSONDecoder().decode([Review].self, from: data) {
            userReviews = loadedReviews
            let existingReviewIds = Set(reviews.map { $0.id })
            for review in loadedReviews where !existingReviewIds.contains(review.id) {
                reviews.append(review)
            }
        }
        if let raw = defaults.string(forKey: jurisdictionKey),
           let j = Jurisdiction(rawValue: raw) {
            selectedJurisdiction = j
        }
    }

    private func saveStrainIDs() {
        if let data = try? JSONEncoder().encode(savedStrainIDs) { UserDefaults.standard.set(data, forKey: savedStrainIDsKey) }
    }

    private func saveSubstanceIDs() {
        if let data = try? JSONEncoder().encode(savedSubstanceIDs) { UserDefaults.standard.set(data, forKey: savedSubstanceIDsKey) }
    }

    private func saveServiceIDs() {
        if let data = try? JSONEncoder().encode(savedServiceIDs) { UserDefaults.standard.set(data, forKey: savedServiceIDsKey) }
    }

    private func saveTripReports() {
        if let data = try? JSONEncoder().encode(userTripReports) { UserDefaults.standard.set(data, forKey: userTripReportsKey) }
    }

    private func saveReviews() {
        if let data = try? JSONEncoder().encode(userReviews) { UserDefaults.standard.set(data, forKey: userReviewsKey) }
    }

    private func saveJurisdiction() {
        UserDefaults.standard.set(selectedJurisdiction.rawValue, forKey: jurisdictionKey)
    }
}
