@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for TimeUnits
final class TimeUnitsTests: XCTestCase, UnitsTestable {

    /// Test picoseconds.
    func testPicoseconds() {
        assert(
            value: TimeUnits.picoseconds,
            rawValue: "picoseconds",
            abbreviation: "ps",
            description: "picoseconds"
        )
    }

    /// Test nanoseconds.
    func testNanoseconds() {
        assert(
            value: TimeUnits.nanoseconds,
            rawValue: "nanoseconds",
            abbreviation: "ns",
            description: "nanoseconds"
        )
    }

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
        XCTAssertEqual(TimeUnits.highestPrecision, .picoseconds)
        XCTAssertTrue(TimeUnits.sameZeroPoint)
    }

    /// Test exponents is correct.
    func testExponents() {
        let expected: [TimeUnits: Int] = [
            .picoseconds: -12,
            .nanoseconds: -9,
            .microseconds: -6,
            .milliseconds: -3,
            .seconds: 0
        ]
        XCTAssertEqual(TimeUnits.exponents, expected)
    }

}
