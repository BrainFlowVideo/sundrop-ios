import XCTest
@testable import SunDrop

final class ModelTests: XCTestCase {
    func testEntryCategoriesRoundTrip() {
        let entry = GratitudeEntry(
            text: "Warm coffee",
            categories: [.food, .selfCare],
            slipColorIndex: 1)
        XCTAssertEqual(entry.categories, [.food, .selfCare])
        XCTAssertEqual(entry.text, "Warm coffee")
    }

    func testUnknownCategoryRawValuesAreDropped() {
        let entry = GratitudeEntry(text: "x", slipColorIndex: 0)
        entry.categoryRaws = ["people", "not-a-category"]
        XCTAssertEqual(entry.categories, [.people])
    }

    func testAppearanceModeColorSchemes() {
        XCTAssertNil(AppearanceMode.system.colorScheme)
        XCTAssertEqual(AppearanceMode.light.colorScheme, .light)
        XCTAssertEqual(AppearanceMode.night.colorScheme, .dark)
    }
}
