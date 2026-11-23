import Foundation
import XCTest
import JuniCore

final class NumberBondLessonTests: XCTestCase {
    func testU07PreservesManualAndTimedTeaching() throws {
        let lesson = try NumberBondLesson.load(from: fixture("u07"))
        XCTAssertFalse(lesson.synthetic)
        XCTAssertEqual([lesson.observe.whole, lesson.guided.whole, lesson.check.whole], [6, 7, 8])
        XCTAssertEqual([lesson.observe.knownPart, lesson.guided.knownPart, lesson.check.knownPart], [2, 1, 3])
        XCTAssertEqual([lesson.observe.expectedAnswer, lesson.guided.expectedAnswer, lesson.check.expectedAnswer], [4, 6, 5])
        XCTAssertEqual(lesson.steps.filter { $0.requiresImmediateAudioCue == true }.map(\.start), [19, 22, 38, 49])
        XCTAssertEqual(lesson.project(.init(time: 19)).bowl, [1])
        XCTAssertEqual(lesson.project(.init(time: 19, manual: false)).bowl, [])
        XCTAssertEqual(lesson.project(.init(time: 23, manual: false)).bowl, [1, 2])
        XCTAssertEqual(lesson.project(.init(time: 35, manual: false)).indicatedWord, "Four")
        XCTAssertNil(lesson.project(.init(time: 32, manual: false, waitingForFirstCue: true)).indicatedCounter)
        XCTAssertFalse(lesson.project(.init(time: 49, manual: false)).historical)
        XCTAssertTrue(lesson.project(.init(time: 51, manual: false)).historical)
        XCTAssertTrue(lesson.project(.init(time: 49)).showTrayCount)
        XCTAssertEqual(lesson.project(.init(time: 49, manual: false)).bowl, [1, 2])
        XCTAssertEqual(lesson.project(.init(time: 51, manual: false)).bowl, [])
        XCTAssertTrue(lesson.project(.init(time: 60)).canTry)
        XCTAssertFalse(lesson.project(.init(time: 60, manual: false)).canTry)
        XCTAssertTrue(lesson.project(.init(time: 64, manual: false)).canTry)
    }

    func testAlternateContentUsesSameProjectionAndGrader() throws {
        let lesson = try NumberBondLesson.load(from: fixture("synthetic-demo"))
        XCTAssertTrue(lesson.synthetic)
        XCTAssertEqual(lesson.project(.init()).step.caption.text, "Start with all five counters in the tray.")
        XCTAssertEqual(lesson.project(.init(time: 38)).bowl, [1])
        XCTAssertEqual(lesson.project(.init(time: 49)).bowl, [])
        XCTAssertTrue(lesson.guided.matches(answer: 4, bowlCount: 2))
        XCTAssertFalse(lesson.guided.matches(answer: 4, bowlCount: 4))
        XCTAssertTrue(lesson.check.matches(answer: 7, bowlCount: 2))
        XCTAssertTrue(lesson.check.matches(answer: 7, bowlCount: 7))
        XCTAssertFalse(lesson.check.matches(answer: 7, bowlCount: 0))
        XCTAssertFalse(lesson.check.matches(answer: 5, bowlCount: 2))
        XCTAssertFalse(lesson.prompt(.checkEntry).text.contains("seven"))
        XCTAssertFalse(lesson.prompt(.checkRetry).text.contains("seven"))
        XCTAssertNil(lesson.prompt(.checkEntry).clipID)
    }

    func testInvalidContentFailsBeforeProjection() throws {
        let data = try Data(contentsOf: fixture("u07"))
        let original = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        func rejects(_ description: String, edit: (inout [String: Any]) throws -> Void) throws {
            var invalid = original
            try edit(&invalid)
            let bytes = try JSONSerialization.data(withJSONObject: invalid)
            XCTAssertThrowsError(try NumberBondLesson.decode(bytes), description)
        }

        try rejects("unsupported version") { $0["schemaVersion"] = 2 }
        try rejects("missing steps") { $0["steps"] = [] }
        try rejects("incorrect arithmetic") {
            var item = try XCTUnwrap($0["check"] as? [String: Any])
            item["expectedAnswer"] = 6
            $0["check"] = item
        }
        try rejects("check repeats worked example with parts swapped") {
            $0["check"] = ["whole": 6, "knownPart": 4, "expectedAnswer": 2, "modelRequirement": "wholeAndBothParts"]
        }
        try rejects("authored independent prompt") {
            var prompts = try XCTUnwrap($0["prompts"] as? [String: Any])
            prompts["checkRetry"] = ["text": "Use five."]
            $0["prompts"] = prompts
        }
        try rejects("counter out of range") {
            var steps = try XCTUnwrap($0["steps"] as? [[String: Any]])
            steps[3]["cues"] = [["at": 19], ["at": 20, "moveToBowl": 9]]
            $0["steps"] = steps
        }
        try rejects("invalid clip reference") {
            var prompts = try XCTUnwrap($0["prompts"] as? [String: Any])
            prompts["tryEntry"] = ["text": "Start here.", "clipID": "../outside"]
            $0["prompts"] = prompts
        }
        XCTAssertThrowsError(try NumberBondLesson.decode(Data("{".utf8)))
    }

    private func fixture(_ id: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("../../../Juni/NumberBondLessons/\(id).json")
            .standardizedFileURL
    }
}
