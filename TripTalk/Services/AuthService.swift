import Foundation
import Security
import AuthenticationServices
import os.log

// MARK: - Auth Diagnostics

// Used to surface the real cause of "The data couldn't be read because it is missing."
// Logs to Console (Xcode) and produces a human-readable error message.
enum AuthDiagnostics {
    static let log = OSLog(subsystem: "com.triptalk.app", category: "Auth")

    /// Sanitized preview of a response body: trims, truncates, strips obvious tokens.
    static func sanitize(_ data: Data, limit: Int = 400) -> String {
        var s = String(data: data, encoding: .utf8) ?? "<non-utf8 \(data.count)B>"
        // Crude token redaction
        s = s.replacingOccurrences(
            of: #""(access_token|refresh_token|id_token)"\s*:\s*"[^"]+""#,
            with: "\"$1\":\"<redacted>\"",
            options: .regularExpression
        )
        if s.count > limit { s = String(s.prefix(limit)) + "…(truncated)" }
        return s
    }

    static func describe(_ error: Error, body: Data, endpoint: String) -> String {
        let preview = sanitize(body)
        let detail: String
        if let de = error as? DecodingError {
            switch de {
            case .keyNotFound(let key, let ctx):
                detail = "missing key '\(key.stringValue)' at \(ctx.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .valueNotFound(let type, let ctx):
                detail = "missing \(type) at \(ctx.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .typeMismatch(let type, let ctx):
                detail = "type mismatch (\(type)) at \(ctx.codingPath.map { $0.stringValue }.joined(separator: "."))"
            case .dataCorrupted(let ctx):
                detail = "data corrupted at \(ctx.codingPath.map { $0.stringValue }.joined(separator: ".")): \(ctx.debugDescription)"
            @unknown default:
                detail = de.localizedDescription
            }
        } else {
            detail = error.localizedDescription
        }
        let msg = "[\(endpoint)] decode failed: \(detail) | body: \(preview)"
        os_log("%{public}@", log: log, type: .error, msg)
        // Surface response body on-screen too — the iOS Console-app dance is painful.
        let bodyForUI = preview.count > 220 ? String(preview.prefix(220)) + "…" : preview
        return "Auth error (\(endpoint)): \(detail)\n\nResponse: \(bodyForUI)"
    }

    static func logRaw(_ data: Data, endpoint: String) {
        // endpoint is safe to log publicly; the body may contain email/sub PII
        // (sanitize only redacts tokens), so mark it private so it is redacted
        // in device console/sysdiagnose logs outside the debugger.
        os_log("[%{public}@] body=%{private}@", log: log, type: .debug, endpoint, sanitize(data))
    }
}

// MARK: - Keychain Helper

