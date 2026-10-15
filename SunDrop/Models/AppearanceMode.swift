import SwiftUI

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system
    case light
    case night

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "Auto"
        case .light: "Day"
        case .night: "Night"
        }
    }

    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .night: "moon.stars.fill"
        }
    }

    /// `nil` follows the system setting.
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .night: .dark
        }
    }
}
