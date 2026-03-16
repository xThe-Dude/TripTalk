import Foundation
import AuthenticationServices

// MARK: - Auth Response Types

struct AuthTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: AuthUser

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case user
    }
}

struct AuthUser: Codable {
    let id: UUID
    let email: String?
}

struct AuthSignUpResponse: Codable {
    let id: UUID
    let email: String?
}

// MARK: - Auth Service

@Observable
@MainActor
class AuthService {
    var accessToken: String?
    var refreshToken: String?
    var userId: UUID?
    var profile: DBProfile?
    var isAuthenticated: Bool { accessToken != nil && userId != nil }
    var authError: String?

    private let client = SupabaseClient.shared
    private let accessTokenKey = "supabase_access_token"
    private let refreshTokenKey = "supabase_refresh_token"
    private let userIdKey = "supabase_user_id"

    func restoreSession() async {
        guard let storedToken = UserDefaults.standard.string(forKey: accessTokenKey),
              let storedRefresh = UserDefaults.standard.string(forKey: refreshTokenKey),
              let storedUserId = UserDefaults.standard.string(forKey: userIdKey),
              let uid = UUID(uuidString: storedUserId) else { return }

        accessToken = storedToken
        refreshToken = storedRefresh
        userId = uid
        syncTokenToClient()

        // Validate token by fetching user
        do {
            let data = try await client.authGet("user")
            let user = try client.decoder.decode(AuthUser.self, from: data)
            userId = user.id
            await fetchProfile()
        } catch {
            // Token expired — try refresh
            do {
                try await refreshAccessToken()
                await fetchProfile()
            } catch {
                // Refresh failed — clear session
                clearSession()
            }
        }
    }

    func signInWithEmail(_ email: String, password: String) async throws {
        authError = nil
        let body: [String: Any] = ["email": email, "password": password]
        let data = try await client.authPost("token?grant_type=password", body: body)
        let response = try client.decoder.decode(AuthTokenResponse.self, from: data)
        setSession(access: response.accessToken, refresh: response.refreshToken, userId: response.user.id)
        await fetchProfile()
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        authError = nil
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "data": ["display_name": displayName]
        ]
        let data = try await client.authPost("signup", body: body)

        // Supabase may return a session directly or require email confirmation
        if let response = try? client.decoder.decode(AuthTokenResponse.self, from: data) {
            setSession(access: response.accessToken, refresh: response.refreshToken, userId: response.user.id)
            await fetchProfile()
        } else {
            // Email confirmation required — parse user from response
            authError = "Check your email to confirm your account."
        }
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        authError = nil
        let body: [String: Any] = [
            "provider": "apple",
            "id_token": idToken,
            "nonce": nonce
        ]
        let data = try await client.authPost("token?grant_type=id_token", body: body)
        let response = try client.decoder.decode(AuthTokenResponse.self, from: data)
        setSession(access: response.accessToken, refresh: response.refreshToken, userId: response.user.id)
        await fetchProfile()
    }

    func signOut() async {
        if accessToken != nil {
            let _ = try? await client.authPost("logout", body: [:])
        }
        clearSession()
    }

    func refreshAccessToken() async throws {
        guard let refresh = refreshToken else { throw SupabaseError.notAuthenticated }
        let body: [String: Any] = ["refresh_token": refresh]
        let data = try await client.authPost("token?grant_type=refresh_token", body: body)
        let response = try client.decoder.decode(AuthTokenResponse.self, from: data)
        setSession(access: response.accessToken, refresh: response.refreshToken, userId: response.user.id)
    }

    func fetchProfile() async {
        guard let uid = userId else { return }
        do {
            let profiles: [DBProfile] = try await client.get("profiles", query: [
                "id": "eq.\(uid.uuidString)",
                "select": "*"
            ])
            profile = profiles.first
        } catch {
            // Profile fetch failed — not critical
        }
    }

    func updateProfile(displayName: String? = nil, bio: String? = nil) async throws {
        guard let uid = userId else { throw SupabaseError.notAuthenticated }
        let update = ProfileUpdate(displayName: displayName, bio: bio, avatarUrl: nil, experienceLevel: nil)
        try await client.patch("profiles", query: ["id": "eq.\(uid.uuidString)"], body: update)
        await fetchProfile()
    }

    // MARK: - Private

    private func setSession(access: String, refresh: String, userId: UUID) {
        self.accessToken = access
        self.refreshToken = refresh
        self.userId = userId
        UserDefaults.standard.set(access, forKey: accessTokenKey)
        UserDefaults.standard.set(refresh, forKey: refreshTokenKey)
        UserDefaults.standard.set(userId.uuidString, forKey: userIdKey)
        syncTokenToClient()
    }

    private func clearSession() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        profile = nil
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        syncTokenToClient()
    }

    private func syncTokenToClient() {
        // SupabaseClient reads accessToken from UserDefaults directly
    }
}

// MARK: - Apple Sign In Coordinator

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var onCompletion: ((String, String) -> Void)?
    var onError: ((Error) -> Void)?
    private var currentNonce: String?

    func startSignIn() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let tokenData = credential.identityToken,
              let idToken = String(data: tokenData, encoding: .utf8),
              let nonce = currentNonce else { return }
        onCompletion?(idToken, nonce)
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        onError?(error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else {
            return ASPresentationAnchor()
        }
        return window
    }

    // MARK: - Nonce Helpers

    private func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let status = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if status != errSecSuccess { random = UInt8.random(in: 0...255) }
                return random
            }
            for random in randoms {
                if remainingLength == 0 { break }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let data = Data(input.utf8)
        var hash = [UInt8](repeating: 0, count: 32)
        data.withUnsafeBytes { ptr in
            _ = CC_SHA256(ptr.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// CommonCrypto bridge
import CommonCrypto
