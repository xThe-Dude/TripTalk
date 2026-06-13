import SwiftUI

/// Presented when the user opens a password-recovery deep link.
/// The recovery deep-link already authenticated them via `AuthService.beginPasswordRecovery`,
/// so this view only collects + submits a new password.
struct PasswordResetView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var successMessage: String?

    private var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == confirmPassword
    }

    private var passwordLongEnough: Bool {
        newPassword.count >= 8
    }

    private var canSubmit: Bool {
        passwordsMatch && passwordLongEnough && !isLoading
    }

    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)

                    VStack(spacing: 8) {
                        Image(systemName: "key.fill")
                            .font(.ttIconLg)
                            .foregroundStyle(
                                LinearGradient(colors: [Color.ttAccent, Color.ttAccent.opacity(0.75)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        Text("Set a New Password")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Choose a strong password you haven't used elsewhere.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    VStack(spacing: 16) {
                        SecureField("New password", text: $newPassword)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .textContentType(.newPassword)

                        SecureField("Confirm new password", text: $confirmPassword)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .textContentType(.newPassword)

                        // Hints
                        HStack(spacing: 12) {
                            requirementChip("8+ characters", met: passwordLongEnough)
                            requirementChip("Match", met: passwordsMatch)
                        }
                        .font(.caption)
                    }
                    .padding(.horizontal, 24)

                    if let successMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text(successMessage)
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24)
                    } else if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                            .textSelection(.enabled)
                    }

                    Button {
                        Task { await submit() }
                    } label: {
                        HStack {
                            if isLoading { ProgressView().tint(.white) }
                            Text("Update Password")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [Color.ttAccent, Color.ttAccent.opacity(0.75)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(!canSubmit)
                    .padding(.horizontal, 24)

                    Button {
                        appState.pendingPasswordRecovery = false
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func requirementChip(_ text: String, met: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
            Text(text)
        }
        .foregroundColor(met ? .green : .secondary)
    }

    private func submit() async {
        guard canSubmit else { return }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        do {
            try await appState.auth.updatePassword(newPassword)
            successMessage = "Password updated. Welcome back!"
            // Give the success state a beat, then dismiss into the app.
            try? await Task.sleep(for: .seconds(1.2))
            appState.pendingPasswordRecovery = false
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
