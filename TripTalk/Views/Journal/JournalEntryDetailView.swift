// JournalEntryDetailView.swift
// TripTalk — Phase 4: Journal UI
//
// Read-only view of a single journal entry.
// Includes JourneyTimelineView (matching strain if found), all four
// phase notes, intention, highlights, safety notes, rating, and date.
// Edit button opens JournalEntryEditorView; Delete button (with
// confirmation) calls appState.journal.delete.

import SwiftUI

struct JournalEntryDetailView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let entry: JournalEntry
    /// Called after an edit so the list can reload.
    var onUpdate: (() -> Void)? = nil

    @State private var showEditor = false
    @State private var showDeleteConfirm = false
    @State private var deleteError: String? = nil
    @State private var voicePlayback = AudioPlaybackService()

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: TTDesign.spacingXL) {
                headerSection
                voicePlaybackSection
                timelineSection
                phaseSection
                reflectionSection
                deleteButton
            }
            .padding(.bottom, 120)
        }
        .background { GradientBackground() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") { showEditor = true }
                    .foregroundStyle(Color.ttAccent)
            }
        }
        .sheet(isPresented: $showEditor, onDismiss: { onUpdate?() }) {
            JournalEntryEditorView(entry: entry)
        }
        .confirmationDialog(
            "Delete this entry?",
            isPresented: $showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) { deleteEntry() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This journal entry will be permanently removed from your device.")
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            // Substance / title
            Text(entry.substanceName.isEmpty ? "Untitled Journey" : entry.substanceName)
                .font(.ttPageHead)
                .foregroundStyle(Color.ttPrimary)

            // Date
            HStack(spacing: TTDesign.spacingXS) {
                Image(systemName: "calendar")
                    .font(.ttCaption)
                    .foregroundStyle(Color.ttTertiary)
                Text(entry.createdAt.formatted(date: .long, time: .shortened))
                    .font(.ttCaption)
                    .foregroundStyle(Color.ttTertiary)
            }

            // Rating
            if let rating = entry.rating {
                HStack(spacing: TTDesign.spacingXS) {
                    ForEach(1...5, id: \.self) { i in
                        Image(systemName: i <= rating ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundStyle(i <= rating ? Color.ttAccent : Color.ttTertiary)
                    }
                    Text("\(rating)/5")
                        .font(.ttCaption)
                        .foregroundStyle(Color.ttSecondary)
                }
            }

            // Setting + Intention chips
            if !entry.setting.isEmpty || !entry.intention.isEmpty {
                VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
                    if !entry.setting.isEmpty {
                        metaRow(icon: "location", label: "Setting", value: entry.setting)
                    }
                    if !entry.intention.isEmpty {
                        metaRow(icon: "target", label: "Intention", value: entry.intention)
                    }
                }
            }
        }
        .padding(.horizontal, TTDesign.spacingLG)
        .padding(.top, TTDesign.spacingMD)
    }

    // MARK: - Voice playback

    @ViewBuilder
    private var voicePlaybackSection: some View {
        if entry.entryKind == "voice",
           let fileName = entry.audioFileName,
           JournalAudioStorage.audioFileExists(named: fileName) {

            VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
                Label("Voice Note", systemImage: "waveform")
                    .font(.ttSection)
                    .foregroundStyle(Color.ttPrimary)
                    .padding(.horizontal, TTDesign.spacingLG)

                // Play / pause row
                Button(action: { voicePlayback.togglePlayback(fileName: fileName) }) {
                    HStack(spacing: TTDesign.spacingMD) {
                        Image(systemName: voicePlayback.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.ttAccent)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(voicePlayback.isPlaying ? "Playing…" : "Play recording")
                                .font(.ttBody)
                                .foregroundStyle(Color.ttPrimary)
                            Text("Stored privately on your device")
                                .font(.ttCaption)
                                .foregroundStyle(Color.ttTertiary)
                        }
                        Spacer()
                    }
                    .padding(TTDesign.spacingLG)
                    .background(
                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                            .fill(Color.ttCardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .stroke(Color.ttAccent.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, TTDesign.spacingLG)

                if let pbErr = voicePlayback.playbackError {
                    Text(pbErr)
                        .font(.ttCaption)
                        .foregroundStyle(Color.red.opacity(0.8))
                        .padding(.horizontal, TTDesign.spacingLG)
                }

                // Transcript (if available)
                if let transcript = entry.transcript,
                   !transcript.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: TTDesign.spacingSM) {
                        Label("Transcript", systemImage: "text.quote")
                            .font(.ttEyebrow)
                            .foregroundStyle(Color.ttTertiary)
                        Text(transcript)
                            .font(.ttBody)
                            .foregroundStyle(Color.ttPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(TTDesign.spacingLG)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                            .fill(Color.ttCardBg)
                            .overlay(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, TTDesign.spacingLG)
                }
            }
        }
    }

    // MARK: - Timeline

    @ViewBuilder
    private var timelineSection: some View {
        let matchedStrain = matchingStrain
        if let strain = matchedStrain {
            VStack(alignment: .leading, spacing: 0) {
                JourneyTimelineView(strain: strain)
                    .cornerRadius(TTDesign.radiusMD)
            }
            .padding(.horizontal, TTDesign.spacingLG)
        } else if !entry.substanceName.isEmpty {
            // Fall back to string init with generic defaults
            VStack(alignment: .leading, spacing: 0) {
                JourneyTimelineView(
                    onset: "varies",
                    duration: "varies",
                    strainName: entry.substanceName
                )
                .cornerRadius(TTDesign.radiusMD)
            }
            .padding(.horizontal, TTDesign.spacingLG)
        }
        // If no substance at all, skip timeline entirely
    }

    // MARK: - Phase notes

    private var phaseSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
            Label("Journey Notes", systemImage: "timeline.selection")
                .font(.ttSection)
                .foregroundStyle(Color.ttPrimary)
                .padding(.horizontal, TTDesign.spacingLG)

            let phases: [(String, String, String)] = [
                ("Prepare", "moon.stars", entry.phasePrepareNotes),
                ("Onset", "arrow.up.circle", entry.phaseOnsetNotes),
                ("Peak", "sun.max", entry.phasePeakNotes),
                ("Integration", "water.waves", entry.phaseIntegrationNotes)
            ]

            ForEach(phases, id: \.0) { title, icon, text in
                if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    phaseNoteCard(title: title, icon: icon, text: text)
                }
            }

            let allEmpty = phases.allSatisfy {
                $0.2.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            if allEmpty {
                Text("No phase notes recorded.")
                    .font(.ttBody)
                    .foregroundStyle(Color.ttTertiary)
                    .padding(.horizontal, TTDesign.spacingLG)
            }
        }
    }

    // MARK: - Reflection

    @ViewBuilder
    private var reflectionSection: some View {
        let hasHighlights = !entry.highlights.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasSafety = !entry.safetyNotes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        if hasHighlights || hasSafety {
            VStack(alignment: .leading, spacing: TTDesign.spacingMD) {
                Label("Reflection", systemImage: "text.bubble")
                    .font(.ttSection)
                    .foregroundStyle(Color.ttPrimary)
                    .padding(.horizontal, TTDesign.spacingLG)

                if hasHighlights {
                    reflectionCard(title: "Highlights",
                                   icon: "sparkles",
                                   text: entry.highlights,
                                   accentColor: .ttAccent)
                }
                if hasSafety {
                    reflectionCard(title: "Safety Notes",
                                   icon: "exclamationmark.shield",
                                   text: entry.safetyNotes,
                                   accentColor: Color.teal)
                }
            }
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
            if let err = deleteError {
                Text(err)
                    .font(.ttCaption)
                    .foregroundStyle(.red)
                    .padding(.horizontal, TTDesign.spacingLG)
            }
            Button(role: .destructive) {
                showDeleteConfirm = true
            } label: {
                Label("Delete Entry", systemImage: "trash")
                    .font(.ttBody)
                    .foregroundStyle(.red.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, TTDesign.spacingMD)
                    .background(
                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                            .fill(Color.red.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .stroke(Color.red.opacity(0.15), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, TTDesign.spacingLG)
        }
    }

    // MARK: - Component helpers

    private func metaRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: TTDesign.spacingXS) {
            Image(systemName: icon)
                .font(.ttCaption)
                .foregroundStyle(Color.ttAccent)
                .frame(width: 16)
            Text(label + ":")
                .font(.ttEyebrow)
                .foregroundStyle(Color.ttTertiary)
            Text(value)
                .font(.ttMetadata)
                .foregroundStyle(Color.ttSecondary)
                .lineLimit(1)
        }
    }

    private func phaseNoteCard(title: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingSM) {
            HStack(spacing: TTDesign.spacingXS) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.ttAccent)
                Text(title)
                    .font(.ttEyebrow)
                    .foregroundStyle(Color.ttAccent)
            }
            Text(text)
                .font(.ttBody)
                .foregroundStyle(Color.ttPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TTDesign.spacingLG)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                .fill(Color.ttCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                        .stroke(Color.ttAccent.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal, TTDesign.spacingLG)
    }

    private func reflectionCard(title: String, icon: String, text: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingSM) {
            HStack(spacing: TTDesign.spacingXS) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(accentColor)
                Text(title)
                    .font(.ttEyebrow)
                    .foregroundStyle(accentColor)
            }
            Text(text)
                .font(.ttBody)
                .foregroundStyle(Color.ttPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(TTDesign.spacingLG)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                .fill(Color.ttCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                        .stroke(accentColor.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal, TTDesign.spacingLG)
    }

    // MARK: - Strain match

    /// Finds the matching Strain from MockData, preferring substanceId then name.
    private var matchingStrain: Strain? {
        let strains = MockData.strains
        if let sid = entry.substanceId,
           let match = strains.first(where: { $0.id == sid }) {
            return match
        }
        if !entry.substanceName.isEmpty,
           let match = strains.first(where: { $0.name.localizedCaseInsensitiveCompare(entry.substanceName) == .orderedSame }) {
            return match
        }
        return nil
    }

    // MARK: - Delete

    private func deleteEntry() {
        deleteError = nil
        do {
            try appState.journal.delete(entry)
            onUpdate?()
            dismiss()
        } catch {
            deleteError = "Delete failed: \(error.localizedDescription)"
        }
    }
}
