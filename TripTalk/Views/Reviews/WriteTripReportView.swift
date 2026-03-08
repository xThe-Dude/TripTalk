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

    var body: some View {
        NavigationStack {
            Form {
                Section("Rating") {
                    InteractiveRatingStars(rating: $rating)
                        .frame(maxWidth: .infinity)
                }

                Section("Setting") {
                    Picker("Setting", selection: $setting) {
                        ForEach(TripSetting.allCases) { s in
                            Label(s.rawValue, systemImage: s.icon).tag(s)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("Intention") {
                    TextField("What was your intention?", text: $intention)
                        .foregroundStyle(Color.ttPrimary)
                }

                Section("Experience Types") {
                    FlowLayout(spacing: 6) {
                        ForEach(ExperienceType.allCases) { type in
                            TagChip(text: type.rawValue, isSelected: selectedExperienceTypes.contains(type))
                                .onTapGesture {
                                    if selectedExperienceTypes.contains(type) { selectedExperienceTypes.remove(type) }
                                    else { selectedExperienceTypes.insert(type) }
                                }
                        }
                    }
                }

                Section("Intensity") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Visual")
                                .font(.subheadline)
                                .foregroundStyle(Color.ttPrimary)
                                .frame(width: 70, alignment: .leading)
                            Slider(value: $visualIntensity, in: 0...5, step: 1)
                                .tint(.purple)
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
                                .tint(.green)
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
                                .tint(.pink)
                            Text("\(Int(emotionalIntensity))")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary)
                                .frame(width: 20)
                        }
                    }
                }

                Section("Moods") {
                    FlowLayout(spacing: 6) {
                        ForEach(MoodTag.allCases) { mood in
                            TagChip(text: mood.rawValue, isSelected: selectedMoods.contains(mood))
                                .onTapGesture {
                                    if selectedMoods.contains(mood) { selectedMoods.remove(mood) }
                                    else { selectedMoods.insert(mood) }
                                }
                        }
                    }
                }

                Section("What stood out?") {
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

                Section("Safety notes or tips?") {
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

                Section {
                    Toggle("Would you try this again?", isOn: $wouldRepeat)
                        .foregroundStyle(Color.ttPrimary)
                }

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

                if showSuccess {
                    Section {
                        Label("Trip report submitted! Thank you.", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttSheetBg)
            .navigationTitle("Trip Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.ttAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Submit") { submitReport() }
                        .disabled(rating == 0 || highlights.isEmpty || !antiSourcingAgreed)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.ttAccent)
                }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { dismiss() }
    }
}
