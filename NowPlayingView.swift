import SwiftUI

struct MiniPlayer: View {
    @ObservedObject var player: AudioPlayer

    var body: some View {
        guard let track = player.currentTrack else {
            return AnyView(EmptyView())
        }

        return AnyView(
            HStack(spacing: 10) {
                ArtworkView(style: track.artwork, cornerRadius: 6)
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

                Button {
                    player.togglePlayPause()
                } label: {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
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
                ArtworkView(style: track.artwork, cornerRadius: 24)
                    .frame(width: 300, height: 300)

                VStack(spacing: 5) {
                    Text(track.title)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                    Text(track.artist)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Slider(value: Binding(
                    get: { player.progress },
                    set: { player.seek(to: $0) }
                ))
                .tint(.white)

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
}
