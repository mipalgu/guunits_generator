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
        XCTAssertEqual(result, "    return ((radians_d) (((double) degrees) * M_PI / 180.0));")
    }

    /// Test radian to degree cast.
    func testCreateFunctionRadToDeg() {
        let result = creator.createFunction(unit: .radians, to: .degrees, sign: .d, otherSign: .t)
        XCTAssertEqual(result, "    return ((degrees_t) (round(180.0 / M_PI * ((double) radians))));")
    }

    /// Test standard cast.
    func testCreateFunctionDegTToU() {
        let result = creator.createFunction(unit: .degrees, to: .degrees, sign: .t, otherSign: .u)
        let conversionFunction = SignConverter()
            .convert(AngleUnits.degrees.rawValue, otherUnit: AngleUnits.degrees, from: .t, to: .u)
        XCTAssertEqual(result, "    return \(conversionFunction);")
    }

}
