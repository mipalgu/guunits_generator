@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for NumericTypeConverter.
final class NumericTypeConverterTests: XCTestCase {

    /// The converter used in the test functions.
    let converter = NumericTypeConverter()

    /// Test the cast works for the same underlying C-type.
    func testSameType() {
        let result = converter.convert("x", from: .int, to: DistanceUnits.centimetres, sign: .t)
        XCTAssertEqual(result, "((centimetres_t) (x))")
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .t, to: .int)
        XCTAssertEqual(result2, "((int) (x))")
    }

    /// Tests that a float can be converted to a double unit.
    func testFloatToDouble() {
        let result = converter.convert("x", from: .float, to: DistanceUnits.centimetres, sign: .d)
        XCTAssertEqual(result, "((centimetres_d) (x))")
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .d, to: .float)
        XCTAssertEqual(result2, "d_to_f(((double) (x)))")
    }

    /// Tests that a double can be converted to a float unit.
    func testDoubleToFloat() {
        let result = converter.convert("x", from: .double, to: DistanceUnits.centimetres, sign: .f)
        XCTAssertEqual(result, "((centimetres_f) (d_to_f(x)))")
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .f, to: .double)
        XCTAssertEqual(result2, "((double) (x))")
    }

    /// Tests that an int8 can be converted to an int type.
    func testInt8ToInt() {
        let result = converter.convert("x", from: .int8, to: DistanceUnits.centimetres, sign: .t)
        XCTAssertEqual(result, "((centimetres_t) (x))")
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .t, to: .int8)
        XCTAssertEqual(result2, "((int8_t) (MIN(((centimetres_t) (127)), MAX(((centimetres_t) (-128)), x))))")
    }

    /// Tests a down cast into int from int64_t.
    func testInt64ToInt() {
        let result = converter.convert("x", from: .int64, to: DistanceUnits.centimetres, sign: .t)
        XCTAssertEqual(
            result,
            "((centimetres_t) (MIN(((int64_t) (INT_MAX)), MAX(((int64_t) (INT_MIN)), x))))"
        )
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .t, to: .int64)
        XCTAssertEqual(result2, "((int64_t) (x))")
    }

    /// Test convert int to double.
    func testIntToDouble() {
        let result = converter.convert("x", from: .int, to: DistanceUnits.centimetres, sign: .d)
        XCTAssertEqual(result, "((centimetres_d) (x))")
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .d, to: .int)
        XCTAssertEqual(result2, "d_to_i(((double) (x)))")
    }

    /// Test case for unsigned to signed conversion.
    func testUToI() {
        let result = converter.convert("x", from: .uint, to: DistanceUnits.centimetres, sign: .t)
        XCTAssertEqual(result, "((centimetres_t) (MIN(((unsigned int) (INT_MAX)), x)))")
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .t, to: .uint)
        XCTAssertEqual(result2, "((unsigned int) (MAX(((centimetres_t) (0)), x)))")
    }

    /// Test case for double to cm_f conversion.
    func testDoubleToCMF() {
        let result = converter.convert("x", from: .double, to: DistanceUnits.centimetres, sign: .f)
        XCTAssertEqual(result, "((centimetres_f) (d_to_f(x)))")
        let result2 = converter.convert("x", from: DistanceUnits.centimetres, sign: .f, to: .double)
        XCTAssertEqual(result2, "((double) (x))")
    }

}
