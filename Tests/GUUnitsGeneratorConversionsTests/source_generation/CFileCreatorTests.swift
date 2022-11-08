@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for CFileCreator.
final class CFileCreatorTests: XCTestCase {

    /// Mock class for keeping track of how functions are called.
    class MockUnitGenerator: UnitsGeneratable {

        // swiftlint:disable nesting

        /// Using distance units for mock.
        typealias Unit = DistanceUnits

        // swiftlint:enable nesting

        /// Gen function implementation and declaration.
        fileprivate let magicString = "MAGIC!"

        /// The last parameters passed to the generateDeclarations function.
        fileprivate var lastDeclarationCall: [DistanceUnits] = []

        /// The last parameters passed to the generateImplementations function.
        fileprivate var lastImplementationCall: [DistanceUnits] = []

        /// Generate fake function declarations.
        /// - Parameter units: The units to generate.
        /// - Returns: A mock string.
        func generateDeclarations(forUnits units: [DistanceUnits]) -> String? {
            lastDeclarationCall = units
            return magicString
        }

        /// Generate fake function implementations.
        /// - Parameter units: The units to generate functions for.
        /// - Returns: A mock string.
        func generateImplementations(forUnits units: [DistanceUnits]) -> String? {
            lastImplementationCall = units
            return magicString
        }

    }

    /// The creator being tested.
    let creator = CFileCreator(prefix: "prefix")

    /// The suffix which appears at the end of the file.
    var suffix: String {
        [NumericTypes.double, NumericTypes.float].flatMap { type in
            NumericTypes.allCases.compactMap { otherType in
                defineFloatConversion(type.rawValue, from: type, to: otherType)
            }
        }
        .joined(separator: "\n\n")
    }

    /// Create the numeric conversion functions from a floating point type to another numeric type.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - type: The type of the `str` value. This type must be a double or float.
    ///   - otherType: The type to convert to. This type is usually an integral type, however this type
    ///                may also be a float when `type` is a double.
    /// - Returns: The function definition and implementation that performs the conversion.
    private func defineFloatConversion(
        _ str: String,
        from type: NumericTypes,
        to otherType: NumericTypes
    ) -> String? {
        guard (type.isFloat && !otherType.isFloat) || (type == .double && otherType == .float) else {
            return nil
        }
        let roundLiteral = "\(str)Val"
        var roundedString = ""
        if !otherType.isFloat {
            if type == .float {
                roundedString = "const \(type.rawValue) roundedValue = roundf(\(roundLiteral));"
            } else {
                roundedString = "const \(type.rawValue) roundedValue = round(\(roundLiteral));"
            }
        }
        let nextToward = type == .float ? "nexttowardf" : "nexttoward"
        let upperLimit = self.sanitise(literal: otherType.limits.1, to: type)
        let lowerLimit = self.sanitise(literal: otherType.limits.0, to: type)
        let firstLine = "\(otherType.rawValue) \(type.abbreviation)_to_" +
            "\(otherType.abbreviation)(\(type.rawValue) \(str)Val) {"
        let line2 = "const \(type.rawValue) maxValue = " +
            "\(nextToward)(((\(type.rawValue)) (\(upperLimit))), 0.0);"
        let nextLines = !roundedString.isEmpty ? roundedString + "\n" + line2 : line2
        let trailer = """
            const \(type.rawValue) minValue = \(nextToward)(((\(type.rawValue)) (\(lowerLimit))), 0.0);
            if (\(roundedString.isEmpty ? roundLiteral : "roundedValue") > maxValue) {
                return \(otherType.limits.1);
            } else if (\(roundedString.isEmpty ? roundLiteral : "roundedValue") < minValue) {
                return \(otherType.limits.0);
            } else {
                return ((\(otherType.rawValue)) (\(roundedString.isEmpty ? roundLiteral : "roundedValue")));
            }
        }
        """
        return firstLine +
            nextLines.components(separatedBy: .newlines).reduce(into: "") { $0 = $0 + "\n    " + $1 } +
            "\n" +
            trailer
    }

    /// Convert literals into a value suitable for a specific numeric type. For example converting 0 to 0.0
    /// for a double literal.
    /// - Parameters:
    ///   - literal: The literal to sanitise.
    ///   - type: The type to transform it into.
    /// - Returns: The sanitised literal.
    private func sanitise(literal: String, to type: NumericTypes) -> String {
        guard
            !literal.contains(where: {
                guard let scalar = Unicode.Scalar(String($0)) else {
                    return true
                }
                return !(CharacterSet.decimalDigits.contains(scalar) || $0 == "." || $0 == "-")
            }),
            literal.filter({ $0 == "." }).count <= 1,
            literal.filter({ $0 == "-" }).count <= 1,
            let firstChar = literal.first,
            literal.contains("-") ? firstChar == "-" : true
        else {
            return literal
        }
        let hasDecimal = literal.contains(".")
        switch type {
        case .float:
            guard hasDecimal else {
                return "\(literal).0f"
            }
            return "\(literal)f"
        case .double:
            guard hasDecimal else {
                return "\(literal).0"
            }
            return literal
        default:
            guard hasDecimal else {
                return literal
            }
            return "round((double) (\(literal)))"
        }
    }

    /// Test generate function creates all c functions.
    func testGenerate() {
        let generator = MockUnitGenerator()
        let result = creator.generate(
            generators: [AnyGenerator(generating: DistanceUnits.self, using: generator)]
        )
        XCTAssertEqual(generator.lastDeclarationCall, [])
        XCTAssertEqual(generator.lastImplementationCall, Array(DistanceUnits.allCases))
        let expected = """
        prefix

        \(creator.mathDefinitions)

        \(generator.magicString)

        \(suffix)

        \(creator.mathFunctions)

        """
        XCTAssertEqual(result, expected)
    }

}
