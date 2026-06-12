# V3 Phase 5 — Xcode Integration Steps

> Branch: `v3/phase5-voice`
> Date: 2026-06-12

These are the manual steps to complete in **Xcode** after pulling this branch.
The Swift files are compile-correct; these steps add new files to the TripTalk target
so they participate in the build.

---

## 1. Add new service files to the `TripTalk` target

**File → Add Files to "TripTalk"…** (or drag into the Project Navigator).
Ensure **"Add to targets: TripTalk"** is checked for each file.

| File path (relative to repo root) | Navigator group |
|-----------------------------------|-----------------|
| `TripTalk/Services/AudioRecorderService.swift` | Services |
| `TripTalk/Services/TranscriptionService.swift` | Services |
| `TripTalk/Services/AudioPlaybackService.swift` | Services |
| `TripTalk/Views/Journal/VoiceRecorderView.swift` | Views/Journal |

> **Quick check:** select each file → File Inspector (right panel) →
> confirm "Target Membership → TripTalk" is ticked.

---

## 2. Modified existing files (already in target — no action needed)

These files were edited in-place and are already members of the TripTalk target:

| File | Change |
|------|--------|
| `TripTalk/Views/Journal/JournalEntryEditorView.swift` | Added Voice Note section, voice @State fields, `voiceNoteSection`, `removeVoiceRecording()`, voice fields wired into `saveEntry()` and `populateFields()` |
| `TripTalk/Views/Journal/JournalEntryDetailView.swift` | Added `voicePlaybackSection` (after headerSection), `AudioPlaybackService` @State |
| `TripTalk/Info.plist` | Added `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription` |

---

## 3. Info.plist permission keys (already added — verify)

Open `TripTalk/Info.plist` and confirm both keys are present:

| Key | Value |
|-----|-------|
| `NSMicrophoneUsageDescription` | `TripTalk uses the microphone so you can record private voice notes in your journal. Recordings stay on your device.` |
| `NSSpeechRecognitionUsageDescription` | `TripTalk transcribes your voice notes on your device. Audio is never uploaded.` |

Without these keys the app will **crash at runtime** when requesting microphone
or speech recognition access on a real device.

---

## 4. System frameworks required

Phase 5 uses two additional system frameworks. They may already be linked
(they are part of the iOS SDK), but **verify** in Xcode:

1. **AVFoundation** — already linked by prior phases (audio session, recorder, player)
2. **Speech** — NEW in Phase 5 (on-device speech recognition)

To add the Speech framework if it is missing:
- Select the **TripTalk** project → **TripTalk** target → **General** tab →
  scroll to **Frameworks, Libraries, and Embedded Content** → **"+"** →
  search for `Speech.framework` → **Add**.

---

## 5. On-device speech recognition — language pack note

`TranscriptionService` sets `requiresOnDeviceRecognition = true`, which means:

- **On-device recognition must be available for the user's language.**
- The user may need to download the language pack:
  **Settings → General → Language & Region → Speech Recognition / Preferred Language**
  (the exact path varies by iOS version and locale).
- If the language pack is not installed, transcription throws
  `TranscriptionError.onDeviceNotAvailable`, which the UI surfaces with a
  calm, actionable error message (no crash, no silent server fallback).
- `SFSpeechRecognizer.supportsOnDeviceRecognition` is checked before attempting
  transcription; if `false`, the error is thrown immediately.

---

## 6. Privacy model summary

| Data | Where it goes |
|------|--------------|
| Audio recordings (.m4a) | `Application Support/<bundle-id>/JournalAudio/` — on-device only |
| Transcripts | SwiftData local store — on-device only |
| Network requests | **None** — zero network calls in Phase 5 code |
| Microphone data | Never streamed; written directly to local file by AVAudioRecorder |
| Speech recognition | `requiresOnDeviceRecognition = true` — on-device model only |

Deleting a `JournalEntry` via `JournalStore.delete(_:)` automatically removes the
associated audio file via `JournalAudioStorage.deleteAudioFile(named:)`.
The editor's "Remove Recording" button also calls `JournalAudioStorage.deleteAudioFile`
immediately so no orphaned audio files accumulate.

---

## 7. What Phase 5 adds

### `TripTalk/Services/AudioRecorderService.swift`
`@Observable @MainActor` class wrapping `AVAudioRecorder`. Configures the
`.playAndRecord` audio session, generates a unique filename via
`JournalAudioStorage.generateFilename()`, records to `.m4a` (AAC, 44100 Hz,
mono, medium quality). Exposes `isRecording`, `elapsed` (updated every 0.1 s),
`currentFileName`, and `permissionGranted`. `discardCurrentRecording()` stops
and deletes the partial file.

### `TripTalk/Services/TranscriptionService.swift`
`@Observable @MainActor` class. Calls `SFSpeechRecognizer.requestAuthorization`,
creates an `SFSpeechURLRecognitionRequest` with `requiresOnDeviceRecognition = true`
and `shouldReportPartialResults = false`, then runs the recognizer asynchronously.
Returns the `bestTranscription.formattedString`. Throws typed `TranscriptionError`
for all failure cases. Never falls back to server recognition.

### `TripTalk/Services/AudioPlaybackService.swift`
`@Observable @MainActor` class wrapping `AVAudioPlayer`. Configures `.playback`
session, provides `play(fileName:)`, `stop()`, `togglePlayback(fileName:)`.
Used in both `VoiceRecorderView` (post-record preview) and
`JournalEntryDetailView` (read-only playback).

### `TripTalk/Views/Journal/VoiceRecorderView.swift`
SwiftUI sheet. Presents a large record/stop button with a pulsing ring animation
(reduced-motion safe), elapsed time counter, post-record controls (play/pause,
transcribe, discard, confirm), editable transcript `TextEditor`, and a
permission-denied fallback with a Settings deep link. Returns
`(audioFileName: String, transcript: String?)` via `onConfirm` callback.
Includes a persistent privacy badge: "Recorded and transcribed on your device.
Nothing is uploaded."

### Changes to `JournalEntryEditorView.swift`
- New "Voice Note" section (below Reflection) with "Add Voice Note" button
  or, if a recording exists, playback preview + transcript + remove button.
- `isEmptyEntry` now also checks `voiceFileName == nil`.
- `saveEntry()` sets `entry.entryKind`, `entry.audioFileName`, `entry.transcript`.
- `populateFields()` restores voice fields when editing an existing voice entry.

### Changes to `JournalEntryDetailView.swift`
- New `voicePlaybackSection` inserted after `headerSection`.
- Shows play/pause button (via `AudioPlaybackService`) and transcript text
  when `entry.entryKind == "voice"` and the audio file exists on disk.

---

## 8. Summary checklist

| Step | Action | Status |
|------|--------|--------|
| Add 4 new Swift files to TripTalk target | Manual in Xcode | **TODO** |
| Modified files (editor, detail, Info.plist) | Already in target | OK |
| Verify Info.plist has microphone + speech keys | Inspect in Xcode | **TODO** |
| Link `Speech.framework` if not already present | Manual in Xcode | **TODO** |
| Test on real device (speech recognition needs device) | QA | **TODO** |
| Download language pack if on-device speech unavailable | Device Settings | As needed |
