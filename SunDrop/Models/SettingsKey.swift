import Foundation

/// Keys for `@AppStorage` / `UserDefaults.standard`.
enum SettingsKey {
    static let hasOnboarded = "hasOnboarded"
    static let userName = "userName"
    static let reminderMinutes = "reminderMinutes"     // minutes since midnight
    static let remindersEnabled = "remindersEnabled"
    static let reviewCadence = "reviewCadence"         // ReviewCadence.rawValue
    static let jarStartDate = "jarStartDate"           // TimeInterval since 1970
    static let appearanceMode = "appearanceMode"       // AppearanceMode.rawValue
}
