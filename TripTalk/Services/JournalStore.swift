// JournalStore.swift
// TripTalk — Phase 2: Local-only Trip Journal
//
// PRIVACY MODEL:
//   JournalStore owns a SwiftData ModelContainer configured for LOCAL-ONLY
//   storage (no CloudKit, on-disk SQLite under Application Support).
//   No network calls are made anywhere in this file.
//   Deleting an entry cascades to its on-disk audio file via JournalAudioStorage.

import Foundation
import SwiftData
import Observation

/// Manages all CRUD operations for private, on-device `JournalEntry` records.
///
/// Inject this as an environment object from `TripTalkApp` or a scene root.
/// The underlying SwiftData container stores data locally in the app's
/// Application Support directory — no iCloud, no Supabase, no sync.
@Observable
final class JournalStore {

    // MARK: - SwiftData stack

    /// The ModelContainer for JournalEntry. Configured local-only (no CloudKit).
    let container: ModelContainer

    /// Main-actor context used for all UI-facing reads and writes.
    @ObservationIgnored
    private let context: ModelContext

    // MARK: - Init

    /// Creates (or opens) the local SwiftData store for JournalEntry.
    ///
    /// - Parameter inMemory: Pass `true` in unit tests to use an ephemeral store.
    init(inMemory: Bool = false) {
        let schema = Schema([JournalEntry.self])

        // LOCAL-ONLY configuration (no CloudKit, no network).
        // In-memory init for tests vs. on-disk init for production use
        // different ModelConfiguration initializers.
        let finalConfig: ModelConfiguration
        if inMemory {
            finalConfig = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true,
                allowsSave: true,
                cloudKitDatabase: .none
            )
        } else {
            finalConfig = ModelConfiguration(
                schema: schema,
                url: Self.storeURL(),
                allowsSave: true,
                cloudKitDatabase: .none
            )
        }

        do {
            container = try ModelContainer(for: schema, configurations: [finalConfig])
        } catch {
            // Fatal: if the local store can't open, the journal feature is broken.
            // In production this should not happen; schema migrations are additive.
            fatalError("JournalStore: failed to create ModelContainer — \(error)")
        }

        context = ModelContext(container)
        context.autosaveEnabled = true
    }

    // MARK: - CRUD

    /// Inserts a new `JournalEntry` into the local store.
    /// - Parameter entry: A freshly constructed entry; its `id` must be unique.
    func create(_ entry: JournalEntry) throws {
        context.insert(entry)
        try context.save()
    }

    /// Persists in-place mutations made to an already-tracked `JournalEntry`.
    ///
    /// Callers should set `entry.updatedAt = Date()` before calling this.
    func update(_ entry: JournalEntry) throws {
        entry.updatedAt = Date()
        try context.save()
    }

    /// Deletes a `JournalEntry` from the local store.
    ///
    /// If the entry has an associated audio file, that file is also removed
    /// from disk so no orphaned recordings accumulate.
    func delete(_ entry: JournalEntry) throws {
        // Cascade delete the audio file before removing the model record.
        if let audioFileName = entry.audioFileName {
            try? JournalAudioStorage.deleteAudioFile(named: audioFileName)
        }
        context.delete(entry)
        try context.save()
    }

    /// Returns all journal entries sorted by creation date, newest first.
    func fetchAll() throws -> [JournalEntry] {
        let descriptor = FetchDescriptor<JournalEntry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    /// Returns a single entry matching the given `id`, or `nil` if not found.
    func fetch(by id: UUID) throws -> JournalEntry? {
        var descriptor = FetchDescriptor<JournalEntry>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    // MARK: - Store URL

    /// Resolves the on-disk URL for the SQLite store.
    ///
    /// Stored under `Application Support/<bundle-id>/JournalStore.sqlite`
    /// so it survives OS-managed cache purges.
    private static func storeURL() -> URL {
        let fm = FileManager.default
        guard let appSupport = fm.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            fatalError("JournalStore: cannot resolve Application Support directory")
        }

        let bundleId = Bundle.main.bundleIdentifier ?? "com.triptalk.app"
        let storeDir = appSupport.appendingPathComponent(bundleId, isDirectory: true)

        try? fm.createDirectory(at: storeDir, withIntermediateDirectories: true)

        return storeDir.appendingPathComponent("JournalStore.sqlite")
    }
}
