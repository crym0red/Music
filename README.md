# Fugacious

Fugacious is an unreleased SwiftUI music app prototype based on the supplied reference screens.

## Repository layout

```text
Fugacious.xcodeproj/
Fugacious/
├── Info.plist
└── Assets.xcassets/
    └── AppIcon.appiconset/
```

The project is at the repository root. There is no `8Spine.xcodeproj` and no `8spine` bundle identifier.

## App identity

- Product: `Fugacious`
- Bundle identifier: `com.fugacious.music`
- Executable: `Fugacious`
- App icon: `Fugacious/Assets.xcassets/AppIcon.appiconset`

## GitHub Actions

`.github/workflows/build-unsigned-ipa.yml`:

1. Verifies the project and resource paths.
2. Builds the Release iOS target using Xcode 16.4.
3. Disables code signing.
4. Verifies that `Payload/Fugacious.app/Fugacious` exists and is an executable Mach-O file.
5. Packages `build/Fugacious-unsigned.ipa`.
6. Uploads the IPA as an Actions artifact.

An unsigned IPA can contain a valid executable, but iOS will not launch it on a normal device until it has a valid Apple signature/provisioning state. The workflow therefore validates the executable separately from signing.

## Backend

The screenshots did not provide a production API contract. `APIClient.swift` contains the networking abstraction and placeholder endpoint definitions; replace the base URL and endpoint models when the actual backend contract is available.


## Onboarding

First launch shows a three-page onboarding experience inspired by the supplied Fugacious reference: **Fugacious / Off the record. By design.**, **Organize**, and **Listen**. Completion is persisted with `@AppStorage`.

## App icon

The clean Fugacious F mark is included in `AppIcon.appiconset` and a matching `FugaciousMark.imageset` is used by onboarding.
