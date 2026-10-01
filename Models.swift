import Foundation

struct Track: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let artwork: ArtworkStyle
}

struct Playlist: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let artwork: ArtworkStyle
}

struct Album: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let artist: String
    let artwork: ArtworkStyle
}

enum ArtworkStyle: Hashable {
    case blue, orange, olive, midnight, violet, portrait, sunset, flower, smoke, mono
}

struct Artist {
    let name: String
    let subtitle: String
    let artwork: ArtworkStyle
    let tracks: [Track]
}

enum MockData {
    static let artistTracks = [
        Track(title: "Signal Lights", artist: "Lena Cove", artwork: .portrait),
        Track(title: "Fading Sunday", artist: "Lena Cove", artwork: .sunset),
        Track(title: "Barefoot on Pavement", artist: "Lena Cove", artwork: .olive),
        Track(title: "Late Bloomer", artist: "Lena Cove", artwork: .flower),
        Track(title: "Tidepool Heart", artist: "Lena Cove", artwork: .violet)
    ]

    static let artist = Artist(
        name: "Lena Cove",
        subtitle: "Full artist discography",
        artwork: .portrait,
        tracks: artistTracks
    )

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
