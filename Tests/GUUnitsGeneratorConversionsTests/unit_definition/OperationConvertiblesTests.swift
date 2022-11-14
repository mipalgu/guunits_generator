// OperationConvertiblesTests.swift 
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

/// Test class for ``Operation`` code generation functions.
final class OperationConvertiblesTests: XCTestCase {

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

    /// Test replace metres with metres.
    func testReplaceMetres() {
        let convertible: [AnyUnit: AnyUnit] = [
            AnyUnit(DistanceUnits.metres): AnyUnit(DistanceUnits.metres)
        ]
        let result = operation.replace(convertibles: convertible)
        let expected = Operation.division(
            lhs: .exponentiate(
                base: .constant(declaration: AnyUnit(DistanceUnits.metres)),
                power: .literal(declaration: .integer(value: 2))
            ),
            rhs: .exponentiate(
                base: .literal(declaration: .integer(value: 1)),
                power: .literal(declaration: .integer(value: 2))
            )
        )
        XCTAssertEqual(result, expected)
    }

    /// Test replace metres with metres.
    func testReplaceMetresOperation() {
        let convertible: [AnyUnit: GUUnitsGeneratorConversions.Operation] = [
            AnyUnit(DistanceUnits.metres): Operation.constant(declaration: AnyUnit(DistanceUnits.metres))
        ]
        let result = operation.replace(convertibles: convertible)
        let expected = Operation.division(
            lhs: .exponentiate(
                base: .constant(declaration: AnyUnit(DistanceUnits.metres)),
                power: .literal(declaration: .integer(value: 2))
            ),
            rhs: .exponentiate(
                base: .literal(declaration: .integer(value: 1)),
                power: .literal(declaration: .integer(value: 2))
            )
        )
        XCTAssertEqual(result, expected)
    }

    /// Test units computed property.
    func testUnits() {
        let result = operation.units.sorted {
            $0.description < $1.description
        }
        let expected = [
            AnyUnit(MassUnits.kilogram),
            AnyUnit(DistanceUnits.metres),
            AnyUnit(TimeUnits.seconds)
        ]
        XCTAssertEqual(result, expected)
    }

    /// Test dividing by self creates literal 1.
    func testSimplifyEqualDivide() {
        let operation = Operation.division(
            lhs: .literal(declaration: .integer(value: 2)), rhs: .literal(declaration: .integer(value: 2))
        )
        let result = operation.simplify
        let expected = Operation.literal(declaration: .integer(value: 1))
        XCTAssertEqual(result, expected)
    }

    /// Test numerator and denominator are 1 produce literal 1.
    func testSimplifyDivideNumeratorAndDenominatorIs1() {
        let operation = Operation.division(
            lhs: .literal(declaration: .integer(value: 1)), rhs: .literal(declaration: .integer(value: 1))
        )
        let result = operation.simplify
        let expected = Operation.literal(declaration: .integer(value: 1))
        XCTAssertEqual(result, expected)
    }

    /// Dividing by 1 returns the numerator.
    func testSimplifyDivideBy1() {
        let operation = Operation.division(
            lhs: .literal(declaration: .integer(value: 2)), rhs: .literal(declaration: .integer(value: 1))
        )
        let result = operation.simplify
        let expected = Operation.literal(declaration: .integer(value: 2))
        XCTAssertEqual(result, expected)
    }

    /// Test simplify does nothing for simplist form of division.
    func testSimplistDivide() {
        let operation = Operation.division(
            lhs: .literal(declaration: .integer(value: 3)), rhs: .literal(declaration: .integer(value: 2))
        )
        let result = operation.simplify
        XCTAssertEqual(result, operation)
    }

    /// Test multiplying 1 with 1 reduces to literal 1.
    func testSimplifyMultiplication1And1() {
        let operation = Operation.multiplication(lhs: one, rhs: one)
        let result = operation.simplify
        XCTAssertEqual(result, one)
    }

    /// Test multiplying with lhs = 1 reduces to rhs.
    func testSimplifyMultiplyLHSIs1() {
        let operation = Operation.multiplication(lhs: one, rhs: .literal(declaration: .integer(value: 2)))
        let result = operation.simplify
        XCTAssertEqual(result, .literal(declaration: .integer(value: 2)))
    }

    /// Test multiplying with rhs = 1 reduces to lhs.
    func testSimplifyMultiplyRHSIs1() {
        let operation = Operation.multiplication(lhs: .literal(declaration: .integer(value: 2)), rhs: one)
        let result = operation.simplify
        XCTAssertEqual(result, .literal(declaration: .integer(value: 2)))
    }

