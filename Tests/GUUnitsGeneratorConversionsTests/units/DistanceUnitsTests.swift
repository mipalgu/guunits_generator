@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for DistanceUnits.
final class DistanceUnitsTests: XCTestCase, UnitsTestable {

    /// Test mm.
    func testMillimetres() {
        assert(
            value: DistanceUnits.millimetres,
            rawValue: "millimetres",
            abbreviation: "mm",
            description: "millimetres"
        )
    }

    /// Test cm.
    func testCentimetres() {
        assert(
            value: DistanceUnits.centimetres,
            rawValue: "centimetres",
            abbreviation: "cm",
            description: "centimetres"
        )
    }

    /// Test m
    func testMetres() {
        assert(
            value: DistanceUnits.metres,
            rawValue: "metres",
            abbreviation: "m",
            description: "metres"
        )
    }

    /// Test static variables.
    func testStaticVars() {
        XCTAssertEqual(DistanceUnits.category, "Distance")
        XCTAssertEqual(DistanceUnits.highestPrecision, .millimetres)
        XCTAssertTrue(DistanceUnits.sameZeroPoint)
    }

    /// Test exponents static constant is correct.
    func testExponents() {
        let expected: [DistanceUnits: Int] = [
            .millimetres: -3,
            .centimetres: -2,
            .metres: 0
        ]
        XCTAssertEqual(DistanceUnits.exponents, expected)
    }

}
