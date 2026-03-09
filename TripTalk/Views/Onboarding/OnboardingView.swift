import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, subtitle: String)] = [
        ("leaf.fill", "Know Your Journey", "Access detailed variety profiles, community experiences, and evidence-based safety information — all in one place."),
        ("person.3.fill", "Community Wisdom", "Learn from real experiences shared by a thoughtful, safety-focused community."),
        ("shield.checkered", "Stay Safe", "Preparation guides, integration resources, and crisis support — because safety extends beyond the experience itself.")
    ]

    var body: some View {
        ZStack {
            GradientBackground(intensity: .immersive)

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        VStack(spacing: 24) {
                            Spacer()

                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [Color.ttGlow.opacity(0.35), .clear],
                                            center: .center,
                                            startRadius: 10,
                                            endRadius: 70
                                        )
                                    )
                                    .frame(width: 140, height: 140)

                                Image(systemName: page.icon)
                                    .font(.system(size: 56))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.teal, .green.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }

                            Text(page.title)
                                .font(.system(.largeTitle, design: .serif, weight: .bold))
                                .foregroundStyle(Color.ttPrimary)
                                .tracking(1)

                            Text(page.subtitle)
                                .font(.body)
                                .foregroundStyle(Color.ttSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)

                            Spacer()

                            if index == pages.count - 1 {
                                Button {
                                    Haptics.success()
                                    onComplete()
                                } label: {
                                    Text("Get Started")
                                        .font(.headline)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color.ttAccent)
                                        .clipShape(Capsule())
                                        .shadow(color: Color.ttAccent.opacity(0.4), radius: 12, y: 4)
                                }
                                .pressEffect()
                                .padding(.horizontal, 40)
                                .padding(.bottom, 60)
                            } else {
                                Spacer().frame(height: 100)
                            }
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
        }
        .ignoresSafeArea()
    }
}
