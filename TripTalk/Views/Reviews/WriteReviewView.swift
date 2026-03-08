import SwiftUI

struct WriteReviewView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var substanceID: UUID? = nil
    var serviceID: UUID? = nil

    @State private var rating: Int = 0
    @State private var title: String = ""
    @State private var body_: String = ""
    @State private var selectedTags: Set<EffectTag> = []
    @State private var antiSourcingAgreed: Bool = false
    @State private var showSuccess: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rating").foregroundStyle(Color.ttSectionHeader)) {
                    InteractiveRatingStars(rating: $rating)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Your Review").foregroundStyle(Color.ttSectionHeader)) {
                    TextField("Title", text: $title)
                        .foregroundStyle(Color.ttPrimary)
                    ZStack(alignment: .topLeading) {
                        if body_.isEmpty {
                            Text("Share your experience... What was the setting? How did it affect you? What insights did you gain?")
                                .foregroundStyle(Color.ttSecondary.opacity(0.5))
                                .padding(.top, 8)
                        }
                        TextEditor(text: $body_)
                            .foregroundStyle(Color.ttPrimary)
                            .frame(minHeight: 120)
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Tags (select all that apply)").foregroundStyle(Color.ttSectionHeader)) {
                    FlowLayout(spacing: 6) {
                        ForEach(EffectTag.allCases) { tag in
                            TagChip(text: tag.rawValue, isSelected: selectedTags.contains(tag))
                                .onTapGesture {
                                    Haptics.selection()
                                    if selectedTags.contains(tag) { selectedTags.remove(tag) }
                                    else { selectedTags.insert(tag) }
                                }
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section {
                    Toggle(isOn: $antiSourcingAgreed) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Community Agreement")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.ttPrimary)
                            Text("I confirm this review does not contain sourcing information, specific dosing instructions, or encouragement of illegal activity.")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary)
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                if showSuccess {
                    Section {
                        Label("Review submitted! Thank you for contributing.", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .listRowBackground(Color.green.opacity(0.08))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttSheetBg)
            .navigationTitle("Write Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.ttAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Submit") {
                        submitReview()
                    }
                    .disabled(rating == 0 || title.isEmpty || body_.isEmpty || !antiSourcingAgreed)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.ttAccent)
                }
            }
        }
        .presentationBackground(Color.ttSheetBg.opacity(0.95))
    }

    private func submitReview() {
        let review = Review(
            authorName: "You",
            rating: rating,
            title: title,
            body: body_,
            tags: Array(selectedTags),
            substanceID: substanceID,
            serviceID: serviceID
        )
        appState.addReview(review)
        showSuccess = true
        Haptics.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
    }
}
