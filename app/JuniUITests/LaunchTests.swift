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

        let caption = app.staticTexts["observe-caption"]
        let expected = [
            "Let’s count the counters in this tray.",
            "One, two, three, four, five, six.",
            "Six is the whole. That means all the counters. Watch me split them into two groups.",
            "One into the bowl.",
            "One more into the bowl. Two in the bowl.",
            "The tray is our other group. How many are there?",
            "One, two, three, four. Four in the tray.",
            "Two in the bowl. Four in the tray. Two and four make six. This picture is a number bond.",
            "Let’s put the two back. One, two, three, four, five, six. We still have six!",
            "Ready to make your own split? Tap Try."
        ]
        let bowlCounts = [0, 0, 0, 1, 2, 2, 2, 2, 0, 0]
        for (index, text) in expected.enumerated() {
            if index > 0 { next.tap() }
            XCTAssertEqual(caption.label, text)
            assertObserveCounters(in: app, bowl: bowlCounts[index], stage: index)
            if index == 1 || index == 6 || index == 8 {
                verifyManualCount(in: app, firstID: index == 6 ? 3 : 1, caption: text, stage: index)
            }
            if index == 3 { capture("U07-Observe-First-Move") }
            if index == 7 {
                XCTAssertEqual(part("Part 1", in: app).label, "Bowl")
                XCTAssertEqual(part("Part 1", in: app).value as? String, "2")
                XCTAssertEqual(missingPart(in: app).label, "Tray")
                XCTAssertEqual(missingPart(in: app).value as? String, "4")
                XCUIDevice.shared.orientation = .portrait
                expectOrientation(.portrait, in: app)
                XCTAssertTrue(missingPart(in: app).isHittable)
                capture("U07-Observe-Bond")
            }
            if index == 8 {
                XCTAssertEqual(tray.label, "Tray · 6")
                XCTAssertEqual(bowl.label, "Bowl · 0")
                XCTAssertTrue(app.staticTexts["Our split"].exists)
                capture("U07-Observe-Recombined")
            }
            XCTAssertEqual(app.buttons["Try together"].exists, index == 9)
        }
        XCTAssertFalse(next.isEnabled)

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
        XCTAssertEqual(tray.label, "Tray")
        XCTAssertEqual(caption.label, expected[0])
        XCTAssertFalse(missingPart(in: app).exists)
        app.buttons["Try"].tap()

        XCTAssertEqual(app.buttons["counter-1"].label, "Counter in bowl")
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
        XCTAssertEqual(app.buttons["counter-1"].label, "Counter in tray")
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
    func testObserveTimedPlaybackPausesResumesAndSwitchesToManual() throws {
        let app = try launchPreview(orientation: .landscapeLeft)
        defer { app.terminate() }
        let caption = app.staticTexts["observe-caption"]
        let firstCount = "One, two, three, four, five, six."
        app.buttons["Play"].tap()
        expectLabel(firstCount, on: caption, within: 8)
        app.buttons["Pause"].tap()
        let heldCaption = XCTNSPredicateExpectation(predicate: NSPredicate(format: "label != %@", firstCount),
                                                    object: caption)
        heldCaption.isInverted = true
        XCTAssertEqual(XCTWaiter.wait(for: [heldCaption], timeout: 8), .completed)
        app.buttons["Play"].tap()
        expectLabel("Six is the whole. That means all the counters. Watch me split them into two groups.",
                    on: caption, within: 9)
        expectLabel("One into the bowl.", on: caption, within: 9)
        expectLabel("Bowl · 1", on: app.staticTexts["bowl-label"], within: 3)
        expectLabel("One more into the bowl. Two in the bowl.", on: caption, within: 5)
        expectLabel("Bowl · 2", on: app.staticTexts["bowl-label"], within: 3)
        expectLabel("The tray is our other group. How many are there?", on: caption, within: 6)
        expectLabel("One, two, three, four. Four in the tray.", on: caption, within: 8)
        expectLabel("Two in the bowl. Four in the tray. Two and four make six. This picture is a number bond.",
                    on: caption, within: 8)
        expectLabel("Let’s put the two back. One, two, three, four, five, six. We still have six!",
                    on: caption, within: 13)
        expectLabel("Bowl · 0", on: app.staticTexts["bowl-label"], within: 4)
        XCTAssertTrue(app.staticTexts["Our split"].exists)
        assertObserveCounters(in: app, bowl: 0, stage: 8)
        expectLabel("Ready to make your own split? Tap Try.", on: caption, within: 12)
        XCTAssertTrue(app.buttons["Try together"].waitForExistence(timeout: 6))
        app.buttons["Replay"].tap()
        XCTAssertEqual(caption.label, "Let’s count the counters in this tray.")
        assertObserveCounters(in: app, bowl: 0, stage: 0)
        XCTAssertTrue(app.buttons["Pause"].exists)
        app.buttons["Next step"].tap()
        XCTAssertEqual(caption.label, firstCount)
        XCTAssertTrue(app.buttons["Play"].exists)
        assertManualCue(in: app, id: 1, word: "One")
        app.buttons["Count next"].tap()
        assertManualCue(in: app, id: 2, word: "Two")
    }

    @MainActor
    private func verifyManualCount(in app: XCUIApplication, firstID: Int, caption: String, stage: Int) {
        let words = ["One", "Two", "Three", "Four", "Five", "Six"]
        let countNext = app.buttons["Count next"]
        for id in firstID...6 {
            let word = words[id - firstID]
            XCTAssertEqual(app.staticTexts["observe-caption"].label, caption)
            assertManualCue(in: app, id: id, word: word)
            if stage == 8 {
                let fourth = part("observe-counter-4", in: app).frame
                let fifth = part("observe-counter-5", in: app).frame
                XCTAssertGreaterThan(fifth.midY, fourth.midY)
                XCTAssertLessThan(fifth.midX, fourth.midX)
            }
            capture("U07-Manual-Stage-\(stage)-\(word)")
            if id < 6 {
                XCTAssertFalse(app.buttons["Next step"].exists)
                XCTAssertTrue(countNext.isEnabled)
                countNext.tap()
            }
        }
        XCTAssertFalse(countNext.exists)
        XCTAssertTrue(app.buttons["Next step"].isEnabled)
    }

    @MainActor
    private func assertManualCue(in app: XCUIApplication, id: Int, word: String) {
        for candidate in 1...6 {
            let counter = part("observe-counter-\(candidate)", in: app)
            XCTAssertEqual(counter.isSelected, candidate == id)
            if candidate == id {
                XCTAssertEqual(counter.label, word)
                XCTAssertTrue(counter.isHittable)
            } else {
                XCTAssertTrue(["Counter in tray", "Counter in bowl"].contains(counter.label))
            }
        }
    }

    @MainActor
    private func expectLabel(_ label: String, on element: XCUIElement, within timeout: TimeInterval) {
        let predicate = NSPredicate(format: "label == %@", label)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: timeout), .completed)
    }

    @MainActor
    private func assertObserveCounters(in app: XCUIApplication, bowl: Int, stage: Int) {
        let counters = app.descendants(matching: .any)
            .matching(NSPredicate(format: "identifier BEGINSWITH %@", "observe-counter-"))
        XCTAssertEqual(counters.count, 6, "Stage \(stage)")
        let bowlCounters = counters.allElementsBoundByIndex.filter { $0.label == "Counter in bowl" }
        XCTAssertEqual(bowlCounters.count, bowl, "Stage \(stage)")
        for id in 1...6 {
            let match = counters.matching(identifier: "observe-counter-\(id)")
            XCTAssertEqual(match.count, 1)
            XCTAssertEqual(match.firstMatch.label == "Counter in bowl", id <= bowl)
        }
    }

    @MainActor
    private func assertAwaitingWholeCount(in app: XCUIApplication) {
        XCTAssertEqual(app.staticTexts["workspace-prompt"].label,
                       "How many counters are together in the tray? Count them and enter the number.")
        XCTAssertEqual(app.staticTexts["tray-label"].label, "Tray")
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl · 0")
        let counters = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "counter-"))
        XCTAssertEqual(counters.count, 7)
        XCTAssertTrue(counters.allElementsBoundByIndex.allSatisfy { $0.label == "Counter in tray" })
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
        let counters = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "counter-"))
        XCTAssertEqual(counters.count, 8)
        XCTAssertTrue(counters.allElementsBoundByIndex.allSatisfy { $0.label == "Counter in tray" })
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
        XCTAssertEqual(third.label, "Counter in bowl")
        XCTAssertEqual(app.buttons["counter-4"].label, "Counter in tray")
        XCTAssertEqual(app.staticTexts["workspace-prompt"].label, prompt)
        XCTAssertEqual(app.staticTexts["tray-label"].label, "Tray")
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl")
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
        XCTAssertEqual(app.buttons["counter-5"].label, "Counter in bowl")
        app.buttons["Check my answer"].tap()
        XCTAssertEqual(part("Part 1", in: app).label, "Tray")
        XCTAssertEqual(missingPart(in: app).label, "Bowl")

        app.buttons["Home"].tap()
        app.buttons["Start Over"].tap()
        XCTAssertEqual(app.staticTexts["bowl-label"].label, "Bowl")
        app.buttons["Try"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        app.buttons["Check"].tap()
        XCTAssertEqual(missingPart(in: app).value as? String, "Blank")
        XCTAssertEqual(app.buttons["counter-5"].label, "Counter in tray")
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
