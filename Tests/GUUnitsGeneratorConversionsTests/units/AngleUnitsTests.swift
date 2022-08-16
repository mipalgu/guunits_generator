@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for AngleUnits.
final class AngleUnitsTests: XCTestCase, UnitsTestable {

    /// Test Degrees.
    func testDegrees() {
        assert(value: AngleUnits.degrees, rawValue: "degrees", abbreviation: "deg", description: "degrees")
    }

    /// Test Radians.
    func testRadians() {
        assert(value: AngleUnits.radians, rawValue: "radians", abbreviation: "rad", description: "radians")
    }

    /// Test static variables.
    func testStaticVars() {
        XCTAssertEqual(AngleUnits.category, "Angle")
        XCTAssertEqual(AngleUnits.highestPrecision, .degrees)
        XCTAssertTrue(AngleUnits.sameZeroPoint)
    }

}
