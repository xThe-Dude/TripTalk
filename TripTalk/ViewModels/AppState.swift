import SwiftUI

@Observable
class AppState {
    var substances: [Substance] = MockData.substances
    var services: [ServiceCenter] = MockData.services
    var reviews: [Review] = MockData.reviews

    var savedSubstanceIDs: Set<UUID> = []
    var savedServiceIDs: Set<UUID> = []
    var userReviews: [Review] = []

    var selectedJurisdiction: Jurisdiction = .colorado

    // Catalog filters
    var catalogSearchText: String = ""
    var catalogCategoryFilter: SubstanceCategory? = nil
    var catalogEffectFilter: EffectTag? = nil

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

    func reviewsFor(substance id: UUID) -> [Review] {
        reviews.filter { $0.substanceID == id }.sorted { $0.date > $1.date }
    }

    func reviewsFor(service id: UUID) -> [Review] {
        reviews.filter { $0.serviceID == id }.sorted { $0.date > $1.date }
    }

    func addReview(_ review: Review) {
        reviews.insert(review, at: 0)
        userReviews.insert(review, at: 0)
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
}
