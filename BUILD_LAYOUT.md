# Fugacious build layout

The app entry point is:

```text
FugaciousApp.swift
    └── RootView()
```

`RootView` decides whether to show:

```text
OnboardingView
```

or the main library/player interface based on:

```text
hasCompletedFugaciousOnboarding
```

Assets are committed under:

```text
Fugacious/
└── Assets.xcassets/
    ├── AppIcon.appiconset/
    └── FugaciousMark.imageset/
```

The Xcode target explicitly compiles the asset catalog and uses `AppIcon` as its application icon.
