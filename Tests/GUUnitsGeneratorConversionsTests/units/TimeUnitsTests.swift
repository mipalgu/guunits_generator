@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for TimeUnits
final class TimeUnitsTests: XCTestCase, UnitsTestable {

    /// Test microseconds.
    func testMicroseconds() {
        assert(
            value: TimeUnits.microseconds,
            rawValue: "microseconds",
            abbreviation: "us",
            description: "microseconds"
        )
    }

    /// Test milliseconds.
    func testMilliseconds() {
        assert(
            value: TimeUnits.milliseconds,
            rawValue: "milliseconds",
            abbreviation: "ms",
            description: "milliseconds"
        )
    }

    /// Test seconds.
    func testSeconds() {
        assert(
            value: TimeUnits.seconds,
            rawValue: "seconds",
            abbreviation: "s",
            description: "seconds"
        )
    }

    /// Test static variables.
    func testStaticVars() {
        XCTAssertEqual(TimeUnits.category, "Time")
        XCTAssertEqual(TimeUnits.highestPrecision, .microseconds)
        XCTAssertTrue(TimeUnits.sameZeroPoint)
    }

    /// Test exponents is correct.
    func testExponents() {
        let expected: [TimeUnits: Int] = [
            .microseconds: -6,
            .milliseconds: -3,
            .seconds: 0
        ]
        XCTAssertEqual(TimeUnits.exponents, expected)
    }

}
