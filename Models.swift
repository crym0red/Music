import Foundation

struct Track: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let artwork: ArtworkStyle
    let fileURL: URL?
    let duration: Double?
    var isLocal: Bool { fileURL != nil }

    init(id: UUID = UUID(), title: String, artist: String, artwork: ArtworkStyle, fileURL: URL? = nil, duration: Double? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.artwork = artwork
        self.fileURL = fileURL
        self.duration = duration
    }
}

struct Playlist: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let subtitle: String
    let artwork: ArtworkStyle
    init(id: UUID = UUID(), title: String, subtitle: String, artwork: ArtworkStyle) {
        self.id = id; self.title = title; self.subtitle = subtitle; self.artwork = artwork
    }
}

struct Album: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let artist: String
    let artwork: ArtworkStyle
    init(id: UUID = UUID(), title: String, artist: String, artwork: ArtworkStyle) {
        self.id = id; self.title = title; self.artist = artist; self.artwork = artwork
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

enum MockData {
    static let artistTracks = [
        Track(title: "Signal Lights", artist: "Lena Cove", artwork: .portrait),
        Track(title: "Fading Sunday", artist: "Lena Cove", artwork: .sunset),
        Track(title: "Barefoot on Pavement", artist: "Lena Cove", artwork: .olive),
        Track(title: "Late Bloomer", artist: "Lena Cove", artwork: .flower),
        Track(title: "Tidepool Heart", artist: "Lena Cove", artwork: .violet)
    ]
    static let artist = Artist(name: "Lena Cove", subtitle: "Full artist discography", artwork: .portrait, tracks: artistTracks)
    static let libraryTracks = [
        Track(title: "Midnight Drive", artist: "Mia Sol", artwork: .blue),
        Track(title: "Signal Lights", artist: "Lena Cove", artwork: .portrait),
        Track(title: "Static Bloom", artist: "Northbound", artwork: .olive),
        Track(title: "After Dark", artist: "Eli Voss", artwork: .midnight),
        Track(title: "Fading Sunday", artist: "Lena Cove", artwork: .orange),
        Track(title: "Tidepool Heart", artist: "Lena Cove", artwork: .violet),
        Track(title: "Wildflower", artist: "Mia Sol", artwork: .flower),
        Track(title: "Quiet Hours", artist: "Northbound", artwork: .sunset)
    ]
    static let playlists = [
        Playlist(title: "Liked Songs", subtitle: "384 tracks", artwork: .violet),
        Playlist(title: "roadtrip favorites", subtitle: "48 tracks", artwork: .flower),
        Playlist(title: "quiet hours", subtitle: "60 tracks", artwork: .sunset)
    ]
    static let albums = [
        Album(title: "Midnight Drive", artist: "Mia Sol", artwork: .blue),
        Album(title: "Static Bloom", artist: "Northbound", artwork: .olive),
        Album(title: "Signal Lights", artist: "Lena Cove", artwork: .portrait),
        Album(title: "After Dark", artist: "Eli Voss", artwork: .midnight)
    ]
}
