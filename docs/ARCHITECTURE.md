# SunDrop Architecture

Target: iOS 17+, Swift 5.9+, SwiftUI, SwiftData, Observation framework.

## Layers (MVVM)

- **Model**: `GratitudeEntry` (SwiftData) plus the enums `GratitudeCategory`, `ReviewCadence` and `AppearanceMode`. Lightweight settings (name, reminder time, cadence, jar start date, appearance, onboarding flag) live in `@AppStorage`, with every key defined once in `SettingsKey`.
- **ViewModel**: `@Observable @MainActor` classes own transient UI state and orchestration: the drop-animation choreography in `HomeViewModel`, and page state plus completion in `OnboardingViewModel`. They take `ModelContext` as a parameter instead of owning it, so views keep using `@Query` for live data.
- **View**: layout and animation only. Views read `@Query` and `@AppStorage` and forward intent to view models.
- **Services**: small, stateless and unit-testable helpers: `ReviewSchedule` (next review date), `StreakCalculator`, `NotificationService`, `MediaStore`.

## Folder structure

```
SunDrop/
├── App/
│   ├── SunDropApp.swift            @main, ModelContainer
│   └── RootView.swift              onboarding vs. home, applies appearance mode
├── Design/
│   ├── Color+SunDrop.swift         brand palette + adaptive day/night tokens
│   ├── Components.swift            SunBurst, PaperSlip, GrainBackground, SunButtonStyle
│   └── ShakeDetector.swift         .onShake modifier
├── Models/
│   ├── GratitudeEntry.swift
│   ├── GratitudeCategory.swift
│   ├── ReviewCadence.swift
│   ├── AppearanceMode.swift
│   └── SettingsKey.swift
├── Services/
│   ├── NotificationService.swift
│   ├── ReviewSchedule.swift
│   ├── StreakCalculator.swift
│   └── MediaStore.swift
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   └── HomeViewModel.swift
├── Views/
│   ├── Onboarding/OnboardingView.swift
│   ├── Home/ HomeView, JarView, PlantView, CheerBubble, SparkleField
│   ├── Entry/ AddSunDropSheet, CameraCapture
│   ├── Review/ RecapView, ReminisceView, EntryVideoPlayer
│   └── Settings/SettingsView.swift
└── Resources/Assets.xcassets
```

## Key decisions

**Night mode via adaptive tokens.** Brand colors stay fixed (`sunflowerGold`, `raspberryRed`, `vintageBerry`, `sunTeal`, `frostedBlue`). Screens use semantic tokens (`sunInk`, `sunAccentText`, `sunSecondary`, `sunSurface`, `sunBackgroundTop/Bottom`, `sunGlow`) backed by dynamic `UIColor`s, so a view never branches on color scheme just to pick a color. Only the jar and background grain check `colorScheme` for effects such as the lamp glow. `AppearanceMode` maps to `preferredColorScheme` at the root.

**Drop choreography lives in the view model.** `HomeViewModel.add` sequences the lid, falling slip, SwiftData insert, squish keyframes, wink and haptics, and guards against overlapping drops. `JarView` is a pure function of its inputs.

**Stable slip layout.** Each entry stores a random `slipSeed` so its position and tilt in the jar are deterministic across launches. The jar draws the latest 44 slips.

**Media.** Photos are stored in the entry with `.externalStorage`. Videos are copied to `Documents/Videos` and referenced by file name, so the database stays small. Camera capture wraps `UIImagePickerController` (photo or video, 30 second cap); library picking uses `PhotosPicker`.

**Generated Xcode project.** `project.yml` (XcodeGen) is the source of truth. Info.plist values, including camera and microphone usage strings, are build settings in that file.

## Testing

`SunDropTests` covers `StreakCalculator`, `ReviewSchedule` and model helpers using fixed calendars and time zones. Keeping logic in services and view models, rather than views, is what makes this possible.
