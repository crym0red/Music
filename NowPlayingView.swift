import SwiftUI

struct MiniPlayer: View {
    @ObservedObject var player: AudioPlayer

    var body: some View {
        guard let track = player.currentTrack else {
            return AnyView(EmptyView())
        }

        return AnyView(
            HStack(spacing: 10) {
                ArtworkView(style: track.artwork, artworkData: track.artworkData, cornerRadius: 6)
                    .frame(width: 42, height: 42)

                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 12, weight: .semibold))
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.48))
                        .lineLimit(1)
                }

                Spacer()

                if player.playbackError != nil {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.yellow)
                } else {
                    Button {
                        player.togglePlayPause()
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(alignment: .bottom) {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(.white.opacity(0.8))
                        .frame(width: proxy.size.width * player.progress, height: 2)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .allowsHitTesting(false)
            }
        )
    }
}

struct NowPlayingScreen: View {
    @ObservedObject var player: AudioPlayer

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            if let track = player.currentTrack {
                ArtworkView(style: track.artwork, artworkData: track.artworkData, cornerRadius: 24)
                    .frame(width: 300, height: 300)

                VStack(spacing: 7) {
                    Text(track.title)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(3)

                    Text(track.artist)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)

                    if let album = track.album, !album.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text(album)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.white.opacity(0.34))
                            .lineLimit(1)
                    }

                    HStack(spacing: 8) {
                        if let fileURL = track.fileURL {
                            Text(fileURL.pathExtension.uppercased())
                            Text("•")
                            Text(fileSize(for: fileURL))
                        }

                        if player.queue.count > 1 {
                            Text("•")
                            Text("\(player.queueIndex + 1) of \(player.queue.count)")
                        }
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.28))
                    .lineLimit(1)
                }

                VStack(spacing: 5) {
                    Slider(value: Binding(
                        get: { player.progress },
                        set: { player.seek(to: $0) }
                    ))
                    .tint(.white)

                    HStack {
                        Text(formatTime(player.progress * player.duration))
                        Spacer()
                        Text("-" + formatTime(max(player.duration - (player.progress * player.duration), 0)))
                    }
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.42))
                }

                HStack {
                    Button {
                        player.previous()
                    } label: {
                        Image(systemName: "backward.fill")
                    }
                    .buttonStyle(.plain)

                    Button {
                        player.togglePlayPause()
                    } label: {
                        Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 22, weight: .bold))
                            .frame(width: 66, height: 66)
                            .background(.white)
                            .foregroundStyle(.black)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Button {
                        player.next()
                    } label: {
                        Image(systemName: "forward.fill")
                    }
                    .buttonStyle(.plain)
                }
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)

                HStack(spacing: 34) {
                    Button { player.shuffleEnabled.toggle() } label: {
                        Image(systemName: "shuffle")
                            .foregroundStyle(player.shuffleEnabled ? .white : .white.opacity(0.45))
                    }
                    Button {
                        switch player.repeatMode {
                        case .off: player.repeatMode = .all
                        case .all: player.repeatMode = .one
                        case .one: player.repeatMode = .off
                        }
                    } label: {
                        Image(systemName: player.repeatMode == .one ? "repeat.1" : "repeat")
                            .foregroundStyle(player.repeatMode == .off ? .white.opacity(0.45) : .white)
                    }
                }
            } else {
                Text("Nothing playing")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }

            Spacer()
        }
        .padding(22)
        .background(Color.fugaciousBackground.ignoresSafeArea())
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let total = Int(seconds.rounded(.down))
        let minutes = total / 60
        let remaining = total % 60
        return "\(minutes):\(String(format: "%02d", remaining))"
    }

    private func fileSize(for url: URL) -> String {
        guard let bytes = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { return "Local file" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        formatter.includesUnit = true
        formatter.includesCount = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
}
