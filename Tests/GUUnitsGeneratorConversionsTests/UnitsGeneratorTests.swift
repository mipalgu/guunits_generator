@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for UnitsGenerator.
final class UnitsGeneratorTests: XCTestCase {

    /// Definition creator.
    private let definitionCreator = CFunctionDefinitionCreator<DistanceUnits>()

    /// Type converter
    private let numericConverter = NumericTypeConverter()

    /// The difference between metres -> centimetres -> millimetres
    private let unitDifference: [DistanceUnits: Int] = [.millimetres: 10, .centimetres: 100]

    /// The creator to use in the test functions.
    var bodyCreator: GradualFunctionCreator<DistanceUnits> {
        GradualFunctionCreator<DistanceUnits>(unitDifference: unitDifference)
    }

    /// The creator used in the test functions.
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

    /// The generator being tested.
    var generator: UnitsGenerator<
        CompositeFunctionCreator<
            GradualFunctionCreator<DistanceUnits>,
            CFunctionDefinitionCreator<DistanceUnits>,
            NumericTypeConverter
        >
    > {
        UnitsGenerator(creator: creator)
    }

    /// Test generate all function declarations.
    func testDeclarations() {
        let types: [DistanceUnits] = [.millimetres, .centimetres]
        guard let result = generator.generateDeclarations(forUnits: types) else {
            XCTFail("result was nil for declarations")
            return
        }
        XCTAssertNotEqual(result, "")
    }

    /// Test generate all function definitions.
    func testImplementations() {
        guard let result = generator.generateImplementations(forUnits: [.millimetres]) else {
            XCTFail("result was nil for implementations")
            return
        }
        XCTAssertNotEqual(result, "")
    }

    // private func getAllDeclarations(for types: [DistanceUnits]) -> [String] {
    //     let numericTypesCount = NumericTypes.allCases.count
    //     let unitTypesCount = types.count * Signs.allCases.count
    //     let totalTypes = numericTypesCount * unitTypesCount * (max(1, unitTypesCount - 1))
    //     var allDefinitions: [String] = []
    //     allDefinitions.reserveCapacity(totalTypes)
    //     types.forEach { unit in
    //         NumericTypes.allCases.forEach { numeric in
    //             Signs.allCases.forEach { sign in
    //                 let comment2 = generateDeclarationComment(
    //                     from: numeric.rawValue, to: "\(unit.rawValue)_\(sign.rawValue)"
    //                 )
    //                 let comment1 = generateDeclarationComment(
    //                     from: "\(unit.rawValue)_\(sign.rawValue)", to: numeric.rawValue
    //                 )
    //                 let declaration =
    //                     definitionCreator.functionDefinition(forUnit: unit, sign: sign, to: numeric)
    //                 allDefinitions.append(comment1 + "\n" + declaration + ";")
    //                 let declaration2 =
    //                     definitionCreator.functionDefinition(from: numeric, to: unit, sign: sign)
    //                 allDefinitions.append(comment2 + "\n" + declaration2 + ";")
    //             }
    //         }
    //         types.forEach { unit2 in
    //             guard unit != unit2 else {
    //                 return
    //             }
    //             Signs.allCases.forEach { sign1 in
    //                 Signs.allCases.forEach { sign2 in
    //                     guard sign1 != sign2 else {
    //                         return
    //                     }
    //                     let comment = generateDeclarationComment(
    //                         from: "\(unit)_\(sign1)", to: "\(unit2)_\(sign2)"
    //                     )
    //                     let declaration =
    //                         definitionCreator.functionDefinition(
    //                             forUnit: unit, to: unit2, sign: sign1, otherSign: sign2
    //                         )
    //                     allDefinitions.append(comment + "\n" + declaration + ";")
    //                 }
    //             }
    //         }
    //     }
    //     NumericTypes.allCases.forEach { num1 in
    //         NumericTypes.allCases.forEach { num2 in
    //             guard num1 != num2 else {
    //                 return
    //             }
    //             let comment = generateDeclarationComment(from: num1.rawValue, to: num2.rawValue)
    //             let declaration = ""
    //             allDefinitions.append(comment + "\n" + declaration + ";")
    //         }
    //     }
    //     return allDefinitions
    // }

    // private func generateDeclarationComment(from: String, to: String) -> String {
    //     """
    //     /**
    //         * Convert \(from) to \(to).
    //         */
    //     """
    // }

}
