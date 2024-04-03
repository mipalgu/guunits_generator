// SwiftTestFileCreator.swift 
// guunits_generator 
// 
// Created by Morgan McColl.
// Copyright © 2022 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.
// 

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Swift file creator for generating XCTest based files.
public struct SwiftTestFileCreator {

    /// Default init.
    public init() {}

    /// Generate the contents for a test file by using a given test generator.
    /// - Parameter generator: The generator creating the test parameters.
    /// - Returns: The contents of the test file.
    func generate<T: TestGenerator>(
        with generator: T
    ) -> [(String, String)] where T.UnitType: OperationalTestable {
        let prefix = prefix(name: "\(T.UnitType.category)Tests")
        let allTests = standardTests(with: generator) + relationTests(for: T.UnitType.self)
        return allTests.map {
            (
                $0,
                """
                \(prefix)

                \($1)
                """
            )
        }
    }

    /// Generate the contents for a test file by using a given test generator.
    /// - Parameter generator: The generator creating the test parameters.
    /// - Returns: The contents of the test file.
    func generate<T: TestGenerator>(with generator: T) -> [(String, String)] {
        let prefix = prefix(name: "\(T.UnitType.category)Tests")
        let allTests = standardTests(with: generator)
        return allTests.map {
            (
                $0,
                """
                \(prefix)

                \($1)
                """
            )
        }
    }

