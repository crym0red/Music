import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject private var app: AppContainer
    @Binding var showSearch: Bool
    @Binding var showProfile: Bool
    @State private var showCreatePlaylist = false
    @State private var showImporter = false

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 4)

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                // Keep the 64pt toolbar content height, but place it below the
                // real iOS status/Dynamic Island safe area. The entire header is
                // fixed above the scroll view and spans the full screen width.
                topBar()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        if app.library.allTracks.isEmpty {
                            emptyLibrary
                                .frame(maxWidth: .infinity)
                                .padding(.top, 120)
                        } else {
                            libraryContent
                                .padding(.horizontal, 17)
                                .padding(.top, 22)
                        }

                        Color.clear.frame(height: 130)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, proxy.safeAreaInsets.bottom)
                }
                .background(Color.fugaciousBackground)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.fugaciousBackground)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showCreatePlaylist) {
            CreatePlaylistView()
                .environmentObject(app.library)
        }
        .sheet(isPresented: $showImporter) {
            FugaciousDocumentPicker { urls in
                Task { await app.library.importFiles(urls) }
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var libraryContent: some View {
        let tracks = app.library.allTracks
        let favorites = app.library.favoriteTracks
        let albums = app.library.albums

        if !favorites.isEmpty {
            Text("PINNED")
                .font(.system(size: 8, weight: .bold))
                .tracking(2)
                .foregroundStyle(.white.opacity(0.42))
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)

            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(favorites) { track in
                    ArtworkView(style: track.artwork, artworkData: track.artworkData, cornerRadius: 7)
                        .aspectRatio(1, contentMode: .fit)
                        .contentShape(Rectangle())
                        .onTapGesture { play(track) }
                }
            }
            .padding(.bottom, 28)
        }

        HStack {
            Text("Playlists")
                .font(.system(size: 25, weight: .bold, design: .rounded))
            Spacer()
            Button { showCreatePlaylist = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .semibold))
            }
            .buttonStyle(.plain)
        }
        .foregroundStyle(.white)

        if !app.library.playlists.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(app.library.playlists) { playlist in
                        PlaylistCard(playlist: playlist, tracks: tracks)
                    }
                }
                .padding(.top, 12)
            }
        }

        if !albums.isEmpty {
            HStack(spacing: 7) {
                Text("Albums")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.top, 30)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(albums) { album in
                        AlbumCard(album: album)
                    }
                }
                .padding(.top, 12)
            }
        }
    }

    private var emptyLibrary: some View {
        VStack(spacing: 16) {
            Button { showImporter = true } label: {
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 72, height: 72)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(.white.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(.plain)

            Text("Add music")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
        }
    }

    private func topBar() -> some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: FugaciousSafeArea.top)

            HStack(spacing: 0) {
                Text("Your Library")
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .lineLimit(1)

                Spacer(minLength: 12)

                HStack(spacing: 19) {
                    Button { showSearch = true } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("Search")

                    Button { showImporter = true } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add music")

                    Button { showProfile = true } label: {
                        Image(systemName: "person.crop.circle")
                    }
                    .accessibilityLabel("Profile")
                }
                .font(.system(size: 20, weight: .medium))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .offset(y: 8)
        }
        .frame(maxWidth: .infinity)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.white.opacity(0.07))
                        .frame(height: 1)
                }
        }
        .contentShape(Rectangle())
    }


    private func play(_ track: Track) {
        app.player.play(track, from: app.library.allTracks)
        app.library.recordPlay(track)
    }
}

private enum FugaciousSafeArea {
    static var top: CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .safeAreaInsets.top ?? 0
    }
}

struct PlaylistCard: View {
    let playlist: Playlist
    let tracks: [Track]

    private var artwork: Track? { tracks.first { playlist.trackIDs.contains($0.id) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ArtworkView(style: artwork?.artwork ?? .mono, artworkData: artwork?.artworkData, cornerRadius: 8)
                .frame(width: 120, height: 120)
            Text(playlist.title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
            Text(playlist.subtitle)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(width: 120, alignment: .leading)
    }
}

struct AlbumCard: View {
    let album: Album

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ArtworkView(style: .mono, artworkData: album.artworkData, cornerRadius: 8)
                .frame(width: 150, height: 150)
            Text(album.title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
            Text(album.artist)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.45))
                .lineLimit(1)
        }
        .frame(width: 150, alignment: .leading)
    }
}

struct CreatePlaylistView: View {
    @EnvironmentObject private var library: LibraryStore
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Playlist name", text: $title)
                Button("Create") {
                    library.createPlaylist(title: title)
                    dismiss()
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle("New Playlist")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


/// Uses the native Files document picker with `asCopy: true`. This avoids the
/// security-scoped/iCloud URL failures that can occur with SwiftUI's
/// `.fileImporter` when a provider hands back a temporary or coordinated URL.
struct FugaciousDocumentPicker: UIViewControllerRepresentable {
    let onPicked: ([URL]) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPicked: onPicked)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.audio],
            asCopy: true
        )
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        picker.modalPresentationStyle = .formSheet
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        private let onPicked: ([URL]) -> Void

        init(onPicked: @escaping ([URL]) -> Void) {
            self.onPicked = onPicked
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let audioURLs = urls.filter {
                let ext = $0.pathExtension.lowercased()
                return ["mp3", "m4a", "aac", "wav", "aiff", "aif", "caf", "flac", "alac", "m4b", "mp4"].contains(ext)
            }
            onPicked(audioURLs)
        }
    }
}
