import SwiftUI

struct GradientBackground: View {
    var opacity: Double = 0.15
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let effectiveOpacity = colorScheme == .dark ? opacity + 0.05 : opacity
        LinearGradient(
            colors: [Color.green.opacity(effectiveOpacity), Color.blue.opacity(effectiveOpacity)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
