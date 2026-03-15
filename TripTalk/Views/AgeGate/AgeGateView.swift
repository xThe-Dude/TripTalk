import SwiftUI

struct AgeGateView: View {
    @AppStorage("ageVerified") private var ageVerified = false
    @State private var showUnderageAlert = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            GradientBackground(intensity: .immersive)

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    // Soft glow behind icon
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.teal.opacity(0.25), .clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)

                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color.ttPrimary)
                }

                Text("TripTalk")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(Color.ttPrimary)
                    .tracking(2)

                Text("A community for informed, respectful\nconversation about psychedelic experiences.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.ttSecondary)

                Spacer()

                VStack(spacing: 16) {
                    Text("TripTalk is for adults 21 and older.")
                        .font(.headline)
                        .foregroundStyle(Color.ttSecondary)

                    Button {
                        Haptics.success()
                        if reduceMotion {
                            ageVerified = true
                        } else {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                ageVerified = true
                            }
                        }
                    } label: {
                        Text("I am 21+")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.teal, .green.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.teal.opacity(0.4), radius: 16, y: 4)
                    }
                    .pressEffect()
                    .padding(.horizontal, 40)

                    Button {
                        showUnderageAlert = true
                    } label: {
                        Text("I am under 21")
                            .font(.subheadline)
                            .foregroundStyle(Color.ttSecondary)
                    }
                    .alert("Age Requirement", isPresented: $showUnderageAlert) {
                        Button("OK") {}
                    } message: {
                        Text("TripTalk is only available to adults 21 and older. If you're struggling with substance use, please contact SAMHSA at 1-800-662-4357.")
                    }

                    VStack(spacing: 4) {
                        Text("By continuing, you agree to our")
                            .font(.caption)
                            .foregroundStyle(Color.ttSecondary.opacity(0.7))
                        HStack(spacing: 4) {
                            Link("Terms of Service", destination: URL(string: "https://xthe-dude.github.io/TripTalk/terms.html")!)
                                .font(.caption)
                                .foregroundStyle(Color.ttAccent)
                            Text(",")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary.opacity(0.7))
                            Link("Privacy Policy", destination: URL(string: "https://xthe-dude.github.io/TripTalk/privacy.html")!)
                                .font(.caption)
                                .foregroundStyle(Color.ttAccent)
                            Text(", and")
                                .font(.caption)
                                .foregroundStyle(Color.ttSecondary.opacity(0.7))
                            Link("Community Guidelines", destination: URL(string: "https://xthe-dude.github.io/TripTalk/support.html")!)
                                .font(.caption)
                                .foregroundStyle(Color.ttAccent)
                        }
                    }
                    .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
        }
    }
}
