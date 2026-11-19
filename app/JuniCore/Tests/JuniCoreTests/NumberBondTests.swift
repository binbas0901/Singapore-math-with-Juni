import XCTest
@testable import JuniCore
final class NumberBondTests: XCTestCase {
    func testAllValidPairs() {
        for whole in 0...10 { for known in 0...whole { XCTAssertEqual(NumberBond.missingPart(whole: whole, known: known), whole-known) } }
    }
    func testInvalidPairs() {
        XCTAssertNil(NumberBond.missingPart(whole: -1, known: 0))
        XCTAssertNil(NumberBond.missingPart(whole: 11, known: 1))
        XCTAssertNil(NumberBond.missingPart(whole: 5, known: 6))
        XCTAssertNil(NumberBond.missingPart(whole: 5, known: -1))
    }
}
