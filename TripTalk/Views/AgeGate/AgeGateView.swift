import SwiftUI

struct AgeGateView: View {
    @AppStorage("ageVerified") private var ageVerified = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.green.opacity(0.7), Color.blue.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "leaf.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.white)

                Text("TripTalk")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(.white)

                Text("A community for informed, respectful\nconversation about psychedelic experiences.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                VStack(spacing: 16) {
                    Text("TripTalk is for adults.")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Button {
                        withAnimation { ageVerified = true }
                    } label: {
                        Text("I am 21+")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .foregroundStyle(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal, 40)

                    Text("By continuing you agree to our\nCommunity Guidelines.")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.7))
                }

                Spacer()
            }
            .padding()
        }
    }
}
