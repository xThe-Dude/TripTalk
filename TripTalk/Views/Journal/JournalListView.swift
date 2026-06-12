// JournalListView.swift
// TripTalk — Phase 4: Journal UI
//
// Lists all private on-device journal entries (newest first).
// Tapping a row opens JournalEntryDetailView; the "+" button opens
// JournalEntryEditorView to create a new entry.

import SwiftUI

struct JournalListView: View {
    @Environment(AppState.self) private var appState
    @State private var entries: [JournalEntry] = []
    @State private var showNewEntry = false
    @State private var loadError: String? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                GradientBackground()

                if entries.isEmpty && loadError == nil {
                    emptyState
                } else {
                    entryList
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color.ttAccent)
                    }
                    .accessibilityLabel("New journal entry")
                }
            }
            .sheet(isPresented: $showNewEntry, onDismiss: loadEntries) {
                JournalEntryEditorView()
            }
            .onAppear(perform: loadEntries)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack {
            Spacer()
            EmptyStateView(
                icon: "book.closed.fill",
                title: "No journeys logged yet",
                subtitle: "Your first entry starts your journal.",
                actionLabel: "New Entry",
                action: { showNewEntry = true }
            )
            .padding(.horizontal, TTDesign.spacingXL)
            Spacer()
        }
    }

    // MARK: - Entry List

    private var entryList: some View {
        ScrollView {
            LazyVStack(spacing: TTDesign.spacingMD) {
                ForEach(entries) { entry in
                    NavigationLink(destination: JournalEntryDetailView(entry: entry, onUpdate: loadEntries)) {
                        JournalEntryRow(entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, TTDesign.spacingLG)
            .padding(.top, TTDesign.spacingMD)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Data

    private func loadEntries() {
        do {
            entries = try appState.journal.fetchAll()
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }
}

// MARK: - Row

private struct JournalEntryRow: View {
    let entry: JournalEntry

    private var titleText: String {
        entry.substanceName.isEmpty ? "Untitled journey" : entry.substanceName
    }

    private var snippetText: String {
        let intention = entry.intention.trimmingCharacters(in: .whitespacesAndNewlines)
        let highlights = entry.highlights.trimmingCharacters(in: .whitespacesAndNewlines)
        if !intention.isEmpty { return intention }
        if !highlights.isEmpty { return highlights }
        return "No notes yet."
    }

    var body: some View {
        HStack(alignment: .top, spacing: TTDesign.spacingMD) {
            // Left accent strip
            RoundedRectangle(cornerRadius: 2)
                .fill(Color.ttAccent.opacity(0.6))
                .frame(width: 3)

            VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
                // Title + date row
                HStack(alignment: .firstTextBaseline) {
                    Text(titleText)
                        .font(.ttCardTitle)
                        .foregroundStyle(Color.ttPrimary)
                        .lineLimit(1)

                    Spacer(minLength: TTDesign.spacingSM)

                    Text(entry.createdAt, style: .date)
                        .font(.ttCaption)
                        .foregroundStyle(Color.ttTertiary)
                }

                // Snippet
                Text(snippetText)
                    .font(.ttBody)
                    .foregroundStyle(Color.ttSecondary)
                    .lineLimit(1)

                // Rating chips (if rated)
                if let rating = entry.rating {
                    HStack(spacing: TTDesign.spacingXS) {
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: i <= rating ? "star.fill" : "star")
                                .font(.system(size: 11))
                                .foregroundStyle(i <= rating ? Color.ttAccent : Color.ttTertiary)
                        }
                    }
                    .padding(.top, 2)
                }
            }
        }
        .padding(TTDesign.spacingLG)
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
