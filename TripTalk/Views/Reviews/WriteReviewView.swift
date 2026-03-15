import SwiftUI

struct WriteReviewView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var substanceID: UUID? = nil
    var serviceID: UUID? = nil

    @State private var rating: Int = 0
    @State private var title: String = ""
    @State private var body_: String = ""
    @State private var selectedTags: Set<EffectTag> = []
    @State private var antiSourcingAgreed: Bool = false
    @State private var showDiscardAlert: Bool = false

    private var hasContent: Bool {
        rating > 0 || !title.isEmpty || !body_.isEmpty || !selectedTags.isEmpty
    }
    @State private var showSuccessOverlay: Bool = false
    @State private var checkmarkVisible: Bool = false

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
                                .accessibilityHidden(true)
                        }
                        TextEditor(text: $body_)
                            .foregroundStyle(Color.ttPrimary)
                            .frame(minHeight: 120)
                            .accessibilityLabel("Review body")
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
                                .accessibilityAddTraits(.isButton)
                                .accessibilityHint(selectedTags.contains(tag) ? "Double-tap to deselect" : "Double-tap to select")
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
                            Text("I confirm this is a genuine, harm-reduction-focused experience report")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary)
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

            }
            .scrollContentBackground(.hidden)
            .background(Color.ttSheetBg)
            .navigationTitle("Write Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        if hasContent { showDiscardAlert = true } else { dismiss() }
                    }
                    .foregroundStyle(Color.ttAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Share Review") {
                        submitReview()
                    }
                    .disabled(rating == 0 || title.isEmpty || body_.isEmpty || !antiSourcingAgreed)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.ttAccent)
                }
            }
            .alert("Discard Changes?", isPresented: $showDiscardAlert) {
                Button("Discard", role: .destructive) { dismiss() }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("You have unsaved changes that will be lost.")
            }
        }
        .overlay {
            if showSuccessOverlay {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)
                            .scaleEffect(checkmarkVisible ? 1.0 : 0.3)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: checkmarkVisible)
                            .onAppear { checkmarkVisible = true }
                            .onDisappear { checkmarkVisible = false }
                        Text("Thank you!")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                        Text("Thank you for your review. Community feedback makes TripTalk better for everyone.")
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                }
                .animation(
                    reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.4, dampingFraction: 0.7),
                    value: showSuccessOverlay
                )
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
        Haptics.success()
        UIAccessibility.post(notification: .announcement, argument: "Review submitted. Thank you for contributing.")
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccessOverlay = true
        }
        Task {
            try? await Task.sleep(for: .milliseconds(1500))
            dismiss()
        }
    }
}
