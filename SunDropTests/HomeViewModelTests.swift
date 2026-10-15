import XCTest
@testable import SunDrop

@MainActor
final class HomeViewModelTests: XCTestCase {
    func testThereAreFiveCheers() {
        XCTAssertEqual(HomeViewModel.cheers.count, 5)
        XCTAssertEqual(Set(HomeViewModel.cheers).count, 5)
    }

    func testCheerNeverRepeatsBackToBack() {
        let vm = HomeViewModel()
        var last: String?
        for _ in 0..<60 {
            vm.cheerUp()
            XCTAssertNotNil(vm.cheerMessage)
            XCTAssertNotEqual(vm.cheerMessage, last)
            last = vm.cheerMessage
        }
    }

    func testCheerTriggersFrogHop() {
        let vm = HomeViewModel()
        let before = vm.frogHopTrigger
        vm.cheerUp()
        XCTAssertEqual(vm.frogHopTrigger, before + 1)
    }

    func testOpenAddShowsSheet() {
        let vm = HomeViewModel()
        vm.openAdd()
        XCTAssertTrue(vm.showAddSheet)
    }

    func testGreetingUsesNameAndTimeOfDay() {
        let vm = HomeViewModel()
        var comps = DateComponents(year: 2026, month: 10, day: 14, hour: 9)
        let morning = Calendar.current.date(from: comps)!
        XCTAssertEqual(vm.greeting(name: "Sam", now: morning), "Good morning, Sam")
        comps.hour = 19
        let evening = Calendar.current.date(from: comps)!
        XCTAssertEqual(vm.greeting(name: "", now: evening), "Good evening")
    }
}
