import Foundation
import SwiftData

@Model
final class SavedSong {
    @Attribute(.unique) var remoteID: String
    var title: String
    var artist: String
    var artworkURL: String?
    var streamURL: String?
    var isFavorite: Bool
    var createdAt: Date

    init(
        remoteID: String,
        title: String,
        artist: String,
        artworkURL: String? = nil,
        streamURL: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = .now
    ) {
        self.remoteID = remoteID
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.streamURL = streamURL
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }
}

@Model
final class SavedPlaylist {
    @Attribute(.unique) var remoteID: String
    var title: String
    var createdAt: Date

    init(remoteID: String, title: String, createdAt: Date = .now) {
        self.remoteID = remoteID
        self.title = title
        self.createdAt = createdAt
    }
}
