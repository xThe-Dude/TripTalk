import SwiftUI
import UIKit

// MARK: - TTMotion
//
// Named motion system for TripTalk v3.
// All animation, haptic, and scroll-reveal tokens live here.
// Color tokens → ThemeColors.swift  |  Spacing/radius → TTDesign.swift  |  Type → TTType.swift

/// Named animation tokens for TripTalk v3.
///
/// Usage:
/// ```swift
/// withAnimation(TTMotion.standard) { isExpanded = true }
/// view.animation(TTMotion.fastFeedback, value: isPressed)
/// view.animation(TTMotion.animation(TTMotion.completion, reduceMotion: reduceMotion), value: isDone)
/// ```
enum TTMotion {

    // MARK: - Animation Tokens

    /// ~0.15 s easeOut — taps, toggles, immediate feedback
    static let fastFeedback: Animation = .easeOut(duration: 0.15)

    /// ~0.30 s easeInOut — transitions, view appear/disappear
    static let standard: Animation = .easeInOut(duration: 0.30)

    /// ~0.45 s spring — task completion, satisfying confirmations
    static let completion: Animation = .spring(response: 0.45, dampingFraction: 0.8)

    /// ~0.30 s quick spring — error states, attention-grabbing shake
    static let error: Animation = .spring(response: 0.30, dampingFraction: 0.5)

    /// ~0.60 s bouncy spring — milestones, celebratory moments
    static let celebratory: Animation = .spring(response: 0.60, dampingFraction: 0.6)

    // MARK: - Reduce-Motion Helper

    /// Returns `anim` unchanged, or `nil` (instant) when `reduceMotion` is `true`.
    ///
    /// Pass `@Environment(\.accessibilityReduceMotion)` as the second argument:
    /// ```swift
    /// .animation(TTMotion.animation(.standard, reduceMotion: reduceMotion), value: flag)
    /// ```
    static func animation(_ anim: Animation, reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : anim
    }

    // MARK: - Haptics

    private static let notifGen = UINotificationFeedbackGenerator()
    private static let selGen   = UISelectionFeedbackGenerator()

    /// Success haptic — call when a task or step completes successfully.
    static func completionHaptic() {
        notifGen.notificationOccurred(.success)
    }

    /// Error haptic — call on validation failure or error states.
    static func errorHaptic() {
        notifGen.notificationOccurred(.error)
    }

    /// Light selection haptic — call on taps and toggle interactions.
    static func selectionHaptic() {
        selGen.selectionChanged()
    }
}

// MARK: - RevealOnScroll Modifier

/// Fades and slides a view up into position as it appears on screen.
///
/// Semantically tied to scroll-reveal patterns; uses `TTMotion.standard` (easeInOut 0.30 s).
/// The existing `animateIn(delay:)` modifier is preserved and unchanged.
/// When the user has Reduce Motion enabled the view appears instantly with no animation.
private struct RevealOnScrollModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion ? 1 : (isVisible ? 1 : 0))
            .offset(y: (!reduceMotion && !isVisible) ? 16 : 0)
            .animation(
                reduceMotion ? nil : TTMotion.standard.delay(delay),
                value: isVisible
            )
            .onAppear { isVisible = true }
    }
}

extension View {
    /// Fades and slides the view up into position as it appears on screen.
    ///
    /// Respects the user's Reduce Motion accessibility preference — content is shown
    /// immediately without opacity or offset animation when Reduce Motion is on.
    ///
    /// - Parameter delay: Stagger delay in seconds (default `0`). Use to create
    ///   cascading reveal effects across sibling views.
    func revealOnScroll(delay: Double = 0) -> some View {
        modifier(RevealOnScrollModifier(delay: delay))
    }
}
