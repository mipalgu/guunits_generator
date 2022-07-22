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
        var components = result.components(separatedBy: "\n\n")
        components.removeAll { $0.first != "/" && $0.last != ";" }
        let allDeclaration = getAllDeclarations(for: types)
        XCTAssertEqual(allDeclaration.count, components.count)
        let generatedFunctions = Set(components)
        allDeclaration.forEach {
            XCTAssertTrue(generatedFunctions.contains($0))
        }
    }

    /// Test generate all function definitions.
    func testImplementations() {
        let types: [DistanceUnits] = [.millimetres, .centimetres]
        guard let result = generator.generateImplementations(forUnits: types) else {
            XCTFail("result was nil for implementations")
            return
        }
        var components = result.components(separatedBy: "\n\n")
        components.removeAll { $0.first != "/" && $0.last != ";" }
        let allDeclarations = getAllDeclarations(for: types, withImplementation: true)
        XCTAssertEqual(allDeclarations.count, components.count)
        let generatedFunctions = Set(components)
        allDeclarations.forEach {
            XCTAssertTrue(generatedFunctions.contains($0))
        }
    }

    private func getAllDeclarations(
        for types: [DistanceUnits], withImplementation: Bool = false
    ) -> [String] {
        let numericTypesCount = NumericTypes.allCases.count
        let unitTypesCount = types.count * Signs.allCases.count
        let totalTypes = numericTypesCount * unitTypesCount * (max(1, unitTypesCount - 1))
        var allDefinitions: [String] = []
        allDefinitions.reserveCapacity(totalTypes)
        types.forEach { unit in
            NumericTypes.allCases.forEach { numeric in
                Signs.allCases.forEach { sign in
                    let comment2 = generateDeclarationComment(
                        from: numeric.rawValue, to: "\(unit.rawValue)_\(sign.rawValue)"
                    )
                    let comment1 = generateDeclarationComment(
                        from: "\(unit.rawValue)_\(sign.rawValue)", to: numeric.rawValue
                    )
                    let declaration =
                        definitionCreator.functionDefinition(forUnit: unit, sign: sign, to: numeric)
                    if withImplementation {
                        let gen = creator.convert(unit.rawValue, from: unit, sign: sign, to: numeric)
                        createDeclaration(
                            comment: comment1,
                            declaration: declaration,
                            allDefinitions: &allDefinitions,
                            implementation: "return \(gen)"
                        )
                    } else {
                        createDeclaration(
                            comment: comment1,
                            declaration: declaration,
                            allDefinitions: &allDefinitions
                        )
                    }
                    let declaration2 =
                        definitionCreator.functionDefinition(from: numeric, to: unit, sign: sign)
                    if withImplementation {
                        let gen = creator.convert(unit.rawValue, from: numeric, to: unit, sign: sign)
                        createDeclaration(
                            comment: comment2,
                            declaration: declaration2,
                            allDefinitions: &allDefinitions,
                            implementation: "return \(gen)"
                        )
                    } else {
                        createDeclaration(
                            comment: comment2,
                            declaration: declaration2,
                            allDefinitions: &allDefinitions
                        )
                    }
                }
            }
            types.forEach { unit2 in
                Signs.allCases.forEach { sign1 in
                    Signs.allCases.forEach { sign2 in
                        if sign1 == sign2 {
                            guard unit != unit2 else {
                                return
                            }
                        }
                        let comment = generateDeclarationComment(
                            from: "\(unit)_\(sign1)", to: "\(unit2)_\(sign2)"
                        )
                        let declaration =
                            definitionCreator.functionDefinition(
                                forUnit: unit, to: unit2, sign: sign1, otherSign: sign2
                            )
                        var implementation: String?
                        if withImplementation {
                            let gen = creator.createFunction(
                                unit: unit, to: unit2, sign: sign1, otherSign: sign2
                            )
                            implementation = String("\(gen)".dropFirst(4))
                        }
                        createDeclaration(
                            comment: comment,
                            declaration: declaration,
                            allDefinitions: &allDefinitions,
                            implementation: implementation,
                            includeSemicolon: false
                        )
                    }
                }
            }
        }
        return allDefinitions
    }

    private func createDeclaration(
        comment: String,
        declaration: String,
        allDefinitions: inout [String],
        implementation: String? = nil,
        includeSemicolon: Bool = true
    ) {
        guard let implementation = implementation else {
            allDefinitions.append(comment + "\n" + declaration + ";")
            return
        }
        allDefinitions.append(
            comment + "\n" + declaration + "\n{\n    " +
                implementation + (includeSemicolon ? ";" : "") + "\n}"
        )
    }

    private func generateDeclarationComment(from: String, to: String) -> String {
        """
        /**
         * Convert \(from) to \(to).
         */
        """
    }

}