    /// Test remove redundent multiply.
    func testSimplifyInMultiplyWhereLHSIs1OverSomething() {
        let operation = Operation.multiplication(
            lhs: .division(lhs: one, rhs: .literal(declaration: .integer(value: 2))),
            rhs: .literal(declaration: .integer(value: 3))
        )
        let result = operation.simplify
        let expected = Operation.division(
            lhs: .literal(declaration: .integer(value: 3)), rhs: .literal(declaration: .integer(value: 2))
        )
        XCTAssertEqual(result, expected)
    }

    /// Test remove other situation with redundent multiply.
    func testSimplifyInMultiplyWhereRHSIs1OverSomething() {
        let operation = Operation.multiplication(
            lhs: .literal(declaration: .integer(value: 2)),
            rhs: .division(lhs: one, rhs: .literal(declaration: .integer(value: 3)))
        )
        let result = operation.simplify
        let expected = Operation.division(
            lhs: .literal(declaration: .integer(value: 2)), rhs: .literal(declaration: .integer(value: 3))
        )
        XCTAssertEqual(result, expected)
    }

    /// Test simplify does nothing for simplist multiplication.
    func testSimplifyInSimplistMultiplication() {
        let operation = Operation.multiplication(
            lhs: .literal(declaration: .integer(value: 2)), rhs: .literal(declaration: .integer(value: 3))
        )
        let result = operation.simplify
        XCTAssertEqual(result, operation)
    }

    /// Test simplify does nothing for a constant.
    func testSimplifyConstant() {
        let original = Operation.constant(declaration: metres)
        XCTAssertEqual(original.simplify, original)
    }

    /// Test simplify does nothing for literal.
    func testSimplifyLiteral() {
        XCTAssertEqual(one, one.simplify)
    }

    /// Test simplify returns 1 when 1 is raised to any power.
    func testSimplifyForExponentBaseOfOne() {
        let result = Operation.exponentiate(base: one, power: .constant(declaration: metres)).simplify
        XCTAssertEqual(result, one)
    }

    /// Test anything to the power of 0 is 1.
    func testSimplifyForExponentPower0() {
        let result = Operation.exponentiate(
            base: .constant(declaration: metres), power: .literal(declaration: .integer(value: 0))
        ).simplify
        XCTAssertEqual(result, .literal(declaration: .integer(value: 1)))
    }

    /// Test exponent to the power of 1 is just the base.
    func testSimplifyForExponentPower1() {
        let result = Operation.exponentiate(base: .constant(declaration: metres), power: one).simplify
        XCTAssertEqual(result, .constant(declaration: metres))
    }

    /// Test simplify does nothing for general exponentiate case.
    func testSimplifyForExponentiateGeneralCase() {
        let original = Operation.exponentiate(
            base: .constant(declaration: metres), power: .constant(declaration: seconds)
        )
        XCTAssertEqual(original.simplify, original)
    }

    /// Test simplify reduces to rhs when lhs is 0 in an addition operation.
    func testSimplifyAdditionWhereLHSIs0() {
        let rhs = Operation.constant(declaration: metres)
        let result = Operation.addition(lhs: zero, rhs: rhs)
        XCTAssertEqual(result.simplify, rhs)
    }

    /// Test simplify reduces to lhs when rhs is 0 in an addition operation.
    func testSimplifyAdditionWhereRHSIs0() {
        let lhs = Operation.constant(declaration: metres)
        let result = Operation.addition(lhs: lhs, rhs: zero)
        XCTAssertEqual(result.simplify, lhs)
    }

    /// Test simplify returns 0 when adding 0 with 0.
    func testSimplifyAdditionWhenBoth0() {
        let result = Operation.addition(lhs: zero, rhs: zero).simplify
        XCTAssertEqual(result, zero)
    }

    /// Test simplify does nothing for addition operation in simplist form.
    func testSimplifyAddition() {
        let original = Operation.addition(
            lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
        )
        XCTAssertEqual(original.simplify, original)
    }

    /// Test simplify reduces operation to lhs when rhs is 0 in subtraction operation.
    func testSimplifySubtractionWhereRHSIs0() {
        let lhs = Operation.constant(declaration: metres)
        let result = Operation.subtraction(lhs: lhs, rhs: zero).simplify
        XCTAssertEqual(result, lhs)
    }

    /// Test simplify does nothing when performing a subtraction operation with lhs == 0.
    func testSimplifySubtractionWhereLHSIs0() {
        let rhs = Operation.constant(declaration: metres)
        let original = Operation.subtraction(lhs: zero, rhs: rhs)
        XCTAssertEqual(original.simplify, original)
    }

    /// Test simplify does nothing for subtraction operation in simplist form.
    func testSimplifySubtraction() {
        let original = Operation.subtraction(
            lhs: .constant(declaration: metres), rhs: .constant(declaration: seconds)
        )
        XCTAssertEqual(original.simplify, original)
    }

}
