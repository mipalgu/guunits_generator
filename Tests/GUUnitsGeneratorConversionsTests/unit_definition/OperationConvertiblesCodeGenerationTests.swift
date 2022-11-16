// OperationConvertiblesCodeGenerationTests.swift
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

@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for code generation properties in ``Operation``.
final class OperationConvertiblesCodeGenerationTests: XCTestCase {

    /// A zero literal.
    let zero = Operation.literal(declaration: .integer(value: 0))

    /// A one literal.
    let one = Operation.literal(declaration: .integer(value: 1))

    /// A type-erased metres unit that will act as test data.
    let metres = AnyUnit(DistanceUnits.metres)

    /// A type-erased seconds unit that will act as test data.
    let seconds = AnyUnit(TimeUnits.seconds)

    /// The operaiton under test. SI Newton.
    let operation = Operation.division(
        lhs: .multiplication(
            lhs: .constant(declaration: AnyUnit(MassUnits.kilogram)),
            rhs: .exponentiate(
                base: .constant(declaration: AnyUnit(DistanceUnits.metres)),
                power: .literal(declaration: .integer(value: 2))
            )
        ),
        rhs: .exponentiate(
            base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
            power: .literal(declaration: .integer(value: 2))
        )
    )

    /// Test cCode generation for .d Sign.
    func testCCode_d() {
        let code = operation.cCode(sign: .d)
        let type = Signs.d.numericType.rawValue
        let seconds = "((\(type)) (seconds))"
        let metres = "((\(type)) (metres))"
        let kilogram = "((\(type)) (kilogram))"
        let expected = "divide_d((multiply_d((\(kilogram)), (multiply_d((\(metres)), (\(metres))))))," +
            " (multiply_d((\(seconds)), (\(seconds)))))"
        XCTAssertEqual(code, expected)
    }

    /// Test swift code generation for .d sign
    func testSwiftCode_d() {
        let code = operation.swiftCode(sign: .d)
        let type = Signs.d.numericType.swiftType.rawValue
        let seconds = "\(type)(seconds)"
        let metres = "\(type)(metres)"
        let kilogram = "\(type)(kilogram)"
        let expected = "((\(kilogram)) * ((\(metres)) * (\(metres)))) /" +
            " ((\(seconds)) * (\(seconds)))"
        XCTAssertEqual(code, expected)
    }

    // swiftlint:disable opening_brace
    // swiftlint:disable function_body_length