    /// Generate the tests for all conversion functions within the same category.
    /// - Parameter generator: The generator that creates the conversion functions.
    /// - Returns: An array of tuples containing the file name and the code within that file.
    private func standardTests<T: TestGenerator>(with generator: T) -> [(String, String)] {
        let valueTests = T.UnitType.allCases.flatMap { unit in
            Signs.allCases.flatMap { sign in
                createTestClass(from: unit, with: sign, using: generator)
            }
        }
        return typeTests(category: T.UnitType.self) + typeConversionTests(category: T.UnitType.self) +
            valueTests
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable closure_body_length

    /// Create the tests for the relationships within a type. This function will generate the test code
    /// for conversion between different category types.
    /// - Parameter type: The type containing the relationships.
    /// - Returns: An array of tuples containing the file name and the code that is within that file.
    private func relationTests<T: OperationalTestable>(for type: T.Type) -> [(String, String)] {
        let tests = T.relationTests
        guard !tests.isEmpty else {
            return []
        }
        return tests.sorted {
            $0.0.description < $1.0.description
        }
        .flatMap { conversion, parameters -> [String] in
            let relation: Relation = conversion.relation
            let sourceSign = conversion.sourceSign
            let target = relation.target
            let targetSign = conversion.targetSign
            let functionName = relation.name(sign: sourceSign, otherSign: targetSign)
            return parameters.group(size: 10)
            .enumerated()
            .map { index, tests in
                let units = relation.operation.units.sorted {
                    $0.description < $1.description
                }
                guard !units.isEmpty else {
                    fatalError("Invalid relation.")
                }
                let body = tests
                .enumerated()
                .map {
                    let indexStr = $0 > 0 ? "\($0)" : ""
                    let input = $1.input
                    let inputs: String
                    if units.count == 1, let firstUnit = units.first {
                        let typeName = "\(firstUnit.description.capitalized)_\(sourceSign.rawValue)"
                        inputs = "\(typeName)(\(input))"
                    } else {
                        inputs = units.map { unit in
                            let typeName = "\(unit.description.capitalized)_\(sourceSign.rawValue)"
                            return "\(unit.description): \(typeName)(\(input))"
                        }
                        .joined(separator: ", ")
                    }
                    let res = "\(target.description.capitalized)_\(targetSign.rawValue)(\(inputs))"
                    return """
                            let result\(indexStr) = \(res)
                            let expected\(indexStr) = \(functionName)(\($1.input))
                            XCTAssertEqual(result\(indexStr).rawValue, expected\(indexStr))
                    """
                }
                .joined(separator: "\n")
                return """
                    func test\(functionName)\(index > 0 ? "\(index)" : "")() {
                \(body)
                    }
                """
            }
        }
        .group(size: 30)
        .enumerated()
        .map { index, unitTests in
            let fileName = "\(T.category)RelationTests\(index)"
            let classDefinition = """
            final class \(fileName): XCTestCase {

            \(unitTests.joined(separator: "\n\n"))

            }
            """
            return (fileName, classDefinition)
        }
    }

    /// Provides additional tests for particular properties and method in the swift types of GUUnits.
    /// - Parameter category: The category under test.
    /// - Returns: The new tests.
    private func typeConversionTests<T>(category: T.Type) -> [(String, String)] where T: UnitProtocol {
        T.allCases.flatMap { unit -> [(String, String)] in
            let tests: [[String]] = Signs.allCases.flatMap { (sign: Signs) -> [String] in
                T.allCases.flatMap { (otherUnit: T) -> [String] in
                    Signs.allCases.flatMap { (otherSign: Signs) -> [String] in
                        guard sign != otherSign || unit != otherUnit else {
                            return []
                        }
                        return conversionTests(
                            from: unit,
                            with: sign,
                            to: otherUnit,
                            with: otherSign,
                            category: T.category
                        )
                    }
                    .filter { !$0.isEmpty }
                } + categoryTests(
                    from: unit, with: sign.rawValue, category: T.category
                )
            }
            .group(size: 30)
            return tests.enumerated().map { index, test -> (String, String) in
                let name = "\(unit.description.capitalized)ConversionTests\(index)"
                let testCode = test.joined(separator: "\n\n")
                return (
                    name,
                    """
                    final class \(name): XCTestCase {

                    \(testCode)

                    }

                    """
                )
            }
        }
    }

    // swiftlint:enable closure_body_length

    /// Creates category tests working with a unit type.
    /// - Parameters:
    ///   - unit: The unit to work with.
    ///   - sign: The sign of the unit.
    ///   - category: The category under test.
    /// - Returns: A string of tests that test the category with the unit type.
    private func categoryTests<T>(
        from unit: T, with sign: String, category: String
    ) -> [String] where T: UnitProtocol {
        let type = unit.description.capitalized + "_\(sign)"
        let lt = type.lowercased()
        return [
            """
                func test\(type)InitFromTypeEnum() {
                    let underlyingType = \(category).\(category)Types.\(lt)(5)
                    let category = \(category)(rawValue: underlyingType)
                    XCTAssertEqual(category.rawValue, underlyingType)
                }
            """
        ] + staticInitTests(unit: unit, sign: sign, category: category)
    }

    // swiftlint:disable closure_body_length

    /// Provides test functions for the category type working with a particular unit type.
    /// - Parameters:
    ///   - unit: The unit type contained within the category.
    ///   - sign: The sign of the unit type.
    ///   - category: The category.
    /// - Returns: Tests that test the properties and functions of the category with the unit type.
    private func staticInitTests<T>(
        unit: T, sign: String, category: String
    ) -> [String] where T: UnitProtocol {
        let type = unit.description.capitalized + "_\(sign)"
        return SwiftNumericTypes.allCases.flatMap {
            [
                """
                    func test\(category)\(type)\($0)Inits() {
                        let raw = \($0)(5)
                        let expected = \(category)(\(unit): raw)
                        let result = \(category).\(unit)(raw)
                        XCTAssertEqual(expected, result)
                        let ctype = \($0.numericType.abbreviation)_to_\(unit.abbreviation)_\(sign)(5)
                        let expected2 = \($0)(
                            \(unit.abbreviation)_\(sign)_to_\($0.numericType.abbreviation)(ctype)
                        )
                        let result2 = \($0)(expected)
                        XCTAssertEqual(result2, expected2)
                    }
                """,
                """
                    func test\(type)\($0)Inits() {
                        let raw = \($0)(5)
                        let ctype = \($0.numericType.abbreviation)_to_\(unit.abbreviation)_\(sign)(5)
                        let expected = \(type)(raw)
                        XCTAssertEqual(expected.rawValue, ctype)
                        XCTAssertEqual(
                            \($0)(expected),
                            \($0)(\(unit.abbreviation)_\(sign)_to_\($0.numericType.abbreviation)(ctype))
                        )
                    }
                """,
                """
                    func test\(type)\($0)RawValueInit() {
                        let raw = \(unit.description)_\(sign)(5)
                        let ctype = \(unit.abbreviation)_\(sign)_to_\($0.numericType.abbreviation)(raw)
                        let expected = \(type)(\($0)(ctype))
                        XCTAssertEqual(\(type)(rawValue: raw), expected)
                    }
                """,
                """
                    func test\(type)\(category)\($0)Init() {
                        let raw = \(type)(\($0)(5))
                        let category = \(category)(raw)
                        let expected = \(category)(rawValue: .\(type.lowercased())(raw))
                        XCTAssertEqual(category, expected)
                    }
                """
            ]
        }
    }

    // swiftlint:enable closure_body_length

    /// Creates tests for a generic conversion from 1 unit to the other.
    /// - Parameters:
    ///   - unit: The unit converting from.
    ///   - sign: The sign of the first unit.
    ///   - otherUnit: The unit converting to.
    ///   - otherSign: The sign of the second unit.
    ///   - category: The category these units belong to.
    /// - Returns: The tests performing the conversion.
    private func conversionTests<T>(
        from unit: T, with sign: Signs, to otherUnit: T, with otherSign: Signs, category: String
    ) -> [String] where T: UnitProtocol {
        let type = unit.description.capitalized + "_" + sign.rawValue
        let otherType = otherUnit.description.capitalized + "_" + otherSign.rawValue
        let category = category
        let ctype2 = "\(unit.abbreviation)_\(sign)_to_\(otherUnit.abbreviation)_\(otherSign)(ctype1)"
        return [
            """
                func test\(type)To\(otherType)\(category)Conversions() {
                    let original = \(type)(5)
                    let category = \(category)(original)
                    let other = category.\(otherUnit)_\(otherSign)
                    XCTAssertEqual(other, \(otherType)(original))
                }
            """,
            """
                func test\(otherType)To\(type)Conversions() {
                    let ctype1 = \(unit.description)_\(sign)(5)
                    let swiftType1 = \(type)(rawValue: ctype1)
                    let ctype2 = \(ctype2)
                    let swiftType2 = \(otherType)(rawValue: ctype2)
                    XCTAssertEqual(swiftType2, \(otherType)(swiftType1))
                }
            """
        ]
    }

    /// Additional tests needed to test the protocol conformances in the swift abstraction.
    /// - Parameter category: The unit category.
    /// - Returns: The new tests.
    private func typeTests<T>(category: T.Type) -> [(String, String)] where T: UnitProtocol {
        T.allCases.flatMap { type -> [(String, String)] in
            let tests: [String] = Signs.allCases.flatMap { sign -> [String] in
                let typeDef = "\(type.description.capitalized)_\(sign)"
                let rawType = sign.numericType.swiftType.rawValue
                let primitiveTests = sign.isFloatingPoint ?
                    typeFloatTests(type: typeDef, rawType: rawType) :
                    typeIntegerTests(type: typeDef, rawType: rawType)
                return typeGeneralTests(type: typeDef, rawType: rawType) + primitiveTests
            }
            return tests.group(size: 30).enumerated().map { index, test -> (String, String) in
                let name = "\(type.description.capitalized)TypeTests\(index)"
                let testCode = test.joined(separator: "\n\n")
                return (
                    name,
                    """
                    final class \(name): XCTestCase {

                    \(testCode)

                    }

                    """
                )
            }
        }
    }

    /// Tests that are common to both integer and floating point types.
    /// - Parameter type: The type.
    /// - Returns: The new tests.
    private func typeGeneralTests(type: String, rawType: String) -> [String] {
        [
            """
                func test\(type)Equality() {
                    XCTAssertEqual(\(type)(5), \(type)(5))
                }
            """,
            """
                func test\(type)Coding() throws {
                    let encoder = JSONEncoder()
                    let decoder = JSONDecoder()
                    let original = \(type)(10)
                    XCTAssertEqual(
                        original,
                        try decoder.decode(\(type).self, from: try encoder.encode(original))
                    )
                }
            """,
            """
                func test\(type)SelfInit() {
                    let expected = \(type)(15)
                    XCTAssertEqual(expected, \(type)(expected))
                }
            """,
            """
                func test\(type)SelfExactlyInit() {
                    let expected = \(type)(15)
                    XCTAssertEqual(expected, \(type)(exactly: expected))
                }
            """,
            """
                func test\(type)Comparable() {
                    let lhs = \(type)(1)
                    let rhs = \(type)(100)
                    XCTAssertLessThan(lhs, rhs)
                }
            """
        ]
    }

    /// Additional tests needed for testing the integer protocol conformances.
    /// - Parameters:
    ///   - type: The type of the parent struct conforming to the BinaryInteger protocol.
    ///   - rawType: The raw type of the parent protocol as a swift type.
    /// - Returns: The tests.
    private func typeIntegerTests(type: String, rawType: String) -> [String] {
        [
            """
                func test\(type)Magnitude() {
                    let expected = \(rawType)(5).magnitude
                    XCTAssertEqual(\(type)(5).magnitude, expected)
                }
            """,
            """
                func test\(type)TruncatingInit() {
                    let expected = \(type)(\(rawType)(truncatingIfNeeded: UInt64.max))
                    XCTAssertEqual(\(type)(truncatingIfNeeded: expected), expected)
                }
            """,
            """
                func test\(type)ClampingInit() {
                    let expected = \(type)(\(rawType)(clamping: UInt64.max))
                    XCTAssertEqual(\(type)(clamping: expected), expected)
                }
            """,
            """
                func test\(type)BitWidth() {
                    let expected = \(rawType)(5).bitWidth
                    XCTAssertEqual(\(type)(5).bitWidth, expected)
                }
            """,
            """
                func test\(type)LeadingZeroBitCount() {
                    let expected = \(rawType)(5).leadingZeroBitCount
                    XCTAssertEqual(\(type)(5).leadingZeroBitCount, expected)
                }
            """,
            """
                func test\(type)NonzeroBitCount() {
                    let expected = \(rawType)(5).nonzeroBitCount
                    XCTAssertEqual(\(type)(5).nonzeroBitCount, expected)
                }
            """,
            """
                func test\(type)IntegerLiteralInit() {
                    let expected = \(rawType)(integerLiteral: \(rawType).max)
                    XCTAssertEqual(\(type)(expected), \(type)(integerLiteral: \(rawType).max))
                }
            """,
            """
                func test\(type)TruncatingBits() {
                    let expected = \(type)(\(rawType)(_truncatingBits: UInt.max))
                    XCTAssertEqual(expected, \(type)(_truncatingBits: UInt.max))
                }
            """,
            """
                func test\(type)Addition() {
                    let expected = \(type)(\(rawType)(5) + \(rawType)(3))
                    XCTAssertEqual(\(type)(5) + \(type)(3), expected)
                }
            """,
            """
                func test\(type)Subtraction() {
                    let expected = \(type)(\(rawType)(5) - \(rawType)(3))
                    XCTAssertEqual(\(type)(5) - \(type)(3), expected)
                }
            """,
            """
                func test\(type)Multiplication() {
                    let expected = \(type)(\(rawType)(5) * \(rawType)(3))
                    XCTAssertEqual(\(type)(5) * \(type)(3), expected)
                }
            """,
            """
                func test\(type)Division() {
                    let expected = \(type)(\(rawType)(6) / \(rawType)(3))
                    XCTAssertEqual(\(type)(6) / \(type)(3), expected)
                }
            """,
            """
                func test\(type)AddOverflow() {
                    let rawOriginal = \(rawType).max
                    let rawResult = rawOriginal.addingReportingOverflow(\(rawType)(1))
                    let original = \(type)(rawOriginal)
                    let result = original.addingReportingOverflow(\(type)(1))
                    XCTAssertEqual(result.0, \(type)(rawResult.0))
                    XCTAssertEqual(result.1, rawResult.1)
                    XCTAssertTrue(result.1)
                }
            """,
            """
                func test\(type)MultiplyOverflow() {
                    let rawOriginal = \(rawType).max
                    let rawResult = rawOriginal.multipliedReportingOverflow(by: \(rawType)(2))
                    let original = \(type)(rawOriginal)
                    let result = original.multipliedReportingOverflow(by: \(type)(2))
                    XCTAssertEqual(result.0, \(type)(rawResult.0))
                    XCTAssertEqual(result.1, rawResult.1)
                    XCTAssertTrue(result.1)
                }
            """,
            """
                func test\(type)SubtractOverflow() {
                    let rawOriginal = \(rawType).min
                    let rawResult = rawOriginal.subtractingReportingOverflow(\(rawType)(1))
                    let original = \(type)(rawOriginal)
                    let result = original.subtractingReportingOverflow(\(type)(1))
                    XCTAssertEqual(result.0, \(type)(rawResult.0))
                    XCTAssertEqual(result.1, rawResult.1)
                    XCTAssertTrue(result.1)
                }
            """,
            """
                func test\(type)DivideOverflow() {
                    let rawOriginal = \(rawType)(1)
                    let rawResult = rawOriginal.dividedReportingOverflow(by: \(rawType).max)
                    let original = \(type)(rawOriginal)
                    let result = original.dividedReportingOverflow(by: \(type)(\(rawType).max))
                    XCTAssertEqual(result.0, \(type)(rawResult.0))
                    XCTAssertEqual(result.1, rawResult.1)
                }
            """,
            """
                func test\(type)RemainderOverflow() {
                    let rawOriginal = \(rawType)(1)
                    let rawResult = rawOriginal.remainderReportingOverflow(dividingBy: \(rawType).max)
                    let original = \(type)(rawOriginal)
                    let result = original.remainderReportingOverflow(dividingBy: \(type)(\(rawType).max))
                    XCTAssertEqual(result.0, \(type)(rawResult.0))
                    XCTAssertEqual(result.1, rawResult.1)
                }
            """,
            """
                func test\(type)TrailingZeroBitCount() {
                    let original = \(rawType)(1)
                    XCTAssertEqual(\(type)(original).trailingZeroBitCount, original.trailingZeroBitCount)
                }
            """,
            """
                func test\(type)TimesEquals() {
                    var original = \(rawType)(2)
                    original *= 4
                    var result = \(type)(\(rawType)(2))
                    result *= 4
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)DivideEquals() {
                    var original = \(rawType)(4)
                    original /= 2
                    var result = \(type)(\(rawType)(4))
                    result /= 2
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)ModEquals() {
                    var original = \(rawType)(4)
                    original %= 2
                    var result = \(type)(\(rawType)(4))
                    result %= 2
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)AndEquals() {
                    var original = \(rawType)(2)
                    original &= 6
                    var result = \(type)(\(rawType)(2))
                    result &= 6
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)OrEquals() {
                    var original = \(rawType)(2)
                    original |= 4
                    var result = \(type)(\(rawType)(2))
                    result |= 4
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)HatEquals() {
                    var original = \(rawType)(2)
                    original ^= 4
                    var result = \(type)(\(rawType)(2))
                    result ^= 4
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)Mod() {
                    let original = \(rawType)(4)
                    let expected = \(type)(original % 2)
                    XCTAssertEqual(\(type)(original) % 2, expected)
                }
            """
        ]
    }

    /// Provided additional tests for testing the parent swift struct that represents
    /// a GUUnits floating point unit.
    /// - Parameters:
    ///   - type: The type of the parent struct conforming to BinaryFloatingPoint.
    ///   - rawType: The raw type of the parent struct.
    /// - Returns: The new tests.
    private func typeFloatTests(type: String, rawType: String) -> [String] {
        [
            """
                func test\(type)Radix() {
                    XCTAssertEqual(\(type).radix, \(rawType).radix)
                }
            """,
            """
                func test\(type)ExponentBitCount() {
                    XCTAssertEqual(\(type).exponentBitCount, \(rawType).exponentBitCount)
                }
            """,
            """
                func test\(type)SignificandBitCount() {
                    XCTAssertEqual(\(type).significandBitCount, \(rawType).significandBitCount)
                }
            """,
            """
                func test\(type)Magnitude() {
                    let expected = \(type)(\(rawType)(5).magnitude)
                    XCTAssertEqual(\(type)(5).magnitude, expected)
                }
            """,
            """
                func test\(type)ExactlyInit() {
                    let expected = \(type)(\(rawType)(exactly: Int(5)) ?? \(rawType).infinity)
                    XCTAssertEqual(\(type)(exactly: Int(5)), expected)
                }
            """,
            """
                func test\(type)IsTotallyOrdered() {
                    let param = \(rawType)(100)
                    let other = \(rawType)(5)
                    XCTAssertEqual(
                        \(type)(param).isTotallyOrdered(belowOrEqualTo: \(type)(other)),
                        param.isTotallyOrdered(belowOrEqualTo: other)
                    )
                }
            """,
            """
                func test\(type)Binade() {
                    let raw = \(rawType)(5)
                    let expected = \(type)(raw.binade)
                    XCTAssertEqual(\(type)(raw).binade, expected)
                }
            """,
            """
                func test\(type)SignificandWidth() {
                    let raw = \(rawType)(5)
                    XCTAssertEqual(\(type)(raw).significandWidth, raw.significandWidth)
                }
            """,
            """
                func test\(type)DebugDescription() {
                    let raw = \(rawType)(5)
                    XCTAssertEqual(\(type)(raw).debugDescription, raw.debugDescription)
                }
            """,
            """
                func test\(type)DescriptionInit() {
                    let raw = \(rawType)(\"5.0\") ?? \(rawType).nan
                    XCTAssertEqual(\(type)(\"5.0\"), \(type)(raw))
                }
            """,
            """
                func test\(type)StaticVars() {
                    XCTAssertEqual(\(type).nan.isNaN, \(type)(\(rawType).nan).isNaN)
                    XCTAssertEqual(
                        \(type).signalingNaN.isSignalingNaN,
                        \(type)(\(rawType).signalingNaN).isSignalingNaN
                    )
                    XCTAssertEqual(\(type).infinity, \(type)(\(rawType).infinity))
                    XCTAssertEqual(
                        \(type).greatestFiniteMagnitude,\(type)(\(rawType).greatestFiniteMagnitude)
                    )
                    XCTAssertEqual(\(type).pi, \(type)(\(rawType).pi))
                    XCTAssertEqual(\(type).leastNormalMagnitude, \(type)(\(rawType).leastNormalMagnitude))
                    XCTAssertEqual(\(type).leastNonzeroMagnitude, \(type)(\(rawType).leastNonzeroMagnitude))
                }
            """,
            """
                func test\(type)Ulp() {
                    let raw = \(rawType)(5)
                    XCTAssertEqual(\(type)(raw).ulp, \(type)(raw.ulp))
                }
            """,
            """
                func test\(type)Sign() {
                    let raw = \(rawType)(5)
                    XCTAssertEqual(\(type)(raw).sign, raw.sign)
                }
            """,
            """
                func test\(type)Significand() {
                    let raw = \(rawType)(5)
                    XCTAssertEqual(\(type)(raw).significand, \(type)(raw.significand))
                }
            """,
            """
                func test\(type)NextUp() {
                    let raw = \(rawType)(5)
                    XCTAssertEqual(\(type)(raw).nextUp, \(type)(raw.nextUp))
                }
            """,
            """
                func test\(type)Vars() {
                    XCTAssertEqual(\(type)(5).isNormal, \(rawType)(5).isNormal)
                    XCTAssertEqual(\(type)(5).isFinite, \(rawType)(5).isFinite)
                    XCTAssertEqual(\(type)(5).isZero, \(rawType)(5).isZero)
                    XCTAssertEqual(\(type)(0).isZero, \(rawType)(0).isZero)
                    XCTAssertEqual(\(type)(5).isSubnormal, \(rawType)(5).isSubnormal)
                    XCTAssertEqual(\(type)(5).isInfinite, \(rawType)(5).isInfinite)
                    XCTAssertEqual(\(type).infinity.isInfinite, \(rawType).infinity.isInfinite)
                    XCTAssertEqual(\(type)(5).isNaN, \(rawType)(5).isNaN)
                    XCTAssertEqual(\(type).nan.isNaN, \(rawType).nan.isNaN)
                    XCTAssertEqual(\(type)(5).isSignalingNaN, \(rawType)(5).isSignalingNaN)
                    XCTAssertEqual(\(type).nan.isSignalingNaN, \(rawType).nan.isSignalingNaN)
                    XCTAssertEqual(\(type)(5).isCanonical, \(rawType)(5).isCanonical)
                    XCTAssertEqual(\(type)(5).description, \(rawType)(5).description)
                    XCTAssertEqual(\(type)(5).exponentBitPattern, \(rawType)(5).exponentBitPattern)
                    XCTAssertEqual(\(type)(5).significandBitPattern, \(rawType)(5).significandBitPattern)
                    XCTAssertEqual(\(type)(5).exponent, \(rawType)(5).exponent)
                }
            """,
            """
                func test\(type)FormRemainder() {
                    var original = \(rawType)(4)
                    let denominator = \(rawType)(3)
                    original.formRemainder(dividingBy: denominator)
                    var result = \(type)(\(rawType)(4))
                    result.formRemainder(dividingBy: \(type)(denominator))
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)FormTruncatingRemainder() {
                    var original = \(rawType)(4)
                    let denominator = \(rawType)(3)
                    original.formTruncatingRemainder(dividingBy: denominator)
                    var result = \(type)(\(rawType)(4))
                    result.formTruncatingRemainder(dividingBy: \(type)(denominator))
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)FormSquareRoot() {
                    var original = \(rawType)(4)
                    original.formSquareRoot()
                    var result = \(type)(\(rawType)(4))
                    result.formSquareRoot()
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)AddProduct() {
                    var original = \(rawType)(4)
                    let lhs = \(rawType)(3)
                    let rhs = \(rawType)(5)
                    original.addProduct(lhs, rhs)
                    var result = \(type)(\(rawType)(4))
                    result.addProduct(\(type)(lhs), \(type)(rhs))
                    XCTAssertEqual(result, \(type)(original))
                }
            """,
            """
                func test\(type)IsEqual() {
                    let this = \(type)(5)
                    let other = \(type)(6)
                    XCTAssertTrue(this.isEqual(to: this))
                    XCTAssertFalse(this.isEqual(to: other))
                }
            """,
            """
                func test\(type)IsLess() {
                    let this = \(type)(5)
                    let other = \(type)(6)
                    XCTAssertFalse(this.isLess(than: this))
                    XCTAssertTrue(this.isLess(than: other))
                }
            """,
            """
                func test\(type)IsLessThanOrEqual() {
                    let this = \(type)(5)
                    let other = \(type)(6)
                    let other2 = \(type)(4)
                    XCTAssertTrue(this.isLessThanOrEqualTo(this))
                    XCTAssertTrue(this.isLessThanOrEqualTo(other))
                    XCTAssertFalse(this.isLessThanOrEqualTo(other2))
                }
            """,
            """
                func test\(type)Operations() {
                    let lhs = \(type)(6)
                    let rhs = \(type)(3)
                    XCTAssertEqual(lhs + rhs, \(type)(9))
                    XCTAssertEqual(lhs - rhs, \(type)(3))
                    XCTAssertEqual(lhs * rhs, \(type)(18))
                    XCTAssertEqual(lhs / rhs, \(type)(2))
                }
            """,
            """
                func test\(type)TimesEqual() {
                    var this = \(type)(3)
                    this *= \(type)(4)
                    XCTAssertEqual(this, \(type)(12))
                }
            """,
            """
                func test\(type)DivideEqual() {
                    var this = \(type)(6)
                    this /= \(type)(3)
                    XCTAssertEqual(this, \(type)(2))
                }
            """,
            """
                func test\(type)Round() {
                    var expected = \(rawType)(5.6)
                    expected.round(.up)
                    var result = \(type)(5.6)
                    result.round(.up)
                    XCTAssertEqual(result, \(type)(expected))
                }
            """,
            """
                func test\(type)DistanceTo() {
                    let original = \(rawType)(5.0)
                    let other = \(rawType)(23)
                    let expected = original.distance(to: other)
                    XCTAssertEqual(\(type)(original).distance(to: \(type)(other)), expected)
                }
            """,
            """
                func test\(type)AdvancedBy() {
                    let original = \(rawType)(5)
                    let expected = original.advanced(by: 3)
                    XCTAssertEqual(\(type)(original).advanced(by: 3), \(type)(expected))
                }
            """
        ]
    }

    // swiftlint:enable function_body_length

    /// Creates a class containing test for a given unit and sign.
    /// - Parameters:
    ///   - unit: The unit to convert from in the unit tests.
    ///   - sign: The sign of the unit.
    ///   - generator: The generator creating the test parameters.
    /// - Returns: The Swift class enacting the unit tests.
    private func createTestClass<T: TestGenerator>(
        from unit: T.UnitType, with sign: Signs, using generator: T
    ) -> [(String, String)] {
        let testCases: [String] = Signs.allCases.flatMap { otherSign in
            T.UnitType.allCases.flatMap { otherUnit -> [String] in
                guard (sign != otherSign) || (unit != otherUnit) else {
                    return []
                }
                let tests = generator
                    .testParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
                    .group(size: 10)
                return tests.enumerated().map { index, test in
                    createTest(
                        from: unit, with: sign, to: otherUnit, with: otherSign, and: test, index: index
                    )
                }
            }
            .filter { !$0.isEmpty }
        }
        let numericTests: [String] = NumericTypes.allCases.flatMap { numeric -> [String] in
            generator.testParameters(from: unit, with: sign, to: numeric)
            .group(size: 10)
            .enumerated()
            .map { index, toTest in
                createTest(from: unit, with: sign, to: numeric, and: toTest, index: index)
            } + generator.testParameters(from: numeric, to: unit, with: sign)
            .group(size: 10)
            .enumerated()
            .map { index, fromTest in
                createTest(from: numeric, to: unit, with: sign, and: fromTest, index: index)
            }
        }
        return (testCases + numericTests).group(size: 30).enumerated().map { index, group in
            let testCode = group.joined(separator: "\n\n")
            let name = "\(unit.rawValue.capitalized)_\(sign)Tests\(index)"
            return (
                name,
                """
                /// Provides \(unit.rawValue.lowercased())_\(sign) unit tests.
                final class \(name): XCTestCase {

                \(testCode)

                }

                """
            )
        }
    }

    // swiftlint:disable function_parameter_count
    // swiftlint:disable function_body_length
    // swiftlint:disable closure_body_length

    /// Create a test case for a unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    ///   - parameters: The parameters used in the test.
    /// - Returns: The swift code performing the test.
    private func createTest<T: UnitProtocol>(
        from unit: T,
        with sign: Signs,
        to otherUnit: T,
        with otherSign: Signs,
        and parameters: [TestParameters],
        index: Int
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let creator = TestFunctionBodyCreator<T>()
        let helper = FunctionHelpers<T>()
        let fnTestName = "test\(unit.description)_\(sign.rawValue)To" +
            "\(otherUnit.description)_\(otherSign.rawValue)\(index > 0 ? "\(index)" : "")"
        let fnName = helper.functionName(
            forUnit: unit, to: otherUnit, sign: sign, otherSign: otherSign, unique: true
        )
        let body = parameters
        .enumerated()
        .map {
            let indexStr = $0 > 0 ? "\($0)" : ""
            let unit = "\(unit.rawValue.capitalized)_\(sign)(\($1.input))"
            let conversion = "\(otherUnit.rawValue.capitalized)_\(otherSign)(unit\(indexStr))"
            if $1.input == "Double.greatestFiniteMagnitude" ||
                $1.input == "-Double.greatestFiniteMagnitude" {
                return """
                        let unit\(indexStr) = \(unit)
                        let expected\(indexStr) = \(fnName)(\($1.input))
                        let result\(indexStr) = \(conversion).rawValue
                        XCTAssertEqual(expected\(indexStr), result\(indexStr))
                """
            }
            let tolerance = creator.sanitiseLiteral(literal: "1", sign: otherSign)
            let categoryConversion = "\(T.category)(unit\(indexStr)).\(otherUnit.rawValue)_\(otherSign)"
            let catResult = "categoryResult\(indexStr)"
            return """
                    let unit\(indexStr) = \(unit)
                    let expected\(indexStr) = \(fnName)(\($1.input))
                    let result\(indexStr) = \(conversion).rawValue
                    XCTAssertEqual(expected\(indexStr), result\(indexStr))
                    let tolerance\(indexStr): \(otherUnit.rawValue)_\(otherSign) = \(tolerance)
                    let categoryResult\(indexStr) = \(categoryConversion).rawValue
                    if \(catResult) > expected\(indexStr) {
                        XCTAssertLessThanOrEqual(\(catResult) - expected\(indexStr), tolerance\(indexStr))
                    } else {
                        XCTAssertLessThanOrEqual(expected\(indexStr) - \(catResult), tolerance\(indexStr))
                    }
            """
        }
        .joined(separator: "\n")
        return """
            func \(fnTestName)() {
        \(body)
            }
        """
    }

    // swiftlint:enable function_parameter_count
    // swiftlint:enable function_body_length
    // swiftlint:enable closure_body_length

    /// Create a unit test for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    ///   - parameters: The parameters used in the test.
    /// - Returns: The swift code enacting the test.
    private func createTest<T: UnitProtocol>(
        from unit: T,
        with sign: Signs,
        to numeric: NumericTypes,
        and parameters: [TestParameters],
        index: Int
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let helper = FunctionHelpers<T>()
        let fnTestName = "test\(unit.description)_\(sign.rawValue)To" +
            "\(numeric.swiftType)\(index > 0 ? "\(index)" : "")"
        let fnName = helper.functionName(forUnit: unit, sign: sign, to: numeric, unique: true)
        let body = parameters
        .enumerated()
        .map {
            let indexStr = $0 > 0 ? "\($0)" : ""
            let initialiser = "\(unit.rawValue.capitalized)_\(sign.rawValue)(\($1.input))"
            return """
                    let expected\(indexStr) = \(fnName)(\($1.input))
                    let result\(indexStr) = \(numeric.swiftType)(\(initialiser))
                    XCTAssertEqual(expected\(indexStr), result\(indexStr))
            """
        }
        .joined(separator: "\n")
        return """
            func \(fnTestName)() {
        \(body)
            }
        """
    }

    /// Create a unit test for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    ///   - parameters: The parameters used in the test.
    /// - Returns: The swift code enacting the unit test.
    private func createTest<T: UnitProtocol>(
        from numeric: NumericTypes,
        to unit: T,
        with sign: Signs,
        and parameters: [TestParameters],
        index: Int
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let helper = FunctionHelpers<T>()
        let fnTestName = "test\(numeric.swiftType)To\(unit.description)_\(sign.rawValue)" +
            "\(index > 0 ? "\(index)" : "")"
        let fnName = helper.functionName(from: numeric, to: unit, sign: sign, unique: true)
        let unitType = "\(unit.rawValue.capitalized)_\(sign.rawValue)"
        let body = parameters
        .enumerated()
        .map {
            let indexStr = $0 > 0 ? "\($0)" : ""
            let initialiser = "\(unitType)(\(numeric.swiftType)(\($1.input)))"
            return """
                    let expected\(indexStr) = \(fnName)(\($1.input))
                    let result\(indexStr) = \(initialiser).rawValue
                    XCTAssertEqual(expected\(indexStr), result\(indexStr))
            """
        }
        .joined(separator: "\n")
        return """
            func \(fnTestName)() {
        \(body)
            }
        """
    }

    // swiftlint:disable function_body_length

    /// The header that appears at the top of the swift file.
    /// - Parameter name: The name of the file.
    /// - Returns: The `String` contents of the header.
    private func prefix(name: String) -> String {
        """
        /*
        * \(name).swift
        * GUUnitsTests
        *
        * Created by Callum McColl on 05/06/2019.
        * Copyright © 2019 Callum McColl. All rights reserved.
        *
        * Redistribution and use in source and binary forms, with or without
        * modification, are permitted provided that the following conditions
        * are met:
        *
        * 1. Redistributions of source code must retain the above copyright
        *    notice, this list of conditions and the following disclaimer.
        *
        * 2. Redistributions in binary form must reproduce the above
        *    copyright notice, this list of conditions and the following
        *    disclaimer in the documentation and/or other materials
        *    provided with the distribution.
        *
        * 3. All advertising materials mentioning features or use of this
        *    software must display the following acknowledgement:
        *
        *        This product includes software developed by Callum McColl.
        *
        * 4. Neither the name of the author nor the names of contributors
        *    may be used to endorse or promote products derived from this
        *    software without specific prior written permission.
        *
        * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
        * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
        * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
        * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
        * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
        * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
        * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
        * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
        * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
        * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        *
        * -----------------------------------------------------------------------
        * This program is free software; you can redistribute it and/or
        * modify it under the above terms or under the terms of the GNU
        * General Public License as published by the Free Software Foundation;
        * either version 2 of the License, or (at your option) any later version.
        *
        * This program is distributed in the hope that it will be useful,
        * but WITHOUT ANY WARRANTY; without even the implied warranty of
        * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        * GNU General Public License for more details.
        *
        * You should have received a copy of the GNU General Public License
        * along with this program; if not, see http://www.gnu.org/licenses/
        * or write to the Free Software Foundation, Inc., 51 Franklin Street,
        * Fifth Floor, Boston, MA  02110-1301, USA.
        *
        */

        import CGUUnits
        @testable import GUUnits
        import XCTest
        """
    }

    // swiftlint:enable function_body_length

}
// swiftlint:enable type_body_length
// swiftlint:enable file_length
