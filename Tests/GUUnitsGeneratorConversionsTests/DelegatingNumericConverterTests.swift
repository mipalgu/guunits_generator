@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for DelegatingNumericConverter
final class DelegatingNumericConverterTests: XCTestCase {

    /// The converter to use in the test functions.
    let converter = DelegatingNumericConverter()

    /// Test conversion to a numeric type works.
    func testConvertToNumeric() {
        let result = converter.convert("x", from: DistanceUnits.centimetres, sign: .t, to: .double)
        XCTAssertEqual(result, "::cm_t_to_d(x)")
    }

    /// Test conversion to a unit type works.
    func testConvertToUnit() {
        let result = converter.convert("x", from: .int8, to: DistanceUnits.centimetres, sign: .d)
        XCTAssertEqual(result, "::i8_to_cm_d(x)")
    }

}
