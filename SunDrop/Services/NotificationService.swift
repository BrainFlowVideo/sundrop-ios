import Foundation
import UserNotifications

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private let identifier = "sundrop.daily.reminder"

    private init() {}

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Schedules (or replaces) the repeating daily reminder.
    func scheduleDailyReminder(minutesSinceMidnight: Int, name: String) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        let content = UNMutableNotificationContent()
        content.title = "Time for a SunDrop ☀️"
        content.body = name.isEmpty
            ? "What's one good thing from today?"
            : "\(name), what's one good thing from today?"
        content.sound = .default

        var components = DateComponents()
        components.hour = minutesSinceMidnight / 60
        components.minute = minutesSinceMidnight % 60

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}
