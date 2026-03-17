import SwiftUI

/// Persistent "Get Help" floating action button available on all main screens.
/// Tapping reveals a sheet with crisis resources and direct-dial links.
struct CrisisButton: View {
    @State private var showSheet = false

    var body: some View {
        Button {
            Haptics.selection()
            showSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 16, weight: .semibold))
                Text("Get Help")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(.red.opacity(0.85))
                    .shadow(color: .red.opacity(0.3), radius: 8, y: 4)
            )
        }
        .accessibilityLabel("Get Help — crisis resources")
        .accessibilityHint("Opens crisis support hotlines and safety resources")
        .sheet(isPresented: $showSheet) {
            CrisisSheet()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

struct CrisisSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.red)
                        Text("You're Not Alone")
                            .font(.title2.weight(.semibold))
                        Text("If you or someone you know needs support, these resources are available 24/7.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 12) {
                        // 988
                        CrisisResourceRow(
                            icon: "phone.fill",
                            color: .green,
                            title: "988 Suicide & Crisis Lifeline",
                            subtitle: "Call or text 988",
                            action: { UIApplication.shared.open(URL(string: "tel:988")!) },
                            accessibilityHint: "Double-tap to call 988"
                        )

                        // Fireside
                        CrisisResourceRow(
                            icon: "flame.fill",
                            color: .purple,
                            title: "Fireside Project",
                            subtitle: "Psychedelic peer support: (623) 473-7433",
                            action: { UIApplication.shared.open(URL(string: "tel:6234737433")!) },
                            accessibilityHint: "Double-tap to call the Fireside Project"
                        )

                        // Crisis Text Line
                        CrisisResourceRow(
                            icon: "message.fill",
                            color: .blue,
                            title: "Crisis Text Line",
                            subtitle: "Text HOME to 741741",
                            action: { UIApplication.shared.open(URL(string: "sms:741741&body=HOME")!) },
                            accessibilityHint: "Double-tap to text the Crisis Text Line"
                        )

                        // SAMHSA
                        CrisisResourceRow(
                            icon: "cross.case.fill",
                            color: .teal,
                            title: "SAMHSA Helpline",
                            subtitle: "1-800-662-4357 (substance use)",
                            action: { UIApplication.shared.open(URL(string: "tel:18006624357")!) },
                            accessibilityHint: "Double-tap to call SAMHSA"
                        )
                    }
                    .padding(.horizontal)

                    // Fireside website
                    Link(destination: URL(string: "https://firesideproject.org")!) {
                        Text("Visit firesideproject.org")
                            .font(.footnote)
                            .foregroundStyle(Color.accentColor)
                    }
                    .padding(.top, 4)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Crisis Resources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

struct CrisisResourceRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    let accessibilityHint: String

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 36, height: 36)
                    .background(color.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(subtitle)")
        .accessibilityHint(accessibilityHint)
    }
}
