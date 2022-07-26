/*
 * TestFileCreator.swift 
 * guunits_generator 
 *
 * Created by Morgan McColl.
 * Copyright © 2022 Morgan McColl. All rights reserved.
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
 *        This product includes software developed by Morgan McColl.
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

/// Creates the contents for a test file. This struct generates all of the test code required
/// to fully test a Unit category.
public struct TestFileCreator<TestGeneratorType: TestGenerator> {

    /// The unit category to test.
    typealias Unit = TestGeneratorType.UnitType

    /// A function helper for providing apt function names.
    private let helper = FunctionHelpers<Unit>()

    /// The body creator for generating test function code.
    private let bodyCreator = TestFunctionBodyCreator<Unit>()

    /// Converts the generated test parameters into test classes.
    /// - Parameters:
    ///   - generator: The generator creating the test parameters.
    ///   - imports: Imports that are placed at the top of this file.
    /// - Returns: An array of tuples containing the name of the files and the class definitions.
    private func doTests(generator: TestGeneratorType, imports: String) -> [(String, String)] {
        let head = "\(imports)\nimport Foundation\nimport XCTest"
        let unitTests: [(String, [[String]])] = Unit.allCases.flatMap { unit in
            Signs.allCases.map { sign in
                (
                    unit.rawValue.capitalized + "_" + sign.rawValue,
                    (
                        Unit.allCases.flatMap { otherUnit in
                            Signs.allCases.flatMap { otherSign in
                                self.createTests(
                                    from: unit,
                                    with: sign,
                                    to: otherUnit,
                                    with: otherSign,
                                    using: generator
                                )
                            }
                        } +
                        NumericTypes.allCases.flatMap { numeric in
                            self.createTests(from: unit, with: sign, to: numeric, using: generator) +
                                self.createTests(from: numeric, to: unit, with: sign, using: generator)
                        }
                    )
                    .sorted()
                    .group(size: 30)
                )
            }
        }
        return unitTests.flatMap { testTuple -> [(String, String)] in
            testTuple.1.enumerated().map { index, tests -> (String, String) in
                let name = "\(Unit.category)_\(testTuple.0)Tests\(index)"
                let testString = tests.joined(separator: "\n\n")
                return (
                    name,
                    """
                    \(head)

                    final class \(name): XCTestCase {

                    \(testString)

                    }

                    """
                )
            }
        }
    }

    /// Create tests for a unit to unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    ///   - generator: The generator which creates the test parameters for this conversion function.
    /// - Returns: 
    private func createTests(
        from unit: Unit,
        with sign: Signs,
        to otherUnit: Unit,
        with otherSign: Signs,
        using generator: TestGeneratorType
    ) -> [String] {
        generator.testParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
        .group(size: 10)
        .enumerated()
        .compactMap {
            self.createTestFunction(
                from: unit, with: sign, to: otherUnit, with: otherSign, with: $0.1, index: $0.0
            )
        }
    }

    /// Generates an array of test functions that test a conversion from a unit to a numeric type.
    /// - Parameters:
    ///   - unit: The unit to convert.
    ///   - sign: The sign of the unit.
    ///   - numeric: The type to convert to.
    ///   - generator: The generator which creates the test cases.
    /// - Returns: An array of test functions that test the conversion function.
    private func createTests(
        from unit: Unit,
        with sign: Signs,
        to numeric: NumericTypes,
        using generator: TestGeneratorType
    ) -> [String] {
        generator.testParameters(from: unit, with: sign, to: numeric)
        .group(size: 10)
        .enumerated()
        .compactMap {
            self.createTestFunction(from: unit, with: sign, to: numeric, with: $0.1, index: $0.0)
        }
    }

    /// Generates an array of test functions that test a conversion from a numeric to a unit type.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    ///   - generator: The generator which creates the test function body.
    /// - Returns: The tests that test the conversion function.
    private func createTests(
        from numeric: NumericTypes,
        to unit: Unit,
        with sign: Signs,
        using generator: TestGeneratorType
    ) -> [String] {
        generator.testParameters(from: numeric, to: unit, with: sign)
        .group(size: 10)
        .enumerated()
        .compactMap {
            self.createTestFunction(from: numeric, to: unit, with: sign, with: $0.1, index: $0.0)
        }
    }

    // swiftlint:disable function_parameter_count

    /// Creates a test function for a unit to unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    ///   - parameters: The test parameters to use in the test.
    /// - Returns: A test which uses the test parameters for the conversion function.
    private func createTestFunction(
        from unit: Unit,
        with sign: Signs,
        to otherUnit: Unit,
        with otherSign: Signs,
        with parameters: [TestParameters],
        index: Int
    ) -> String? {
        guard !parameters.isEmpty else {
            return nil
        }
        let indexStr = index == 0 ? "" : "\(index)"
        let name = "test\(unit.description)_\(sign.rawValue)_to_\(otherUnit.description)_" +
            "\(otherSign.rawValue)\(indexStr)"
        let body = bodyCreator.generateFunction(
            from: unit, with: sign, to: otherUnit, with: otherSign, using: parameters
        )
        let formattedBody = body.components(separatedBy: .newlines)
            .map { "        " + $0 }
            .joined(separator: "\n")
        return "    func \(name)() {\n\(formattedBody)\n    }"
    }

    // swiftlint:enable function_parameter_count

    /// Create a test function for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    ///   - parameters: The test parameters to use in the test.
    /// - Returns: A function which tests the conversion function using the test parameters.
    private func createTestFunction(
        from unit: Unit,
        with sign: Signs,
        to numeric: NumericTypes,
        with parameters: [TestParameters],
        index: Int
    ) -> String? {
        guard !parameters.isEmpty else {
            return nil
        }
        let indexStr = index == 0 ? "" : "\(index)"
        let name = "test\(unit.description)_\(sign.rawValue)_to_\(numeric.rawValue)\(indexStr)"
        let body = bodyCreator.generateFunction(from: unit, with: sign, to: numeric, using: parameters)
        let formattedBody = body.components(separatedBy: .newlines)
            .map { "        " + $0 }
            .joined(separator: "\n")
        return "    func \(name)() {\n\(formattedBody)\n    }"
    }

    /// Create a test function for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    ///   - parameters: The parameters to use in the test function.
    /// - Returns: A test which tests the conversion function by using the given parameters.
    private func createTestFunction(
        from numeric: NumericTypes,
        to unit: Unit,
        with sign: Signs,
        with parameters: [TestParameters],
        index: Int
    ) -> String? {
        guard !parameters.isEmpty else {
            return nil
        }
        let indexStr = index == 0 ? "" : "\(index)"
        let name = "test\(numeric.rawValue)_to_\(unit.description)_\(sign.rawValue)\(indexStr)"
        let body = bodyCreator.generateFunction(from: numeric, to: unit, with: sign, using: parameters)
        let formattedBody = body.components(separatedBy: .newlines)
            .map { "        " + $0 }
            .joined(separator: "\n")
        return "    func \(name)() {\n\(formattedBody)\n    }"
    }

}

extension TestFileCreator {

    /// Create all of the tests for a Unit category. This function produces an array of test files
    /// for the unit category.
    /// - Parameters:
    ///   - generator: A test generator for creating the test parameters for different test functions.
    ///   - imports: Any additional imports required in the test file. XCTest, Foundation and CGUUnits
    ///              are included by default.
    /// - Returns: All of the test code as an array of tuples containing the file name and contents.
    func tests(generator: TestGeneratorType, imports: String) -> [(String, String)] {
        doTests(generator: generator, imports: imports)
    }

}

extension TestFileCreator where Unit: OperationalTestable {

    /// Create all of the tests for a Unit category. This function produces an array of test files
    /// for the unit category.
    /// - Parameters:
    ///   - generator: A test generator for creating the test parameters for different test functions.
    ///   - imports: Any additional imports required in the test file. XCTest, Foundation and CGUUnits
    ///              are included by default.
    /// - Returns: All of the test code as an array of tuples containing the file name and contents.
    func tests(generator: TestGeneratorType, imports: String) -> [(String, String)] {
        let head = "\(imports)\nimport Foundation\nimport XCTest"
        let conversionTests = doTests(generator: generator, imports: imports)
        let relations = Unit.relationTests
        guard !relations.isEmpty else {
            return conversionTests
        }
        let testCode = relations.flatMap { conversion, parameters -> [String] in
            let relation = conversion.relation
            let source = relation.source
            let target = relation.target
            let sign = conversion.sourceSign
            let otherSign = conversion.targetSign
            return parameters.group(size: 10).enumerated().map { index, param in
                let indexStr = index == 0 ? "" : "\(index)"
                let functionName = "test\(source.description)_\(sign.rawValue)To" +
                    "\(target.description)_\(otherSign.rawValue)Relation\(indexStr)"
                let body = bodyCreator.relationTest(conversion: conversion, parameter: param)
                let formattedBody = body.components(separatedBy: .newlines)
                    .map { "        " + $0 }
                    .joined(separator: "\n")
                return "    func \(functionName)() {\n\(formattedBody)\n    }"
            }
        }
        .group(size: 30)
        let relationFiles = testCode.enumerated().map { index, params -> (String, String) in
            let name = "\(Unit.category)RelationTests\(index)"
            return (
                name,
                """
                \(head)

                final class \(name): XCTestCase {

                \(params.joined(separator: "\n\n"))

                }

                """
            )
        }
        return conversionTests + relationFiles
    }

}
