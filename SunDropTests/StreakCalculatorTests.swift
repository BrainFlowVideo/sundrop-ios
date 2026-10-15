import XCTest
@testable import SunDrop

final class StreakCalculatorTests: XCTestCase {
    private var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(secondsFromGMT: 0)!
        return c
    }

    private func date(_ day: Int, hour: Int = 12) -> Date {
        cal.date(from: DateComponents(year: 2026, month: 10, day: day, hour: hour))!
    }

    func testEmptyIsZero() {
        XCTAssertEqual(StreakCalculator.streak(days: [], now: date(14), calendar: cal), 0)
    }

    func testTodayOnlyIsOne() {
        XCTAssertEqual(StreakCalculator.streak(days: [date(14)], now: date(14), calendar: cal), 1)
    }

    func testConsecutiveDays() {
        let days = [date(12), date(13), date(14)]
        XCTAssertEqual(StreakCalculator.streak(days: days, now: date(14), calendar: cal), 3)
    }

    func testYesterdayStillCounts() {
        let days = [date(12), date(13)]
        XCTAssertEqual(StreakCalculator.streak(days: days, now: date(14), calendar: cal), 2)
    }

    func testGapBreaksStreak() {
        let days = [date(10), date(13), date(14)]
        XCTAssertEqual(StreakCalculator.streak(days: days, now: date(14), calendar: cal), 2)
    }

    func testStaleStreakIsZero() {
        XCTAssertEqual(StreakCalculator.streak(days: [date(10)], now: date(14), calendar: cal), 0)
    }

    func testMultipleEntriesPerDayCountOnce() {
        let days = [date(14, hour: 8), date(14, hour: 20)]
        XCTAssertEqual(StreakCalculator.streak(days: days, now: date(14), calendar: cal), 1)
    }
}
