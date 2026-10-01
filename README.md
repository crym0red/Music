# Fugacious

Fugacious is an unreleased SwiftUI music app built from the supplied visual references.

## Included

- Dark purple/black music-library UI
- Artwork library grid
- Pinned playlists
- Album rail
- Artist/discography screen
- Popular tracks
- Search
- Profile/settings
- Bottom navigation
- Mini player
- Full Now Playing screen
- AVPlayer playback foundation
- Background audio session
- Lock-screen / Control Center playback commands
- SwiftData persistence models
- Keychain token storage
- Async URLSession API layer
- GitHub Actions unsigned-IPA build

## Open in Xcode

Open:

```text
Fugacious.xcodeproj
```

The project is at repository root. The GitHub workflow therefore builds the same project path that exists in the repository.

## GitHub Actions

Workflow:

```text
.github/workflows/build-unsigned-ipa.yml
```

It can be started manually from GitHub Actions or runs on pushes to `main`.

The workflow:

1. Checks out the repository.
2. Selects Xcode 16.4.
3. Verifies `Fugacious.xcodeproj`.
4. Builds the Release iOS target with code signing disabled.
5. Packages the application as:

```text
build/Fugacious-unsigned.ipa
```

6. Uploads the IPA as a GitHub Actions artifact.

The IPA is intentionally unsigned and is not an App Store distribution artifact.

## Backend

No production backend/API contract was supplied with the screenshots. The networking layer therefore uses placeholder endpoint definitions in `APIClient.swift`.

When the real API contract is available, configure the base URL and endpoint/model definitions there without changing the UI architecture.

See `API_CONTRACT.md`.

## Project structure

```text
Fugacious.xcodeproj/
FugaciousApp.swift
RootView.swift
LibraryView.swift
ArtistView.swift
SearchView.swift
ArtworkView.swift
Models.swift
AudioPlayer.swift
NowPlayingView.swift
APIClient.swift
KeychainStore.swift
Persistence.swift
AppContainer.swift
SettingsView.swift
Info.plist
Assets.xcassets/

.github/workflows/build-unsigned-ipa.yml
API_CONTRACT.md
README.md
```


## App identity

- Display name: `Fugacious`
- Bundle identifier: `com.fugacious.music`
- App icon: `Fugacious/Assets.xcassets/AppIcon.appiconset`

The project contains no `8spine` bundle identifier.

## IPA packaging

The GitHub workflow creates a standard iOS `.ipa` containing:

```text
Payload/Fugacious.app/
```

The app executable is the `Fugacious` Mach-O inside the `.app`. The build is intentionally unsigned (`CODE_SIGNING_ALLOWED=NO`); signing is required before installation on a physical iOS device.
