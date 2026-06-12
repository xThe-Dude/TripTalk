// TranscriptionService.swift
// TripTalk — Phase 5: Voice Journal
//
// PRIVACY MODEL:
//   Transcription is performed exclusively on-device via Apple's Speech framework.
//   `requiresOnDeviceRecognition = true` is always set; no audio is ever sent to
//   Apple's servers or any remote endpoint. If on-device recognition is unavailable
//   for the user's locale, a clear error is thrown — we never silently fall back
//   to server-side processing.

import Foundation
import Speech
import Observation

// MARK: - Errors

enum TranscriptionError: LocalizedError {
    case permissionDenied
    case recognizerUnavailable
    case onDeviceNotAvailable
    case noTranscriptProduced
    case recognitionFailed(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Speech recognition permission was denied. Go to Settings → Privacy → Speech Recognition to enable it."
        case .recognizerUnavailable:
            return "On-device speech recognition is not available right now. Please try again later."
        case .onDeviceNotAvailable:
            return "On-device transcription is not available for your language. You can download the language pack in Settings → General → Language & Region."
        case .noTranscriptProduced:
            return "The recording could not be transcribed — it may be too short, too quiet, or contain no speech."
        case .recognitionFailed(let error):
            return "Transcription failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - TranscriptionService

/// On-device speech-to-text using Apple's Speech framework.
///
/// `requiresOnDeviceRecognition` is always `true`. If on-device recognition is not
/// available for the current locale, `TranscriptionError.onDeviceNotAvailable` is
/// thrown — we never silently fall back to server-side processing.
///
/// Usage:
/// ```swift
/// let ts = TranscriptionService()
/// await ts.requestAuthorization()
/// let text = try await ts.transcribe(fileName: entry.audioFileName!)
/// ```
@Observable
@MainActor
final class TranscriptionService {

    // MARK: - Observable state

    private(set) var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    private(set) var isTranscribing = false

    // MARK: - Authorization

    /// Requests Speech Recognition permission and stores the result in `authorizationStatus`.
    func requestAuthorization() async {
        let status = await withCheckedContinuation { (continuation: CheckedContinuation<SFSpeechRecognizerAuthorizationStatus, Never>) in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        authorizationStatus = status
    }

    // MARK: - Transcription

    /// Transcribes the given audio file on-device and returns the best transcript string.
    ///
    /// - Parameter fileName: The `JournalEntry.audioFileName` value.
    ///   The URL is resolved via `JournalAudioStorage.audioFileURL(for:)`.
    /// - Returns: The best transcription string from the on-device model.
    /// - Throws: `TranscriptionError` for any failure condition, including
    ///   on-device unavailability (never falls back to server recognition).
    func transcribe(fileName: String) async throws -> String {
        guard authorizationStatus == .authorized else {
            throw TranscriptionError.permissionDenied
        }

        let url = try JournalAudioStorage.audioFileURL(for: fileName)

        guard let recognizer = SFSpeechRecognizer() else {
            throw TranscriptionError.recognizerUnavailable
        }

        guard recognizer.isAvailable else {
            throw TranscriptionError.recognizerUnavailable
        }

        // Enforce on-device-only policy: refuse to proceed if on-device is unavailable.
        guard recognizer.supportsOnDeviceRecognition else {
            throw TranscriptionError.onDeviceNotAvailable
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        request.requiresOnDeviceRecognition = true
        request.shouldReportPartialResults = false

        isTranscribing = true
        defer {
            // This defer runs on MainActor when the async function exits.
            isTranscribing = false
        }

        return try await withCheckedThrowingContinuation { continuation in
            var didResume = false
            var recognitionTask: SFSpeechRecognitionTask?

            recognitionTask = recognizer.recognitionTask(with: request) { result, error in
                guard !didResume else { return }

                if let error {
                    let nsErr = error as NSError
                    // Code 203 in kAFAssistantErrorDomain typically means on-device
                    // recognition is not available / language pack not downloaded.
                    if nsErr.domain == "kAFAssistantErrorDomain" && nsErr.code == 203 {
                        didResume = true
                        recognitionTask = nil
                        continuation.resume(throwing: TranscriptionError.onDeviceNotAvailable)
                        return
                    }
                    didResume = true
                    recognitionTask = nil
                    continuation.resume(throwing: TranscriptionError.recognitionFailed(error))
                    return
                }

                guard let result else { return }

                if result.isFinal {
                    let text = result.bestTranscription.formattedString
                    didResume = true
                    recognitionTask = nil
                    if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        continuation.resume(throwing: TranscriptionError.noTranscriptProduced)
                    } else {
                        continuation.resume(returning: text)
                    }
                }
            }

            // Retain the task until completion to prevent premature deallocation.
            _ = recognitionTask
        }
    }
}
