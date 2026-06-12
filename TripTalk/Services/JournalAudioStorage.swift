// JournalAudioStorage.swift
// TripTalk — Phase 2: Local-only Trip Journal
//
// PRIVACY MODEL:
//   All audio recordings are stored exclusively on-device inside the app's
//   Application Support directory under a dedicated "JournalAudio" subfolder.
//   No audio file is ever uploaded, synced, or shared automatically.
//   Deleting a JournalEntry triggers JournalStore.delete(_:), which calls
//   JournalAudioStorage.deleteAudioFile(named:) to clean up the recording.

import Foundation

/// Filesystem helpers for managing private voice-memo audio files.
///
/// Files are stored at:
///   `<Application Support>/<bundle-id>/JournalAudio/<filename>`
///
/// Callers never construct paths manually — always go through the helpers
/// here to ensure consistent, predictable on-disk layout.
enum JournalAudioStorage {

    // MARK: - Directory

    /// Returns (and lazily creates) the dedicated audio storage directory.
    ///
    /// Placing files under Application Support rather than the Caches or
    /// tmp directories ensures recordings survive OS-managed cache purges.
    ///
    /// - Throws: FileManager errors if the directory cannot be created.
    static func audioDirectory() throws -> URL {
        let fm = FileManager.default
        guard let appSupport = fm.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw JournalAudioError.cannotResolveAppSupportDirectory
        }

        let bundleId = Bundle.main.bundleIdentifier ?? "com.triptalk.app"
        let audioDir = appSupport
            .appendingPathComponent(bundleId, isDirectory: true)
            .appendingPathComponent("JournalAudio", isDirectory: true)

        if !fm.fileExists(atPath: audioDir.path) {
            try fm.createDirectory(at: audioDir, withIntermediateDirectories: true)
        }

        return audioDir
    }

    // MARK: - Filename generation

    /// Generates a unique filename for a new audio recording.
    ///
    /// Format: `journal_<uuid>.<ext>` — e.g. `journal_A1B2C3D4-....m4a`
    ///
    /// The caller should pass the file extension matching the AVAudioRecorder
    /// format in use (typically "m4a" for AAC/MPEG-4 Audio, or "caf").
    ///
    /// - Parameter ext: File extension without leading dot. Defaults to "m4a".
    /// - Returns: A filename string (not a full path).
    static func generateFilename(ext: String = "m4a") -> String {
        "journal_\(UUID().uuidString).\(ext)"
    }

    // MARK: - URL resolution

    /// Returns the full on-disk URL for the given audio filename.
    ///
    /// Use this to pass a URL to `AVAudioRecorder` or `AVAudioPlayer`.
    ///
    /// - Parameter fileName: The value stored in `JournalEntry.audioFileName`.
    /// - Throws: `JournalAudioError.cannotResolveAppSupportDirectory` if the
    ///   base directory cannot be resolved.
    static func audioFileURL(for fileName: String) throws -> URL {
        try audioDirectory().appendingPathComponent(fileName)
    }

    // MARK: - Deletion

    /// Deletes the audio file with the given filename from disk.
    ///
    /// Called automatically by `JournalStore.delete(_:)` when an entry is removed.
    /// Safe to call if the file does not exist (no-op).
    ///
    /// - Parameter fileName: The value stored in `JournalEntry.audioFileName`.
    /// - Throws: FileManager errors for permission or I/O failures (not thrown
    ///   for "file not found" — that case is silently ignored).
    static func deleteAudioFile(named fileName: String) throws {
        let url = try audioFileURL(for: fileName)
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else { return }
        try fm.removeItem(at: url)
    }

    // MARK: - Existence check

    /// Returns `true` if the audio file exists on disk.
    ///
    /// Useful for defensive UI checks before attempting playback.
    static func audioFileExists(named fileName: String) -> Bool {
        guard let url = try? audioFileURL(for: fileName) else { return false }
        return FileManager.default.fileExists(atPath: url.path)
    }
}

// MARK: - Errors

enum JournalAudioError: LocalizedError {
    case cannotResolveAppSupportDirectory

    var errorDescription: String? {
        switch self {
        case .cannotResolveAppSupportDirectory:
            return "JournalAudioStorage: cannot resolve Application Support directory."
        }
    }
}
