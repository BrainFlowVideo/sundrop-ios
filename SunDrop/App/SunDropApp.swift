import SwiftUI
import SwiftData

@main
struct SunDropApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(for: GratitudeEntry.self)
    }
}
