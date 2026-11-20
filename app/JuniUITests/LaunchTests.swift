import XCTest

final class LaunchTests: XCTestCase {
    @MainActor
    func testWelcomeScreenInPortraitAndLandscape() {
        let device = XCUIDevice.shared
        defer { device.orientation = .portrait }

        device.orientation = .portrait
        let app = XCUIApplication()
        app.launch()

        let title = app.staticTexts["Singapore Math with Juni"]
        let window = app.windows.firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 10))

        expectLayout(title: title, window: window, landscape: false)
        device.orientation = .landscapeLeft
        expectLayout(title: title, window: window, landscape: true)
    }

    @MainActor
    private func expectLayout(title: XCUIElement, window: XCUIElement, landscape: Bool) {
        let layout = NSPredicate { _, _ in
            let frame = window.frame
            let correctOrientation = landscape ? frame.width > frame.height : frame.height > frame.width
            return correctOrientation && title.isHittable && frame.contains(title.frame)
        }
        let expectation = XCTNSPredicateExpectation(predicate: layout, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .completed)
    }
}
