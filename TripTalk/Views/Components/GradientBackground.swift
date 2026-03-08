import SwiftUI

struct GradientBackground: View {
    var intensity: GradientIntensity = .standard

    enum GradientIntensity {
        case subtle, standard, immersive
    }

    var body: some View {
        ZStack {
            // Base: deep dark teal-to-navy
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.04, green: 0.15, blue: 0.12), location: 0),
                    .init(color: Color(red: 0.05, green: 0.12, blue: 0.22), location: 0.5),
                    .init(color: Color(red: 0.08, green: 0.08, blue: 0.25), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Overlay: soft radial glow
            RadialGradient(
                colors: [Color.teal.opacity(0.15), .clear],
                center: .top,
                startRadius: 50,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}
