# Fugacious API Contract

The UI and networking layer are intentionally separated from the server implementation.

Configure `APIEnvironment.baseURL` in `APIClient.swift` when the production host is known.

## Expected endpoints

### POST /auth/login

Request:

```json
{
  "email": "user@example.com",
  "password": "password"
}
```

Response:

```json
{
  "token": "access-token"
}
```

The token is stored in the iOS Keychain.

### GET /library

Expected response:

```json
[
  {
    "id": "track-1",
    "title": "Signal Lights",
    "artist": "Lena Cove",
    "artworkURL": "https://example.com/art.jpg",
    "streamURL": "https://example.com/audio.m4a"
  }
]
```

### GET /search

The eventual implementation can use a query parameter such as:

`/search?q=signal`

### GET /playlists

Returns the authenticated user's playlists.

## Important

These paths are scaffolding because no Fugacious backend/API contract was supplied with the screenshots. Replace the paths and JSON models with the actual server contract when available; the UI does not need to change.
