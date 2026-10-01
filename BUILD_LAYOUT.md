# Fugacious build layout

The Xcode project intentionally references these committed paths:

```text
Fugacious.xcodeproj/
Fugacious/
├── Info.plist
└── Assets.xcassets/
    ├── Contents.json
    └── AppIcon.appiconset/
        └── Contents.json
```

The GitHub Actions workflow checks these paths before invoking `xcodebuild`.
