import SwiftUI

struct ArtistView: View {
    let artist: Artist
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false

    var body: some View {
        ZStack {
            Color.fugaciousBackground.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    header

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(artist.name)
                                .font(.system(size: 34, weight: .black, design: .rounded))
                            Text("Full artist discography")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.48))
                        }
                        Spacer()
                        Button {
                            isPlaying.toggle()
                        } label: {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(width: 46, height: 46)
                                .background(.white)
                                .clipShape(Circle())
                        }
                    }

                    Button {
                        // Add artist to library.
                    } label: {
                        Text("Add to library  +")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.white.opacity(0.1))
                            .clipShape(Capsule())
                    }

                    Text("Popular Tracks")
                        .font(.system(size: 19, weight: .bold, design: .rounded))

                    VStack(spacing: 3) {
                        ForEach(Array(artist.tracks.enumerated()), id: \.element.id) { index, track in
                            ArtistTrackRow(number: index + 1, track: track)
                        }
                    }

                    Text("Albums")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .padding(.top, 10)

                    Color.clear.frame(height: 90)
                }
                .padding(.horizontal, 18)
                .padding(.top, 6)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        ZStack(alignment: .topLeading) {
            ArtworkView(style: artist.artwork, cornerRadius: 25)
                .frame(height: 310)
                .overlay {
                    LinearGradient(
                        colors: [.clear, Color.fugaciousBackground.opacity(0.15), Color.fugaciousBackground.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                }

            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 34, height: 34)
                    .background(.black.opacity(0.28))
                    .clipShape(Circle())
            }
            .padding(12)
        }
    }
}

struct ArtistTrackRow: View {
    let number: Int
    let track: Track

    var body: some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.48))
                .frame(width: 20)

            ArtworkView(style: track.artwork, artworkData: track.artworkData, cornerRadius: 5)
                .frame(width: 43, height: 43)

            VStack(alignment: .leading, spacing: 3) {
                Text(track.title)
                    .font(.system(size: 13, weight: .semibold))
                Text(track.artist)
                    .font(.system(size: 10))
                    .foregroundStyle(.white.opacity(0.42))
            }

            Spacer()

            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.vertical, 7)
    }
}
