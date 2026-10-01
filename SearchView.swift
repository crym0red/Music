import SwiftUI
import UniformTypeIdentifiers

struct SearchView: View {
    @EnvironmentObject private var library: LibraryStore
    @State private var query = ""

    private var results: [Track] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return library.allTracks }
        return library.allTracks.filter { $0.title.localizedCaseInsensitiveContains(q) || $0.artist.localizedCaseInsensitiveContains(q) }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("Search").font(.system(size: 34, weight: .black, design: .rounded))
                HStack {
                    Image(systemName: "magnifyingglass")
                    TextField("Artists, albums, songs", text: $query)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                .padding(13)
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 13))

                if query.isEmpty {
                    Text("Your library").font(.system(size: 15, weight: .semibold)).foregroundStyle(.white.opacity(0.55))
                }

                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(results) { track in
                            TrackRow(track: track)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
            .padding(18)
            .foregroundStyle(.white)
            .background(Color.fugaciousBackground)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct LibraryTracksView: View {
    @EnvironmentObject private var app: AppContainer
    var body: some View {
        NavigationStack {
            List {
                ForEach(app.library.importedTracks) { track in TrackRow(track: track) }
                    .onDelete { offsets in offsets.map { app.library.importedTracks[$0] }.forEach { app.library.delete($0) } }
            }
            .scrollContentBackground(.hidden)
            .background(Color.fugaciousBackground)
            .foregroundStyle(.white)
            .navigationTitle("Library")
        }
    }
}

struct TrackRow: View {
    @EnvironmentObject private var app: AppContainer
    let track: Track

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(style: track.artwork, artworkData: track.artworkData, cornerRadius: 8).frame(width: 50, height: 50)
            VStack(alignment: .leading, spacing: 3) {
                Text(track.title).font(.system(size: 14, weight: .semibold)).lineLimit(1)
                Text(track.artist).font(.system(size: 11)).foregroundStyle(.white.opacity(0.5)).lineLimit(1)
            }
            Spacer()
            Button { app.library.toggleFavorite(track) } label: {
                Image(systemName: app.library.isFavorite(track) ? "heart.fill" : "heart")
                    .foregroundStyle(app.library.isFavorite(track) ? .pink : .white.opacity(0.5))
            }.buttonStyle(.plain)
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
        .onTapGesture { app.player.play(track, from: app.library.allTracks); app.library.recordPlay(track) }
    }
}

struct AddMenuView: View {
    @EnvironmentObject private var library: LibraryStore
    @Environment(\.dismiss) private var dismiss
    @State private var showImporter = false

    var body: some View {
        NavigationStack {
            List {
                Button { showImporter = true } label: { Label("Import music", systemImage: "square.and.arrow.down") }
                Text("Music is copied into Fugacious storage so it stays available offline.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .navigationTitle("Add")
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.audio], allowsMultipleSelection: true) { result in
                if case .success(let urls) = result {
                    Task { await library.importFiles(urls); dismiss() }
                }
            }
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill").font(.system(size: 70)).foregroundStyle(.white.opacity(0.8))
                Text("Fugacious").font(.title.bold())
                Text("Account & Settings").foregroundStyle(.secondary)
                NavigationLink("Settings") { SettingsView() }.buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.fugaciousBackground)
            .foregroundStyle(.white)
            .navigationTitle("Profile")
        }
    }
}
