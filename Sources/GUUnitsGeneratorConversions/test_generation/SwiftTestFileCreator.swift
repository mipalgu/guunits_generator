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
    func generate<T: TestGenerator>(with generator: T) -> String {
        prefix(name: "\(T.UnitType.category)Tests") +
            "\n\n" +
            typeTests(category: T.UnitType.self) +
            typeConversionTests(category: T.UnitType.self) +
            T.UnitType.allCases.flatMap { unit in
                Signs.allCases.map { sign in
                    createTestClass(from: unit, with: sign, using: generator)
                }
            }
            .joined(separator: "\n\n") + "\n"
    }

    private func typeConversionTests<T>(category: T.Type) -> String where T: UnitProtocol {
        T.allCases.flatMap { unit in
            Signs.allCases.flatMap { (sign: Signs) -> [String] in
                let type = "\(unit)_\(sign)"
                return T.allCases.flatMap { (otherUnit: T) -> [String] in
                    Signs.allCases.compactMap { (otherSign: Signs) -> String? in
                        guard sign != otherSign || unit != otherUnit else {
                            return nil
                        }
                        let otherType = "\(otherUnit)_\(otherSign)"
                        return conversionTests(from: type, to: otherType)
                    }
                }
            }
        }
        .joined(separator: "\n\n")
    }

    private func conversionTests(from type: String, to otherType: String) -> String {

    }

    /// Additional tests needed to test the protocol conformances in the swift abstraction.
    /// - Parameter category: The unit category.
    /// - Returns: The new tests.
    private func typeTests<T>(category: T.Type) -> String where T: UnitProtocol {
        T.allCases.map { type in
            let tests = Signs.allCases.map { sign in
                let typeDef = "\(type.description.capitalized)_\(sign)"
                let rawType = sign.numericType.swiftType.rawValue
                let primitiveTests = sign.isFloatingPoint ?
                    typeFloatTests(type: typeDef, rawType: rawType) :
                    typeIntegerTests(type: typeDef, rawType: rawType)
                return """
                \(typeGeneralTests(type: typeDef, rawType: rawType))

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
    private func typeGeneralTests(type: String, rawType: String) -> String {
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
            func test\(type)Magnitude() {
                let expected = \(rawType)(5).magnitude
                XCTAssertEqual(\(type)(5).magnitude, expected)
            }

            func test\(type)TruncatingInit() {
                let expected = \(type)(\(rawType)(truncatingIfNeeded: UInt64.max))
                XCTAssertEqual(\(type)(truncatingIfNeeded: expected), expected)
            }

            func test\(type)ClampingInit() {
                let expected = \(type)(\(rawType)(clamping: UInt64.max))
                XCTAssertEqual(\(type)(clamping: expected), expected)
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
                let original = \(type)(rawOriginal)
                let result = original.addingReportingOverflow(\(type)(1))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }

            func test\(type)MultiplyOverflow() {
                let rawOriginal = \(rawType).max
                let rawResult = rawOriginal.multipliedReportingOverflow(by: \(rawType)(2))
                let original = \(type)(rawOriginal)
                let result = original.multipliedReportingOverflow(by: \(type)(2))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }

            func test\(type)SubtractOverflow() {
                let rawOriginal = \(rawType).min
                let rawResult = rawOriginal.subtractingReportingOverflow(\(rawType)(1))
                let original = \(type)(rawOriginal)
                let result = original.subtractingReportingOverflow(\(type)(1))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
                XCTAssertTrue(result.1)
            }

            func test\(type)DivideOverflow() {
                let rawOriginal = \(rawType)(1)
                let rawResult = rawOriginal.dividedReportingOverflow(by: \(rawType).max)
                let original = \(type)(rawOriginal)
                let result = original.dividedReportingOverflow(by: \(type)(\(rawType).max))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
            }

            func test\(type)RemainderOverflow() {
                let rawOriginal = \(rawType)(1)
                let rawResult = rawOriginal.remainderReportingOverflow(dividingBy: \(rawType).max)
                let original = \(type)(rawOriginal)
                let result = original.remainderReportingOverflow(dividingBy: \(type)(\(rawType).max))
                XCTAssertEqual(result.0, \(type)(rawResult.0))
                XCTAssertEqual(result.1, rawResult.1)
            }

            func test\(type)TrailingZeroBitCount() {
                let original = \(rawType)(1)
                XCTAssertEqual(\(type)(original).trailingZeroBitCount, original.trailingZeroBitCount)
            }

            func test\(type)TimesEquals() {
                var original = \(rawType)(2)
                original *= 4
                var result = \(type)(\(rawType)(2))
                result *= 4
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)DivideEquals() {
                var original = \(rawType)(4)
                original /= 2
                var result = \(type)(\(rawType)(4))
                result /= 2
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)ModEquals() {
                var original = \(rawType)(4)
                original %= 2
                var result = \(type)(\(rawType)(4))
                result %= 2
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)AndEquals() {
                var original = \(rawType)(2)
                original &= 6
                var result = \(type)(\(rawType)(2))
                result &= 6
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)OrEquals() {
                var original = \(rawType)(2)
                original |= 4
                var result = \(type)(\(rawType)(2))
                result |= 4
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)HatEquals() {
                var original = \(rawType)(2)
                original ^= 4
                var result = \(type)(\(rawType)(2))
                result ^= 4
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)Mod() {
                let original = \(rawType)(4)
                let expected = \(type)(original % 2)
                XCTAssertEqual(\(type)(original) % 2, expected)
            }
        """
    }

    /// Provided additional tests for testing the parent swift struct that represents
    /// a GUUnits floating point unit.
    /// - Parameters:
    ///   - type: The type of the parent struct conforming to BinaryFloatingPoint.
    ///   - rawType: The raw type of the parent struct.
    /// - Returns: The new tests.
    private func typeFloatTests(type: String, rawType: String) -> String {
        """
            func test\(type)Radix() {
                XCTAssertEqual(\(type).radix, \(rawType).radix)
            }

            func test\(type)ExponentBitCount() {
                XCTAssertEqual(\(type).exponentBitCount, \(rawType).exponentBitCount)
            }

            func test\(type)SignificandBitCount() {
                XCTAssertEqual(\(type).significandBitCount, \(rawType).significandBitCount)
            }

            func test\(type)Magnitude() {
                let expected = \(type)(\(rawType)(5).magnitude)
                XCTAssertEqual(\(type)(5).magnitude, expected)
            }

            func test\(type)ExactlyInit() {
                let expected = \(type)(\(rawType)(exactly: Int(5)) ?? \(rawType).infinity)
                XCTAssertEqual(\(type)(exactly: Int(5)), expected)
            }

            func test\(type)IsTotallyOrdered() {
                let param = \(rawType)(100)
                let other = \(rawType)(5)
                XCTAssertEqual(
                    \(type)(param).isTotallyOrdered(belowOrEqualTo: \(type)(other)),
                    param.isTotallyOrdered(belowOrEqualTo: other)
                )
            }

            func test\(type)Binade() {
                let raw = \(rawType)(5)
                let expected = \(type)(raw.binade)
                XCTAssertEqual(\(type)(raw).binade, expected)
            }

            func test\(type)SignificandWidth() {
                let raw = \(rawType)(5)
                XCTAssertEqual(\(type)(raw).significandWidth, raw.significandWidth)
            }

            func test\(type)DebugDescription() {
                let raw = \(rawType)(5)
                XCTAssertEqual(\(type)(raw).debugDescription, raw.debugDescription)
            }

            func test\(type)DescriptionInit() {
                let raw = \(rawType)(\"5.0\") ?? \(rawType).nan
                XCTAssertEqual(\(type)(\"5.0\"), \(type)(raw))
            }

            func test\(type)StaticVars() {
                XCTAssertEqual(\(type).nan.isNaN, \(type)(\(rawType).nan).isNaN)
                XCTAssertEqual(
                    \(type).signalingNaN.isSignalingNaN,
                    \(type)(\(rawType).signalingNaN).isSignalingNaN
                )
                XCTAssertEqual(\(type).infinity, \(type)(\(rawType).infinity))
                XCTAssertEqual(\(type).greatestFiniteMagnitude, \(type)(\(rawType).greatestFiniteMagnitude))
                XCTAssertEqual(\(type).pi, \(type)(\(rawType).pi))
                XCTAssertEqual(\(type).leastNormalMagnitude, \(type)(\(rawType).leastNormalMagnitude))
                XCTAssertEqual(\(type).leastNonzeroMagnitude, \(type)(\(rawType).leastNonzeroMagnitude))
            }

            func test\(type)Ulp() {
                let raw = \(rawType)(5)
                XCTAssertEqual(\(type)(raw).ulp, \(type)(raw.ulp))
            }

            func test\(type)Sign() {
                let raw = \(rawType)(5)
                XCTAssertEqual(\(type)(raw).sign, raw.sign)
            }

            func test\(type)Significand() {
                let raw = \(rawType)(5)
                XCTAssertEqual(\(type)(raw).significand, \(type)(raw.significand))
            }

            func test\(type)NextUp() {
                let raw = \(rawType)(5)
                XCTAssertEqual(\(type)(raw).nextUp, \(type)(raw.nextUp))
            }

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

            func test\(type)FormRemainder() {
                var original = \(rawType)(4)
                let denominator = \(rawType)(3)
                original.formRemainder(dividingBy: denominator)
                var result = \(type)(\(rawType)(4))
                result.formRemainder(dividingBy: \(type)(denominator))
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)FormTruncatingRemainder() {
                var original = \(rawType)(4)
                let denominator = \(rawType)(3)
                original.formTruncatingRemainder(dividingBy: denominator)
                var result = \(type)(\(rawType)(4))
                result.formTruncatingRemainder(dividingBy: \(type)(denominator))
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)FormSquareRoot() {
                var original = \(rawType)(4)
                original.formSquareRoot()
                var result = \(type)(\(rawType)(4))
                result.formSquareRoot()
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)AddProduct() {
                var original = \(rawType)(4)
                let lhs = \(rawType)(3)
                let rhs = \(rawType)(5)
                original.addProduct(lhs, rhs)
                var result = \(type)(\(rawType)(4))
                result.addProduct(\(type)(lhs), \(type)(rhs))
                XCTAssertEqual(result, \(type)(original))
            }

            func test\(type)IsEqual() {
                let this = \(type)(5)
                let other = \(type)(6)
                XCTAssertTrue(this.isEqual(to: this))
                XCTAssertFalse(this.isEqual(to: other))
            }

            func test\(type)IsLess() {
                let this = \(type)(5)
                let other = \(type)(6)
                XCTAssertFalse(this.isLess(than: this))
                XCTAssertTrue(this.isLess(than: other))
            }

            func test\(type)IsLessThanOrEqual() {
                let this = \(type)(5)
                let other = \(type)(6)
                let other2 = \(type)(4)
                XCTAssertTrue(this.isLessThanOrEqualTo(this))
                XCTAssertTrue(this.isLessThanOrEqualTo(other))
                XCTAssertFalse(this.isLessThanOrEqualTo(other2))
            }

            func test\(type)Operations() {
                let lhs = \(type)(6)
                let rhs = \(type)(3)
                XCTAssertEqual(lhs + rhs, \(type)(9))
                XCTAssertEqual(lhs - rhs, \(type)(3))
                XCTAssertEqual(lhs * rhs, \(type)(18))
                XCTAssertEqual(lhs / rhs, \(type)(2))
            }

            func test\(type)TimesEqual() {
                var this = \(type)(3)
                this *= \(type)(4)
                XCTAssertEqual(this, \(type)(12))
            }

            func test\(type)DivideEqual() {
                var this = \(type)(6)
                this /= \(type)(3)
                XCTAssertEqual(this, \(type)(2))
            }

            func test\(type)Round() {
                var expected = \(rawType)(5.6)
                expected.round(.up)
                var result = \(type)(5.6)
                result.round(.up)
                XCTAssertEqual(result, \(type)(expected))
            }

            func test\(type)DistanceTo() {
                let original = \(rawType)(5.0)
                let other = \(rawType)(23)
                let expected = original.distance(to: other)
                XCTAssertEqual(\(type)(original).distance(to: \(type)(other)), expected)
            }

            func test\(type)AdvancedBy() {
                let original = \(rawType)(5)
                let expected = original.advanced(by: 3)
                XCTAssertEqual(\(type)(original).advanced(by: 3), \(type)(expected))
            }
        """
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
// swiftlint:enable file_length