    /// Test c code is valid for all operations.
    func testCCodeGeneration() {
        let cases: [(GUUnitsGeneratorConversions.Operation, (Signs) -> String)] = [
            (Operation.constant(declaration: metres), { "((\($0.numericType.rawValue)) (metres))" }),
            (one, { "((\($0.numericType.rawValue)) (1))" }),
            (
                Operation.division(lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)),
                {
                    "divide_\($0.rawValue)((((\($0.numericType.rawValue)) (metres))), " +
                        "(((\($0.numericType.rawValue)) (seconds))))"
                }
            ),
            (
                Operation.multiplication(
                    lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
                ),
                {
                    "multiply_\($0.rawValue)((((\($0.numericType.rawValue)) (metres))), " +
                        "(((\($0.numericType.rawValue)) (seconds))))"
                }
            ),
            (
                Operation.exponentiate(
                    base: .constant(declaration: metres), power: .literal(declaration: .integer(value: 2))
                ),
                {
                    "multiply_\($0.rawValue)((((\($0.numericType.rawValue)) (metres))), " +
                        "(((\($0.numericType.rawValue)) (metres))))"
                }
            ),
            (
                Operation.exponentiate(
                    base: .constant(declaration: metres), power: .literal(declaration: .integer(value: 3))
                ),
                {
                    "multiply_\($0.rawValue)((((\($0.numericType.rawValue)) (metres))), " +
                        "(multiply_\($0.rawValue)((((\($0.numericType.rawValue)) (metres))), " +
                        "(((\($0.numericType.rawValue)) (metres))))))"
                }
            ),
            (
                Operation.exponentiate(
                    base: .constant(declaration: metres), power: .constant(declaration: seconds)
                ),
                {
                    "(pow(((\($0.numericType.rawValue)) (metres)), " +
                        "((\($0.numericType.rawValue)) (seconds))))"
                }
            ),
            (one, { "((\($0.numericType.rawValue)) (1))" }),
            (
                Operation.literal(declaration: .decimal(value: 1.0)),
                { "((\($0.numericType.rawValue)) (1.0))" }
            ),
            (
                Operation.addition(
                    lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
                ),
                {
                    "addition_\($0.rawValue)((((\($0.numericType.rawValue)) (metres))), " +
                        "(((\($0.numericType.rawValue)) (seconds))))"
                }
            ),
            (
                Operation.subtraction(
                    lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
                ),
                {
                    "subtraction_\($0.rawValue)((((\($0.numericType.rawValue)) (metres))), " +
                        "(((\($0.numericType.rawValue)) (seconds))))"
                }
            )
        ]
        cases.forEach { operation, expected in
            guard isValidCCode(for: operation, expected: expected) else {
                XCTFail("\(operation) does not produce valid C code.")
                Signs.allCases.forEach {
                    print("C Code: ")
                    print(operation.cCode(sign: $0))
                    print("Expected: ")
                    print(expected($0))
                }
                fflush(stdout)
                return
            }
        }
    }

    /// Test swift code is valid for all operations.
    func testSwiftCodeGeneration() {
        let cases: [(GUUnitsGeneratorConversions.Operation, (Signs) -> String)] = [
            (Operation.constant(declaration: metres), { "\($0.numericType.swiftType.rawValue)(metres)" }),
            (one, { "\($0.numericType.swiftType.rawValue)(1)" }),
            (
                Operation.division(lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)),
                {
                    "(\($0.numericType.swiftType.rawValue)(metres)) / " +
                        "(\($0.numericType.swiftType.rawValue)(seconds))"
                }
            ),
            (
                Operation.multiplication(
                    lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
                ),
                {
                    "(\($0.numericType.swiftType.rawValue)(metres)) * " +
                        "(\($0.numericType.swiftType.rawValue)(seconds))"
                }
            ),
            (
                Operation.exponentiate(
                    base: .constant(declaration: metres), power: .literal(declaration: .integer(value: 2))
                ),
                {
                    "(\($0.numericType.swiftType.rawValue)(metres)) * " +
                        "(\($0.numericType.swiftType.rawValue)(metres))"
                }
            ),
            (
                Operation.exponentiate(
                    base: .constant(declaration: metres), power: .literal(declaration: .integer(value: 3))
                ),
                {
                    "(\($0.numericType.swiftType.rawValue)(metres)) * " +
                        "((\($0.numericType.swiftType.rawValue)(metres)) * " +
                        "(\($0.numericType.swiftType.rawValue)(metres)))"
                }
            ),
            (
                Operation.exponentiate(
                    base: .constant(declaration: metres), power: .constant(declaration: seconds)
                ),
                {
                    "(pow(\($0.numericType.swiftType.rawValue)(metres), " +
                        "\($0.numericType.swiftType.rawValue)(seconds)))"
                }
            ),
            (one, { "\($0.numericType.swiftType.rawValue)(1)" }),
            (
                Operation.literal(declaration: .decimal(value: 1.0)),
                { "\($0.numericType.swiftType.rawValue)(1.0)" }
            ),
            (
                Operation.addition(
                    lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
                ),
                {
                    "(\($0.numericType.swiftType.rawValue)(metres)) + " +
                        "(\($0.numericType.swiftType.rawValue)(seconds))"
                }
            ),
            (
                Operation.subtraction(
                    lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
                ),
                {
                    "(\($0.numericType.swiftType.rawValue)(metres)) - " +
                        "(\($0.numericType.swiftType.rawValue)(seconds))"
                }
            )
        ]
        cases.forEach { operation, expected in
            guard isValidSwiftCode(for: operation, expected: expected) else {
                XCTFail("\(operation) does not produce valid swift code.")
                Signs.allCases.forEach {
                    print("Swift Code: ")
                    print(operation.swiftCode(sign: $0))
                    print("Expected: ")
                    print(expected($0))
                }
                fflush(stdout)
                return
            }
        }
    }

    // swiftlint:enable opening_brace
    // swiftlint:enable function_body_length

    /// Helper function for checking C code.
    /// - Parameters:
    ///   - operation: The operation to check.
    ///   - expected: The expected C code from the operation.
    /// - Returns: Whether the expected C code matches the actual C code in the operation.
    private func isValidCCode(
        for operation: GUUnitsGeneratorConversions.Operation, expected: (Signs) -> String
    ) -> Bool {
        isValidCode(for: operation, codeFn: { $0.cCode(sign: $1) }, expected: expected)
    }

    /// Helper function for checking Swift code.
    /// - Parameters:
    ///   - operation: The operation to check.
    ///   - expected: The expected Swift code from the operation.
    /// - Returns: Whether the expected Swift code matches the actual Swift code in the operation.
    private func isValidSwiftCode(
        for operation: GUUnitsGeneratorConversions.Operation, expected: (Signs) -> String
    ) -> Bool {
        isValidCode(for: operation, codeFn: { $0.swiftCode(sign: $1) }, expected: expected)
    }

    /// Checks a code generation function in an operation.
    /// - Parameters:
    ///   - operation: The operation to check.
    ///   - codeFn: The function to generate the code.
    ///   - expected: The expected code.
    /// - Returns: Whether the generated code matches the expected code.
    private func isValidCode(
        for operation: GUUnitsGeneratorConversions.Operation,
        codeFn: (GUUnitsGeneratorConversions.Operation, Signs) -> String,
        expected: (Signs) -> String
    ) -> Bool {
        Signs.allCases.allSatisfy {
            expected($0) == codeFn(operation, $0)
        }
    }

}
