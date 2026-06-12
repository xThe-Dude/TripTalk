import SwiftUI
import PhotosUI

/// Avatar picker + uploader for user profiles.
struct AvatarPickerView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploading = false
    @State private var avatarURL: String?

    var body: some View {
        ZStack {
            if let urlStr = avatarURL ?? appState.auth.profile?.avatarUrl,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        fallbackAvatar
                    default:
                        ProgressView()
                    }
                }
            } else {
                fallbackAvatar
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) {
            if appState.auth.isAuthenticated {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Image(systemName: "camera.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, Color.ttAccent)
                        .background(Circle().fill(.black.opacity(0.5)))
                }
                .disabled(isUploading)
            }
        }
        .overlay {
            if isUploading {
                Circle()
                    .fill(.ultraThinMaterial)
                ProgressView()
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            guard let item = newItem else { return }
            uploadAvatar(item: item)
        }
        .accessibilityLabel("Profile photo")
        .accessibilityHint(appState.auth.isAuthenticated ? "Tap to change" : "Sign in to set a photo")
    }

    private var fallbackAvatar: some View {
        Image(systemName: "person.circle.fill")
            .font(.ttIconHero)
            .foregroundStyle(
                LinearGradient(colors: [.teal, .green.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }

    private func uploadAvatar(item: PhotosPickerItem) {
        guard let uid = appState.auth.userId else { return }
        isUploading = true

        Task {
            defer { isUploading = false }

            guard let data = try? await item.loadTransferable(type: Data.self) else { return }

            // Resize to max 512x512 and compress
            guard let uiImage = UIImage(data: data),
                  let resized = uiImage.resizedToFit(maxDimension: 512),
                  let jpegData = resized.jpegData(compressionQuality: 0.8) else { return }

            // Strip EXIF by re-encoding through UIImage
            do {
                let publicURL = try await StorageService().uploadAvatar(userId: uid, imageData: jpegData)
                // Update profile with new avatar URL
                try await SupabaseClient.shared.patch(
                    "profiles",
                    query: ["id": "eq.\(uid.uuidString)"],
                    body: ["avatar_url": publicURL]
                )
                avatarURL = publicURL
                Haptics.success()
            } catch {
                // Silent failure — avatar stays as default
            }
        }
    }
}

extension UIImage {
    func resizedToFit(maxDimension: CGFloat) -> UIImage? {
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        guard ratio < 1 else { return self }
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        draw(in: CGRect(origin: .zero, size: newSize))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
