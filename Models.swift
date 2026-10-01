import Foundation

struct Track: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let album: String?
    let artwork: ArtworkStyle
    let artworkData: Data?
    let fileURL: URL?
    let duration: Double?
    var isLocal: Bool { fileURL != nil }

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        album: String? = nil,
        artwork: ArtworkStyle = .mono,
        artworkData: Data? = nil,
        fileURL: URL? = nil,
        duration: Double? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.artworkData = artworkData
        self.fileURL = fileURL
        self.duration = duration
    }
}

struct Playlist: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var trackIDs: [UUID]
    var artworkData: Data?

    init(id: UUID = UUID(), title: String, trackIDs: [UUID] = [], artworkData: Data? = nil) {
        self.id = id
        self.title = title
        self.trackIDs = trackIDs
        self.artworkData = artworkData
    }

    var subtitle: String { "\(trackIDs.count) \(trackIDs.count == 1 ? "track" : "tracks")" }
}

struct Album: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let artworkData: Data?
    let trackIDs: [UUID]

    init(id: UUID = UUID(), title: String, artist: String, artworkData: Data? = nil, trackIDs: [UUID] = []) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artworkData = artworkData
        self.trackIDs = trackIDs
    }
}

enum ArtworkStyle: String, Hashable, Codable {
    case blue, orange, olive, midnight, violet, portrait, sunset, flower, smoke, mono
}

struct Artist: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let subtitle: String
    let artwork: ArtworkStyle
    let tracks: [Track]
    init(id: UUID = UUID(), name: String, subtitle: String, artwork: ArtworkStyle, tracks: [Track]) {
        self.id = id; self.name = name; self.subtitle = subtitle; self.artwork = artwork; self.tracks = tracks
    }
}
