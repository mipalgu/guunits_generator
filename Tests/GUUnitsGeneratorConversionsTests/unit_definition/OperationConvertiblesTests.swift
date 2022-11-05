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

}
