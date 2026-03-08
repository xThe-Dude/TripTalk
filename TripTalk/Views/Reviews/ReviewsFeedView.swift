import SwiftUI

struct ReviewsFeedView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedEffectFilter: EffectTag? = nil

    var filteredReviews: [Review] {
        var result = appState.sortedReviews
        if let effect = selectedEffectFilter {
            result = result.filter { $0.tags.contains(effect) }
        }
        return result
    }

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    // Sort
                    Picker("Sort", selection: $state.reviewSortOption) {
                        ForEach(ReviewSortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(Color.ttAccent)
                    .padding(.horizontal)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            TagChip(text: "All", isSelected: selectedEffectFilter == nil)
                                .onTapGesture { Haptics.selection(); selectedEffectFilter = nil }
                            ForEach([EffectTag.spiritualExperience, .introspection, .euphoria, .creativity, .empathy]) { tag in
                                TagChip(text: tag.rawValue, isSelected: selectedEffectFilter == tag)
                                    .onTapGesture { Haptics.selection(); selectedEffectFilter = tag }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Reviews
                    LazyVStack(spacing: 10) {
                        ForEach(Array(filteredReviews.enumerated()), id: \.element.id) { index, review in
                            ReviewCard(
                                review: review,
                                onHelpful: { appState.toggleHelpful(review.id) },
                                onReport: { appState.reportReview(review.id) }
                            )
                            .animateIn(delay: min(Double(index) * 0.03, 0.3))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background { GradientBackground() }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationTitle("Reviews")
        }
    }
}
