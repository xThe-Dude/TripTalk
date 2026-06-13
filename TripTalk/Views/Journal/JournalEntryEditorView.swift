// JournalEntryEditorView.swift
// TripTalk — Phase 4: Journal UI
//
// Create or edit a private trip journal entry.
// All form state is held in local @State variables so dismissing without
// saving never mutates an existing SwiftData record.

import SwiftUI

struct JournalEntryEditorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    // Optional: when non-nil, the editor is in "edit" mode.
    private let existingEntry: JournalEntry?

    // Pre-fill values (used when launching from StrainDetailView)
    private let prefillSubstanceName: String
    private let prefillSubstanceId: UUID?

    // MARK: - Form State

    @State private var substanceName: String = ""
    @State private var substanceId: UUID? = nil
    @State private var useStrainPicker: Bool = false
    @State private var selectedStrainIndex: Int = 0

    @State private var setting: String = ""
    @State private var intention: String = ""
    @State private var ratingValue: Int = 0   // 0 = not rated

    @State private var phasePrepareNotes: String = ""
    @State private var phaseOnsetNotes: String = ""
    @State private var phasePeakNotes: String = ""
    @State private var phaseIntegrationNotes: String = ""

    @State private var highlights: String = ""
    @State private var safetyNotes: String = ""

    @State private var saveError: String? = nil

    // MARK: - Voice note state

    /// Filename of the attached voice recording (nil = no recording).
    @State private var voiceFileName: String? = nil
    /// Transcript text produced from the voice recording (may be nil or empty).
    @State private var voiceTranscript: String? = nil
    /// Whether the VoiceRecorderView sheet is presented.
    @State private var showVoiceRecorder = false
    /// Playback service for the in-editor voice preview.
    @State private var voicePlayback = AudioPlaybackService()

    // MARK: - Init

    /// Create a blank new entry.
    init() {
        self.existingEntry = nil
        self.prefillSubstanceName = ""
        self.prefillSubstanceId = nil
    }

    /// Create a new entry pre-filled with a strain's name/id (e.g. from StrainDetailView).
    init(prefillSubstanceName: String, prefillSubstanceId: UUID? = nil) {
        self.existingEntry = nil
        self.prefillSubstanceName = prefillSubstanceName
        self.prefillSubstanceId = prefillSubstanceId
    }

    /// Edit an existing entry.
    init(entry: JournalEntry) {
        self.existingEntry = entry
        self.prefillSubstanceName = ""
        self.prefillSubstanceId = nil
    }

    // MARK: - Computed

    // Use the same strain list the Catalog uses (server-loaded when available,
    // falling back to MockData). Previously hardcoded to MockData.strains, which
    // made the picker miss catalog entries once the server list loaded.
    private var strains: [Strain] { appState.strains }

    private var isEditMode: Bool { existingEntry != nil }

    private var isEmptyEntry: Bool {
        voiceFileName == nil &&
        substanceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        setting.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        intention.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        phasePrepareNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        phaseOnsetNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        phasePeakNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        phaseIntegrationNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        highlights.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        safetyNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                ScrollView {
                    VStack(alignment: .leading, spacing: TTDesign.spacingXL) {
                        substanceSection
                        basicSection
                        journeySection
                        reflectionSection
                        voiceNoteSection

                        if let err = saveError {
                            Text(err)
                                .font(.ttCaption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, TTDesign.spacingLG)
                        }
                    }
                    .padding(.top, TTDesign.spacingMD)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle(isEditMode ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.ttSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isEditMode ? "Update" : "Save") { saveEntry() }
                        .font(.headline)
                        .foregroundStyle(Color.ttAccent)
                        .disabled(isEmptyEntry)
                }
            }
            .onAppear(perform: populateFields)
            .sheet(isPresented: $showVoiceRecorder) {
                VoiceRecorderView { fileName, transcript in
                    voiceFileName = fileName
                    voiceTranscript = transcript
                }
            }
        }
    }

    // MARK: - Sections

    private var substanceSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            sectionHeader("Substance", systemImage: "leaf")

            VStack(alignment: .leading, spacing: TTDesign.spacingSM) {
                Toggle(isOn: $useStrainPicker) {
                    Text("Pick from catalog")
                        .font(.ttBody)
                        .foregroundStyle(Color.ttSecondary)
                }
                .tint(Color.ttAccent)
                .padding(.horizontal, TTDesign.spacingLG)

                if useStrainPicker {
                    VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
                        Text("Strain")
                            .font(.ttEyebrow)
                            .foregroundStyle(Color.ttTertiary)
                            .padding(.horizontal, TTDesign.spacingLG)

                        Picker("Strain", selection: $selectedStrainIndex) {
                            ForEach(strains.indices, id: \.self) { i in
                                Text(strains[i].name).tag(i)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 120)
                        .clipped()
                        .onChange(of: selectedStrainIndex) { _, newIndex in
                            substanceName = strains[newIndex].name
                            substanceId = strains[newIndex].id
                        }
                    }
                } else {
                    labeledField(label: "Substance name (optional)",
                                 placeholder: "e.g. Golden Teachers") {
                        TextField("e.g. Golden Teachers", text: $substanceName)
                    }
                    .onChange(of: substanceName) { _, _ in
                        substanceId = nil
                    }
                }
            }
        }
    }

    private var basicSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            sectionHeader("Context", systemImage: "mappin.and.ellipse")

            labeledField(label: "Setting", placeholder: "Where were you?") {
                TextField("e.g. home, outdoors, ceremony", text: $setting)
            }

            labeledField(label: "Intention", placeholder: "What were you hoping for?") {
                TextField("e.g. healing, creativity, curiosity", text: $intention)
            }

            VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
                Text("Rating (optional)")
                    .font(.ttEyebrow)
                    .foregroundStyle(Color.ttTertiary)
                    .padding(.horizontal, TTDesign.spacingLG)

                HStack(spacing: TTDesign.spacingMD) {
                    ForEach(1...5, id: \.self) { i in
                        Button {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                                ratingValue = (ratingValue == i) ? 0 : i
                            }
                            Haptics.light()
                        } label: {
                            Image(systemName: i <= ratingValue ? "star.fill" : "star")
                                .font(.system(size: 28))
                                .foregroundStyle(i <= ratingValue ? Color.ttAccent : Color.ttTertiary)
                                .scaleEffect(i <= ratingValue ? 1.0 : 0.85)
                                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: ratingValue)
                        }
                        .buttonStyle(.plain)
                    }
                    if ratingValue > 0 {
                        Button {
                            withAnimation { ratingValue = 0 }
                        } label: {
                            Text("Clear")
                                .font(.ttCaption)
                                .foregroundStyle(Color.ttTertiary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, TTDesign.spacingLG)
            }
        }
    }

    private var journeySection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            sectionHeader("Journey", systemImage: "timeline.selection")

            phaseField(
                phase: "Prepare",
                subtitle: "Set & setting — mindset before",
                text: $phasePrepareNotes
            )
            TTHairline(opacity: 0.12)
            phaseField(
                phase: "Onset",
                subtitle: "Coming up — first effects",
                text: $phaseOnsetNotes
            )
            TTHairline(opacity: 0.12)
            phaseField(
                phase: "Peak",
                subtitle: "Full effects — height of the experience",
                text: $phasePeakNotes
            )
            TTHairline(opacity: 0.12)
            phaseField(
                phase: "Integration",
                subtitle: "Coming down & reflection",
                text: $phaseIntegrationNotes
            )
        }
    }

    private var reflectionSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            sectionHeader("Reflection", systemImage: "text.bubble")

            multilineField(label: "Highlights",
                           placeholder: "Memorable moments, insights, positive notes…",
                           text: $highlights)

            multilineField(label: "Safety notes",
                           placeholder: "Any concerns, difficult moments, notes for next time…",
                           text: $safetyNotes)
        }
    }

    // MARK: - Voice note section

    private var voiceNoteSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            sectionHeader("Voice Note", systemImage: "waveform")

            if let fileName = voiceFileName {
                // Recording attached — show preview card
                VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
                    // Playback row
                    HStack(spacing: TTDesign.spacingMD) {
                        Button(action: { voicePlayback.togglePlayback(fileName: fileName) }) {
                            HStack(spacing: TTDesign.spacingXS) {
                                Image(systemName: voicePlayback.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.ttAccent)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Voice recording")
                                        .font(.ttBody)
                                        .foregroundStyle(Color.ttPrimary)
                                    Text(voicePlayback.isPlaying ? "Playing…" : "Tap to preview")
                                        .font(.ttCaption)
                                        .foregroundStyle(Color.ttTertiary)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Button(action: removeVoiceRecording) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.ttTertiary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(TTDesign.spacingMD)
                    .background(
                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                            .fill(Color.ttCardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .stroke(Color.ttAccent.opacity(0.15), lineWidth: 1)
                            )
                    )

                    if let pbErr = voicePlayback.playbackError {
                        Text(pbErr)
                            .font(.ttCaption)
                            .foregroundStyle(Color.red.opacity(0.8))
                    }

                    // Transcript (if available)
                    if let transcript = voiceTranscript, !transcript.isEmpty {
                        VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
                            Label("Transcript", systemImage: "text.quote")
                                .font(.ttEyebrow)
                                .foregroundStyle(Color.ttTertiary)
                            Text(transcript)
                                .font(.ttBody)
                                .foregroundStyle(Color.ttSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(TTDesign.spacingMD)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                .fill(Color.ttCardBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                                )
                        )
                    }
                }
                .padding(.horizontal, TTDesign.spacingLG)
            } else {
                // No recording yet — show "Add Voice Note" button
                Button(action: { showVoiceRecorder = true }) {
                    HStack(spacing: TTDesign.spacingMD) {
                        Image(systemName: "mic.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(Color.ttAccent.opacity(0.7))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Add Voice Note")
                                .font(.ttBody)
                                .foregroundStyle(Color.ttPrimary)
                            Text("Record and transcribe on-device")
                                .font(.ttCaption)
                                .foregroundStyle(Color.ttTertiary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.ttTertiary)
                    }
                    .padding(TTDesign.spacingMD)
                    .background(
                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                            .fill(Color.ttCardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, TTDesign.spacingLG)
            }
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.ttSection)
            .foregroundStyle(Color.ttPrimary)
            .padding(.horizontal, TTDesign.spacingLG)
    }

    @ViewBuilder
    private func labeledField<Content: View>(
        label: String,
        placeholder: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
            Text(label)
                .font(.ttEyebrow)
                .foregroundStyle(Color.ttTertiary)

            content()
                .font(.ttBody)
                .foregroundStyle(Color.ttPrimary)
                .tint(Color.ttAccent)
                .padding(TTDesign.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                        .fill(Color.ttCardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )
                )
        }
        .padding(.horizontal, TTDesign.spacingLG)
    }

    private func phaseField(phase: String, subtitle: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
            VStack(alignment: .leading, spacing: 2) {
                Text(phase)
                    .font(.ttEyebrow)
                    .foregroundStyle(Color.ttAccent)
                Text(subtitle)
                    .font(.ttCaption)
                    .foregroundStyle(Color.ttTertiary)
            }
            .padding(.horizontal, TTDesign.spacingLG)

            TextEditor(text: text)
                .font(.ttBody)
                .foregroundStyle(Color.ttPrimary)
                .tint(Color.ttAccent)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .frame(minHeight: 80)
                .padding(TTDesign.spacingMD)
                .background(
                    RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                        .fill(Color.ttCardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )
                )
                .padding(.horizontal, TTDesign.spacingLG)
        }
    }

    private func multilineField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
            Text(label)
                .font(.ttEyebrow)
                .foregroundStyle(Color.ttTertiary)
                .padding(.horizontal, TTDesign.spacingLG)

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.ttBody)
                        .foregroundStyle(Color.ttTertiary.opacity(0.6))
                        .padding(.top, TTDesign.spacingMD + 1)
                        .padding(.leading, TTDesign.spacingMD + 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: text)
                    .font(.ttBody)
                    .foregroundStyle(Color.ttPrimary)
                    .tint(Color.ttAccent)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100)
                    .padding(TTDesign.spacingMD)
            }
            .background(
                RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                    .fill(Color.ttCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
            )
            .padding(.horizontal, TTDesign.spacingLG)
        }
    }

    // MARK: - Voice note helpers

    private func removeVoiceRecording() {
        voicePlayback.stop()
        // Delete the file from disk immediately so no orphaned audio accumulates.
        if let fileName = voiceFileName {
            try? JournalAudioStorage.deleteAudioFile(named: fileName)
        }
        voiceFileName = nil
        voiceTranscript = nil
    }

    // MARK: - Populate / Save

    private func populateFields() {
        if let entry = existingEntry {
            // Edit mode: populate from existing entry
            substanceName = entry.substanceName
            substanceId = entry.substanceId
            setting = entry.setting
            intention = entry.intention
            ratingValue = entry.rating ?? 0
            phasePrepareNotes = entry.phasePrepareNotes
            phaseOnsetNotes = entry.phaseOnsetNotes
            phasePeakNotes = entry.phasePeakNotes
            phaseIntegrationNotes = entry.phaseIntegrationNotes
            highlights = entry.highlights
            safetyNotes = entry.safetyNotes

            // Restore voice fields if entry has a recording
            voiceFileName = entry.audioFileName
            voiceTranscript = entry.transcript

            // Sync picker state
            if let idx = strains.firstIndex(where: { $0.name == entry.substanceName }) {
                useStrainPicker = true
                selectedStrainIndex = idx
            }
        } else if !prefillSubstanceName.isEmpty {
            // Pre-filled from StrainDetailView
            substanceName = prefillSubstanceName
            substanceId = prefillSubstanceId
            if let idx = strains.firstIndex(where: { $0.id == prefillSubstanceId }) {
                useStrainPicker = true
                selectedStrainIndex = idx
            }
        }
    }

    private func saveEntry() {
        saveError = nil
        let finalRating: Int? = ratingValue > 0 ? ratingValue : nil
        let finalSubstanceName = useStrainPicker && !strains.isEmpty
            ? strains[selectedStrainIndex].name
            : substanceName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalSubstanceId = useStrainPicker && !strains.isEmpty
            ? strains[selectedStrainIndex].id
            : substanceId

        // Determine entry kind based on whether a voice recording is attached.
        let finalEntryKind = voiceFileName != nil ? "voice" : "text"
        let finalTranscript = voiceTranscript?.trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty

        do {
            if let entry = existingEntry {
                // Update existing
                entry.substanceName = finalSubstanceName
                entry.substanceId = finalSubstanceId
                entry.setting = setting
                entry.intention = intention
                entry.rating = finalRating
                entry.phasePrepareNotes = phasePrepareNotes
                entry.phaseOnsetNotes = phaseOnsetNotes
                entry.phasePeakNotes = phasePeakNotes
                entry.phaseIntegrationNotes = phaseIntegrationNotes
                entry.highlights = highlights
                entry.safetyNotes = safetyNotes
                entry.entryKind = finalEntryKind
                entry.audioFileName = voiceFileName
                entry.transcript = finalTranscript
                try appState.journal.update(entry)
            } else {
                // Create new
                let newEntry = JournalEntry(
                    substanceId: finalSubstanceId,
                    substanceName: finalSubstanceName,
                    rating: finalRating,
                    setting: setting,
                    intention: intention,
                    highlights: highlights,
                    safetyNotes: safetyNotes,
                    phasePrepareNotes: phasePrepareNotes,
                    phaseOnsetNotes: phaseOnsetNotes,
                    phasePeakNotes: phasePeakNotes,
                    phaseIntegrationNotes: phaseIntegrationNotes,
                    entryKind: finalEntryKind,
                    audioFileName: voiceFileName,
                    transcript: finalTranscript
                )
                try appState.journal.create(newEntry)
            }
            voicePlayback.stop()
            dismiss()
        } catch {
            saveError = "Save failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - String convenience

private extension String {
    /// Returns nil if the string is empty after whitespace trimming.
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
