import SwiftUI

struct AgeGateView: View {
    @AppStorage("ageVerified") private var ageVerified = false

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
                    Text("TripTalk is for adults.")
                        .font(.headline)
                        .foregroundStyle(Color.ttPrimary)
                        .opacity(0.6)

                    Button {
                        Haptics.success()
                        withAnimation { ageVerified = true }
                    } label: {
                        Text("I am 21+")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(colors: [.teal, .blue.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.teal.opacity(0.4), radius: 16, y: 4)
                    }
                    .pressEffect()
                    .padding(.horizontal, 40)

                    (Text("By continuing you agree to our\n")
                        .font(.caption)
                        .foregroundColor(Color.ttSecondary.opacity(0.7))
                    +
                    Text("Community Guidelines.")
                        .font(.caption)
                        .foregroundColor(Color.ttAccent))
                    .multilineTextAlignment(.center)
                }

                Spacer()
            }
            .padding()
        }
    }
}
