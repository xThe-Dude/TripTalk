// JournalEntry.swift
// TripTalk — Phase 2: Local-only Trip Journal
//
// PRIVACY MODEL:
//   JournalEntry is stored exclusively on-device via SwiftData.
//   It is never synced to Supabase, CloudKit, or any remote backend.
//   Deleting an entry cascades to its associated audio file on disk.
//   isPrivate defaults to true and is retained for future per-entry
//   export controls; no entry data leaves the device automatically.

import Foundation
import SwiftData

/// A private, on-device trip journal entry.
///
/// Distinct from `TripReport` (the public community review struct).
/// JournalEntry lives entirely in a local SwiftData store — no network,
/// no CloudKit. All enum-like values are persisted as raw `String` so
/// SwiftData does not need to understand custom Swift types.
@Model
final class JournalEntry {

    // MARK: - Identity

    /// Stable identifier used across CRUD operations and audio file naming.
    var id: UUID

    /// Wall-clock time the entry was first created.
    var createdAt: Date

    /// Wall-clock time the entry was last modified.
    var updatedAt: Date

    // MARK: - Substance

    /// Optional reference to a catalog substance UUID (links to Strain/Substance).
    var substanceId: UUID?

    /// Human-readable substance name, stored redundantly so the entry
    /// remains readable even if the catalog row changes or is removed.
    var substanceName: String

    // MARK: - Shared experience fields (mirrors TripReport structure)
    // Stored as primitives / String so SwiftData can encode them directly.

    /// 1-5 star rating; nil if the user hasn't rated yet.
    var rating: Int?

    /// Setting description (e.g. "home", "nature", "social").
    /// Stored as String — use TripSetting.rawValue when bridging to public reviews.
    var setting: String

    /// The user's stated intention for the session.
    var intention: String

    /// Experience type tags selected by the user (e.g. ["visual", "creative"]).
    /// Stored as [String]; use ExperienceType.rawValue when bridging.
    var experienceTypes: [String]

    /// Self-reported visual intensity on a 0-5 scale; nil if not assessed.
    var visualIntensity: Int?

    /// Self-reported body/physical intensity on a 0-5 scale.
    var bodyIntensity: Int?

    /// Self-reported emotional/psychological intensity on a 0-5 scale.
    var emotionalIntensity: Int?

    /// Mood tags for the session (e.g. ["euphoric", "introspective"]).
    /// Stored as [String]; use MoodTag.rawValue when bridging.
    var moods: [String]

    /// Free-form highlights / positive moments from the session.
    var highlights: String

    /// Safety observations, concerns, or notes for future reference.
    var safetyNotes: String

    /// Whether the user would repeat this session; nil if undecided.
    var wouldRepeat: Bool?

    // MARK: - Journal-specific phase notes

    /// Notes captured during the preparation / set-and-setting phase.
    var phasePrepareNotes: String

    /// Notes captured during the onset phase.
    var phaseOnsetNotes: String

    /// Notes captured during the peak phase.
    var phasePeakNotes: String

    /// Notes captured during the integration / come-down phase.
    var phaseIntegrationNotes: String

    // MARK: - Entry kind & audio

    /// How the entry was created. Valid values: "text" | "voice".
    /// Stored as String to avoid SwiftData enum limitations on older betas.
    var entryKind: String

    /// Filename (not full path) of the associated audio recording, if any.
    /// Combine with `JournalAudioStorage.audioFileURL(for:)` to resolve the
    /// full on-disk URL. Nil when entryKind == "text" or recording was deleted.
    var audioFileName: String?

    /// Speech-to-text transcript of the audio recording, if available.
    var transcript: String?

    // MARK: - Privacy

    /// Always true by default — entry data never leaves the device automatically.
    /// Retained as a field to support future per-entry selective export controls
    /// without a schema migration.
    var isPrivate: Bool

    // MARK: - Init

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        substanceId: UUID? = nil,
        substanceName: String = "",
        rating: Int? = nil,
        setting: String = "",
        intention: String = "",
        experienceTypes: [String] = [],
        visualIntensity: Int? = nil,
        bodyIntensity: Int? = nil,
        emotionalIntensity: Int? = nil,
        moods: [String] = [],
        highlights: String = "",
        safetyNotes: String = "",
        wouldRepeat: Bool? = nil,
        phasePrepareNotes: String = "",
        phaseOnsetNotes: String = "",
        phasePeakNotes: String = "",
        phaseIntegrationNotes: String = "",
        entryKind: String = "text",
        audioFileName: String? = nil,
        transcript: String? = nil,
        isPrivate: Bool = true
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.substanceId = substanceId
        self.substanceName = substanceName
        self.rating = rating
        self.setting = setting
        self.intention = intention
        self.experienceTypes = experienceTypes
        self.visualIntensity = visualIntensity
        self.bodyIntensity = bodyIntensity
        self.emotionalIntensity = emotionalIntensity
        self.moods = moods
        self.highlights = highlights
        self.safetyNotes = safetyNotes
        self.wouldRepeat = wouldRepeat
        self.phasePrepareNotes = phasePrepareNotes
        self.phaseOnsetNotes = phaseOnsetNotes
        self.phasePeakNotes = phasePeakNotes
        self.phaseIntegrationNotes = phaseIntegrationNotes
        self.entryKind = entryKind
        self.audioFileName = audioFileName
        self.transcript = transcript
        self.isPrivate = isPrivate
    }
}
