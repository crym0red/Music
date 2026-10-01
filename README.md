# Fugacious

A full-screen SwiftUI music player with a local-first library.

## Current local-first behavior
- Import real audio from the iOS Files picker
- Imported files are copied into Fugacious app storage for offline playback
- No mock songs, playlists, albums, or artists are displayed
- Albums are generated only from imported tracks with real album metadata
- Playlists are created by the user and persisted locally
- Embedded album artwork is used when available
- Favorites and recently-played tracking
- Persistent playback queue
- Previous/next, shuffle and repeat
- Background audio and Lock Screen / Control Center commands
- Search across the imported library
- Full-width top library bar that is part of the scroll content
- Empty library shows a simple plus action to add music
- Existing API client/authentication contract retained
- Existing unsigned-IPA GitHub project structure retained

Open `Fugacious.xcodeproj` in Xcode and build the `Fugacious` target.
