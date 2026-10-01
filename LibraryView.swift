import SwiftUI

struct LibraryView: View {
    @Binding var showSearch: Bool
    @Binding var showAdd: Bool
    @Binding var showProfile: Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 4)

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    hero

                    sectionHeader("Your Library") {
                        HStack(spacing: 15) {
                            Button { showSearch = true } label: {
                                Image(systemName: "magnifyingglass")
                            }
                            Button { showAdd = true } label: {
                                Image(systemName: "plus")
                            }
                            Button { showProfile = true } label: {
                                Image(systemName: "person.crop.circle")
                            }
                        }
                        .foregroundStyle(.white)
                    }

                    LazyVGrid(columns: columns, spacing: 7) {
                        ForEach(MockData.libraryTracks) { track in
                            ArtworkView(style: track.artwork, cornerRadius: 7)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }

                    Text("PINNED")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(2)
                        .foregroundStyle(.white.opacity(0.42))
                        .frame(maxWidth: .infinity)
                        .padding(.top, -7)

                    sectionHeader("Playlists")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 9) {
                            ForEach(MockData.playlists) { playlist in
                                PlaylistCard(playlist: playlist)
                            }
                        }
                    }

                    sectionHeader("Albums", chevron: true)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MockData.albums) { album in
                                AlbumCard(album: album)
                            }
                        }
                    }

                    NavigationLink {
                        ArtistView(artist: MockData.artist)
                    } label: {
                        ArtistBanner(artist: MockData.artist)
                    }
                    .buttonStyle(.plain)

                    Color.clear.frame(height: 100)
                }
                .padding(.horizontal, 17)
                .padding(.top, 12)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("8")
                .font(.system(size: 46, weight: .black, design: .rounded))
                .foregroundStyle(.white)
            Text("Organize your")
                .font(.system(size: 30, weight: .black, design: .rounded))
            Text("library however you")
                .font(.system(size: 30, weight: .black, design: .rounded))
            Text("want")
                .font(.system(size: 30, weight: .black, design: .rounded))
        }
        .foregroundStyle(.white)
        .padding(.vertical, 20)
    }

    @ViewBuilder
    private func sectionHeader(_ title: String, chevron: Bool = false, @ViewBuilder trailing: () -> some View = { EmptyView() }) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.6))
            }
            Spacer()
            trailing()
        }
    }
}

struct PlaylistCard: View {
    let playlist: Playlist
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ArtworkView(style: playlist.artwork, cornerRadius: 8)
                .frame(width: 102, height: 102)
            Text(playlist.title)
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
            Text(playlist.subtitle)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(width: 102, alignment: .leading)
    }
}

struct AlbumCard: View {
    let album: Album
    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            ArtworkView(style: album.artwork, cornerRadius: 8)
                .frame(width: 145, height: 145)
            Text(album.title)
                .font(.system(size: 12, weight: .semibold))
            Text(album.artist)
                .font(.system(size: 10))
                .foregroundStyle(.white.opacity(0.45))
        }
        .frame(width: 145, alignment: .leading)
    }
}

struct ArtistBanner: View {
    let artist: Artist
    var body: some View {
        HStack(spacing: 14) {
            ArtworkView(style: artist.artwork, cornerRadius: 10)
                .frame(width: 72, height: 72)
            VStack(alignment: .leading, spacing: 5) {
                Text("FULL ARTIST DISCOGRAPHIES")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(1.4)
                    .foregroundStyle(.white.opacity(0.5))
                Text(artist.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                Text("View artist")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
            Spacer()
        }
        .padding(12)
        .background(Color.spineCard)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}
