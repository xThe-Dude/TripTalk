import SwiftUI

struct GradientBackground: View {
    var intensity: GradientIntensity = .standard

    enum GradientIntensity {
        case subtle, standard, immersive
    }

    /// Strength of the single, very subtle warm vignette. Editorial "field guide"
    /// aesthetic: matte charcoal base, no teal/indigo/blue orbs.
    private var vignetteOpacity: Double {
        switch intensity {
        case .subtle: return 0.05
        case .standard: return 0.08
        case .immersive: return 0.12
        }
    }

    var body: some View {
        ZStack {
            // Base: matte charcoal with cool navy undertone (#0E1419), near-flat.
            Color(red: 0.055, green: 0.078, blue: 0.098)

            // One restrained warm radial vignette, slightly lighter toward upper-center.
            RadialGradient(
                colors: [
                    Color(red: 0.10, green: 0.13, blue: 0.16).opacity(vignetteOpacity),
                    .clear
                ],
                center: UnitPoint(x: 0.5, y: 0.32),
                startRadius: 40,
                endRadius: 520
            )
        }
        .ignoresSafeArea()
    }
}
