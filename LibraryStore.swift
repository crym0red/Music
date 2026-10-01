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
        var imported: [Track] = []

        for url in urls {
            if let track = await importFile(url) {
                imported.append(track)
            }
        }

        // Add the copied files immediately. Metadata enrichment happens after the
        // copy succeeds, so a valid audio file can never disappear just because
        // metadata loading is slow or unsupported by AVFoundation.
        if !imported.isEmpty {
            importedTracks.append(contentsOf: imported)
            save()
        }

        for track in imported {
            await enrichMetadata(for: track)
        }
    }

    private func importFile(_ url: URL) async -> Track? {
        let accessed = url.startAccessingSecurityScopedResource()
        defer {
            if accessed { url.stopAccessingSecurityScopedResource() }
        }

        // The Files app can return a URL whose extension is not populated in the
        // way UTType expects. We validate common audio extensions as a fallback.
        let ext = url.pathExtension.lowercased()
        let supported = ["mp3", "m4a", "aac", "wav", "aiff", "aif", "caf", "flac", "alac", "m4b", "mp4"]
        guard supported.contains(ext) else { return nil }

        let destination = audioDirectory.appendingPathComponent(UUID().uuidString + "." + ext)

        do {
            // UIDocumentPicker with asCopy:true normally gives us a local temporary
            // copy. Some Files providers still expose a coordinated URL, though, so
            // keep a byte-copy fallback. Both paths run while the security scope is
            // active.
            do {
                try fileManager.copyItem(at: url, to: destination)
            } catch {
                let data = try Data(contentsOf: url, options: [.mappedIfSafe])
                try data.write(to: destination, options: [.atomic])
            }

            let fallbackTitle = url.deletingPathExtension().lastPathComponent
            return Track(
                title: fallbackTitle.isEmpty ? "Untitled" : fallbackTitle,
                artist: "Unknown Artist",
                album: nil,
                artwork: .mono,
                artworkData: nil,
                fileURL: destination,
                duration: nil
            )
        } catch {
            print("Fugacious import error:", error)
            return nil
        }
    }

    private func enrichMetadata(for track: Track) async {
        guard let url = track.fileURL else { return }

        let asset = AVURLAsset(url: url)
        let metadata = asset.commonMetadata
        let title = metadata.firstValue(for: .commonKeyTitle)
        let artist = metadata.firstValue(for: .commonKeyArtist)
        let album = metadata.firstValue(for: .commonKeyAlbumName)
        let artworkData = metadata.first { $0.commonKey == .commonKeyArtwork }?.dataValue
        let duration = asset.duration.seconds.isFinite ? asset.duration.seconds : nil

        guard let index = importedTracks.firstIndex(where: { $0.id == track.id }) else { return }

        let current = importedTracks[index]
        importedTracks[index] = Track(
            id: current.id,
            title: title?.isEmpty == false ? title! : current.title,
            artist: artist?.isEmpty == false ? artist! : current.artist,
            album: album?.isEmpty == false ? album : current.album,
            artwork: current.artwork,
            artworkData: artworkData ?? current.artworkData,
            fileURL: current.fileURL,
            duration: duration ?? current.duration
        )
        save()
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
        // Remove the old placeholder playlist from early builds and discard
        // references to tracks that no longer exist on disk.
        let validIDs = Set(importedTracks.map(\.id))
        playlists = state.playlists
            .filter { $0.title.trimmingCharacters(in: .whitespacesAndNewlines) != "999" }
            .map { playlist in
                var cleaned = playlist
                cleaned.trackIDs = playlist.trackIDs.filter { validIDs.contains($0) }
                return cleaned
            }
        favorites = Set(state.favorites.filter { validIDs.contains($0) })
        recentlyPlayed = state.recentlyPlayed.filter { validIDs.contains($0) }

        // Persist migrations immediately so removed placeholder data such as the
        // old "999" playlist cannot reappear on the next launch.
        save()
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
