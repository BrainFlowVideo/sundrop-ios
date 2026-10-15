import SwiftUI
import Observation

@MainActor
@Observable
final class OnboardingViewModel {
    static let pageCount = 4

    var page = 0
    var name = ""
    var reminderTime: Date = {
        var c = DateComponents()
        c.hour = 20
        c.minute = 0
        return Calendar.current.date(from: c) ?? .now
    }()
    var cadence: ReviewCadence = .weekly

    var isLastPage: Bool { page == Self.pageCount - 1 }

    var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    func next() {
        guard !isLastPage else { return }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) { page += 1 }
    }

    func back() {
        guard page > 0 else { return }
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) { page -= 1 }
    }

    /// Persists choices, asks for notification permission and schedules the reminder.
    func finish() async {
        let defaults = UserDefaults.standard
        let comps = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let minutes = (comps.hour ?? 20) * 60 + (comps.minute ?? 0)

        defaults.set(trimmedName, forKey: SettingsKey.userName)
        defaults.set(minutes, forKey: SettingsKey.reminderMinutes)
        defaults.set(cadence.rawValue, forKey: SettingsKey.reviewCadence)
        defaults.set(Date.now.timeIntervalSince1970, forKey: SettingsKey.jarStartDate)

        let granted = await NotificationService.shared.requestAuthorization()
        defaults.set(granted, forKey: SettingsKey.remindersEnabled)
        if granted {
            await NotificationService.shared.scheduleDailyReminder(
                minutesSinceMidnight: minutes, name: trimmedName)
        }

        defaults.set(true, forKey: SettingsKey.hasOnboarded)
    }
}
