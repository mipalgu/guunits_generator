@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for SignConverter.
final class SignConverterTests: XCTestCase {

    /// The converter to use in the tests.
    let converter = SignConverter()

    /// Test convert a signed type to an unsigned type.
    func testConvertTToU() {
        let result = converter.convert("x", otherUnit: DistanceUnits.centimetres, from: .t, to: .u)
        XCTAssertEqual(result, "((centimetres_u) ((x) < 0 ? 0 : x))")
    }

    /// Test convert an unsigned type to a signed type.
    func testConvertUToT() {
        let result = converter.convert("x", otherUnit: DistanceUnits.centimetres, from: .u, to: .t)
        XCTAssertEqual(
            result,
            "((centimetres_t) ((x) > ((unsigned int) (INT_MAX)) ? ((unsigned int) (INT_MAX)) : x))"
        )
    }

    /// Test convert a signed integer to a float.
    func testConvertTToF() {
        let result = converter.convert("x", otherUnit: DistanceUnits.centimetres, from: .t, to: .f)
        XCTAssertEqual(result, "((centimetres_f) (x))")
    }

    /// Test convert a signed integer to a double.
    func testConvertTToD() {
        let result = converter.convert("x", otherUnit: DistanceUnits.centimetres, from: .t, to: .d)
        XCTAssertEqual(result, "((centimetres_d) (x))")
    }

    /// Test convert a double to a signed integer.
    func testConvertDToT() {
        let result = converter.convert("x", otherUnit: DistanceUnits.centimetres, from: .d, to: .t)
        XCTAssertEqual(result, "((centimetres_t) (round(((double) (x)))))")
    }

}
