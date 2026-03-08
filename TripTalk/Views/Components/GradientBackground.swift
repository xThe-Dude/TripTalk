import SwiftUI

struct GradientBackground: View {
    var intensity: GradientIntensity = .standard

    enum GradientIntensity {
        case subtle, standard, immersive
    }

    private var orbOpacity: Double {
        switch intensity {
        case .subtle: return 0.08
        case .standard: return 0.15
        case .immersive: return 0.25
        }
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

            // Orb 1: Teal glow top-leading
            RadialGradient(
                colors: [Color.teal.opacity(orbOpacity), .clear],
                center: .topLeading,
                startRadius: 30,
                endRadius: 400
            )

            // Orb 2: Indigo glow center
            RadialGradient(
                colors: [Color.indigo.opacity(orbOpacity * 0.8), .clear],
                center: .center,
                startRadius: 20,
                endRadius: 350
            )

            // Orb 3: Deep blue glow bottom-trailing
            RadialGradient(
                colors: [Color(red: 0.2, green: 0.3, blue: 0.8).opacity(orbOpacity * 0.7), .clear],
                center: .bottomTrailing,
                startRadius: 40,
                endRadius: 450
            )

            // Original top glow
            RadialGradient(
                colors: [Color.teal.opacity(orbOpacity), .clear],
                center: .top,
                startRadius: 50,
                endRadius: 500
            )
        }
        .ignoresSafeArea()
    }
}
