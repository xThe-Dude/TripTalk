import SwiftUI

/// Sheet for editing user profile (display name, bio, experience level).
struct EditProfileView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var bio: String = ""
    @State private var experienceLevel: String = "beginner"
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let experienceLevels = ["beginner", "intermediate", "experienced"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Display Name").foregroundStyle(Color.ttSectionHeader)) {
                    TextField("How others see you", text: $displayName)
                        .textContentType(.name)
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Bio").foregroundStyle(Color.ttSectionHeader)) {
                    ZStack(alignment: .topLeading) {
                        if bio.isEmpty {
                            Text("Tell the community about yourself...")
                                .foregroundStyle(Color.ttTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $bio)
                            .frame(minHeight: 80)
                            .scrollContentBackground(.hidden)
                    }
                }
                .listRowBackground(Color.white.opacity(0.05))

                Section(header: Text("Experience Level").foregroundStyle(Color.ttSectionHeader)) {
                    Picker("Experience", selection: $experienceLevel) {
                        ForEach(experienceLevels, id: \.self) { level in
                            Text(level.capitalized).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.white.opacity(0.05))

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.ttSheetBg)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.ttAccent)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { saveProfile() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.ttAccent)
                        .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty || isSaving)
                }
            }
            .onAppear { loadCurrent() }
        }
        .presentationDetents([.medium])
        .presentationBackground(Color.ttSheetBg.opacity(0.95))
    }

    private func loadCurrent() {
        // Load from AuthService or defaults
        displayName = appState.auth.displayName ?? ""
        bio = appState.auth.bio ?? ""
        experienceLevel = appState.auth.experienceLevel ?? "beginner"
    }

    private func saveProfile() {
        guard !displayName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        guard appState.auth.isAuthenticated, let uid = appState.auth.userId else {
            errorMessage = "Sign in to update your profile."
            return
        }

        isSaving = true
        errorMessage = nil

        Task {
            do {
                let body: [String: String] = [
                    "display_name": displayName.trimmingCharacters(in: .whitespaces),
                    "bio": bio.trimmingCharacters(in: .whitespacesAndNewlines),
                    "experience_level": experienceLevel
                ]
                try await SupabaseClient.shared.patch(
                    "profiles",
                    query: ["id": "eq.\(uid.uuidString)"],
                    body: body
                )
                appState.auth.displayName = displayName
                appState.auth.bio = bio
                appState.auth.experienceLevel = experienceLevel
                Haptics.success()
                dismiss()
            } catch {
                errorMessage = "Failed to save. Please try again."
                isSaving = false
            }
        }
    }
}
