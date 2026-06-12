// AudioRecorderService.swift
// TripTalk — Phase 5: Voice Journal
//
// PRIVACY MODEL:
//   Audio is recorded locally via AVAudioRecorder to the app's private
//   JournalAudio directory. No recording data ever leaves the device.
//   Permission is requested on first use via AVAudioApplication.requestRecordPermission (iOS 17+).
//   The session is deactivated after each recording to be a good audio-system citizen.

import AVFoundation
import Foundation
import Observation

/// Wraps AVAudioRecorder for private, on-device voice memo capture.
///
/// Create as `@State private var recorder = AudioRecorderService()` in a SwiftUI view,
/// or as a stored property in an `@Observable` view model.
/// All public methods are @MainActor-isolated; call them from SwiftUI or Task blocks.
@Observable
@MainActor
final class AudioRecorderService: NSObject {

    // MARK: - Observable state

    /// `true` while a recording is in progress.
    private(set) var isRecording = false

    /// Elapsed recording duration in seconds, updated every 0.1 s while recording.
    private(set) var elapsed: TimeInterval = 0

    /// The filename (not full path) of the most recent or in-progress recording.
    /// Pass to `JournalAudioStorage.audioFileURL(for:)` to resolve the on-disk URL.
    private(set) var currentFileName: String? = nil

    /// `nil` = user has not been asked yet. `true`/`false` = user's decision.
    private(set) var permissionGranted: Bool? = nil

    // MARK: - Private

    private var recorder: AVAudioRecorder?
    private var elapsedTimer: Timer?

    // MARK: - Permission

    /// Requests microphone access and stores the result in `permissionGranted`.
    ///
    /// Safe to call multiple times — subsequent calls query the existing permission
    /// status rather than re-prompting the user.
    func requestPermission() async {
        // Check current status first to avoid redundant prompts.
        // iOS 17+: AVAudioApplication replaces AVAudioSession for permission APIs.
        let currentStatus = AVAudioApplication.shared.recordPermission
        switch currentStatus {
        case .granted:
            permissionGranted = true
            return
        case .denied:
            permissionGranted = false
            return
        case .undetermined:
            break
        @unknown default:
            break
        }

        let granted = await AVAudioApplication.requestRecordPermission()
        permissionGranted = granted
    }

    // MARK: - Recording

    /// Configures the audio session and starts a new recording.
    ///
    /// - Returns: The generated audio filename (a value like `journal_<uuid>.m4a`).
    ///   Store this in `JournalEntry.audioFileName` after the recording is confirmed.
    /// - Throws: `AVFoundation` errors if the session or recorder cannot be configured.
    @discardableResult
    func startRecording() throws -> String {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try session.setActive(true)

        let fileName = JournalAudioStorage.generateFilename()
        let fileURL = try JournalAudioStorage.audioFileURL(for: fileName)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]

        let rec = try AVAudioRecorder(url: fileURL, settings: settings)
        rec.delegate = self
        rec.record()

        recorder = rec
        currentFileName = fileName
        isRecording = true
        elapsed = 0

        elapsedTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self else { return }
            MainActor.assumeIsolated {
                self.elapsed = self.recorder?.currentTime ?? self.elapsed
            }
        }

        return fileName
    }

    /// Stops the active recording and deactivates the audio session.
    ///
    /// After this returns, `currentFileName` holds the completed file's name.
    func stopRecording() {
        elapsedTimer?.invalidate()
        elapsedTimer = nil

        recorder?.stop()
        recorder = nil
        isRecording = false

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    /// Stops any in-progress recording and permanently deletes the audio file.
    ///
    /// Call this when the user taps "Discard" or "Re-record".
    func discardCurrentRecording() {
        stopRecording()
        if let fileName = currentFileName {
            try? JournalAudioStorage.deleteAudioFile(named: fileName)
            currentFileName = nil
        }
        elapsed = 0
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioRecorderService: AVAudioRecorderDelegate {

    nonisolated func audioRecorderDidFinishRecording(
        _ recorder: AVAudioRecorder,
        successfully flag: Bool
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.elapsedTimer?.invalidate()
            self.elapsedTimer = nil
            self.isRecording = false
            if !flag {
                // Encode or I/O failure — clean up the partial file.
                if let fileName = self.currentFileName {
                    try? JournalAudioStorage.deleteAudioFile(named: fileName)
                    self.currentFileName = nil
                }
            }
        }
    }

    nonisolated func audioRecorderEncodeErrorDidOccur(
        _ recorder: AVAudioRecorder,
        error: Error?
    ) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.elapsedTimer?.invalidate()
            self.elapsedTimer = nil
            self.isRecording = false
        }
    }
}
