// JourneyPhase.swift
// TripTalk — Phase 3: Journey Timeline
//
// Enum describing the four phases of a psychedelic journey, with display
// properties and time-label helpers derived from a PhaseTiming value.

import SwiftUI

/// The four phases of a psychedelic journey.
///
/// Cases are ordered chronologically: `.prepare` → `.onset` → `.peak` → `.integration`.
/// Use `JourneyPhase.current(at:timing:)` to determine the active phase from
/// elapsed time, and `timeLabel(using:)` to build a human-readable time window.
enum JourneyPhase: Int, CaseIterable, Hashable {
    case prepare
    case onset
    case peak
    case integration

    // MARK: - Display properties

    /// Short title shown in the timeline header row.
    var title: String {
        switch self {
        case .prepare:     return "Prepare"
        case .onset:       return "Onset"
        case .peak:        return "Peak"
        case .integration: return "Integration"
        }
    }

    /// SF Symbol name representing this phase.
    var symbolName: String {
        switch self {
        case .prepare:     return "moon.stars"
        case .onset:       return "arrow.up.circle"
        case .peak:        return "sparkles"
        case .integration: return "leaf"
        }
    }

    /// One-line descriptor shown beneath the phase title.
    var shortDescription: String {
        switch self {
        case .prepare:     return "Set & setting"
        case .onset:       return "Coming up"
        case .peak:        return "Full effects"
        case .integration: return "Coming down & reflection"
        }
    }

    // MARK: - Time label

    /// Human-readable time-window string for this phase, derived from a `PhaseTiming`.
    ///
    /// Examples: `"0 – 60 min"`, `"1 h – 4 h 30 min"`, `"Before ingestion"`.
    func timeLabel(using timing: PhaseTiming) -> String {
        switch self {
        case .prepare:
            return "Before ingestion"
        case .onset:
            return "0 – \(Self.formatMinutes(timing.onsetEnd))"
        case .peak:
            return "\(Self.formatMinutes(timing.onsetEnd)) – \(Self.formatMinutes(timing.peakEnd))"
        case .integration:
            // Add '+' suffix when timing is estimated to communicate uncertainty.
            let endLabel = timing.wasEstimated
                ? "\(Self.formatMinutes(timing.totalEnd))+"
                : Self.formatMinutes(timing.totalEnd)
            return "\(Self.formatMinutes(timing.peakEnd)) – \(endLabel)"
        }
    }

    // MARK: - Phase membership

    /// Returns the current journey phase given elapsed minutes since ingestion.
    ///
    /// - Parameter elapsedMinutes: Minutes since ingestion. Negative values
    ///   return `.prepare` (ingestion has not yet occurred).
    static func current(at elapsedMinutes: Int, timing: PhaseTiming) -> JourneyPhase {
        if elapsedMinutes < 0               { return .prepare }
        if elapsedMinutes < timing.onsetEnd  { return .onset }
        if elapsedMinutes < timing.peakEnd   { return .peak }
        return .integration
    }

    // MARK: - Formatting

    /// Format a minute count into a human-readable string.
    ///
    /// Examples: `"0 min"`, `"45 min"`, `"1 h"`, `"1 h 30 min"`.
    static func formatMinutes(_ minutes: Int) -> String {
        guard minutes > 0 else { return "0 min" }
        if minutes < 60 { return "\(minutes) min" }
        let h = minutes / 60
        let m = minutes % 60
        return m == 0 ? "\(h) h" : "\(h) h \(m) min"
    }
}
