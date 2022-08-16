import Foundation
@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for TemperatureTestGenerator Celsius to Numeric conversions.
final class TemperatureTestGeneratorNumTests: XCTestCase,
    TestParameterTestable,
    TestGeneratorNumericTestable {

    /// The generator to test.
    let generator = TemperatureTestGenerator()

    // swiftlint:disable missing_docs

    func testUnitTypes() {
        TemperatureUnits.allCases.forEach { unit in
            [Signs.t, Signs.u, Signs.f, Signs.d].forEach { sign in
                self.unitTest(unit: unit, sign: sign)
            }
        }
    }

    func testUnitToNumericTypes() {
        TemperatureUnits.allCases.forEach { unit in
            [Signs.t, Signs.u, Signs.f, Signs.d].forEach { sign in
                self.numericTest(unit: unit, sign: sign)
            }
        }
    }

    // swiftlint:enable missing_docs

}
