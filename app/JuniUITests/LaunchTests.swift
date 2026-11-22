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

final class U07PreviewTests: XCTestCase {
    @MainActor
    func testObserveRecombinesAndReplayPreservesTryWork() {
        let app = launchPreview(orientation: .landscapeLeft)
        let tray = app.staticTexts["tray-label"]
        let bowl = app.staticTexts["bowl-label"]
        let next = app.buttons["Next step"]

        XCTAssertEqual(tray.label, "Tray · 6")
        next.tap()
        XCTAssertEqual(bowl.label, "Bowl · 1")
        next.tap()
        XCTAssertEqual(bowl.label, "Bowl · 2")
        next.tap()
        XCTAssertEqual(tray.label, "Other part · Tray · 4")
        XCTAssertTrue(app.staticTexts["6 = 2 + 4"].exists)

        XCUIDevice.shared.orientation = .portrait
        expectOrientation(.portrait, in: app)
        XCTAssertTrue(app.staticTexts["6 = 2 + 4"].isHittable)
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = "U07 Observe number bond"
        screenshot.lifetime = .keepAlways
        add(screenshot)

        next.tap()
        XCTAssertEqual(tray.label, "Tray · 6")
        XCTAssertEqual(bowl.label, "Bowl · 0")
        XCTAssertTrue(app.staticTexts["Completed example"].exists)

        app.buttons["Try together"].tap()
        XCTAssertEqual(tray.label, "Tray · 7")
        app.buttons["counter-1"].tap()
        app.buttons["put-in-bowl"].tap()
        app.buttons["key-6"].tap()

        app.buttons["Observe"].tap()
        app.buttons["Replay"].tap()
        XCTAssertEqual(tray.label, "Tray · 6")
        XCTAssertFalse(app.staticTexts["6 = 2 + 4"].exists)
        app.buttons["Try"].tap()

        XCTAssertEqual(bowl.label, "Bowl · 1")
        XCTAssertEqual(tray.label, "Tray · 6")
        XCTAssertEqual(missingPart(in: app).value as? String, "6")
        app.buttons["Check my model"].tap()
        XCTAssertTrue(app.staticTexts["Your counters and number bond match."].exists)
        app.buttons["Recombine counters"].tap()
        XCTAssertEqual(tray.label, "Tray · 7")
    }

    @MainActor
    func testCheckStartsBlankAndUsesBothModelAndNumber() {
        let app = launchPreview(orientation: .portrait)
        app.buttons["Check"].tap()

        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        XCTAssertEqual(app.staticTexts["tray-label"].label, "Tray")
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "counter-")).count, 8)
        let submit = app.buttons["Check my model"]
        XCTAssertFalse(submit.isEnabled)

        app.buttons["key-5"].tap()
        submit.tap()
        XCTAssertTrue(app.staticTexts["Recount the two groups and check the missing number."].exists)
        for id in 1...2 {
            app.buttons["counter-\(id)"].tap()
            app.buttons["put-in-bowl"].tap()
        }
        let third = app.buttons["counter-3"]
        let bowl = app.staticTexts["bowl-label"]
        let dropPoint = bowl.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1))
            .withOffset(CGVector(dx: 0, dy: 82))
        third.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.6, thenDragTo: dropPoint)
        XCTAssertEqual(third.label, "Counter 3 in bowl")
        XCTAssertEqual(app.buttons["counter-4"].label, "Counter 4 in tray")

        app.buttons["key-4"].tap()
        submit.tap()
        XCTAssertTrue(app.staticTexts["Recount the two groups and check the missing number."].exists)
        app.buttons["Clear answer"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        app.buttons["key-5"].tap()
        submit.tap()
        XCTAssertTrue(app.staticTexts["Your counters and number bond match."].exists)
    }

    @MainActor
    private func launchPreview(orientation: UIDeviceOrientation) -> XCUIApplication {
        XCUIDevice.shared.orientation = orientation
        let app = XCUIApplication()
        app.launchArguments = ["-u07-preview"]
        app.launch()
        let start = app.buttons["Start lesson preview"]
        XCTAssertTrue(start.waitForExistence(timeout: 10))
        start.tap()
        expectOrientation(orientation, in: app)
        return app
    }

    @MainActor
    private func expectOrientation(_ orientation: UIDeviceOrientation, in app: XCUIApplication) {
        let window = app.windows.firstMatch
        let landscape = orientation.isLandscape
        let layout = NSPredicate { _, _ in
            let frame = window.frame
            return landscape ? frame.width > frame.height : frame.height > frame.width
        }
        let expectation = XCTNSPredicateExpectation(predicate: layout, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 10), .completed)
    }

    @MainActor
    private func missingPart(in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: "missing-part").firstMatch
    }
}
