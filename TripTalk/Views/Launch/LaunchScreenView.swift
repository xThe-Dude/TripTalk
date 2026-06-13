import SwiftUI

struct LaunchScreenView: View {
    @State private var opacity: Double = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            GradientBackground(intensity: .immersive)

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.ttGlow.opacity(0.4), .clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)

                    Image(systemName: "leaf.circle.fill")
                        .font(.ttIconHero)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.ttAccent, Color.ttAccent.opacity(0.75)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                Text("TripTalk")
                    .font(.ttDisplay)
                    .foregroundStyle(Color.ttPrimary)
                    .tracking(2)
            }
            .opacity(opacity)
        }
        .ignoresSafeArea()
        .onAppear {
            if reduceMotion {
                opacity = 1
            } else {
                withAnimation(.easeIn(duration: 0.6)) {
                    opacity = 1
                }
            }
        }
    }
}
