import Foundation

enum GratitudeCategory: String, CaseIterable, Identifiable, Codable {
    case people, nature, food, win, selfCare, moment

    var id: String { rawValue }

    var title: String {
        switch self {
        case .people: "People"
        case .nature: "Nature"
        case .food: "Food"
        case .win: "Win"
        case .selfCare: "Self-care"
        case .moment: "Little moment"
        }
    }

    var emoji: String {
        switch self {
        case .people: "🫶"
        case .nature: "🌿"
        case .food: "🍓"
        case .win: "🏆"
        case .selfCare: "🛁"
        case .moment: "✨"
        }
    }
}
