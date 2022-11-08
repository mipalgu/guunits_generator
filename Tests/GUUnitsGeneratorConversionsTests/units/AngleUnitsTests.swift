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

    /// Test same conversion produces constant conversion function.
    func testSameConversion() {
        let unit = AngleUnits.radians
        let expected = Operation.constant(declaration: AnyUnit(AngleUnits.radians))
        XCTAssertEqual(expected, unit.conversion(to: .radians))
        let unit2 = AngleUnits.degrees
        let expected2 = Operation.constant(declaration: AnyUnit(AngleUnits.degrees))
        XCTAssertEqual(expected2, unit2.conversion(to: .degrees))
    }

    /// Test degrees to radians conversion is correct.
    func testDegreesToRadiansConversion() {
        let unit = AngleUnits.degrees
        let expected = Operation.multiplication(
            lhs: .division(
                lhs: .constant(declaration: AnyUnit(AngleUnits.degrees)),
                rhs: .literal(declaration: .integer(value: 180))
            ),
            rhs: .literal(declaration: .decimal(value: Double.pi))
        )
        XCTAssertEqual(expected, unit.conversion(to: .radians))
    }

    /// Test Radians to Degrees conversion is correct.
    func testRadiansToDegreesConversion() {
        let unit = AngleUnits.radians
        let expected = Operation.multiplication(
            lhs: .division(
                lhs: .constant(declaration: AnyUnit(AngleUnits.radians)),
                rhs: .literal(declaration: .decimal(value: Double.pi))
            ),
            rhs: .literal(declaration: .integer(value: 180))
        )
        XCTAssertEqual(expected, unit.conversion(to: .degrees))
    }

}
