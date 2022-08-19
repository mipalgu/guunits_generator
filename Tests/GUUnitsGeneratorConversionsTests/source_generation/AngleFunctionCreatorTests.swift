@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for AngleFunctionCreator.
final class AngleFunctionCreatorTests: XCTestCase {

    /// The creator to use in the test functions.
    let creator = AngleFunctionCreator()

    /// Test standard cast.
    func testCastFunction() {
        let result = creator.castFunc(forUnit: .degrees, sign: .t, otherSign: .u)
        let conversionFunction = SignConverter()
            .convert(AngleUnits.degrees.rawValue, otherUnit: AngleUnits.degrees, from: .t, to: .u)
        XCTAssertEqual(result, "    return \(conversionFunction);")
    }

    /// Test degree to radian cast.
    func testCreateFunctionDegToRad() {
        let result = creator.createFunction(unit: .degrees, to: .radians, sign: .t, otherSign: .d)
        XCTAssertEqual(result, "    return ((radians_d) (((double) (degrees)) / 180.0 * M_PI));")
    }

    /// Test radian to degree cast.
    func testCreateFunctionRadToDeg() {
        let result = creator.createFunction(unit: .radians, to: .degrees, sign: .d, otherSign: .t)
        let expected = """
            const double maxValue = ((double) (INT_MAX)) / 180.0 * M_PI;
            const double minValue = ((double) (INT_MIN)) / 180.0 * M_PI;
            const double castedValue = ((double) (radians));
            if (castedValue > maxValue) {
                return INT_MAX;
            }
            if (castedValue < minValue) {
                return INT_MIN;
            }
            return ((degrees_t) (round(castedValue / M_PI * 180.0)));
        """
        XCTAssertEqual(result, expected)
    }

    /// Test standard cast.
    func testCreateFunctionDegTToU() {
        let result = creator.createFunction(unit: .degrees, to: .degrees, sign: .t, otherSign: .u)
        let conversionFunction = SignConverter()
            .convert(AngleUnits.degrees.rawValue, otherUnit: AngleUnits.degrees, from: .t, to: .u)
        XCTAssertEqual(result, "    return \(conversionFunction);")
    }

}
