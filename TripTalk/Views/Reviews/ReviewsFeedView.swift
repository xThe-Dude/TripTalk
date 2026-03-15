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
                                .accessibilityHint(selectedEffectFilter == nil ? "Double-tap to deselect" : "Double-tap to select")
                            ForEach([EffectTag.spiritualExperience, .introspection, .euphoria, .creativity, .empathy]) { tag in
                                TagChip(text: tag.rawValue, isSelected: selectedEffectFilter == tag)
                                    .onTapGesture { Haptics.selection(); selectedEffectFilter = tag }
                                    .accessibilityHint(selectedEffectFilter == tag ? "Double-tap to deselect" : "Double-tap to select")
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Reviews
                    LazyVStack(spacing: 10) {
                        ForEach(filteredReviews) { review in
                            ReviewCard(
                                review: review,
                                onHelpful: { appState.toggleHelpful(review.id) },
                                onReport: { appState.reportReview(review.id) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 90)
            }
            .refreshable {
                try? await Task.sleep(for: .seconds(0.8))
            }
            .background { GradientBackground() }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationTitle("Reviews")
        }
    }
}
