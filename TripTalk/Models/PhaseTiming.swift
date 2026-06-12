// PhaseTiming.swift
// TripTalk — Phase 3: Journey Timeline
//
// Pure value type + parser that turns free-text onset/duration strings into
// structured four-phase time boundaries. No UI dependencies.

import Foundation

/// Parsed timing boundaries for the four phases of a psychedelic journey.
///
/// All `Int` properties are **minutes from the moment of ingestion**.
///
/// | Phase       | Time span            |
/// |-------------|----------------------|
/// | Prepare     | pre-ingestion        |
/// | Onset       | 0 → `onsetEnd`       |
/// | Peak        | `onsetEnd` → `peakEnd` |
/// | Integration | `peakEnd` → `totalEnd` |
///
/// Produced by `PhaseTiming.parse(onset:duration:)`. Use `wasEstimated` to
/// surface a disclaimer when the source strings could not be parsed.
struct PhaseTiming: Equatable {

    // MARK: - Phase boundaries

    /// Minutes from ingestion at which the onset phase ends and peak begins.
    let onsetEnd: Int

    /// Minutes from ingestion at which the peak ends and integration begins.
    let peakEnd: Int

    /// Minutes from ingestion at which the total experience ends.
    let totalEnd: Int

    /// `true` when parsing failed and these values are fallback estimates.
    /// The UI should show a disclaimer when this is `true`.
    let wasEstimated: Bool

    // MARK: - Fallback

    /// Sensible default timing returned when both strings cannot be parsed.
    /// Onset 45 min, total 5 hours (300 min).
    static let fallback = PhaseTiming(
        onsetEnd: 45,
        peakEnd: 236, // 45 + round(255 * 0.75) = 45 + 191
        totalEnd: 300,
        wasEstimated: true
    )

    // MARK: - Parser

    /// Parse free-text onset and duration strings into four-phase time boundaries.
    ///
    /// **Recognised formats** (case-insensitive):
    /// - `"30-60 min"`, `"5-10 min"`, `"45-60 min + afterglow"`
    /// - `"1-2 hours"`, `"4-6 hours"`, `"1-1.5 hours"`, `"8-12 hours"`
    /// - `"Immediate"` → treated as 2-minute onset
    ///
    /// The **upper bound** of any range is used for conservative (longer) estimates.
    /// Returns `PhaseTiming.fallback` (with `wasEstimated: true`) on parse failure.
    static func parse(onset onsetRaw: String, duration durationRaw: String) -> PhaseTiming {
        guard
            let onsetEnd = extractUpperMinutes(from: onsetRaw),
            let totalEnd = extractUpperMinutes(from: durationRaw),
            totalEnd > onsetEnd
        else {
            return fallback
        }

        // Active plateau = time from end-of-onset to end-of-experience.
        // Peak occupies ~75 % of the active plateau; integration takes the rest.
        let plateau = totalEnd - onsetEnd
        let peakEnd = onsetEnd + Int((Double(plateau) * 0.75).rounded())

        return PhaseTiming(
            onsetEnd: onsetEnd,
            peakEnd: peakEnd,
            totalEnd: totalEnd,
            wasEstimated: false
        )
    }

    // MARK: - Private helpers

    /// Extract the upper bound (in minutes) from a free-text timing string.
    ///
    /// Strips trailing annotations (`+ afterglow`, `(approx)`, etc.) before
    /// parsing. Converts hour values to minutes automatically.
    private static func extractUpperMinutes(from raw: String) -> Int? {
        var s = raw.lowercased()

        // Strip everything after '+' or '(' (e.g. "+ afterglow", "(approx)")
        if let idx = s.firstIndex(of: "+") { s = String(s[s.startIndex..<idx]) }
        if let idx = s.firstIndex(of: "(") { s = String(s[s.startIndex..<idx]) }
        s = s.trimmingCharacters(in: .whitespaces)

        // Special keyword: "immediate" → ~2 min onset
        if s.contains("immediate") { return 2 }

        let isHours   = s.contains("hour") || s.contains("hr")
        let isMinutes = s.contains("min")

        // Extract every decimal number (integer or floating-point)
        guard let regex = try? NSRegularExpression(pattern: #"(\d+\.?\d*)"#) else { return nil }
        let ns      = s as NSString
        let matches = regex.matches(in: s, range: NSRange(location: 0, length: ns.length))
        let numbers: [Double] = matches.compactMap { Double(ns.substring(with: $0.range)) }

        // Upper bound = the last (largest) number in the string
        guard let upper = numbers.last else { return nil }

        if isHours {
            return Int((upper * 60).rounded())
        } else if isMinutes {
            return Int(upper.rounded())
        } else {
            // No explicit unit — heuristic: values ≤ 5 are likely hours, larger are minutes
            return upper <= 5
                ? Int((upper * 60).rounded())
                : Int(upper.rounded())
        }
    }
}