struct KeychainStore {
    static func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecValueData: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func read(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: kCFBooleanTrue as Any
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Auth Response Types

struct AuthTokenResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: AuthUser
    // No explicit CodingKeys — the shared decoder uses .convertFromSnakeCase,
    // which transforms access_token -> accessToken before key lookup.
    // Adding rawValue="access_token" CodingKeys actually BREAKS the match
    // because the decoder is comparing the converted key ("accessToken")
    // against the rawValue ("access_token"). Letting Swift's auto-synthesized
    // CodingKeys do the work fixes it.
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
    var displayName: String? {
        get { profile?.displayName }
        set { profile?.displayName = newValue ?? "Anonymous" }
    }
    var bio: String? {
        get { profile?.bio }
        set { profile?.bio = newValue }
    }
    var experienceLevel: String? {
        get { profile?.experienceLevel }
        set { profile?.experienceLevel = newValue }
    }
    var authError: String?

    private let client = SupabaseClient.shared
    private let accessTokenKey = "supabase_access_token"
    private let refreshTokenKey = "supabase_refresh_token"
    private let userIdKey = "supabase_user_id"

    func restoreSession() async {
        guard let storedToken = KeychainStore.read(key: accessTokenKey),
              let storedRefresh = KeychainStore.read(key: refreshTokenKey),
              let storedUserId = KeychainStore.read(key: userIdKey),
              let uid = UUID(uuidString: storedUserId) else { return }

        accessToken = storedToken
        refreshToken = storedRefresh
        userId = uid

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
        AuthDiagnostics.logRaw(data, endpoint: "signInWithEmail")
        let response: AuthTokenResponse
        do {
            response = try client.decoder.decode(AuthTokenResponse.self, from: data)
        } catch {
            let msg = AuthDiagnostics.describe(error, body: data, endpoint: "signInWithEmail")
            authError = msg
            throw NSError(domain: "AuthService", code: -1001, userInfo: [NSLocalizedDescriptionKey: msg])
        }
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
        // Same bridge redirect as password reset: the email-confirmation link
        // must route through confirm.html -> triptalk://auth/callback so the
        // user lands back IN the app after confirming, not on the website.
        let data = try await client.authPost(
            "signup",
            body: body,
            query: ["redirect_to": "https://triptalk.guide/auth/confirm.html"]
        )
        AuthDiagnostics.logRaw(data, endpoint: "signUp")

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            let msg = "Signup response was not valid JSON. Body: \(AuthDiagnostics.sanitize(data))"
            authError = msg
            throw NSError(domain: "AuthService", code: -1002, userInfo: [NSLocalizedDescriptionKey: msg])
        }

        // Case 1: error body (Supabase returns 200 with a JSON error for some signup failures,
        // e.g. weak_password). Detect by presence of `error_code` or `code`+`msg`.
        if let errorCode = json["error_code"] as? String ?? (json["code"] is Int ? (json["msg"] as? String).map { _ in "error" } : nil) {
            let serverMsg = (json["msg"] as? String) ?? (json["message"] as? String) ?? "Unknown error"
            let userFacing = Self.friendlySignupError(code: errorCode, message: serverMsg, raw: json)
            authError = userFacing
            throw NSError(domain: "AuthService", code: -1004, userInfo: [NSLocalizedDescriptionKey: userFacing])
        }

        // Case 2: session returned (auto-confirm enabled).
        if json["access_token"] != nil {
            do {
                let response = try client.decoder.decode(AuthTokenResponse.self, from: data)
                setSession(access: response.accessToken, refresh: response.refreshToken, userId: response.user.id)
                await fetchProfile()
            } catch {
                let msg = AuthDiagnostics.describe(error, body: data, endpoint: "signUp")
                authError = msg
                throw NSError(domain: "AuthService", code: -1002, userInfo: [NSLocalizedDescriptionKey: msg])
            }
            return
        }

        // Case 3: user object returned. This is ambiguous — Supabase returns the
        // SAME shape for genuine new signups AND for duplicates (to prevent user
        // enumeration). The tell: a real new signup has at least one entry in
        // `identities`; a duplicate has `identities: []` and `role: ""`.
        if json["id"] != nil {
            let identities = (json["identities"] as? [Any]) ?? []
            let role = json["role"] as? String ?? ""
            if identities.isEmpty || role.isEmpty {
                // Duplicate signup disguised as success.
                let msg = "An account with this email already exists. Sign in instead, or reset your password if you forgot it."
                authError = msg
                throw NSError(domain: "AuthService", code: -1006, userInfo: [NSLocalizedDescriptionKey: msg])
            }
            // Genuine new signup pending email confirmation.
            authError = "Check your email to confirm your account."
            return
        }

        // Unknown shape — don't pretend it worked.
        let msg = "Unexpected signup response. Body: \(AuthDiagnostics.sanitize(data))"
        authError = msg
        throw NSError(domain: "AuthService", code: -1005, userInfo: [NSLocalizedDescriptionKey: msg])
    }

    private static func friendlySignupError(code: String, message: String, raw: [String: Any]) -> String {
        switch code {
        case "weak_password":
            if let weak = raw["weak_password"] as? [String: Any],
               let reasons = weak["reasons"] as? [String], reasons.contains("pwned") {
                return "That password has been seen in a known data breach. Please choose a different one."
            }
            return "Password is too weak. \(message)"
        case "user_already_exists", "email_exists":
            return "An account with this email already exists. Try signing in instead."
        case "signup_disabled":
            return "New signups are temporarily disabled."
        case "validation_failed":
            return "Couldn't create your account: \(message)"
        case "over_email_send_rate_limit":
            return "Too many signup attempts. Please wait a few minutes and try again."
        default:
            return "Signup failed: \(message)"
        }
    }

    func sendPasswordReset(email: String) async throws {
        authError = nil
        let body: [String: Any] = ["email": email]
        // redirect_to must point at the web->app bridge (confirm.html), which
        // forwards the recovery tokens into triptalk://auth/recover so the
        // reset completes IN the app. Without this, GoTrue falls back to the
        // bare Site URL (https://triptalk.guide) and the link never opens the app.
        _ = try await client.authPost(
            "recover",
            body: body,
            query: ["redirect_to": "https://triptalk.guide/auth/confirm.html"]
        )
        // Supabase always returns 200 here regardless of whether the email
        // exists — again to prevent enumeration. We always tell the user
        // "if your email exists, a reset link is on the way."
    }

    /// Activate a recovery session from a deep-link.
    /// After this, `updatePassword` may be called to set a new password.
    /// The session is real (the user is authenticated) — we just present a
    /// password-reset UI before letting them into the rest of the app.
    func beginPasswordRecovery(accessToken: String, refreshToken: String) async {
        authError = nil
        guard let userId = Self.extractUserId(from: accessToken) else {
            authError = "Recovery link is invalid or expired."
            return
        }
        setSession(access: accessToken, refresh: refreshToken, userId: userId)
        await fetchProfile()
    }

