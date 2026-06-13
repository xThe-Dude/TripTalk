import SwiftUI
import UIKit

extension Color {
    // Primary text: cream/warm white
    static let ttPrimary = Color(red: 0.95, green: 0.94, blue: 0.91)
    // Secondary text: muted sage
    static let ttSecondary = Color(red: 0.7, green: 0.75, blue: 0.72)
    // Tertiary text: even more muted for timestamps etc (≥4.5:1 on glass card surfaces)
    static let ttTertiary = Color(red: 0.62, green: 0.66, blue: 0.64)
    // Accent: champagne/gold (#D9C8A0) — the single brand accent
    static let ttAccent = Color(red: 0.851, green: 0.784, blue: 0.627)
    // Card background
    static let ttCardBg = Color.white.opacity(0.05)
    // Section header
    static let ttSectionHeader = Color(red: 0.95, green: 0.94, blue: 0.91)
    // Dark sheet background — matte charcoal, cool navy undertone (#0E1419)
    static let ttSheetBg = Color(red: 0.055, green: 0.078, blue: 0.098)
    // Glow accent — retuned from teal to champagne gold so emphasis stays on one accent
    static let ttGlow = Color(red: 0.851, green: 0.784, blue: 0.627)

    // Contextual tag / meter colors — muted toward the editorial palette
    // (champagne-gold + muted teal), away from the old purple/green/pink "dashboard" look.
    static let ttVisual = Color(red: 0.851, green: 0.784, blue: 0.627)  // champagne gold
    static let ttBody = Color(red: 0.42, green: 0.66, blue: 0.62)       // muted teal
    static let ttEmotional = Color(red: 0.74, green: 0.66, blue: 0.50)  // muted sand
    static let ttSpiritual = Color(red: 0.851, green: 0.784, blue: 0.627) // champagne gold
}

/// Keyline card modifier — editorial "field guide" surface.
/// Thin hairline border, near-transparent fill, no heavy material or glow.
struct DarkGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.03))
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.10), lineWidth: 0.5)
            )
    }
}

/// Elevated dark glass card for hero/featured content
struct DarkGlassCardElevated: ViewModifier {
    var glowColor: Color = .ttGlow

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.04))
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(glowColor.opacity(0.28), lineWidth: 0.8)
            )
    }
}

extension View {
    func darkGlassCard() -> some View {
        modifier(DarkGlassCard())
    }

    func darkGlassCardElevated(glowColor: Color = .ttGlow) -> some View {
        modifier(DarkGlassCardElevated(glowColor: glowColor))
    }

    func animateIn(delay: Double = 0) -> some View {
        modifier(AnimatedAppearance(delay: delay))
    }

    func pressEffect() -> some View {
        modifier(PressEffect())
    }
}

// MARK: - Animated Appearance

struct AnimatedAppearance: ViewModifier {
    let delay: Double
    @State private var appeared = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(appeared ? 1 : 0)
            .offset(y: (!reduceMotion && !appeared) ? 20 : 0)
            .animation(reduceMotion ? .none : .easeOut(duration: 0.4).delay(delay), value: appeared)
            .onAppear { appeared = true }
    }
}

// MARK: - Press Effect

struct PressEffect: ViewModifier {
    @State private var isPressed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect((!reduceMotion && isPressed) ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}

// MARK: - Haptics

enum Haptics {
    private static let lightGen = UIImpactFeedbackGenerator(style: .light)
    private static let mediumGen = UIImpactFeedbackGenerator(style: .medium)
    private static let notifGen = UINotificationFeedbackGenerator()
    private static let selGen = UISelectionFeedbackGenerator()

    static func light() { lightGen.impactOccurred() }
    static func medium() { mediumGen.impactOccurred() }
    static func success() { notifGen.notificationOccurred(.success) }
    static func selection() { selGen.selectionChanged() }
}

// MARK: - Shimmer

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if !reduceMotion {
                        LinearGradient(
                            colors: [.clear, Color.white.opacity(0.08), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .rotationEffect(.degrees(20))
                        .offset(x: phase)
                        .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: phase)
                    }
                }
            )
            .clipped()
            .onAppear { if !reduceMotion { phase = 300 } }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
