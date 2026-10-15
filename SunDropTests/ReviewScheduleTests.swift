import XCTest
@testable import SunDrop

final class ReviewScheduleTests: XCTestCase {
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }

    private func date(_ month: Int, _ day: Int) -> Date {
        cal.date(from: DateComponents(year: 2026, month: month, day: day, hour: 12))!
    }

    func testWeeklyNextReviewSteps() {
        let next = ReviewSchedule.nextReview(
            start: date(10, 1), cadence: .weekly, now: date(10, 14), calendar: cal)
        XCTAssertEqual(next, date(10, 15))
    }

    func testWeeklyDaysUntil() {
        let days = ReviewSchedule.daysUntilReview(
            start: date(10, 1), cadence: .weekly, now: date(10, 14), calendar: cal)
        XCTAssertEqual(days, 1)
    }

    func testMonthlyDaysUntil() {
        let days = ReviewSchedule.daysUntilReview(
            start: date(9, 20), cadence: .monthly, now: date(10, 14), calendar: cal)
        XCTAssertEqual(days, 6)
    }

    func testFutureStartReturnsStart() {
        let next = ReviewSchedule.nextReview(
            start: date(10, 20), cadence: .weekly, now: date(10, 14), calendar: cal)
        XCTAssertEqual(next, date(10, 20))
    }

    func testReviewDayRollsToNextPeriod() {
        let next = ReviewSchedule.nextReview(
            start: date(10, 14), cadence: .weekly, now: date(10, 14), calendar: cal)
        XCTAssertEqual(next, date(10, 21))
    }
}
