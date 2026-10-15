import Foundation

enum ReviewCadence: String, CaseIterable, Identifiable, Codable {
    case weekly
    case monthly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly: "Weekly"
        case .monthly: "Monthly"
        }
    }

    var blurb: String {
        switch self {
        case .weekly: "Open your jar every 7 days for a cozy little recap."
        case .monthly: "Let the jar fill up, then savor it once a month."
        }
    }

    var symbol: String {
        switch self {
        case .weekly: "calendar.badge.clock"
        case .monthly: "calendar"
        }
    }

    var component: Calendar.Component {
        switch self {
        case .weekly: .weekOfYear
        case .monthly: .month
        }
    }
}
