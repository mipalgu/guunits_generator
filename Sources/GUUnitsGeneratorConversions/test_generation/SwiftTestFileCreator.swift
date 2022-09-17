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

// swiftlint:disable type_body_length

/// Swift file creator for generating XCTest based files.
public struct SwiftTestFileCreator {

    /// Default init.
    public init() {}

    /// Generate the contents for a test file by using a given test generator.
    /// - Parameter generator: The generator creating the test parameters.
    /// - Returns: The contents of the test file.
    func generate<T: TestGenerator>(with generator: T) -> String {
        prefix(name: "\(T.UnitType.category)Tests") + "\n\n" + typeTests(category: T.UnitType.self) +
            T.UnitType.allCases.flatMap { unit in
                Signs.allCases.map { sign in
                    createTestClass(from: unit, with: sign, using: generator)
                }
            }
            .joined(separator: "\n\n") + "\n"
    }

    /// Additional tests needed to test the protocol conformances in the swift abstraction.
    /// - Parameter category: The unit category.
    /// - Returns: The new tests.
    private func typeTests<T>(category: T.Type) -> String where T: UnitProtocol {
        T.allCases.map { type in
            let tests = Signs.allCases.map { sign in
                let typeDef = "\(type.description.capitalized)_\(sign)"
                let primitiveTests = sign.isFloatingPoint ?
                    typeFloatTests(type: typeDef, rawType: sign.numericType.swiftType.rawValue) :
                    typeIntegerTests(type: typeDef, rawType: sign.numericType.swiftType.rawValue)
                return """
                \(typeGeneralTests(type: typeDef))

                \(primitiveTests)
                """
            }
            .joined(separator: "\n\n")
            return """
            final class \(type.description.capitalized)TypeTests: XCTestCase {

            \(tests)

            }
            """
        }
        .joined(separator: "\n\n")
    }

    /// Tests that are common to both integer and floating point types.
    /// - Parameter type: The type.
    /// - Returns: The new tests.
    private func typeGeneralTests(type: String) -> String {
        """
            func test\(type)Equality() {
                XCTAssertEqual(\(type)(5), \(type)(5))
            }

            func test\(type)Coding() throws {
                let encoder = JSONEncoder()
                let decoder = JSONDecoder()
                let original = \(type)(10)
                XCTAssertEqual(
                    original,
                    try decoder.decode(\(type).self, from: try encoder.encode(original))
                )
            }

            func test\(type)SelfInit() {
                let expected = \(type)(15)
                XCTAssertEqual(expected, \(type)(expected))
            }

            func test\(type)SelfExactlyInit() {
                let expected = \(type)(15)
                XCTAssertEqual(expected, \(type)(exactly: expected))
            }

            func test\(type)Comparable() {
                let lhs = \(type)(1)
                let rhs = \(type)(100)
                XCTAssertLessThan(lhs, rhs)
            }
        """
    }

    // swiftlint:disable function_body_length

