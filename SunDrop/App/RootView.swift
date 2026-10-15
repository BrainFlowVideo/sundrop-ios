import SwiftUI

struct RootView: View {
    @AppStorage(SettingsKey.hasOnboarded) private var hasOnboarded = false
    @AppStorage(SettingsKey.appearanceMode) private var appearanceRaw = AppearanceMode.system.rawValue

    private var appearance: AppearanceMode {
        AppearanceMode(rawValue: appearanceRaw) ?? .system
    }

    var body: some View {
        ZStack {
            if hasOnboarded {
                HomeView()
                    .transition(.opacity.combined(with: .scale(scale: 1.04)))
            } else {
                OnboardingView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: hasOnboarded)
        .preferredColorScheme(appearance.colorScheme)
        .animation(.easeInOut(duration: 0.35), value: appearanceRaw)
    }
}
