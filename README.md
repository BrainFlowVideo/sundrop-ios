# SunDrop Gratitude Jar ☀️🫙

A cozy, kawaii gratitude journal for iPhone. Drop one moment of thanks into your jar each day, watch it fill with colorful paper slips, and look back on it whenever you like.

Built with SwiftUI, SwiftData and the Observation framework. Everything is stored on-device: no accounts, no servers, no tracking.

## Features

- **Skeuomorphic jar** that fills with paper slips, winks and squishes when you add a SunDrop, with a spring-physics drop animation. Tap the jar to add one
- **Growing plant** in a cute pot: it grows a little with every SunDrop, leaves pop out from the third drop, a bud forms at ten and a sunflower blooms at twelve. Tap the pot for one of five little cheers. Floating sparkles too
- **Onboarding** in four pages: welcome, your name, daily reminder time, weekly or monthly review
- **Multi-media entries**: a note, category tags, a photo or a short video, captured with the **camera** or picked from your library
- **Day and Night modes**: a pale gold and frost sunrise by day, a deep teal evening by night; follow the system or choose in Settings
- **Daily reminder** local notification, plus a countdown to your next **Jar Review**
- **Recap** of the current week or month and **Shake to Reminisce** to pull a random memory
- **Settings** for name, appearance, reminder and review cadence

## Design system

| Color | Hex | Used for |
| --- | --- | --- |
| Sunflower Gold | `#FFBC42` | Sun motifs, jar lid, warm highlights |
| Raspberry Red | `#D81159` | Primary action buttons, energetic accents |
| Vintage Berry | `#8F2D56` | Text and headers by day |
| Teal | `#218380` | Secondary buttons, interactive elements, night backgrounds |
| Frosted Blue | `#73D2DE` | Soft glow and cool accents; secondary color at night |

Day and night variants are exposed as adaptive tokens in `Design/Color+SunDrop.swift` (`sunInk`, `sunSurface`, `sunSecondary`, `sunBackgroundTop` and so on).

## Requirements

- macOS with Xcode 16 or newer
- iOS 17+ deployment target
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)

The `.xcodeproj` is generated from `project.yml` and is not committed, which keeps the repo clean and avoids merge conflicts in project files.

## Getting started

```bash
git clone <your-repo-url>
cd sundrop-ios
brew install xcodegen
xcodegen generate
open SunDrop.xcodeproj
```

Before running on a physical device:

1. In `project.yml`, change `bundleIdPrefix` and the two `PRODUCT_BUNDLE_IDENTIFIER` values from `com.example` to your own identifier.
2. Re-run `xcodegen generate`.
3. In Xcode, select the SunDrop target, open Signing & Capabilities and choose your team.

The camera is only available on real devices. On the Simulator the Camera button explains this and you can still attach media from the library.

## Running the tests

```bash
xcodegen generate
xcodebuild test \
  -project SunDrop.xcodeproj \
  -scheme SunDrop \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

Unit tests cover the streak calculation, review-date math and model helpers. GitHub Actions runs the same command on every push and pull request (`.github/workflows/ci.yml`).

## Project layout

```
SunDrop/
├── App/            App entry point, onboarding/home switch, appearance
├── Design/         Colors, shared components, shake detector
├── Models/         SwiftData entry, enums, settings keys
├── Services/       Notifications, review dates, streaks, media files
├── ViewModels/     Onboarding and Home logic
├── Views/          Onboarding, Home (jar, plant, sparkles), Entry, Review, Settings
└── Resources/      Asset catalog (accent color, app icon)
SunDropTests/       Unit tests
docs/ARCHITECTURE.md
project.yml         XcodeGen project definition
```

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for the MVVM breakdown.

## Privacy

All entries, photos and videos stay on your device. The app asks for camera and microphone access only when you record a memory, and for notification permission to send your daily reminder.

## Roadmap

- Locked jar that opens on review day
- Entry detail and edit screens
- Home screen widget showing the jar and streak
- iCloud sync
- Custom app icon artwork (the included icon is a simple generated placeholder)

## License

MIT, see [LICENSE](LICENSE).

## Web preview

`web/index.html` is a self-contained browser prototype of the app (no build step). A GitHub Actions workflow publishes it to GitHub Pages; on iPhone, open the Pages link in Safari and use Share, then Add to Home Screen for a full-screen app.
