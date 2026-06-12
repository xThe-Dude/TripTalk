// AudioPlaybackService.swift
// TripTalk — Phase 5: Voice Journal
//
// Lightweight AVAudioPlayer wrapper used in VoiceRecorderView (post-record preview)
// and JournalEntryDetailView (read-only playback). Handles session activation and
// end-of-playback detection via AVAudioPlayerDelegate.

import AVFoundation
import Foundation
import Observation

/// Wraps `AVAudioPlayer` for simple on-device audio file playback.
///
/// Create as `@State private var playback = AudioPlaybackService()` in a SwiftUI view.
/// All methods must be called on the MainActor (SwiftUI body satisfies this).
@Observable
@MainActor
final class AudioPlaybackService: NSObject {

    // MARK: - Observable state

    private(set) var isPlaying = false
    private(set) var playbackError: String? = nil

    // MARK: - Private

    private var player: AVAudioPlayer?

    // MARK: - Playback

    /// Starts playback of the given file. Configures the audio session for playback.
    ///
    /// - Parameter fileName: The `JournalEntry.audioFileName` value.
    ///   Resolved to a full URL via `JournalAudioStorage.audioFileURL(for:)`.
    func play(fileName: String) {
        playbackError = nil
        do {
            let url = try JournalAudioStorage.audioFileURL(for: fileName)
            guard JournalAudioStorage.audioFileExists(named: fileName) else {
                playbackError = "Audio file not found on device."
                return
            }
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            p.play()
            player = p
            isPlaying = true
        } catch {
            playbackError = "Playback failed: \(error.localizedDescription)"
        }
    }

    /// Stops playback and deactivates the audio session.
    func stop() {
        player?.stop()
        player = nil
        isPlaying = false
        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
    }

    /// Toggles play/stop for the given file.
    func togglePlayback(fileName: String) {
        if isPlaying {
            stop()
        } else {
            play(fileName: fileName)
        }
    }

    // MARK: - Cleanup
    //
    // No custom deinit: `player` is @MainActor-isolated and cannot be touched
    // from the nonisolated deinit context. AVAudioPlayer stops and releases
    // itself on deallocation, and `stop()` / the delegate callbacks already
    // tear down the session, so explicit cleanup here is unnecessary.
}

// MARK: - AVAudioPlayerDelegate

extension AudioPlaybackService: AVAudioPlayerDelegate {

    nonisolated func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {
        Task { @MainActor [weak self] in
            self?.player = nil
            self?.isPlaying = false
            try? AVAudioSession.sharedInstance().setActive(
                false,
                options: .notifyOthersOnDeactivation
            )
        }
    }

    nonisolated func audioPlayerDecodeErrorDidOccur(
        _ player: AVAudioPlayer,
        error: Error?
    ) {
        Task { @MainActor [weak self] in
            self?.player = nil
            self?.isPlaying = false
            self?.playbackError = error?.localizedDescription ?? "Playback error."
        }
    }
}
