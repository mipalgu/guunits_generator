@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for AngleUnits.
final class AngleUnitsTests: XCTestCase {

    /// Test Degrees.
    func testDegrees() {
        assert(value: .degrees, rawValue: "degrees", abbreviation: "deg", description: "degrees")
    }

    /// Test Radians.
    func testRadians() {
        assert(value: .radians, rawValue: "radians", abbreviation: "rad", description: "radians")
    }

    /// Test static variables.
    func testStaticVars() {
        XCTAssertEqual(AngleUnits.category, "Angle")
        XCTAssertEqual(AngleUnits.highestPrecision, .degrees)
        XCTAssertTrue(AngleUnits.sameZeroPoint)
    }

    /// Assert that the value matches the test data.
    /// - Parameters:
    ///   - value: The uut.
    ///   - rawValue: The expected rawValue.
    ///   - abbreviation: The expected abbreviation.
    ///   - description: The expected description.
    private func assert(value: AngleUnits, rawValue: String, abbreviation: String, description: String) {
        XCTAssertEqual(value.rawValue, rawValue)
        XCTAssertEqual(value.abbreviation, abbreviation)
        XCTAssertEqual(value.description, description)
    }

}
