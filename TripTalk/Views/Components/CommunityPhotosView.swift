import SwiftUI
import PhotosUI

/// Displays community photos for a strain and allows authenticated users to upload.
struct CommunityPhotosView: View {
    @Environment(AppState.self) private var appState
    let strain: Strain

    @State private var photoURLs: [String] = []
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploading = false
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Community Photos")
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundStyle(Color.ttPrimary)
                    .accessibilityAddTraits(.isHeader)
                Spacer()
                Text("\(photoURLs.count)")
                    .font(.caption)
                    .foregroundStyle(Color.ttSecondary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // Upload button (authenticated only)
                    if appState.auth.isAuthenticated {
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 100, height: 100)
                                .overlay {
                                    if isUploading {
                                        ProgressView()
                                    } else {
                                        VStack(spacing: 4) {
                                            Image(systemName: "plus.circle")
                                                .font(.title3)
                                            Text("Add")
                                                .font(.caption2)
                                        }
                                        .foregroundStyle(Color.ttAccent)
                                    }
                                }
                        }
                        .disabled(isUploading)
                        .accessibilityLabel("Add a community photo")
                    }

                    // Photo grid
                    if isLoading && photoURLs.isEmpty {
                        ForEach(0..<min(3, strain.communityPhotoCount), id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 100, height: 100)
                                .overlay { ProgressView() }
                        }
                    } else if photoURLs.isEmpty {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 100, height: 100)
                            .overlay {
                                VStack(spacing: 4) {
                                    Image(systemName: "photo")
                                        .foregroundStyle(Color.ttSecondary)
                                    Text("No photos yet")
                                        .font(.caption2)
                                        .foregroundStyle(Color.ttTertiary)
                                }
                            }
                    } else {
                        ForEach(photoURLs, id: \.self) { urlStr in
                            if let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    case .failure:
                                        photoPlaceholder
                                    default:
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.white.opacity(0.05))
                                            .frame(width: 100, height: 100)
                                            .overlay { ProgressView() }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .accessibilityLabel("\(photoURLs.count) community photos")
        }
        .padding(.horizontal)
        .task { await loadPhotos() }
        .onChange(of: selectedItem) { _, newItem in
            guard let item = newItem else { return }
            uploadPhoto(item: item)
        }
    }

    private var photoPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white.opacity(0.05))
            .frame(width: 100, height: 100)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(Color.ttSecondary)
            }
    }

    private func loadPhotos() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let photos: [DBCommunityPhoto] = try await SupabaseClient.shared.get(
                "community_photos",
                query: [
                    "strain_id": "eq.\(strain.id.uuidString)",
                    "is_removed": "eq.false",
                    "order": "created_at.desc",
                    "limit": "20"
                ]
            )
            photoURLs = photos.compactMap { photo in
                "\(SupabaseClient.shared.baseURL)/storage/v1/object/public/community-photos/\(photo.storagePath)"
            }
        } catch {
            // Silent — show empty state
        }
    }

    private func uploadPhoto(item: PhotosPickerItem) {
        guard let uid = appState.auth.userId else { return }
        isUploading = true

        Task {
            defer {
                isUploading = false
                selectedItem = nil
            }

            guard let data = try? await item.loadTransferable(type: Data.self) else { return }

            guard let uiImage = UIImage(data: data),
                  let resized = uiImage.resizedToFit(maxDimension: 1024),
                  let jpegData = resized.jpegData(compressionQuality: 0.8) else { return }

            do {
                let publicURL = try await StorageService().uploadCommunityPhoto(
                    userId: uid,
                    strainId: strain.id,
                    imageData: jpegData
                )

                // Create DB record
                let insert = DBCommunityPhotoInsert(
                    authorId: uid,
                    strainId: strain.id,
                    storagePath: publicURL.replacingOccurrences(
                        of: "\(SupabaseClient.shared.baseURL)/storage/v1/object/public/community-photos/",
                        with: ""
                    ),
                    caption: nil
                )
                let _ = try await SupabaseClient.shared.post("community_photos", body: insert)

                photoURLs.insert(publicURL, at: 0)
                Haptics.success()
            } catch {
                // Silent failure
            }
        }
    }
}

struct DBCommunityPhoto: Codable {
    let id: UUID
    let authorId: UUID
    let strainId: UUID
    let storagePath: String
    let caption: String?
    let isRemoved: Bool
    let createdAt: Date
}

struct DBCommunityPhotoInsert: Codable {
    let authorId: UUID
    let strainId: UUID
    let storagePath: String
    let caption: String?
}
