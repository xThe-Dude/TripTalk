import SwiftUI

struct PotencyDots: View {
    let level: Int  // 1-4
    let maxLevel: Int = 4
    var dotSize: CGFloat = 6
    var activeColor: Color = .ttAccent

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...maxLevel, id: \.self) { i in
                Circle()
                    .fill(i <= level ? activeColor : Color.white.opacity(0.15))
                    .frame(width: dotSize, height: dotSize)
            }
        }
    }
}
