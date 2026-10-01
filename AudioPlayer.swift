import AVFoundation
import MediaPlayer

@MainActor
final class AudioPlayer: NSObject, ObservableObject {
    static let shared = AudioPlayer()

    enum RepeatMode: String { case off, one, all }
    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published private(set) var progress: Double = 0
    @Published private(set) var duration: Double = 0
    @Published private(set) var queue: [Track] = []
    @Published private(set) var queueIndex: Int = 0
    @Published private(set) var playbackError: String?
    @Published var shuffleEnabled = false
    @Published var repeatMode: RepeatMode = .off

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?
    private var failedObserver: NSObjectProtocol?
    private var statusObservation: NSKeyValueObservation?
    private var item: AVPlayerItem?

    private override init() {
        super.init()
        configureAudioSession()
        configureRemoteCommands()
    }

    deinit {
        if let timeObserver, let player { player.removeTimeObserver(timeObserver) }
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        if let failedObserver { NotificationCenter.default.removeObserver(failedObserver) }
        statusObservation?.invalidate()
    }

    func play(_ track: Track, from tracks: [Track]? = nil) {
        if let tracks, !tracks.isEmpty {
            queue = tracks
            queueIndex = tracks.firstIndex(of: track) ?? 0
        } else if queue.isEmpty {
            queue = [track]
            queueIndex = 0
        } else if let index = queue.firstIndex(of: track) {
            queueIndex = index
        }
        loadAndPlay(track)
    }

    func setQueue(_ tracks: [Track], startingAt index: Int = 0) {
        guard !tracks.isEmpty else { return }
        queue = tracks
        queueIndex = min(max(index, 0), tracks.count - 1)
        loadAndPlay(queue[queueIndex])
    }

    private func loadAndPlay(_ track: Track) {
        playbackError = nil
        currentTrack = track
        progress = 0
        duration = track.duration ?? 0
        isPlaying = false
        removeObservers()

        guard let url = track.fileURL, FileManager.default.fileExists(atPath: url.path) else {
            fail("The audio file is no longer available.")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            fail("Audio output could not be activated: \(error.localizedDescription)")
            return
        }

        let newItem = AVPlayerItem(url: url)
        newItem.preferredForwardBufferDuration = 5
        item = newItem

        let newPlayer = AVPlayer(playerItem: newItem)
        newPlayer.automaticallyWaitsToMinimizeStalling = false
        player = newPlayer

        statusObservation = newItem.observe(\AVPlayerItem.status, options: [.initial, .new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self else { return }
                switch item.status {
                case .readyToPlay:
                    self.duration = item.duration.seconds.isFinite && item.duration.seconds > 0 ? item.duration.seconds : self.duration
                    self.player?.playImmediately(atRate: 1.0)
                    self.isPlaying = true
                    self.playbackError = nil
                    self.updateNowPlaying()
                case .failed:
                    self.fail(item.error?.localizedDescription ?? "This audio file could not be played.")
                default:
                    break
                }
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newItem,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.advanceAfterEnd() }
        }

        failedObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime,
            object: newItem,
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
                self?.fail(error?.localizedDescription ?? "Playback failed.")
            }
        }

        installTimeObserver()
        updateNowPlaying()
    }

    func togglePlayPause() {
        guard let player else { return }
        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            do { try AVAudioSession.sharedInstance().setActive(true) } catch { }
            player.playImmediately(atRate: 1.0)
            isPlaying = true
        }
        updateNowPlaying()
    }

    func next() {
        guard !queue.isEmpty else { return }
        if shuffleEnabled, queue.count > 1 {
            var next = queueIndex
            while next == queueIndex { next = Int.random(in: 0..<queue.count) }
            queueIndex = next
        } else {
            queueIndex += 1
            if queueIndex >= queue.count {
                guard repeatMode == .all else { stop(); return }
                queueIndex = 0
            }
        }
        loadAndPlay(queue[queueIndex])
    }

    func previous() {
        if progress > 0.05 { seek(to: 0); return }
        guard !queue.isEmpty else { return }
        queueIndex = queueIndex == 0 ? (repeatMode == .all ? queue.count - 1 : 0) : queueIndex - 1
        loadAndPlay(queue[queueIndex])
    }

    func seek(to fraction: Double) {
        guard let player, duration > 0 else { return }
        let value = min(max(fraction, 0), 1)
        player.seek(to: CMTime(seconds: duration * value, preferredTimescale: 600))
        progress = value
        updateNowPlaying()
    }

    func stop() {
        player?.pause()
        isPlaying = false
        progress = 0
        updateNowPlaying()
    }

    private func advanceAfterEnd() {
        if repeatMode == .one { loadAndPlay(queue[queueIndex]); return }
        next()
    }

    private func installTimeObserver() {
        guard let player else { return }
        if let timeObserver { player.removeTimeObserver(timeObserver) }
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { [weak self, weak player] time in
            guard let self else { return }
            let current = time.seconds
            let total = player?.currentItem?.duration.seconds ?? 0
            Task { @MainActor in
                self.duration = total.isFinite && total > 0 ? total : self.duration
                self.progress = self.duration > 0 ? min(max(current / self.duration, 0), 1) : 0
                self.updateNowPlaying()
            }
        }
    }

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.allowAirPlay, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("Audio session error:", error)
        }
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            guard let self, let player = self.player else { return .commandFailed }
            player.playImmediately(atRate: 1.0)
            self.isPlaying = true
            self.updateNowPlaying()
            return .success
        }
        center.pauseCommand.addTarget { [weak self] _ in
            guard let self, let player = self.player else { return .commandFailed }
            player.pause()
            self.isPlaying = false
            self.updateNowPlaying()
            return .success
        }
        center.nextTrackCommand.addTarget { [weak self] _ in self?.next(); return .success }
        center.previousTrackCommand.addTarget { [weak self] _ in self?.previous(); return .success }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self, let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.player?.seek(to: CMTime(seconds: event.positionTime, preferredTimescale: 600))
            return .success
        }
    }

    private func updateNowPlaying() {
        guard let track = currentTrack else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: progress * duration,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]
        if duration > 0 { info[MPMediaItemPropertyPlaybackDuration] = duration }
        if let data = track.artworkData, let image = UIImage(data: data) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func fail(_ message: String) {
        player?.pause()
        isPlaying = false
        playbackError = message
        updateNowPlaying()
        print("Fugacious playback error:", message)
    }

    private func removeObservers() {
        if let endObserver { NotificationCenter.default.removeObserver(endObserver); self.endObserver = nil }
        if let failedObserver { NotificationCenter.default.removeObserver(failedObserver); self.failedObserver = nil }
        statusObservation?.invalidate()
        statusObservation = nil
        if let timeObserver, let player { player.removeTimeObserver(timeObserver) }
        timeObserver = nil
    }
}
