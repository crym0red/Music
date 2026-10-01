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

The project is at the repository root. There is no `Fugacious.xcodeproj` and no `fugacious` bundle identifier.

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


## Root view and assets

`FugaciousApp` launches `RootView`.

`RootView` owns the first-launch decision and presents `OnboardingView` until onboarding is completed.

The target includes the asset catalog at:

```text
Fugacious/Assets.xcassets
```

It contains:

- `AppIcon.appiconset`
- `FugaciousMark.imageset`

The onboarding screen uses `Image("FugaciousMark")`, while the application target uses `AppIcon`.

## Swift build fix

`OnboardingView.swift` uses normal Swift decimal literals such as `0.25`, `0.72`, and `0.015`. No leading-dot numeric literals remain.


## Edge-to-edge layout

Fugacious now treats `RootView` as the full scene root. The root and onboarding backgrounds use `ignoresSafeArea()`, while interactive controls use the scene's safe-area insets for their readable placement.

This follows the same public SwiftUI edge-to-edge layout approach used in the supplied DELvEK source, whose Flek home view explicitly ignores the top and bottom safe areas. Apple's SwiftUI documentation likewise recommends `ignoresSafeArea` when a background should extend to the display edges.

If Fugacious is launched inside another app/container that deliberately constrains its window to a smaller rectangle, the host controls that outer window size; Fugacious cannot expand beyond a host-imposed window frame.
