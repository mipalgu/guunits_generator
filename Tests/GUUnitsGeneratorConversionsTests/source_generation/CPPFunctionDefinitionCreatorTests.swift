@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for CPPFunctionDefinitionCreator.
final class CPPFunctionDefinitionCreatorTests: XCTestCase {

    /// The creator used in the test functions.
    var creator: CPPFunctionDefinitionCreator<DistanceUnits> {
        CPPFunctionDefinitionCreator<DistanceUnits>(namespace: namespace)
    }

    /// The helper used in the test functions.
    let helper = FunctionHelpers<DistanceUnits>()

    /// The namespace which the creator uses.
    let namespace = "test"

    /// Test init correctly assigns stored properties.
    func testInit() {
        XCTAssertEqual(creator.namespace, "test")
        let newCreator = CPPFunctionDefinitionCreator<DistanceUnits>()
        XCTAssertNil(newCreator.namespace)
    }

    /// Test unit to unit conversion.
    func testUnitToUnit() {
        let expected = helper.functionDefinition(
            forUnit: .centimetres, to: .metres, sign: .t, otherSign: .t, unique: false, namespace: namespace
        )
        let result = creator.functionDefinition(forUnit: .centimetres, to: .metres, sign: .t, otherSign: .t)
        XCTAssertEqual(expected, result)
    }

    /// Test unit to numeric conversion.
    func testUnitToNumeric() {
        let expected = helper.functionDefinition(
            forUnit: .centimetres, sign: .u, to: .float, unique: false, namespace: namespace
        )
        let result = creator.functionDefinition(forUnit: .centimetres, sign: .u, to: .float)
        XCTAssertEqual(expected, result)
    }

    /// Test numeric to unit conversion.
    func testNumericToUnit() {
        let expected = helper.functionDefinition(
            from: .uint64, to: .millimetres, sign: .d, unique: false, namespace: namespace
        )
        let result = creator.functionDefinition(from: .uint64, to: .millimetres, sign: .d)
        XCTAssertEqual(result, expected)
    }

}
