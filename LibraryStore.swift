import Foundation
import Combine
import AVFoundation
import UniformTypeIdentifiers

@MainActor
final class LibraryStore: ObservableObject {
    @Published private(set) var importedTracks: [Track] = []
    @Published private(set) var playlists: [Playlist] = []
    @Published private(set) var favorites: Set<UUID> = []
    @Published private(set) var recentlyPlayed: [UUID] = []

    private let fileManager = FileManager.default
    private let stateURL: URL
    private let audioDirectory: URL

    init() {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let root = support.appendingPathComponent("Fugacious", isDirectory: true)
        audioDirectory = root.appendingPathComponent("Music", isDirectory: true)
        stateURL = root.appendingPathComponent("library.json")
        try? fileManager.createDirectory(at: audioDirectory, withIntermediateDirectories: true)
        load()
    }

    var allTracks: [Track] { importedTracks }

    var albums: [Album] {
        var grouped: [String: [Track]] = [:]
        for track in importedTracks {
            guard let album = track.album?.trimmingCharacters(in: .whitespacesAndNewlines), !album.isEmpty else { continue }
            grouped[album, default: []].append(track)
        }

        return grouped.keys.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }.compactMap { title in
            guard let tracks = grouped[title], let first = tracks.first else { return nil }
            return Album(
                title: title,
                artist: first.artist,
                artworkData: first.artworkData,
                trackIDs: tracks.map(\.id)
            )
        }
    }

    var favoriteTracks: [Track] {
        importedTracks.filter { favorites.contains($0.id) }
    }

    func importFiles(_ urls: [URL]) async {
        for url in urls { await importFile(url) }
        save()
    }

    private func importFile(_ url: URL) async {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
        }

        let ext = url.pathExtension.lowercased()
        guard ["mp3", "m4a", "aac", "wav", "aiff", "aif", "caf", "flac", "alac"].contains(ext) else { return }

        let destination = audioDirectory.appendingPathComponent(UUID().uuidString + "." + ext)

        do {
            try fileManager.copyItem(at: url, to: destination)
            let asset = AVURLAsset(url: destination)
            let metadata = asset.commonMetadata
            let title = metadata.firstValue(for: .commonKeyTitle) ?? url.deletingPathExtension().lastPathComponent
            let artist = metadata.firstValue(for: .commonKeyArtist) ?? "Unknown Artist"
            let album = metadata.firstValue(for: .commonKeyAlbumName)
            let duration = asset.duration.seconds.isFinite ? asset.duration.seconds : nil
            let artworkData = metadata.first { $0.commonKey == .commonKeyArtwork }?.dataValue

            importedTracks.append(
                Track(
                    title: title,
                    artist: artist,
                    album: album,
                    artwork: .mono,
                    artworkData: artworkData,
                    fileURL: destination,
                    duration: duration
                )
            )
        } catch {
            print("Fugacious import error:", error)
        }
    }

    func createPlaylist(title: String) {
        let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        playlists.append(Playlist(title: clean))
        save()
    }

    func add(_ track: Track, to playlist: Playlist) {
        guard let index = playlists.firstIndex(where: { $0.id == playlist.id }), !playlists[index].trackIDs.contains(track.id) else { return }
        playlists[index].trackIDs.append(track.id)
        save()
    }

    func toggleFavorite(_ track: Track) {
        if favorites.contains(track.id) { favorites.remove(track.id) }
        else { favorites.insert(track.id) }
        save()
    }

    func isFavorite(_ track: Track) -> Bool { favorites.contains(track.id) }

    func recordPlay(_ track: Track) {
        recentlyPlayed.removeAll { $0 == track.id }
        recentlyPlayed.insert(track.id, at: 0)
        if recentlyPlayed.count > 50 { recentlyPlayed.removeLast() }
        save()
    }

    func delete(_ track: Track) {
        if let url = track.fileURL { try? fileManager.removeItem(at: url) }
        importedTracks.removeAll { $0.id == track.id }
        favorites.remove(track.id)
        recentlyPlayed.removeAll { $0 == track.id }
        for index in playlists.indices {
            playlists[index].trackIDs.removeAll { $0 == track.id }
        }
        save()
    }

    private struct State: Codable {
        var tracks: [Track]
        var playlists: [Playlist]
        var favorites: [UUID]
        var recentlyPlayed: [UUID]
    }

    private func load() {
        guard let data = try? Data(contentsOf: stateURL),
              let state = try? JSONDecoder().decode(State.self, from: data) else { return }

        importedTracks = state.tracks.filter { track in
            guard let url = track.fileURL else { return false }
            return fileManager.fileExists(atPath: url.path)
        }
        playlists = state.playlists
        favorites = Set(state.favorites)
        recentlyPlayed = state.recentlyPlayed
    }

    private func save() {
        let state = State(
            tracks: importedTracks,
            playlists: playlists,
            favorites: Array(favorites),
            recentlyPlayed: recentlyPlayed
        )
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: stateURL, options: .atomic)
        }
    }
}

private extension Array where Element == AVMetadataItem {
    func firstValue(for key: AVMetadataKey) -> String? {
        first { $0.commonKey == key }?.stringValue
    }
}
