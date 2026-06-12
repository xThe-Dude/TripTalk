// JourneyTimelineView.swift
// TripTalk — Phase 3: Journey Timeline
//
// The app's signature interaction: a visual four-phase timeline showing
// what to expect across Prepare → Onset → Peak → Integration.
//
// Design principles:
//  · Editorial, calm — matches triptalk.guide aesthetic.
//  · TTType fonts and tt color tokens throughout; no hardcoded values.
//  · Reduced motion: no essential information is conveyed through animation
//    alone. All content is visible in the static layout.
//  · Live mode is framed as safety/awareness only; never as optimisation.
//  · No timers — the live hint reflects time at the moment of render.

import SwiftUI

// MARK: - JourneyTimelineView

/// A vertical four-phase timeline for a psychedelic experience.
///
/// **Basic usage** (static, no active phase):
/// ```swift
/// JourneyTimelineView(onset: "30-60 min", duration: "4-6 hours", strainName: "Golden Teachers")
/// ```
///
/// **Live mode** (shows which phase is currently active, safety-framed):
/// ```swift
/// JourneyTimelineView(strain: selectedStrain, ingestionDate: session.startDate)
/// ```
struct JourneyTimelineView: View {

    // MARK: - Inputs

    let strainName: String
    let onset: String
    let duration: String

    /// When provided, the view highlights the current phase and shows an
    /// awareness hint ("~45 min in · peak in ~30 min"). Never nil-checks required
    /// in the body — `nil` simply disables all live-mode rendering.
    var ingestionDate: Date? = nil

    // MARK: - Convenience initialisers

    /// Create the timeline from an existing `Strain` value.
    init(strain: Strain, ingestionDate: Date? = nil) {
        self.strainName    = strain.name
        self.onset         = strain.onset
        self.duration      = strain.duration
        self.ingestionDate = ingestionDate
    }

    /// Create the timeline from raw strings (useful in previews and unit tests).
    init(onset: String, duration: String, strainName: String, ingestionDate: Date? = nil) {
        self.onset         = onset
        self.duration      = duration
        self.strainName    = strainName
        self.ingestionDate = ingestionDate
    }

    // MARK: - Derived state

    private var timing: PhaseTiming {
        PhaseTiming.parse(onset: onset, duration: duration)
    }

    /// The currently active phase, or `nil` when no ingestion date is set.
    private var activePhase: JourneyPhase? {
        guard let date = ingestionDate else { return nil }
        let elapsed = Int(Date().timeIntervalSince(date) / 60)
        return JourneyPhase.current(at: elapsed, timing: timing)
    }

    /// Elapsed minutes since ingestion, or `nil` when no ingestion date is set.
    private var elapsedMinutes: Int? {
        guard let date = ingestionDate else { return nil }
        return Int(Date().timeIntervalSince(date) / 60)
    }

    /// Safety-awareness hint text rendered in the live-mode banner.
    /// Returns `nil` when no `ingestionDate` is provided.
    private var liveHintText: String? {
        guard let elapsed = elapsedMinutes else { return nil }

        if elapsed < 0 {
            let until = JourneyPhase.formatMinutes(abs(elapsed))
            return "Ingestion in ~\(until)"
        }

        let current     = JourneyPhase.current(at: elapsed, timing: timing)
        let elapsedStr  = JourneyPhase.formatMinutes(elapsed)

        switch current {
        case .prepare:
            return "Beginning · ingestion at T+0"
        case .onset:
            let remaining = max(1, timing.onsetEnd - elapsed)
            return "~\(elapsedStr) in · peak in ~\(JourneyPhase.formatMinutes(remaining))"
        case .peak:
            let remaining = max(1, timing.peakEnd - elapsed)
            return "~\(elapsedStr) in · winding down in ~\(JourneyPhase.formatMinutes(remaining))"
        case .integration:
            let remaining = timing.totalEnd - elapsed
            if remaining > 0 {
                return "~\(elapsedStr) in · ~\(JourneyPhase.formatMinutes(remaining)) remaining"
            }
            return "~\(elapsedStr) in · approaching baseline"
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Header ──────────────────────────────────────────────────
            headerSection
                .padding(.bottom, TTDesign.spacingXL)

            // ── Phase rows ──────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 0) {
                ForEach(JourneyPhase.allCases, id: \.self) { phase in
                    phaseRow(phase: phase, isLast: phase == .integration)
                }
            }

            // ── Live awareness banner ────────────────────────────────────
            if let hint = liveHintText {
                liveHintBanner(hint)
                    .padding(.top, TTDesign.spacingLG)
            }

            // ── Estimated-timing disclaimer ──────────────────────────────
            if timing.wasEstimated {
                Text("Timing is estimated — exact onset and duration vary by dose, set, and setting.")
                    .font(.ttCaption)
                    .foregroundColor(.ttTertiary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, TTDesign.spacingMD)
            }
        }
        .padding(TTDesign.spacingLG)
        .background(Color.ttSheetBg)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
            Text("Journey Timeline")
                .font(.ttEyebrow)
                .foregroundColor(.ttTertiary)

