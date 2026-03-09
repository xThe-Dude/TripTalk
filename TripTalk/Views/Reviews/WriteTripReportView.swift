import SwiftUI

struct WriteTripReportView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let strainId: UUID

    @State private var rating: Int = 0
    @State private var setting: TripSetting = .home
    @State private var intention: String = ""
    @State private var selectedExperienceTypes: Set<ExperienceType> = []
    @State private var visualIntensity: Double = 3
    @State private var bodyIntensity: Double = 3
    @State private var emotionalIntensity: Double = 3
    @State private var selectedMoods: Set<MoodTag> = []
    @State private var highlights: String = ""
    @State private var safetyNotes: String = ""
    @State private var wouldRepeat: Bool = true
    @State private var antiSourcingAgreed: Bool = false
    @State private var showSuccess: Bool = false
    @State private var showDiscardAlert: Bool = false

    private var hasContent: Bool {
        rating > 0 || !highlights.isEmpty || !intention.isEmpty || !safetyNotes.isEmpty || !selectedMoods.isEmpty || !selectedExperienceTypes.isEmpty
    }
    @State private var showSuccessOverlay: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Rating").foregroundStyle(Color.ttSectionHeader)) {
                    InteractiveRatingStars(rating: $rating)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Setting").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Setting", selection: $setting) {
                        ForEach(TripSetting.allCases) { s in
                            Label(s.rawValue, systemImage: s.icon).tag(s)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Intention").foregroundStyle(Color.ttSectionHeader)) {
                    TextField("What was your intention?", text: $intention)
                        .foregroundStyle(Color.ttPrimary)
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Experience Types").foregroundStyle(Color.ttSectionHeader)) {
                    FlowLayout(spacing: 6) {
                        ForEach(ExperienceType.allCases) { type in
                            TagChip(text: type.rawValue, isSelected: selectedExperienceTypes.contains(type))
                                .onTapGesture {
                                    Haptics.selection()
                                    if selectedExperienceTypes.contains(type) { selectedExperienceTypes.remove(type) }
                                    else { selectedExperienceTypes.insert(type) }
                                }
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Intensity").foregroundStyle(Color.ttSectionHeader)) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Visual")
                                .font(.subheadline)
                                .foregroundStyle(Color.ttPrimary)
                                .frame(width: 70, alignment: .leading)
                            Slider(value: $visualIntensity, in: 0...5, step: 1)
                                .tint(Color.ttVisual)
                            Text("\(Int(visualIntensity))")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary)
                                .frame(width: 20)
                        }
                        HStack {
                            Text("Body")
                                .font(.subheadline)
                                .foregroundStyle(Color.ttPrimary)
                                .frame(width: 70, alignment: .leading)
                            Slider(value: $bodyIntensity, in: 0...5, step: 1)
                                .tint(Color.ttBody)
                            Text("\(Int(bodyIntensity))")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary)
                                .frame(width: 20)
                        }
                        HStack {
                            Text("Emotional")
                                .font(.subheadline)
                                .foregroundStyle(Color.ttPrimary)
                                .frame(width: 70, alignment: .leading)
                            Slider(value: $emotionalIntensity, in: 0...5, step: 1)
                                .tint(Color.ttEmotional)
                            Text("\(Int(emotionalIntensity))")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary)
                                .frame(width: 20)
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Moods").foregroundStyle(Color.ttSectionHeader)) {
                    FlowLayout(spacing: 6) {
                        ForEach(MoodTag.allCases) { mood in
                            TagChip(text: mood.rawValue, isSelected: selectedMoods.contains(mood))
                                .onTapGesture {
                                    Haptics.selection()
                                    if selectedMoods.contains(mood) { selectedMoods.remove(mood) }
                                    else { selectedMoods.insert(mood) }
                                }
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("What stood out?").foregroundStyle(Color.ttSectionHeader)) {
                    ZStack(alignment: .topLeading) {
                        if highlights.isEmpty {
                            Text("Describe the highlights of your experience...")
                                .foregroundStyle(Color.ttSecondary.opacity(0.5))
                                .padding(.top, 8)
                        }
                        TextEditor(text: $highlights)
                            .foregroundStyle(Color.ttPrimary)
                            .frame(minHeight: 80)
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Safety notes or tips?").foregroundStyle(Color.ttSectionHeader)) {
                    ZStack(alignment: .topLeading) {
                        if safetyNotes.isEmpty {
                            Text("Any safety advice for others?")
                                .foregroundStyle(Color.ttSecondary.opacity(0.5))
                                .padding(.top, 8)
                        }
                        TextEditor(text: $safetyNotes)
                            .foregroundStyle(Color.ttPrimary)
                            .frame(minHeight: 60)
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section {
                    Toggle("Would you try this again?", isOn: $wouldRepeat)
                        .foregroundStyle(Color.ttPrimary)
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section {
                    Toggle(isOn: $antiSourcingAgreed) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Community Agreement")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.ttPrimary)
                            Text("I confirm this report does not contain sourcing information, specific dosing instructions, or encouragement of illegal activity.")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary)
                        }
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                if showSuccess {
                    Section {
                        Label("Trip report submitted! Thank you.", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .listRowBackground(Color.green.opacity(0.08))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttSheetBg)
            .navigationTitle("Trip Report")
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
                    Button("Submit") { submitReport() }
                        .disabled(rating == 0 || highlights.isEmpty || !antiSourcingAgreed)
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
                            .scaleEffect(showSuccessOverlay ? 1.0 : 0.5)
                        Text("Thank you!")
                            .font(.system(.title2, design: .serif, weight: .bold))
                            .foregroundStyle(Color.ttPrimary)
                        Text("Your contribution helps the community.")
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                    }
                    .padding(32)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .transition(.scale.combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSuccessOverlay)
            }
        }
        .presentationBackground(Color.ttSheetBg.opacity(0.95))
    }

    private func submitReport() {
        let report = TripReport(
            id: UUID(),
            strainId: strainId,
            rating: rating,
            setting: setting,
            intention: intention,
            experienceTypes: Array(selectedExperienceTypes),
            visualIntensity: Int(visualIntensity),
            bodyIntensity: Int(bodyIntensity),
            emotionalIntensity: Int(emotionalIntensity),
            moods: Array(selectedMoods),
            highlights: highlights,
            safetyNotes: safetyNotes,
            wouldRepeat: wouldRepeat,
            authorName: "You",
            date: Date()
        )
        appState.addTripReport(report)
        showSuccess = true
        showSuccessOverlay = true
        Haptics.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
    }
}