    /// Additional tests needed for testing the integer protocol conformances.
    /// - Parameters:
    ///   - type: The type of the parent struct conforming to the BinaryInteger protocol.
    ///   - rawType: The raw type of the parent protocol as a swift type.
    /// - Returns: The tests.
    private func typeIntegerTests(type: String, rawType: String) -> String {
        """
            func test\(type)ExactlyInit() {
                let expected = \(type)(15)
                XCTAssertEqual(expected, \(type)(exactly: 15))
            }

            func test\(type)TruncatingInit() {
                let expected = \(rawType)(truncatingIfNeeded: UInt64.max)
                XCTAssertEqual(\(type)(truncatingIfNeeded: UInt64.max), \(type)(expected))
            }

            func test\(type)ClampingInit() {
                let expected = \(rawType)(clamping: UInt64.max)
                XCTAssertEqual(\(type)(clamping: UInt64.max), \(type)(expected))
            }

            func test\(type)BitWidth() {
                let expected = \(rawType)(5).bitWidth
                XCTAssertEqual(\(type)(5).bitWidth, expected)
            }

            func test\(type)LeadingZeroBitCount() {
                let expected = \(rawType)(5).leadingZeroBitCount
                XCTAssertEqual(\(type)(5).leadingZeroBitCount, expected)
            }

            func test\(type)NonzeroBitCount() {
                let expected = \(rawType)(5).nonzeroBitCount
                XCTAssertEqual(\(type)(5).nonzeroBitCount, expected)
            }

            func test\(type)Magnitude() {
                let expected = \(rawType)(5).magnitude
                XCTAssertEqual(\(type)(5).magnitude, expected)
            }

            func test\(type)IntegerLiteralInit() {
                let expected = \(rawType)(integerLiteral: \(rawType).max)
                XCTAssertEqual(\(type)(expected), \(type)(integerLiteral: \(rawType).max))
            }

            func test\(type)TruncatingBits() {
                let expected = \(type)(\(rawType)(_truncatingBits: UInt.max))
                XCTAssertEqual(expected, \(type)(_truncatingBits: UInt.max))
            }

            func test\(type)Addition() {
                let expected = \(type)(\(rawType)(5) + \(rawType)(3))
                XCTAssertEqual(\(type)(5) + \(type)(3), expected)
            }

            func test\(type)Subtraction() {
                let expected = \(type)(\(rawType)(5) - \(rawType)(3))
                XCTAssertEqual(\(type)(5) - \(type)(3), expected)
            }

            func test\(type)Multiplication() {
                let expected = \(type)(\(rawType)(5) * \(rawType)(3))
                XCTAssertEqual(\(type)(5) * \(type)(3), expected)
            }

            func test\(type)Division() {
                let expected = \(type)(\(rawType)(6) / \(rawType)(3))
                XCTAssertEqual(\(type)(6) / \(type)(3), expected)
            }

            func test\(type)AddOverflow() {
                let rawOriginal = \(rawType).max
                let rawResult = rawOriginal.addingReportingOverflow(\(rawType)(1))
                let original = \(type)(original)
                let result = original.addingReportingOverflow(\(type)(1))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }

            func test\(type)MultiplyOverflow() {
                let rawOriginal = \(rawType).max
                let rawResult = rawOriginal.multipliedReportingOverflow(\(rawType)(2))
                let original = \(type)(original)
                let result = original.multipliedReportingOverflow(\(type)(2))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }

            func test\(type)SubtractOverflow() {
                let rawOriginal = \(rawType).min
                let rawResult = rawOriginal.subtractingReportingOverflow(\(rawType)(1))
                let original = \(type)(original)
                let result = original.subtractingReportingOverflow(\(type)(1))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }

            func test\(type)DivideOverflow() {
                let rawOriginal = \(rawType).max
                let rawResult = rawOriginal.dividedReportingOverflow(\(rawType)(0))
                let original = \(type)(original)
                let result = original.dividedReportingOverflow(\(type)(0))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }

            func test\(type)RemainderOverflow() {
                let rawOriginal = \(rawType).max
                let rawResult = rawOriginal.remainderReportingOverflow(\(rawType)(0))
                let original = \(type)(original)
                let result = original.remainderReportingOverflow(\(type)(0))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }
        """
    }

    // swiftlint:enable function_body_length

    /// Provided additional tests for testing the parent swift struct that represents
    /// a GUUnits floating point unit.
    /// - Parameters:
    ///   - type: The type of the parent struct conforming to BinaryFloatingPoint.
    ///   - rawType: The raw type of the parent struct.
    /// - Returns: The new tests.
    private func typeFloatTests(type: String, rawType: String) -> String {
        ""
    }

    /// Creates a class containing test for a given unit and sign.
    /// - Parameters:
    ///   - unit: The unit to convert from in the unit tests.
    ///   - sign: The sign of the unit.
    ///   - generator: The generator creating the test parameters.
    /// - Returns: The Swift class enacting the unit tests.
    private func createTestClass<T: TestGenerator>(
        from unit: T.UnitType, with sign: Signs, using generator: T
    ) -> String {
        let testCases: String = Signs.allCases.map { otherSign in
            T.UnitType.allCases.compactMap { otherUnit in
                guard (sign != otherSign) || (unit != otherUnit) else {
                    return nil
                }
                let tests = generator.testParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
                return tests.map { test in
                    createTest(from: unit, with: sign, to: otherUnit, with: otherSign, and: test)
                }
                .joined(separator: "\n\n")
            }
            .joined(separator: "\n\n")
        }
        .joined(separator: "\n\n")
        let numericTests = NumericTypes.allCases.map { numeric in
            generator.testParameters(from: unit, with: sign, to: numeric)
            .map { toTest in
                createTest(from: unit, with: sign, to: numeric, and: toTest)
            }
            .joined(separator: "\n\n") + "\n\n" +
            generator.testParameters(from: numeric, to: unit, with: sign)
            .map { fromTest in
                createTest(from: numeric, to: unit, with: sign, and: fromTest)
            }
            .joined(separator: "\n\n")
        }
        .joined(separator: "\n\n")
        let name = "\(unit.rawValue.capitalized)_\(sign)Tests"
        return """
        /// Provides \(unit.rawValue.lowercased())_\(sign) unit tests.
        final class \(name): XCTestCase {

        \(testCases)

        \(numericTests)

        }
        """
    }

