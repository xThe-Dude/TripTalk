import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var currentPage = 0

    private let pages: [(icon: String, title: String, subtitle: String, backgroundImage: String)] = [
        ("leaf.fill", "Know Your Journey", "Access detailed variety profiles, community experiences, and evidence-based safety information — all in one place.", "onboarding_knowledge"),
        ("person.3.fill", "Community Wisdom", "Learn from real experiences shared by a thoughtful, safety-focused community.", "onboarding_community"),
        ("shield.checkered", "Stay Safe", "Preparation guides, integration resources, and crisis support — because safety extends beyond the experience itself.", "onboarding_safety")
    ]

    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    ZStack {
                        // Full-bleed background image
                        GeometryReader { geo in
                            Image(page.backgroundImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geo.size.width)
                                .clipped()
                        }
                        .ignoresSafeArea()

                        // Dark gradient overlay for readability
                        LinearGradient(
                            colors: [.black.opacity(0.4), .black.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()

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
                                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                            Text(page.subtitle)
                                .font(.body)
                                .foregroundStyle(Color.ttSecondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                                .padding(.horizontal, 40)
                                .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                            Spacer()

                            if index == pages.count - 1 {
                                Button {
                                    Haptics.success()
                                    onComplete()
                                } label: {
                                    Text("Get Started")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(
                                            LinearGradient(
                                                colors: [.teal, .green.opacity(0.8)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .clipShape(Capsule())
                                        .shadow(color: .teal.opacity(0.4), radius: 12, y: 4)
                                }
                                .pressEffect()
                                .padding(.horizontal, 40)
                                .padding(.bottom, 60)
                            } else {
                                Spacer().frame(height: 100)
                            }
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .ignoresSafeArea()
    }
}
