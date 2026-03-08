import SwiftUI

struct TagChip: View {
    let text: String
    var isSelected: Bool = false

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? Color.teal.opacity(0.35) : Color.teal.opacity(0.15))
            .foregroundStyle(isSelected ? Color.ttPrimary : Color.ttSecondary)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.teal.opacity(isSelected ? 0.4 : 0.2), lineWidth: 0.5))
    }
}
