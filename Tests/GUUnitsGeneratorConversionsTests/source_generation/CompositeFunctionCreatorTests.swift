@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for CompositeFunctionCreator.
final class CompositeFunctionCreatorTests: XCTestCase {

    /// Definition creator.
    let definitionCreator = CFunctionDefinitionCreator<DistanceUnits>()

    /// Type converter
    let numericConverter = NumericTypeConverter()

    /// The difference between metres -> centimetres -> millimetres
    let unitDifference: [DistanceUnits: Int] = [.millimetres: 10, .centimetres: 100]

    /// The creator to use in the test functions.
    var bodyCreator: GradualFunctionCreator<DistanceUnits> {
        GradualFunctionCreator<DistanceUnits>(unitDifference: unitDifference)
    }

    /// The creator used in the test functions. This is the uut.
    var creator: CompositeFunctionCreator<
        GradualFunctionCreator<DistanceUnits>,
        CFunctionDefinitionCreator<DistanceUnits>,
        NumericTypeConverter
    > {
        CompositeFunctionCreator<
            GradualFunctionCreator<DistanceUnits>,
            CFunctionDefinitionCreator<DistanceUnits>,
            NumericTypeConverter
        >(
            bodyCreator: bodyCreator,
            definitionCreator: definitionCreator,
            numericConverter: numericConverter
        )
    }

    /// Test that we can convert from a numeric type to a unit type.
    func testConvertFromNumericToUnit() {
        let result = creator.convert("x", from: .uint16, to: .millimetres, sign: .f)
        let expected = numericConverter.convert("x", from: .uint16, to: DistanceUnits.millimetres, sign: .f)
        XCTAssertEqual(result, expected)
    }

    /// Test that we can convert from a unit type to a numeric type.
    func testConvertFromUnitToNumeric() {
        let result = creator.convert("x", from: .metres, sign: .t, to: .int16)
        let expected = numericConverter.convert("x", from: DistanceUnits.metres, sign: .t, to: .int16)
        XCTAssertEqual(result, expected)
    }

    /// Test that creator can generate function bodies.
    func testCreateFunction() {
        let result = creator.createFunction(unit: .centimetres, to: .millimetres, sign: .t, otherSign: .u)
        let expected = bodyCreator.createFunction(
            unit: .centimetres, to: .millimetres, sign: .t, otherSign: .u
        )
        XCTAssertEqual(result, expected)
    }

    /// Test definition from unit to unit.
    func testDefUnitToUnit() {
        let result = creator.functionDefinition(
            forUnit: .millimetres, to: .centimetres, sign: .f, otherSign: .d
        )
        let expected = definitionCreator.functionDefinition(
            forUnit: .millimetres, to: .centimetres, sign: .f, otherSign: .d
        )
        XCTAssertEqual(result, expected)
    }

    /// Test definition for unit to numeric.
    func testDefUnitToNumeric() {
        let result = creator.functionDefinition(forUnit: .metres, sign: .t, to: .float)
        let expected = definitionCreator.functionDefinition(forUnit: .metres, sign: .t, to: .float)
        XCTAssertEqual(result, expected)
    }

    /// Test definition for numeric to unit.
    func testDefNumericToUnit() {
        let result = creator.functionDefinition(from: .uint64, to: .centimetres, sign: .u)
        let expected = definitionCreator.functionDefinition(from: .uint64, to: .centimetres, sign: .u)
        XCTAssertEqual(result, expected)
    }

}
