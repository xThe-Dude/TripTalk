import SwiftUI

struct ProfileView: View {
    @Environment(AppState.self) private var appState
    @State private var showDeleteConfirm = false
    @State private var isDeletingAccount = false
    @State private var showEditProfile = false
    @State private var showNamePrompt = false
    @State private var showExportShare = false
    @State private var exportURL: URL?

    var body: some View {
        @Bindable var state = appState
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Premium avatar area with glow
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.ttGlow.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 160, height: 160)

                        AvatarPickerView()
                    }

                    VStack(spacing: 4) {
                        Text(appState.auth.profile?.displayName ?? "Explorer")
                            .font(.ttCardTitle)
                            .foregroundStyle(Color.ttPrimary)
                        if let bio = appState.auth.profile?.bio, !bio.isEmpty {
                            Text(bio)
                                .font(.subheadline)
                                .foregroundStyle(Color.ttSecondary)
                        } else {
                            Text(appState.auth.isAuthenticated ? "Signed In" : "Guest Mode")
                                .font(.subheadline)
                                .foregroundStyle(Color.ttSecondary)
                        }
                    }
                    .animateIn(delay: 0.1)

                    if appState.auth.isAuthenticated {
                        Button {
                            showEditProfile = true
                        } label: {
                            Label("Edit Profile", systemImage: "pencil")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.ttAccent)
                        }
                        .padding(.top, 4)
                        .sheet(isPresented: $showEditProfile) {
                            EditProfileView()
                                .environment(appState)
                        }
                    }

                    // Saved Strains
                    profileSection("Saved Varieties") {
                        if appState.savedStrainIDs.isEmpty {
                            EmptyStateView(icon: "leaf", imageName: "empty_saved", title: "No Saved Varieties", subtitle: "Tap the bookmark icon on any variety to save it here")
                        } else {
                            ForEach(appState.strains.filter { appState.savedStrainIDs.contains($0.id) }) { strain in
                                NavigationLink(value: strain) {
                                    HStack {
                                        Image(systemName: strain.parentSubstance.icon)
                                            .foregroundStyle(strain.parentSubstance.color)
                                        Text(strain.name)
                                            .foregroundStyle(Color.ttPrimary)
                                        Spacer()
                                        PotencyDots(level: strain.potency.level, dotSize: 6, activeColor: strain.potency.color)
                                        .accessibilityElement(children: .ignore)
                                        .accessibilityLabel("Potency: \(strain.potency.rawValue), level \(strain.potency.level) of 4")
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .animateIn(delay: 0.2)

                    // My Trip Reports
                    profileSection("My Trip Reports") {
                        if appState.userTripReports.isEmpty {
                            EmptyStateView(icon: "square.and.pencil", imageName: "empty_reports", title: "No Trip Reports", subtitle: "Share your experience from any variety's detail page")
                        } else {
                            ForEach(appState.userTripReports) { report in
                                let strainName = appState.strains.first(where: { $0.id == report.strainId })?.name ?? "Unknown"
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(strainName)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.ttPrimary)
                                    RatingStars(rating: Double(report.rating), size: 10)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .animateIn(delay: 0.3)

                    // Saved Substances
                    profileSection("Saved Substances") {
                        if appState.savedSubstanceIDs.isEmpty {
                            EmptyStateView(icon: "testtube.2", imageName: "empty_saved", title: "No Saved Substances", subtitle: "Tap the bookmark icon on any substance to save it here")
                        } else {
                            ForEach(appState.substances.filter { appState.savedSubstanceIDs.contains($0.id) }) { substance in
                                NavigationLink(value: substance) {
                                    HStack {
                                        Image(systemName: substance.imageSymbol)
                                            .foregroundStyle(Color.ttGlow)
                                        Text(substance.name)
                                            .foregroundStyle(Color.ttPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .animateIn(delay: 0.4)

                    // Saved Services
                    profileSection("Saved Services") {
                        if appState.savedServiceIDs.isEmpty {
                            EmptyStateView(icon: "building.2", imageName: "empty_services", title: "No Saved Services", subtitle: "Tap the bookmark icon on any service center to save it here")
                        } else {
                            ForEach(appState.services.filter { appState.savedServiceIDs.contains($0.id) }) { service in
                                NavigationLink(value: service) {
                                    HStack {
                                        Image(systemName: service.imageSymbol)
                                            .foregroundStyle(Color.ttGlow)
                                        Text(service.name)
                                            .foregroundStyle(Color.ttPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption2)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .animateIn(delay: 0.35)

                    // My Reviews
                    profileSection("My Reviews") {
                        if appState.userReviews.isEmpty {
                            EmptyStateView(icon: "text.bubble", imageName: "empty_reviews", title: "No Reviews Yet", subtitle: "Leave a review from any substance or service detail page")
                        } else {
                            ForEach(appState.userReviews) { review in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(review.title)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color.ttPrimary)
                                    RatingStars(rating: Double(review.rating), size: 10)
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .animateIn(delay: 0.35)

                    // Settings
                    profileSection("Settings") {
                        HStack {
                            Text("Jurisdiction")
                                .foregroundStyle(Color.ttPrimary)
                            Spacer()
                            Picker("Jurisdiction", selection: $state.selectedJurisdiction) {
                                ForEach(Jurisdiction.allCases) { j in
                                    Text(j.rawValue).tag(j)
                                }
                            }
                            .tint(Color.ttAccent)
                            .onChange(of: appState.selectedJurisdiction) {
                                appState.updateJurisdiction(appState.selectedJurisdiction)
                            }
                        }
                        Button {
                            if let data = DataExportService.exportUserData(from: appState) {
                                let url = DataExportService.exportFileURL()
                                try? data.write(to: url)
                                exportURL = url
                                showExportShare = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundStyle(Color.ttGlow)
                                Text("Export My Data")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .animateIn(delay: 0.4)
                    .sheet(isPresented: $showExportShare) {
                        if let url = exportURL {
                            ShareSheet(items: [url])
                        }
                    }

                    // Links
                    profileSection("Info") {
                        Link(destination: URL(string: "https://triptalk.guide/support.html")!) {
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(Color.ttGlow)
                                Text("Community Guidelines")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                        Link(destination: URL(string: "https://triptalk.guide/privacy.html")!) {
                            HStack {
                                Image(systemName: "hand.raised")
                                    .foregroundStyle(Color.ttGlow)
                                Text("Privacy Policy")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                        Link(destination: URL(string: "https://triptalk.guide/terms.html")!) {
                            HStack {
                                Image(systemName: "doc.plaintext")
                                    .foregroundStyle(Color.ttGlow)
                                Text("Terms of Service")
                                    .foregroundStyle(Color.ttPrimary)
                                Spacer()
                                Image(systemName: "arrow.up.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ttSecondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .animateIn(delay: 0.4)

                    // Crisis Resources
                    profileSection("Crisis Resources") {
                        VStack(alignment: .leading, spacing: 8) {
                            Link(destination: URL(string: "tel:988")!) {
                                HStack {
                                    Image(systemName: "phone.circle.fill")
                                        .foregroundStyle(.green)
                                    VStack(alignment: .leading) {
                                        Text("988 Suicide & Crisis Lifeline")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.ttPrimary)
                                        Text("Call or text 988")
                                            .font(.caption)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.ttTertiary)
                                }
                            }
                            .accessibilityHint("Double-tap to call 988")
                            Divider().overlay(Color.white.opacity(0.05))
                            Link(destination: URL(string: "tel:6234737433")!) {
                                HStack {
                                    Image(systemName: "heart.circle.fill")
                                        .foregroundStyle(Color.ttVisual)
                                    VStack(alignment: .leading) {
                                        Text("Fireside Project")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.ttPrimary)
                                        Text("Psychedelic peer support: (623) 473-7433")
                                            .font(.caption)
                                            .foregroundStyle(Color.ttSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(Color.ttTertiary)
                                }
                            }
                            .accessibilityHint("Double-tap to call the Fireside Project psychedelic peer support line")
                        }
                    }
                    .animateIn(delay: 0.4)

                    // About
                    profileSection("About") {
                        HStack {
                            Text("Version")
                                .foregroundStyle(Color.ttPrimary)
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                                .foregroundStyle(Color.ttSecondary)
                        }
                        .padding(.vertical, 2)
                    }
                    .animateIn(delay: 0.4)

                    // Account
                    if appState.auth.isAuthenticated {
                        Button {
                            Task { await appState.auth.signOut() }
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.subheadline)
                                .foregroundStyle(.orange)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 0.5))
                        }
                        .padding(.horizontal)

                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label(isDeletingAccount ? "Deleting…" : "Delete Account", systemImage: "person.crop.circle.badge.minus")
                                .font(.subheadline)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 0.5))
                        }
                        .disabled(isDeletingAccount)
                        .padding(.horizontal)
                        .alert("Delete your account?", isPresented: $showDeleteConfirm) {
                            Button("Delete", role: .destructive) {
                                isDeletingAccount = true
                                Task {
                                    try? await appState.auth.deleteAccount()
                                    isDeletingAccount = false
                                }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This will permanently delete your profile, reviews, and trip reports. This cannot be undone.")
                        }
                    } else {
                        Button {
                            UserDefaults.standard.set(false, forKey: "guest_mode")
                        } label: {
                            Label("Sign In to Sync Data", systemImage: "person.badge.plus")
                                .font(.subheadline)
                                .foregroundStyle(.ttAccent)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.ttAccent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.ttAccent.opacity(0.3), lineWidth: 0.5))
                        }
                        .padding(.horizontal)
                    }

                    // Reset
                    Button(role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "ageVerified")
                    } label: {
                        Label("Reset Age Verification", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 0.5))
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
                .padding(.bottom, 90)
            }
            .background { GradientBackground() }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .navigationTitle("Profile")
            // After a sign-in that produced no display name, prompt the user
            // once to choose one (Apple often returns no name on repeat sign-ins).
            .sheet(isPresented: $showNamePrompt) {
                EditProfileView()
                    .environment(appState)
            }
            .onChange(of: appState.auth.needsDisplayNamePrompt) { _, needs in
                if needs {
                    showNamePrompt = true
                    appState.auth.needsDisplayNamePrompt = false
                }
            }
            .onAppear {
                if appState.auth.needsDisplayNamePrompt {
                    showNamePrompt = true
                    appState.auth.needsDisplayNamePrompt = false
                }
            }
            .navigationDestination(for: Strain.self) { strain in
                StrainDetailView(strain: strain)
            }
            .navigationDestination(for: Substance.self) { substance in
                SubstanceDetailView(substance: substance)
            }
            .navigationDestination(for: ServiceCenter.self) { service in
                ServiceDetailView(service: service)
            }
        }
    }

    @ViewBuilder
    private func profileSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.ttCardTitle)
                .foregroundStyle(Color.ttPrimary)
                .tracking(0.5)
                .padding(.horizontal)
                .accessibilityAddTraits(.isHeader)
            VStack(alignment: .leading, spacing: 4) {
                content()
            }
            .darkGlassCard()
            .padding(.horizontal)
        }
    }
}
