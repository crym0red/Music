# 8Spine

8Spine is a SwiftUI-first iOS music app prototype built from the supplied visual references.

The project currently provides the visual shell, local persistence model, audio-player foundation, remote-control integration, API abstraction, Keychain token storage, and a GitHub Actions workflow that produces an **unsigned IPA**.

## What is included

### UI

- Dark purple/black 8Spine visual system
- Library home
- Four-column artwork grid
- Pinned playlists
- Horizontal album rail
- Artist/discography screen
- Popular tracks
- Search screen
- Add menu
- Profile/settings
- Bottom navigation
- Mini player foundation
- Full now-playing screen
- Responsive SwiftUI layouts

### Audio

`AudioPlayer.swift` uses `AVPlayer` and `AVAudioSession`.

It includes:

- Play/pause
- Seeking
- Playback progress
- Background audio session
- AirPlay/Bluetooth playback options
- Lock-screen/Control Center play/pause
- Lock-screen seek support
- Now Playing metadata

A real queue/next/previous implementation can be connected once the server's track/stream contract is available.

### Storage

`Persistence.swift` defines SwiftData models for:

- Saved songs
- Favorites
- Saved playlists

### Networking

`APIClient.swift` provides an async `URLSession` API layer.

`API_CONTRACT.md` documents the expected shape of the currently scaffolded endpoints:

- `POST /auth/login`
- `GET /library`
- `GET /search`
- `GET /playlists`

**The screenshots did not contain a backend URL or API contract, so these endpoints are placeholders.** Replace `APIEnvironment.baseURL` and the endpoint/model definitions with the actual 8Spine backend when it is available.

### Authentication

`KeychainStore.swift` stores the access token in the iOS Keychain rather than UserDefaults.

## Build locally

Requirements:

- macOS
- Xcode
- iOS 17 SDK or newer

Open:

```text
8Spine/8Spine.xcodeproj
```

Select an iPhone simulator or physical device and run.

## GitHub Actions: unsigned IPA

The repository contains:

```text
.github/workflows/build-unsigned-ipa.yml
```

It runs on pushes to `main` and manually through **Actions → Build unsigned IPA → Run workflow**.

The workflow:

1. Checks out the repository.
2. Selects Xcode.
3. Builds the Release iOS app with code signing disabled.
4. Creates:

```text
build/8Spine-unsigned.ipa
```

5. Uploads it as the `8Spine-unsigned-ipa` GitHub Actions artifact.

### Important

An unsigned IPA is an application package without an Apple signing identity. It is intended as a build artifact for subsequent signing/installation workflows; it is not App Store distributable by itself.

## Project structure

```text
8Spine/
├── 8Spine.xcodeproj/
├── 8SpineApp.swift
├── RootView.swift
├── LibraryView.swift
├── ArtistView.swift
├── SearchView.swift
├── ArtworkView.swift
├── Models.swift
├── AudioPlayer.swift
├── NowPlayingView.swift
├── APIClient.swift
├── KeychainStore.swift
├── Persistence.swift
├── AppContainer.swift
├── SettingsView.swift
├── Info.plist
└── Assets.xcassets

.github/
└── workflows/
    └── build-unsigned-ipa.yml

API_CONTRACT.md
README.md
```

## Next production work

1. Connect the real 8Spine API.
2. Replace generated placeholder artwork with supplied/remote artwork.
3. Implement authentication UI.
4. Implement the actual queue and next/previous playback.
5. Add image caching.
6. Add playlist creation/editing.
7. Add offline downloads if supported by the service.
8. Tune typography, spacing, artwork treatment, and animations against the final reference designs.