    /// Create a test case for a unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    ///   - parameters: The parameters used in the test.
    /// - Returns: The swift code performing the test.
    private func createTest<T: UnitProtocol>(
        from unit: T, with sign: Signs, to otherUnit: T, with otherSign: Signs, and parameters: TestParameters
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let creator = TestFunctionBodyCreator<T>()
        let helper = FunctionHelpers<T>()
        let fnTestName = helper.testFunctionName(
            from: unit, with: sign, to: otherUnit, with: otherSign, using: parameters
        )
        let fnName = helper.functionName(
            forUnit: unit, to: otherUnit, sign: sign, otherSign: otherSign, unique: true
        )
        let unit = "\(unit.rawValue.capitalized)_\(sign)(\(parameters.input))"
        let conversion = "\(otherUnit.rawValue.capitalized)_\(otherSign)(unit)"
        if parameters.input == "Double.greatestFiniteMagnitude" ||
            parameters.input == "-Double.greatestFiniteMagnitude" {
            return """
                func \(fnTestName)() {
                    let unit = \(unit)
                    let expected = \(fnName)(\(parameters.input))
                    let result = \(conversion).rawValue
                    XCTAssertEqual(expected, result)
                }
            """
        }
        let tolerance = creator.sanitiseLiteral(literal: "1", sign: otherSign)
        let categoryConversion = "\(T.category.capitalized)(unit).\(otherUnit.rawValue)_\(otherSign)"
        return """
            func \(fnTestName)() {
                let unit = \(unit)
                let expected = \(fnName)(\(parameters.input))
                let result = \(conversion).rawValue
                XCTAssertEqual(expected, result)
                let tolerance: \(otherUnit.rawValue)_\(otherSign) = \(tolerance)
                let categoryResult = \(categoryConversion).rawValue
                if categoryResult > expected {
                    XCTAssertLessThanOrEqual(categoryResult - expected, tolerance)
                } else {
                    XCTAssertLessThanOrEqual(expected - categoryResult, tolerance)
                }
            }
        """
    }

    /// Create a unit test for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    ///   - parameters: The parameters used in the test.
    /// - Returns: The swift code enacting the test.
    private func createTest<T: UnitProtocol>(
        from unit: T, with sign: Signs, to numeric: NumericTypes, and parameters: TestParameters
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let helper = FunctionHelpers<T>()
        let fnTestName = helper.testFunctionName(from: unit, with: sign, to: numeric, using: parameters)
        let fnName = helper.functionName(forUnit: unit, sign: sign, to: numeric, unique: true)
        let initialiser = "\(unit.rawValue.capitalized)_\(sign.rawValue)(\(parameters.input))"
        return """
            func \(fnTestName)() {
                let expected = \(fnName)(\(parameters.input))
                let result = \(numeric.swiftType)(\(initialiser))
                XCTAssertEqual(expected, result)
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
        from numeric: NumericTypes, to unit: T, with sign: Signs, and parameters: TestParameters
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let helper = FunctionHelpers<T>()
        let fnTestName = helper.testFunctionName(from: numeric, to: unit, with: sign, using: parameters)
        let fnName = helper.functionName(from: numeric, to: unit, sign: sign, unique: true)
        let unitType = "\(unit.rawValue.capitalized)_\(sign.rawValue)"
        let initialiser = "\(unitType)(\(numeric.swiftType)(\(parameters.input)))"
        return """
            func \(fnTestName)() {
                let expected = \(fnName)(\(parameters.input))
                let result = \(initialiser).rawValue
                XCTAssertEqual(expected, result)
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
        import GUUnits
        import XCTest
        """
    }

}
// swiftlint:enable type_body_length
