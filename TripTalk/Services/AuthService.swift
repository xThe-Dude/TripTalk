import Foundation
import Supabase
import Auth

@Observable
@MainActor
class AuthService {
    var session: Session?
    var profile: DBProfile?

    var isAuthenticated: Bool { session != nil }

    func restoreSession() async {
        do {
            session = try await SupabaseManager.client.auth.session
            if let userId = session?.user.id {
                profile = try await fetchProfile(userId)
            }
        } catch {
            session = nil
            profile = nil
        }
    }

    func signInWithApple(idToken: String, nonce: String) async throws {
        let response = try await SupabaseManager.client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        session = response.session
        profile = try await fetchProfile(response.user.id)
    }

    func signInWithEmail(_ email: String, password: String) async throws {
        let response = try await SupabaseManager.client.auth.signIn(
            email: email,
            password: password
        )
        session = response.session
        profile = try await fetchProfile(response.user.id)
    }

    func signUp(email: String, password: String, displayName: String) async throws {
        let response = try await SupabaseManager.client.auth.signUp(
            email: email,
            password: password,
            data: ["display_name": .string(displayName)]
        )
        session = response.session
        if let userId = response.user?.id {
            profile = try? await fetchProfile(userId)
        }
    }

    func signOut() async throws {
        try await SupabaseManager.client.auth.signOut()
        session = nil
        profile = nil
    }

    private func fetchProfile(_ userId: UUID) async throws -> DBProfile {
        try await SupabaseManager.client
            .from("profiles")
            .select()
            .eq("id", value: userId.uuidString)
            .single()
            .execute()
            .value
    }
}
