import SwiftUI

extension Color {
    // Primary text: cream/warm white
    static let ttPrimary = Color(red: 0.95, green: 0.94, blue: 0.91)
    // Secondary text: muted sage
    static let ttSecondary = Color(red: 0.7, green: 0.75, blue: 0.72)
    // Accent: soft gold/champagne
    static let ttAccent = Color(red: 0.85, green: 0.78, blue: 0.55)
    // Card background
    static let ttCardBg = Color.white.opacity(0.08)
    // Section header
    static let ttSectionHeader = Color(red: 0.85, green: 0.88, blue: 0.85)
    // Dark sheet background
    static let ttSheetBg = Color(red: 0.06, green: 0.1, blue: 0.15)
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

extension View {
    func darkGlassCard() -> some View {
        modifier(DarkGlassCard())
    }
}