    /// Update the current user's password. Must be authenticated.
    func updatePassword(_ newPassword: String) async throws {
        guard accessToken != nil else { throw SupabaseError.notAuthenticated }
        let body: [String: Any] = ["password": newPassword]
        let url = URL(string: "\(client.baseURL)/auth/v1/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(client.apiKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(accessToken ?? client.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.httpError(0, "no response")
        }
        guard (200...299).contains(http.statusCode) else {
            // Surface friendly error from the JSON body when present.
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let code = (json["error_code"] as? String) ?? (json["code"] as? String) ?? ""
                let msg = (json["msg"] as? String) ?? (json["message"] as? String) ?? "Unknown error"
                let userFacing: String
                switch code {
                case "weak_password":
                    if let weak = json["weak_password"] as? [String: Any],
                       let reasons = weak["reasons"] as? [String], reasons.contains("pwned") {
                        userFacing = "That password has been seen in a known data breach. Please choose a different one."
                    } else {
                        userFacing = "Password is too weak. \(msg)"
                    }
                case "same_password":
                    userFacing = "New password must be different from the old one."
                default:
                    userFacing = msg
                }
                throw NSError(domain: "AuthService", code: -1010, userInfo: [NSLocalizedDescriptionKey: userFacing])
            }
            throw SupabaseError.httpError(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }
    }

    /// Sign in with Apple.
    ///
    /// - Parameter fullName: The user's name from `ASAuthorizationAppleIDCredential.fullName`.
    ///   Apple only provides this on the FIRST authorization, so when present we
    ///   persist it to the profile immediately (otherwise the profile would show
    ///   "Anonymous").
    func signInWithApple(idToken: String, nonce: String, fullName: String? = nil) async throws {
        authError = nil
        let body: [String: Any] = [
            "provider": "apple",
            "id_token": idToken,
            "nonce": nonce
        ]
        let data = try await client.authPost("token?grant_type=id_token", body: body)
        AuthDiagnostics.logRaw(data, endpoint: "signInWithApple")
        let response: AuthTokenResponse
        do {
            response = try client.decoder.decode(AuthTokenResponse.self, from: data)
        } catch {
            let msg = AuthDiagnostics.describe(error, body: data, endpoint: "signInWithApple")
            authError = msg
            throw NSError(domain: "AuthService", code: -1003, userInfo: [NSLocalizedDescriptionKey: msg])
        }
        setSession(access: response.accessToken, refresh: response.refreshToken, userId: response.user.id)
        await fetchProfile()

        // Persist the Apple-provided name if the profile has no real display name yet.
        // Apple returns the name only once (first sign-in), so we must save it now.
        if let fullName = fullName?.trimmingCharacters(in: .whitespacesAndNewlines), !fullName.isEmpty {
            let current = (profile?.displayName ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if current.isEmpty || current == "Anonymous" {
                try? await updateProfile(displayName: fullName)
            }
        }
    }

    /// Handle auth callback from email confirmation deep link
    func handleAuthCallback(accessToken: String, refreshToken: String) async {
        authError = nil
        // Decode the JWT to extract the user ID
        if let userId = Self.extractUserId(from: accessToken) {
            setSession(access: accessToken, refresh: refreshToken, userId: userId)
            await fetchProfile()
        } else {
            authError = "Failed to process authentication."
        }
    }

    /// Extract user ID (sub claim) from a JWT access token
    private static func extractUserId(from jwt: String) -> UUID? {
        let parts = jwt.split(separator: ".")
        guard parts.count >= 2 else { return nil }
        var base64 = String(parts[1])
        // Pad base64 if needed
        while base64.count % 4 != 0 { base64.append("=") }
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let sub = json["sub"] as? String else { return nil }
        return UUID(uuidString: sub)
    }

    func signOut() async {
        if accessToken != nil {
            let _ = try? await client.authPost("logout", body: [:])
        }
        clearSession()
    }

    // SQL to deploy before calling this function:
    //
    // CREATE OR REPLACE FUNCTION delete_own_account()
    // RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
    // BEGIN
    //   DELETE FROM profiles WHERE id = auth.uid();
    //   DELETE FROM auth.users WHERE id = auth.uid();
    // END;
    // $$;
    // REVOKE EXECUTE ON FUNCTION delete_own_account() FROM PUBLIC;
    // GRANT EXECUTE ON FUNCTION delete_own_account() TO authenticated;
    func deleteAccount() async throws {
        try await client.rpc("delete_own_account")
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
        KeychainStore.save(key: accessTokenKey, value: access)
        KeychainStore.save(key: refreshTokenKey, value: refresh)
        KeychainStore.save(key: userIdKey, value: userId.uuidString)
    }

    private func clearSession() {
        accessToken = nil
        refreshToken = nil
        userId = nil
        profile = nil
        KeychainStore.delete(key: accessTokenKey)
        KeychainStore.delete(key: refreshTokenKey)
        KeychainStore.delete(key: userIdKey)
    }
}

// MARK: - Apple Sign In Coordinator

class AppleSignInCoordinator: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    var onCompletion: ((String, String) -> Void)?
    var onError: ((Error) -> Void)?
    private var currentNonce: String?

    func startSignIn() {
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)

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

    static func randomNonceString(length: Int = 32) -> String {
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

    static func sha256(_ input: String) -> String {
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
