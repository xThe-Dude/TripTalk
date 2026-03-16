import SwiftUI
import AuthenticationServices

struct SignInView: View {
    @Environment(AppState.self) private var appState
    @State private var email = ""
    @State private var password = ""
    @State private var displayName = ""
    @State private var isSignUp = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var appleCoordinator = AppleSignInCoordinator()

    var onContinueAsGuest: () -> Void
    var onSignedIn: () -> Void

    var body: some View {
        ZStack {
            GradientBackground().ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer().frame(height: 60)

                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(colors: [.teal, .green.opacity(0.8)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                        Text(isSignUp ? "Create Account" : "Welcome Back")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Sign in to save reviews, bookmarks, and trip reports across devices")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    // Form
                    VStack(spacing: 16) {
                        if isSignUp {
                            TextField("Display Name", text: $displayName)
                                .textFieldStyle(.plain)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .textContentType(.name)
                        }

                        TextField("Email", text: $email)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)

                        SecureField("Password", text: $password)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .textContentType(isSignUp ? .newPassword : .password)
                    }
                    .padding(.horizontal, 24)

                    // Error
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                    }

                    // Primary Button
                    Button {
                        Task { await submitForm() }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView().tint(.white)
                            }
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.teal, .green.opacity(0.8)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && displayName.isEmpty))
                    .padding(.horizontal, 24)

                    // Toggle sign up / sign in
                    Button {
                        withAnimation { isSignUp.toggle() }
                        errorMessage = nil
                    } label: {
                        Text(isSignUp ? "Already have an account? **Sign In**" : "Don't have an account? **Sign Up**")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Divider
                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.15))
                        Text("or").foregroundColor(.secondary).font(.caption)
                        Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.15))
                    }
                    .padding(.horizontal, 24)

                    // Sign in with Apple
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.white)
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)

                    // Guest
                    Button {
                        onContinueAsGuest()
                    } label: {
                        Text("Continue as Guest")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(.white.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 24)

                    Text("Guest mode is read-only. Sign in to write reviews and save bookmarks.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    Spacer().frame(height: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Actions

    private func submitForm() async {
        isLoading = true
        errorMessage = nil
        do {
            if isSignUp {
                try await appState.auth.signUp(email: email, password: password, displayName: displayName)
            } else {
                try await appState.auth.signInWithEmail(email, password: password)
            }
            if appState.auth.isAuthenticated {
                onSignedIn()
            } else if let msg = appState.auth.authError {
                errorMessage = msg
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credential.identityToken,
                  let idToken = String(data: tokenData, encoding: .utf8) else {
                errorMessage = "Failed to get Apple ID token"
                return
            }
            // For Apple Sign In with Supabase, we need the nonce
            // Using the coordinator approach for proper nonce handling
            Task {
                isLoading = true
                do {
                    // Generate a simple nonce for now — in production use the coordinator
                    let nonce = UUID().uuidString
                    try await appState.auth.signInWithApple(idToken: idToken, nonce: nonce)
                    if appState.auth.isAuthenticated {
                        onSignedIn()
                    }
                } catch {
                    errorMessage = error.localizedDescription
                }
                isLoading = false
            }
        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }
}
