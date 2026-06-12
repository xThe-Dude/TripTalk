// VoiceRecorderView.swift
// TripTalk — Phase 5: Voice Journal
//
// A sheet for recording a private voice note and optionally transcribing it
// on-device. The caller receives (audioFileName, transcript?) via onConfirm.
//
// PRIVACY:
//   Audio is stored locally only. Transcription uses on-device Speech recognition.
//   Nothing is uploaded. This is stated explicitly in the UI.

import SwiftUI
import AVFoundation

// MARK: - Elapsed time formatter

private func formatElapsed(_ t: TimeInterval) -> String {
    let total = Int(t)
    let m = total / 60
    let s = total % 60
    return String(format: "%d:%02d", m, s)
}

// MARK: - VoiceRecorderView

struct VoiceRecorderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Called when the user confirms the recording. Transcript may be nil.
    let onConfirm: (_ fileName: String, _ transcript: String?) -> Void

    // MARK: - Services (owned by this sheet)

    @State private var recorder = AudioRecorderService()
    @State private var transcriptionSvc = TranscriptionService()
    @State private var playback = AudioPlaybackService()

    // MARK: - State

    /// Filename of the completed recording (set when user stops).
    @State private var confirmedFileName: String? = nil
    /// Duration of the completed recording.
    @State private var confirmedDuration: TimeInterval = 0
    /// Editable transcript text after transcription.
    @State private var transcriptText: String = ""
    /// Whether a transcript has been produced.
    @State private var hasTranscript = false
    /// Error messages surfaced to the user.
    @State private var errorMessage: String? = nil
    /// Whether we've already requested permissions.
    @State private var permissionsRequested = false

    // MARK: - Animation state

    @State private var pulse1Scale: CGFloat = 1.0
    @State private var pulse2Scale: CGFloat = 1.0
    @State private var pulse1Opacity: Double = 0.5
    @State private var pulse2Opacity: Double = 0.3

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.ttSheetBg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Sheet handle
                Capsule()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 4)
                    .padding(.top, TTDesign.spacingMD)
                    .padding(.bottom, TTDesign.spacingXL)

                ScrollView {
                    VStack(spacing: TTDesign.spacingXL) {
                        titleRow
                        privacyBadge
                        recorderArea
                        if let err = errorMessage {
                            errorBanner(err)
                        }
                        controlsArea
                        if hasTranscript {
                            transcriptEditor
                        }
                        Spacer(minLength: TTDesign.spacingXXL)
                    }
                    .padding(.horizontal, TTDesign.spacingLG)
                    .padding(.bottom, 120)
                }
            }
        }
        .task {
            guard !permissionsRequested else { return }
            permissionsRequested = true
            await recorder.requestPermission()
            await transcriptionSvc.requestAuthorization()
        }
        .onChange(of: recorder.isRecording) { _, nowRecording in
            if nowRecording {
                startPulse()
            } else {
                stopPulse()
            }
        }
    }

    // MARK: - Title row

    private var titleRow: some View {
        HStack {
            Text("Voice Note")
                .font(.ttCardTitle)
                .foregroundStyle(Color.ttPrimary)
            Spacer()
            Button("Cancel") {
                recorder.discardCurrentRecording()
                playback.stop()
                dismiss()
            }
            .font(.ttBody)
            .foregroundStyle(Color.ttSecondary)
        }
    }

    // MARK: - Privacy badge

    private var privacyBadge: some View {
        HStack(spacing: TTDesign.spacingXS) {
            Image(systemName: "lock.fill")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.ttAccent.opacity(0.8))
            Text("Recorded and transcribed on your device. Nothing is uploaded.")
                .font(.ttCaption)
                .foregroundStyle(Color.ttTertiary)
        }
        .padding(.horizontal, TTDesign.spacingMD)
        .padding(.vertical, TTDesign.spacingSM)
        .background(
            Capsule()
                .fill(Color.ttCardBg)
                .overlay(
                    Capsule()
                        .stroke(Color.ttAccent.opacity(0.15), lineWidth: 0.5)
                )
        )
        .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - Recorder area (big button + pulse)

    @ViewBuilder
    private var recorderArea: some View {
        if recorder.permissionGranted == false {
            permissionDeniedView
        } else {
            VStack(spacing: TTDesign.spacingLG) {
                ZStack {
                    // Outer pulse rings (only while recording)
                    if recorder.isRecording && !reduceMotion {
                        Circle()
                            .stroke(Color.red.opacity(0.25), lineWidth: 1.5)
                            .frame(width: 120, height: 120)
                            .scaleEffect(pulse2Scale)
                            .opacity(pulse2Opacity)

                        Circle()
                            .stroke(Color.red.opacity(0.4), lineWidth: 2)
                            .frame(width: 96, height: 96)
                            .scaleEffect(pulse1Scale)
                            .opacity(pulse1Opacity)
                    }

                    // Main record/stop button
                    Button(action: handleMainButton) {
                        ZStack {
                            Circle()
                                .fill(buttonFill)
                                .frame(width: 72, height: 72)
                                .shadow(color: buttonShadow, radius: 12, y: 4)

                            if recorder.isRecording {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .frame(width: 22, height: 22)
                            } else if confirmedFileName != nil {
                                Image(systemName: "mic.badge.plus")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundStyle(Color.white)
                            } else {
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundStyle(Color.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .scaleEffect(recorder.isRecording ? 1.05 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.65), value: recorder.isRecording)
                }
                .frame(height: 140)

                // Elapsed / duration label
                Group {
                    if recorder.isRecording {
                        Text(formatElapsed(recorder.elapsed))
                            .font(.system(.title2, design: .monospaced).weight(.light))
                            .foregroundStyle(Color.ttPrimary)
                    } else if confirmedFileName != nil {
                        Text(formatElapsed(confirmedDuration))
                            .font(.system(.title2, design: .monospaced).weight(.light))
                            .foregroundStyle(Color.ttSecondary)
                    } else {
                        Text("Tap to start recording")
                            .font(.ttBody)
                            .foregroundStyle(Color.ttTertiary)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: recorder.isRecording)
            }
        }
    }

    // MARK: - Controls area (after recording stops)

    @ViewBuilder
    private var controlsArea: some View {
        if let fileName = confirmedFileName, !recorder.isRecording {
            VStack(spacing: TTDesign.spacingMD) {
                // Playback row
                HStack(spacing: TTDesign.spacingMD) {
                    Button(action: { playback.togglePlayback(fileName: fileName) }) {
                        HStack(spacing: TTDesign.spacingXS) {
                            Image(systemName: playback.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 16, weight: .medium))
                            Text(playback.isPlaying ? "Pause" : "Play")
                                .font(.ttBody)
                        }
                        .foregroundStyle(Color.ttPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, TTDesign.spacingMD)
                        .background(
                            RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                .fill(Color.ttCardBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(.plain)

                    // Transcribe button (shown if not yet transcribed and not in progress)
                    if !hasTranscript {
                        Button(action: runTranscription) {
                            HStack(spacing: TTDesign.spacingXS) {
                                if transcriptionSvc.isTranscribing {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .scaleEffect(0.7)
                                } else {
                                    Image(systemName: "text.bubble")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                Text(transcriptionSvc.isTranscribing ? "Transcribing…" : "Transcribe")
                                    .font(.ttBody)
                            }
                            .foregroundStyle(transcriptionSvc.isTranscribing ? Color.ttTertiary : Color.ttAccent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TTDesign.spacingMD)
                            .background(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .fill(Color.ttCardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                            .stroke(Color.ttAccent.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(transcriptionSvc.isTranscribing)
                    }
                }

                // Action row: Discard + Confirm
                HStack(spacing: TTDesign.spacingMD) {
                    Button(action: discardAndReset) {
                        Label("Discard", systemImage: "trash")
                            .font(.ttBody)
                            .foregroundStyle(Color.red.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TTDesign.spacingMD)
                            .background(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .fill(Color.red.opacity(0.06))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                            .stroke(Color.red.opacity(0.12), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(.plain)

                    Button(action: confirmRecording) {
                        Text("Use Recording")
                            .font(.ttBody)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.ttSheetBg)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, TTDesign.spacingMD)
                            .background(
                                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                                    .fill(Color.ttAccent)
                            )
                    }
                    .buttonStyle(.plain)
                }

                if let pbErr = playback.playbackError {
                    Text(pbErr)
                        .font(.ttCaption)
                        .foregroundStyle(Color.red.opacity(0.8))
                }
            }
        }
    }

    // MARK: - Transcript editor

    private var transcriptEditor: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
            Label("Transcript", systemImage: "text.quote")
                .font(.ttEyebrow)
                .foregroundStyle(Color.ttTertiary)

            ZStack(alignment: .topLeading) {
                if transcriptText.isEmpty {
                    Text("No text transcribed.")
                        .font(.ttBody)
                        .foregroundStyle(Color.ttTertiary.opacity(0.5))
                        .padding(.top, TTDesign.spacingMD + 1)
                        .padding(.leading, TTDesign.spacingMD + 4)
                        .allowsHitTesting(false)
                }
                TextEditor(text: $transcriptText)
                    .font(.ttBody)
                    .foregroundStyle(Color.ttPrimary)
                    .tint(Color.ttAccent)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .frame(minHeight: 100)
                    .padding(TTDesign.spacingMD)
            }
            .background(
                RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                    .fill(Color.ttCardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                            .stroke(Color.ttAccent.opacity(0.12), lineWidth: 1)
                    )
            )

            Text("You can edit this transcript before saving.")
                .font(.ttCaption)
                .foregroundStyle(Color.ttTertiary)
        }
    }

    // MARK: - Permission denied view

    private var permissionDeniedView: some View {
        VStack(spacing: TTDesign.spacingMD) {
            Image(systemName: "mic.slash.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color.ttTertiary)

            Text("Microphone Access Required")
                .font(.ttCardTitle)
                .foregroundStyle(Color.ttPrimary)
                .multilineTextAlignment(.center)

            Text("TripTalk needs microphone access to record voice notes. Your recordings stay on your device.")
                .font(.ttBody)
                .foregroundStyle(Color.ttSecondary)
                .multilineTextAlignment(.center)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.ttBody)
            .foregroundStyle(Color.ttAccent)
            .padding(.top, TTDesign.spacingXS)
        }
        .padding(TTDesign.spacingXL)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: TTDesign.radiusLG)
                .fill(Color.ttCardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: TTDesign.radiusLG)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }

    // MARK: - Error banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: TTDesign.spacingXS) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.orange)
            Text(message)
                .font(.ttCaption)
                .foregroundStyle(Color.ttSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button {
                withAnimation { errorMessage = nil }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.ttTertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(TTDesign.spacingMD)
        .background(
            RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: TTDesign.radiusMD)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }

    // MARK: - Button visuals

    private var buttonFill: Color {
        if recorder.isRecording { return Color.red }
        if confirmedFileName != nil { return Color.ttAccent.opacity(0.7) }
        return Color(red: 0.85, green: 0.2, blue: 0.2)
    }

    private var buttonShadow: Color {
        recorder.isRecording
            ? Color.red.opacity(0.4)
            : Color.black.opacity(0.3)
    }

    // MARK: - Actions

    private func handleMainButton() {
        errorMessage = nil
        if recorder.isRecording {
            // Stop
            recorder.stopRecording()
            confirmedDuration = recorder.elapsed
            confirmedFileName = recorder.currentFileName
            Haptics.medium()
        } else if confirmedFileName != nil {
            // Re-record: discard existing and start fresh
            discardAndReset()
        } else {
            // Start recording
            guard recorder.permissionGranted == true else {
                Task { await recorder.requestPermission() }
                return
            }
            do {
                try recorder.startRecording()
                Haptics.light()
            } catch {
                errorMessage = "Could not start recording: \(error.localizedDescription)"
            }
        }
    }

    private func runTranscription() {
        guard let fileName = confirmedFileName else { return }
        errorMessage = nil

        Task {
            // Request auth if not yet determined
            if transcriptionSvc.authorizationStatus == .notDetermined {
                await transcriptionSvc.requestAuthorization()
            }
            do {
                let text = try await transcriptionSvc.transcribe(fileName: fileName)
                transcriptText = text
                hasTranscript = true
                Haptics.success()
            } catch {
                errorMessage = (error as? TranscriptionError)?.errorDescription
                    ?? error.localizedDescription
            }
        }
    }

    private func discardAndReset() {
        playback.stop()
        recorder.discardCurrentRecording()
        confirmedFileName = nil
        confirmedDuration = 0
        transcriptText = ""
        hasTranscript = false
        errorMessage = nil
        Haptics.light()
    }

    private func confirmRecording() {
        guard let fileName = confirmedFileName else { return }
        playback.stop()
        onConfirm(
            fileName,
            hasTranscript && !transcriptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? transcriptText.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil
        )
        dismiss()
    }

    // MARK: - Pulse animation

    private func startPulse() {
        guard !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
            pulse1Scale = 1.35
            pulse1Opacity = 0.0
        }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.25)) {
            pulse2Scale = 1.55
            pulse2Opacity = 0.0
        }
    }

    private func stopPulse() {
        withAnimation(.easeOut(duration: 0.25)) {
            pulse1Scale = 1.0
            pulse1Opacity = 0.5
            pulse2Scale = 1.0
            pulse2Opacity = 0.3
        }
    }
}
