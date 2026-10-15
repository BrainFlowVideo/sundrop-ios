import Foundation

enum ReviewSchedule {
    /// The next review date strictly after `now`, stepping from `start` by the cadence.
    static func nextReview(
        start: Date,
        cadence: ReviewCadence,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Date {
        var next = start
        var iterations = 0
        while next <= now && iterations < 1000 {
            if let stepped = calendar.date(byAdding: cadence.component, value: 1, to: next) {
                next = stepped
            } else {
                next = next.addingTimeInterval(7 * 86_400)
            }
            iterations += 1
        }
        return next
    }

    /// Whole days from today until the next review (0 means today).
    static func daysUntilReview(
        start: Date,
        cadence: ReviewCadence,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Int {
        let next = nextReview(start: start, cadence: cadence, now: now, calendar: calendar)
        let from = calendar.startOfDay(for: now)
        let to = calendar.startOfDay(for: next)
        return max(0, calendar.dateComponents([.day], from: from, to: to).day ?? 0)
    }
}
