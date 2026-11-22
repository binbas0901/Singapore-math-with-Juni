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
        XCTAssertEqual(tray.label, "Tray · 4")
        XCTAssertEqual(part("Part 1", in: app).label, "Bowl")
        XCTAssertEqual(part("Part 1", in: app).value as? String, "2")
        XCTAssertEqual(missingPart(in: app).label, "Tray")
        XCTAssertEqual(missingPart(in: app).value as? String, "4")

        XCUIDevice.shared.orientation = .portrait
        expectOrientation(.portrait, in: app)
        XCTAssertTrue(missingPart(in: app).isHittable)
        capture("U07-Observe")

        next.tap()
        XCTAssertEqual(tray.label, "Tray · 6")
        XCTAssertEqual(bowl.label, "Bowl · 0")
        XCTAssertTrue(app.staticTexts["Completed example"].exists)

        app.buttons["Try together"].tap()
        XCTAssertEqual(tray.label, "Tray · 7")
        let prompt = app.staticTexts["workspace-prompt"]
        XCTAssertEqual(prompt.label, "Move one counter into the bowl.")
        XCTAssertFalse(app.buttons["put-in-bowl"].isEnabled)
        app.buttons["counter-1"].tap()
        XCTAssertFalse(app.buttons["put-in-tray"].isEnabled)
        app.buttons["put-in-bowl"].tap()
        XCTAssertTrue(prompt.label.hasPrefix("How many counters are left in the tray?"))
        XCTAssertEqual(tray.label, "Tray")
        XCTAssertEqual(missingPart(in: app).label, "Tray")
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        XCUIDevice.shared.orientation = .landscapeLeft
        expectOrientation(.landscapeLeft, in: app)
        capture("U07-Try")
        app.buttons["key-6"].tap()

        app.buttons["Observe"].tap()
        app.buttons["Replay"].tap()
        XCTAssertEqual(tray.label, "Tray · 6")
        XCTAssertFalse(missingPart(in: app).exists)
        app.buttons["Try"].tap()

        XCTAssertEqual(app.buttons["counter-1"].label, "Counter 1 in bowl")
        XCTAssertEqual(tray.label, "Tray")
        XCTAssertEqual(missingPart(in: app).value as? String, "6")
        app.buttons["Check my answer"].tap()
        XCTAssertTrue(app.staticTexts["Your counters and number bond match."].exists)
        XCTAssertEqual(prompt.label, "Now put the two groups back together in the tray.")
        app.buttons["Recombine counters"].tap()
        XCTAssertEqual(tray.label, "Tray · 7")
        XCTAssertTrue(prompt.label.hasPrefix("You made the whole again."))
    }

    @MainActor
    func testCheckStartsBlankAndUsesBothModelAndNumber() {
        let app = launchPreview(orientation: .portrait)
        app.buttons["Check"].tap()

        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        XCTAssertEqual(app.staticTexts["tray-label"].label, "Tray")
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl")
        XCTAssertEqual(app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "counter-")).count, 8)
        let submit = app.buttons["Check my answer"]
        XCTAssertFalse(submit.isEnabled)
        let prompt = app.staticTexts["workspace-prompt"].label
        XCTAssertEqual(missingPart(in: app).label, "Part 2")
        capture("U07-Check")

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
        XCTAssertEqual(app.staticTexts["workspace-prompt"].label, prompt)
        XCTAssertEqual(missingPart(in: app).label, "Part 2")

        app.buttons["key-4"].tap()
        submit.tap()
        XCTAssertTrue(app.staticTexts["Recount the two groups and check the missing number."].exists)
        app.buttons["Clear answer"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        app.buttons["key-5"].tap()
        submit.tap()
        XCTAssertTrue(app.staticTexts["Your counters and number bond match."].exists)
        XCTAssertEqual(missingPart(in: app).label, "Tray")
    }

    @MainActor
    func testCheckAcceptsTrayAsKnownPartAndHomeResetsBothWorkspaces() {
        let app = launchPreview(orientation: .landscapeLeft)
        app.buttons["Next step"].tap()
        app.buttons["Try"].tap()
        app.buttons["key-6"].tap()
        app.buttons["Check"].tap()
        for id in 1...5 {
            app.buttons["counter-\(id)"].tap()
            app.buttons["put-in-bowl"].tap()
        }
        XCTAssertEqual(missingPart(in: app).label, "Part 2")
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        app.buttons["key-5"].tap()
        app.buttons["Home"].tap()
        app.buttons["Resume"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "5")
        XCTAssertEqual(app.buttons["counter-5"].label, "Counter 5 in bowl")
        app.buttons["Check my answer"].tap()
        XCTAssertEqual(part("Part 1", in: app).label, "Tray")
        XCTAssertEqual(missingPart(in: app).label, "Bowl")

        app.buttons["Home"].tap()
        app.buttons["Start Over"].tap()
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl · 0")
        app.buttons["Try"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        app.buttons["Check"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        XCTAssertEqual(app.buttons["counter-5"].label, "Counter 5 in tray")
    }

    @MainActor
    private func capture(_ name: String) {
        let screenshot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        screenshot.name = name
        screenshot.lifetime = .keepAlways
        add(screenshot)
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
        part("missing-part", in: app)
    }

    @MainActor
    private func part(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
