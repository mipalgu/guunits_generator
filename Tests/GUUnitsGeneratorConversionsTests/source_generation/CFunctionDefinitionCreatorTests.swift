@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for CFunctionDefinitionCreator.
final class CFunctionDefinitionCreatorTests: XCTestCase {

    /// The creator used in the test functions.
    let creator = CFunctionDefinitionCreator<DistanceUnits>()

    /// Helper to use in the test functions.
    let helper = FunctionHelpers<DistanceUnits>()

    /// Test that a unit can convert to another unit.
    func testUnitConversion() {
        let expected = helper.functionDefinition(
            forUnit: .centimetres, to: .centimetres, sign: .t, otherSign: .u
        )
        let result = creator.functionDefinition(
            forUnit: .centimetres, to: .centimetres, sign: .t, otherSign: .u
        )
        XCTAssertEqual(result, expected)
    }

    /// Test that a unit can be converted to a numeric type.
    func testUnitToNumeric() {
        let expected = helper.functionDefinition(forUnit: .centimetres, sign: .t, to: .int16)
        let result = creator.functionDefinition(forUnit: .centimetres, sign: .t, to: .int16)
        print(result)
        XCTAssertEqual(expected, result)
    }

    /// Test that a numeric type can be converted to a unit type.
    func testNumericToUnit() {
        let expected = helper.functionDefinition(from: .int8, to: .centimetres, sign: .f)
        let result = creator.functionDefinition(from: .int8, to: .centimetres, sign: .f)
        XCTAssertEqual(result, expected)
    }

}
