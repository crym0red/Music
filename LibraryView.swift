import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var app: AppContainer
    @Binding var showSearch: Bool
    @Binding var showAdd: Bool
    @Binding var showProfile: Bool

    @State private var playlistHeaderY: CGFloat = .greatestFiniteMagnitude

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 7), count: 4)

    private var activeTitle: String {
        playlistHeaderY < 165 ? "Playlists" : "Your Library"
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color.fugaciousBackground
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        // The large promotional copy has intentionally been removed.
                        // The floating header now carries the section identity.

                        LazyVGrid(columns: columns, spacing: 7) {
                            ForEach(app.library.importedTracks.isEmpty ? MockData.libraryTracks : app.library.importedTracks) { track in
                                ArtworkView(style: track.artwork, cornerRadius: 7)
                                    .aspectRatio(1, contentMode: .fit)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        app.player.play(track, from: app.library.allTracks)
                                        app.library.recordPlay(track)
                                    }
                                    .contextMenu {
                                        Button { app.library.toggleFavorite(track) } label: {
                                            Label(app.library.isFavorite(track) ? "Remove Favorite" : "Favorite", systemImage: app.library.isFavorite(track) ? "heart.slash" : "heart")
                                        }
                                    }
                            }
                        }

                        Text("PINNED")
                            .font(.system(size: 8, weight: .bold))
                            .tracking(2)
                            .foregroundStyle(.white.opacity(0.42))
                            .frame(maxWidth: .infinity)
                            .padding(.top, -7)

                        GeometryReader { sectionProxy in
                            Color.clear
                                .preference(
                                    key: PlaylistHeaderPositionKey.self,
                                    value: sectionProxy.frame(in: .named("libraryScroll")).minY
                                )
                        }
                        .frame(height: 0)

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

                        Color.clear.frame(height: 130)
                    }
                    .padding(.horizontal, 17)
                    .padding(.top, proxy.safeAreaInsets.top + 72)
                    .padding(.bottom, proxy.safeAreaInsets.bottom + 110)
                }
                .coordinateSpace(name: "libraryScroll")
                .onPreferenceChange(PlaylistHeaderPositionKey.self) { value in
                    playlistHeaderY = value
                }

                floatingHeader(topInset: proxy.safeAreaInsets.top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private func floatingHeader(topInset: CGFloat) -> some View {
        HStack(spacing: 0) {
            Text(activeTitle)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .contentTransition(.opacity)

            Spacer()

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
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 17)
        .frame(height: 54)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.fugaciousCard.opacity(0.82),
                                Color.fugaciousTabBar.opacity(0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.08), lineWidth: 1)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, topInset + 8)
        .shadow(color: .black.opacity(0.22), radius: 16, y: 8)
        .animation(.easeOut(duration: 0.18), value: activeTitle)
    }

    @ViewBuilder
    private func sectionHeader(
        _ title: String,
        chevron: Bool = false,
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) -> some View {
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

private struct PlaylistHeaderPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = .greatestFiniteMagnitude

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
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
        .background(Color.fugaciousCard)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}
