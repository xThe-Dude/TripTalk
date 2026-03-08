import SwiftUI

extension Color {
    // Primary text: cream/warm white
    static let ttPrimary = Color(red: 0.95, green: 0.94, blue: 0.91)
    // Secondary text: muted sage
    static let ttSecondary = Color(red: 0.7, green: 0.75, blue: 0.72)
    // Tertiary text: even more muted for timestamps etc
    static let ttTertiary = Color(red: 0.5, green: 0.54, blue: 0.52)
    // Accent: soft gold/champagne
    static let ttAccent = Color(red: 0.85, green: 0.78, blue: 0.55)
    // Card background
    static let ttCardBg = Color.white.opacity(0.08)
    // Section header
    static let ttSectionHeader = Color(red: 0.85, green: 0.88, blue: 0.85)
    // Dark sheet background
    static let ttSheetBg = Color(red: 0.06, green: 0.1, blue: 0.15)
    // Glow accent
    static let ttGlow = Color.teal

    // Contextual tag colors
    static let ttVisual = Color(red: 0.65, green: 0.45, blue: 0.95)   // purple
    static let ttBody = Color(red: 0.3, green: 0.8, blue: 0.55)       // green
    static let ttEmotional = Color(red: 0.9, green: 0.45, blue: 0.65) // pink
    static let ttSpiritual = Color(red: 0.85, green: 0.75, blue: 0.35) // gold
}

/// Dark glass card modifier
struct DarkGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.07))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
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
                    .fill(Color.white.opacity(0.10))
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial)
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [glowColor.opacity(0.4), Color.white.opacity(0.1), glowColor.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: glowColor.opacity(0.15), radius: 20, y: 0)
            .shadow(color: .black.opacity(0.3), radius: 16, y: 8)
    }
}

extension View {
    func darkGlassCard() -> some View {
        modifier(DarkGlassCard())
    }

    func darkGlassCardElevated(glowColor: Color = .ttGlow) -> some View {
        modifier(DarkGlassCardElevated(glowColor: glowColor))
    }
}
