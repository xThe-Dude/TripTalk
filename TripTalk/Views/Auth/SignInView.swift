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
    @State private var showEmailConfirmation = false
    @State private var showPasswordResetSent = false
    @State private var appleCoordinator = AppleSignInCoordinator()
    @State private var currentNonce: String?

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
                            .font(.ttIconLg)
                            .foregroundStyle(
                                LinearGradient(colors: [Color.ttAccent, Color.ttAccent.opacity(0.75)],
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

                        if isSignUp && !password.isEmpty && password.count < 8 {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle")
                                Text("Password must be at least 8 characters")
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Status messages
                    if showEmailConfirmation {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope.badge")
                                .foregroundColor(.green)
                            Text("Check your email to confirm your account!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        .padding(12)
                        .background(Color.green.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24)
                    } else if showPasswordResetSent {
                        HStack(spacing: 8) {
                            Image(systemName: "envelope.badge")
                                .foregroundColor(.ttAccent)
                            Text("If an account exists for that email, a reset link is on the way.")
                                .font(.caption)
                                .foregroundColor(.ttAccent)
                        }
                        .padding(12)
                        .background(Color.ttAccent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.horizontal, 24)
                    } else if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.horizontal, 24)
                            .textSelection(.enabled)
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
                            LinearGradient(colors: [Color.ttAccent, Color.ttAccent.opacity(0.75)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && (displayName.isEmpty || password.count < 8)))
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

                    // Forgot password (sign-in mode only)
                    if !isSignUp {
                        Button {
                            Task { await requestPasswordReset() }
                        } label: {
                            Text("Forgot password?")
                                .font(.caption)
                                .foregroundColor(.ttAccent)
                        }
                        .disabled(email.isEmpty || isLoading)
                        .opacity(email.isEmpty ? 0.4 : 1)
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
                        let nonce = AppleSignInCoordinator.randomNonceString()
                        currentNonce = nonce
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = AppleSignInCoordinator.sha256(nonce)
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
        .onAppear {
            // Clear stale errors from previous session/auth attempts.
            errorMessage = nil
            showEmailConfirmation = false
            showPasswordResetSent = false
        }
        .onChange(of: isSignUp) { _, _ in
            errorMessage = nil
            showEmailConfirmation = false
            showPasswordResetSent = false
        }
    }

    // MARK: - Actions

    private func submitForm() async {
        isLoading = true
        errorMessage = nil
        showEmailConfirmation = false
        showPasswordResetSent = false
        do {
            if isSignUp {
                try await appState.auth.signUp(email: email, password: password, displayName: displayName)
            } else {
                try await appState.auth.signInWithEmail(email, password: password)
            }
            if appState.auth.isAuthenticated {
                onSignedIn()
            } else if let msg = appState.auth.authError {
                if msg.contains("Check your email") {
                    showEmailConfirmation = true
                } else {
                    errorMessage = msg
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func requestPasswordReset() async {
        guard !email.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        showEmailConfirmation = false
        showPasswordResetSent = false
        do {
            try await appState.auth.sendPasswordReset(email: email)
            showPasswordResetSent = true
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
            // Use the nonce that was sent to Apple in the request
            guard let nonce = currentNonce else {
                errorMessage = "Missing nonce for Apple Sign In"
                return
            }
            // Apple only returns the user's name on the FIRST authorization.
            // Capture it here so it can be persisted to the profile.
            let appleFullName: String? = {
                guard let components = credential.fullName else { return nil }
                let formatter = PersonNameComponentsFormatter()
                let name = formatter.string(from: components).trimmingCharacters(in: .whitespacesAndNewlines)
                return name.isEmpty ? nil : name
            }()
            Task {
                isLoading = true
                do {
                    try await appState.auth.signInWithApple(idToken: idToken, nonce: nonce, fullName: appleFullName)
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
