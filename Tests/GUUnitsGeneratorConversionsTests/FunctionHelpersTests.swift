@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for FunctionHelpers.
final class FunctionHelpersTests: XCTestCase {

    /// Helper used in test functions.
    let helper = FunctionHelpers<DistanceUnits>()

    /// Test helper creates name correctly.
    func testGetFunctionName() {
        let name = helper.functionName(forUnit: .centimetres, sign: .t, to: .int32)
        XCTAssertEqual(name, "cm_t_to_i32")
        let name2 = helper.functionName(forUnit: .centimetres, to: .millimetres, sign: .t, otherSign: .u)
        XCTAssertEqual(name2, "cm_t_to_mm_u")
    }

    /// Test the function definition is generated correctly.
    func testDefinition() {
        let definition = helper.functionDefinition(forUnit: .centimetres, sign: .t, to: .int32)
        XCTAssertEqual(definition, "int32_t cm_t_to_i32(centimetres_t centimetres)")
        let definition2 = helper.functionDefinition(
            forUnit: .centimetres, sign: .t, to: .int32, unique: true, namespace: "test"
        )
        XCTAssertEqual(definition2, "int32_t testcm_t_to_i32(centimetres_t centimetres)")
        let definition3 = helper.functionDefinition(
            forUnit: .centimetres, to: .millimetres, sign: .t, otherSign: .u
        )
        XCTAssertEqual(definition3, "millimetres_u cm_t_to_mm_u(centimetres_t centimetres)")
        let definition4 = helper.functionDefinition(
            forUnit: .centimetres, to: .millimetres, sign: .t, otherSign: .u, unique: true, namespace: "test"
        )
        XCTAssertEqual(definition4, "millimetres_u testcm_t_to_mm_u(centimetres_t centimetres)")
        let definition5 = helper.functionDefinition(from: .int32, to: .centimetres, sign: .t)
        XCTAssertEqual(definition5, "centimetres_t i32_to_cm_t(int32_t centimetres)")
        let definition6 = helper.functionDefinition(
            from: .int32, to: .centimetres, sign: .t, unique: true, namespace: "test"
        )
        XCTAssertEqual(definition6, "centimetres_t testi32_to_cm_t(int32_t centimetres)")
    }

    /// Test the modify function returns the correct literal value.
    func testModify() {
        let result = helper.modify(value: 5, forSign: .d)
        XCTAssertEqual(result, "5.0")
        let result2 = helper.modify(value: 5, forSign: .f)
        XCTAssertEqual(result2, "5.0f")
        let result3 = helper.modify(value: 5, forSign: .u)
        XCTAssertEqual(result3, "5")
        let result4 = helper.modify(value: 5, forSign: .t)
        XCTAssertEqual(result4, "5")
    }

    /// Test create test function name for unit conversion.
    func testTestFunctionNameUsingUnits() {
        let result = helper.testFunctionName(
            from: TemperatureUnits.celsius,
            with: .t,
            to: TemperatureUnits.kelvin,
            with: .u,
            using: TestParameters(input: "300", output: "27")
        )
        let expected = "testcelsius_tTokelvin_uUsing300Expecting27"
        XCTAssertEqual(result, expected)
    }

    /// Test create test function name for unit to numeric conversion.
    func testTestFunctionNameUsingUnitToNumericConversion() {
        let result = helper.testFunctionName(
            from: TemperatureUnits.kelvin,
            with: .d,
            to: .float,
            using: TestParameters(input: "23.0", output: "23.0f")
        )
        let expected = "testkelvin_dTofloatUsing23Expecting23"
        XCTAssertEqual(result, expected)
    }

    /// Test create test function name for numeric to unit conversion.
    func testTestFunctionNameUsingNumericToUnitConversion() {
        let result = helper.testFunctionName(
            from: .int,
            to: TemperatureUnits.fahrenheit,
            with: .u,
            using: TestParameters(input: "2", output: "2")
        )
        let expected = "testintTofahrenheit_uUsing2Expecting2"
        XCTAssertEqual(result, expected)
    }

}