            Text(strainName)
                .font(.ttSection)
                .foregroundColor(.ttPrimary)

            if timing.wasEstimated {
                Label("Timing estimated", systemImage: "info.circle")
                    .font(.ttCaption)
                    .foregroundColor(.ttTertiary)
                    .padding(.top, TTDesign.spacingXS)
            }
        }
    }

    // MARK: - Phase row

    private func phaseRow(phase: JourneyPhase, isLast: Bool) -> some View {
        let isActive = activePhase == phase

        return HStack(alignment: .top, spacing: TTDesign.spacingMD) {

            // Left column: icon node + vertical connector
            VStack(spacing: 0) {
                iconNode(for: phase, isActive: isActive)
                if !isLast {
                    Rectangle()
                        .fill(Color.ttSecondary.opacity(0.15))
                        .frame(width: 2, height: 40)
                }
            }

            // Right column: labels
            VStack(alignment: .leading, spacing: TTDesign.spacingXS) {
                HStack(spacing: TTDesign.spacingXS) {
                    Text(phase.title.uppercased())
                        .font(.ttEyebrow)
                        .foregroundColor(isActive ? .ttAccent : .ttTertiary)

                    // Active-phase indicator dot
                    if isActive {
                        Circle()
                            .fill(Color.ttAccent)
                            .frame(width: 5, height: 5)
                    }
                }

                Text(phase.shortDescription)
                    .font(.ttBody)
                    .foregroundColor(.ttPrimary)

                Text(phase.timeLabel(using: timing))
                    .font(.ttCaption)
                    .foregroundColor(isActive ? .ttSecondary : .ttTertiary)
            }
            .padding(.bottom, isLast ? 0 : TTDesign.spacingMD)

            Spacer(minLength: 0)
        }
    }

    // MARK: - Icon node

    private func iconNode(for phase: JourneyPhase, isActive: Bool) -> some View {
        ZStack {
            Circle()
                .fill(isActive
                      ? Color.ttAccent.opacity(0.12)
                      : Color.white.opacity(0.04))
                .frame(width: 36, height: 36)

            Circle()
                .stroke(
                    isActive
                        ? Color.ttAccent.opacity(0.45)
                        : Color.ttSecondary.opacity(0.18),
                    lineWidth: isActive ? 1.5 : 1
                )
                .frame(width: 36, height: 36)

            Image(systemName: phase.symbolName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isActive ? .ttAccent : .ttSecondary)
        }
    }

    // MARK: - Live hint banner

    /// Subtle safety-awareness banner shown when an ingestion date is provided.
    /// Framed as orientation/awareness, never as optimisation language.
    private func liveHintBanner(_ hint: String) -> some View {
        HStack(spacing: TTDesign.spacingSM) {
            Image(systemName: "clock")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.ttAccent)

            Text(hint)
                .font(.ttMetadata)
                .foregroundColor(.ttSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, TTDesign.spacingMD)
        .padding(.vertical, TTDesign.spacingSM)
        .background(
            RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                .fill(Color.ttAccent.opacity(0.07))
                .overlay(
                    RoundedRectangle(cornerRadius: TTDesign.radiusSM)
                        .stroke(Color.ttAccent.opacity(0.18), lineWidth: 1)
                )
        )
    }
}

// MARK: - Previews

#Preview("Golden Teachers · static") {
    ScrollView {
        JourneyTimelineView(
            onset: "30-60 min",
            duration: "4-6 hours",
            strainName: "Golden Teachers"
        )
    }
    .background(Color.ttSheetBg)
    .ignoresSafeArea()
}

#Preview("Ketamine IV · live ~45 min in") {
    ScrollView {
        JourneyTimelineView(
            onset: "Immediate",
            duration: "45-60 min",
            strainName: "IV Infusion",
            // Simulate session that started 45 minutes ago
            ingestionDate: Date().addingTimeInterval(-45 * 60)
        )
    }
    .background(Color.ttSheetBg)
    .ignoresSafeArea()
}

#Preview("Ayahuasca · live onset phase") {
    ScrollView {
        JourneyTimelineView(
            onset: "45-60 min + afterglow",
            duration: "4-6 hours",
            strainName: "Caapi + Chacruna",
            // Simulate session that started 20 minutes ago (onset phase)
            ingestionDate: Date().addingTimeInterval(-20 * 60)
        )
    }
    .background(Color.ttSheetBg)
    .ignoresSafeArea()
}

#Preview("Unknown strain · estimated timing") {
    ScrollView {
        JourneyTimelineView(
            onset: "varies",
            duration: "unknown",
            strainName: "Custom Blend"
        )
    }
    .background(Color.ttSheetBg)
    .ignoresSafeArea()
}
