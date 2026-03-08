import SwiftUI

struct TagChip: View {
    let text: String
    var isSelected: Bool = false
    var color: Color? = nil

    private var chipColor: Color {
        color ?? .teal
    }

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? chipColor.opacity(0.35) : chipColor.opacity(0.15))
            .foregroundStyle(isSelected ? Color.ttPrimary : Color.ttSecondary)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(chipColor.opacity(isSelected ? 0.5 : 0.2), lineWidth: 0.5))
            .shadow(color: isSelected ? chipColor.opacity(0.3) : .clear, radius: 6, y: 0)
    }
}
