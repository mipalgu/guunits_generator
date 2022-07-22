@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for PercentUnits.
final class PercentUnitsTests: XCTestCase, UnitsTestable {

    /// Test Percent.
    func testPercent() {
        assert(value: PercentUnits.percent, rawValue: "percent", abbreviation: "pct", description: "percent")
    }

    /// Test Static Variables.
    func testStaticVariables() {
        XCTAssertEqual(PercentUnits.category, "Percent")
        XCTAssertEqual(PercentUnits.highestPrecision, .percent)
        XCTAssertTrue(PercentUnits.sameZeroPoint)
    }

}
