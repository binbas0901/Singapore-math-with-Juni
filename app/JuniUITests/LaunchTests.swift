import XCTest

final class LaunchTests: XCTestCase {
    @MainActor
    func testWelcomeScreenInPortraitAndLandscape() {
        let device = XCUIDevice.shared
        defer { device.orientation = .portrait }

        device.orientation = .portrait
        let app = XCUIApplication()
        app.launch()
        defer { app.terminate() }

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
    func testObserveRecombinesAndReplayPreservesTryWork() throws {
        let app = try launchPreview(orientation: .landscapeLeft)
        defer { app.terminate() }
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
        assertAwaitingWholeCount(in: app)
        capture("U07-Try-Count-Whole")

        app.buttons["key-6"].tap()
        app.buttons["Check my count"].tap()
        XCTAssertTrue(app.staticTexts["Count the counters in the tray again."].exists)
        XCTAssertFalse(app.buttons["Check my answer"].exists)
        XCTAssertFalse(app.buttons["Continue to Check"].exists)

        verifyWhole(in: app)
        capture("U07-Try-Completed-Split")
        app.buttons["Continue to Check"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        XCTAssertEqual(app.buttons["counter-1"].label, "Counter 1 in tray")
        XCTAssertTrue(app.buttons["counter-8"].exists)
    }

    @MainActor
    func testTryManuallyRecombinesByDragAndTapAndResetsWhenEdited() throws {
        let app = try launchPreview(orientation: .landscapeLeft)
        defer { app.terminate() }
        app.buttons["Try"].tap()
        let counter = app.buttons["counter-1"]
        let tray = app.staticTexts["tray-label"]

        counter.tap()
        app.buttons["put-in-bowl"].tap()
        app.buttons["key-6"].tap()
        app.buttons["Check my answer"].tap()

        let dropPoint = tray.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 1))
            .withOffset(CGVector(dx: 0, dy: 82))
        counter.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
            .press(forDuration: 0.6, thenDragTo: dropPoint)
        assertAwaitingWholeCount(in: app)
        verifyWhole(in: app)

        counter.tap()
        app.buttons["put-in-bowl"].tap()
        XCTAssertFalse(app.staticTexts["Completed split"].exists)
        XCTAssertFalse(app.buttons["Continue to Check"].exists)
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        XCTAssertFalse(app.buttons["Check my answer"].isEnabled)

        app.buttons["key-6"].tap()
        app.buttons["Check my answer"].tap()
        counter.tap()
        app.buttons["put-in-tray"].tap()
        assertAwaitingWholeCount(in: app)
        verifyWhole(in: app)
    }

    @MainActor
    private func assertAwaitingWholeCount(in app: XCUIApplication) {
        XCTAssertEqual(app.staticTexts["workspace-prompt"].label,
                       "How many counters are together in the tray? Count them and enter the number.")
        XCTAssertEqual(app.staticTexts["tray-label"].label, "Tray")
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl · 0")
        let counters = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "counter-"))
        XCTAssertEqual(counters.count, 7)
        XCTAssertTrue(counters.allElementsBoundByIndex.allSatisfy { $0.label.hasSuffix("in tray") })
        XCTAssertTrue(app.staticTexts["Completed split"].exists)
        XCTAssertFalse(app.staticTexts["Number bond"].exists)
        XCTAssertEqual(part("Whole", in: app).value as? String, "Blank")
        XCTAssertEqual(part("Part 1", in: app).label, "Part 1")
        XCTAssertEqual(part("Part 1", in: app).value as? String, "1")
        XCTAssertEqual(missingPart(in: app).label, "Part 2")
        XCTAssertEqual(missingPart(in: app).value as? String, "6")
        XCTAssertEqual(part("Your count", in: app).value as? String, "Blank")
        XCTAssertFalse(app.buttons["Check my answer"].exists)
        XCTAssertFalse(app.buttons["Check my count"].isEnabled)
        XCTAssertFalse(app.buttons["Continue to Check"].exists)
    }

    @MainActor
    private func verifyWhole(in app: XCUIApplication) {
        app.buttons["key-7"].tap()
        app.buttons["Check my count"].tap()
        XCTAssertEqual(app.staticTexts["tray-label"].label, "Tray · 7")
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl · 0")
        XCTAssertTrue(app.staticTexts["Completed split"].exists)
        XCTAssertEqual(part("Whole", in: app).value as? String, "7")
        XCTAssertEqual(missingPart(in: app).value as? String, "6")
        XCTAssertFalse(app.buttons["Check my answer"].exists)
        XCTAssertFalse(app.buttons["Check my count"].exists)
        XCTAssertTrue(app.buttons["Continue to Check"].isHittable)
    }

    @MainActor
    func testCheckStartsBlankAndUsesBothModelAndNumber() throws {
        let app = try launchPreview(orientation: .portrait)
        defer { app.terminate() }
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
    func testCheckAcceptsTrayAsKnownPartAndHomeResetsBothWorkspaces() throws {
        let app = try launchPreview(orientation: .landscapeLeft)
        defer { app.terminate() }
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
    private func launchPreview(orientation: UIDeviceOrientation) throws -> XCUIApplication {
        let app = XCUIApplication()
        // Rotate with the previous app process stopped, then wait for the fresh
        // window to finish laying out before interacting with the welcome screen.
        app.terminate()
        XCTAssertTrue(app.wait(for: .notRunning, timeout: 10))
        XCUIDevice.shared.orientation = orientation
        app.launchArguments = ["-u07-preview"]
        app.launch()
        expectOrientation(orientation, in: app)
        let start = app.buttons["Start lesson preview"]
        let welcome = start.waitForExistence(timeout: 10) ? start : nil
        try XCTUnwrap(welcome, "Expected the U07 welcome screen after a fresh launch.").tap()
        XCTAssertTrue(app.buttons["Next step"].waitForExistence(timeout: 10))
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
