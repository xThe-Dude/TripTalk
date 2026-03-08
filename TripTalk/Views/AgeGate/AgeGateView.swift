import SwiftUI

struct AgeGateView: View {
    @AppStorage("ageVerified") private var ageVerified = false

    var body: some View {
        ZStack {
            // Deep immersive gradient
            LinearGradient(
                stops: [
                    .init(color: Color(red: 0.04, green: 0.18, blue: 0.14), location: 0),
                    .init(color: Color(red: 0.05, green: 0.12, blue: 0.22), location: 0.5),
                    .init(color: Color(red: 0.08, green: 0.08, blue: 0.28), location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Radial glow
            RadialGradient(
                colors: [Color.teal.opacity(0.2), .clear],
                center: .center,
                startRadius: 50,
                endRadius: 400
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.ttPrimary)

                Text("TripTalk")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(Color.ttPrimary)

                Text("A community for informed, respectful\nconversation about psychedelic experiences.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.ttSecondary)

                Spacer()

                VStack(spacing: 16) {
                    Text("TripTalk is for adults.")
                        .font(.headline)
                        .foregroundStyle(Color.ttPrimary)

                    Button {
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
                    }
                    .padding(.horizontal, 40)

                    Text("By continuing you agree to our\nCommunity Guidelines.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.ttSecondary.opacity(0.7))
                }

                Spacer()
            }
            .padding()
        }
    }
}
