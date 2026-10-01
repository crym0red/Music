import Foundation
import Combine
import AVFoundation

@MainActor
final class LibraryStore: ObservableObject {
    @Published private(set) var importedTracks: [Track] = []
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

    var allTracks: [Track] { importedTracks + MockData.libraryTracks }

    func importFiles(_ urls: [URL]) async {
        for url in urls {
            await importFile(url)
        }
        save()
    }

    private func importFile(_ url: URL) async {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        let ext = url.pathExtension.lowercased()
        guard ["mp3", "m4a", "aac", "wav", "aiff", "caf", "flac"].contains(ext) else { return }

        let destination = audioDirectory.appendingPathComponent(UUID().uuidString + "." + ext)
        do {
            try fileManager.copyItem(at: url, to: destination)
            let asset = AVURLAsset(url: destination)
            let metadata = asset.commonMetadata
            let title = metadata.firstValue(for: .commonKeyTitle) ?? url.deletingPathExtension().lastPathComponent
            let artist = metadata.firstValue(for: .commonKeyArtist) ?? "Unknown Artist"
            let duration = asset.duration.seconds.isFinite ? asset.duration.seconds : nil
            importedTracks.append(Track(title: title, artist: artist, artwork: .mono, fileURL: destination, duration: duration))
        } catch {
            print("Fugacious import error:", error)
        }
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
        save()
    }

    private struct State: Codable {
        var tracks: [Track]
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
        favorites = Set(state.favorites)
        recentlyPlayed = state.recentlyPlayed
    }

    private func save() {
        let state = State(tracks: importedTracks, favorites: Array(favorites), recentlyPlayed: recentlyPlayed)
        if let data = try? JSONEncoder().encode(state) { try? data.write(to: stateURL, options: .atomic) }
    }
}

private extension AVAsset {
    // Common metadata is available synchronously for local files.
    func commonMetadataValue(_ key: AVMetadataKey) -> String? {
        commonMetadata.first { $0.commonKey == key }?.stringValue
    }
}

private extension Array where Element == AVMetadataItem {
    func firstValue(for key: AVMetadataKey) -> String? {
        first { $0.commonKey == key }?.stringValue
    }
}
