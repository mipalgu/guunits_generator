// OperationTests.swift 
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

/// Test class for `Operation`.
final class OperationTests: XCTestCase {

    /// Operation under test.
    let operation = Operation.division(
        lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
        rhs: Operation.exponentiate(
            base: Operation.constant(declaration: AnyUnit(TimeUnits.seconds)),
            power: Operation.literal(declaration: .integer(value: 2))
        )
    )

    /// Test the abbreviation is correct.
    func testAbbreviation() {
        XCTAssertEqual(operation.abbreviation, "m_per_s_sq")
        XCTAssertEqual(operation.description, "metres_per_seconds_sq")
    }

    /// test abbreviation of huge operation.
    func testHugeAbbreviation() {
        let hugeOperation = Operation.division(
            lhs: Operation.multiplication(
                lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
                rhs: Operation.precedence(
                    operation: Operation.division(
                        lhs: .constant(declaration: AnyUnit(TemperatureUnits.celsius)),
                        rhs: .constant(declaration: AnyUnit(CurrentUnits.amperes))
                    )
                )
            ),
            rhs: .exponentiate(
                base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: .literal(declaration: .integer(value: 3))
            )
        )
        XCTAssertEqual(
            hugeOperation.abbreviation,
            "m__degC_per_A__per_s_cub"
        )
        XCTAssertEqual(
            hugeOperation.description,
            "metres__celsius_per_amperes__per_seconds_cub"
        )
    }

    /// test abbreviation of huge operation.
    func testHugeAbbreviation2() {
        let hugeOperation2 = Operation.division(
            lhs: Operation.multiplication(
                lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
                rhs: Operation.precedence(
                    operation: Operation.division(
                        lhs: .constant(declaration: AnyUnit(TemperatureUnits.celsius)),
                        rhs: .constant(declaration: AnyUnit(CurrentUnits.amperes))
                    )
                )
            ),
            rhs: .exponentiate(
                base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: .literal(declaration: .integer(value: 4))
            )
        )
        XCTAssertEqual(
            hugeOperation2.abbreviation,
            "m__degC_per_A__per_s_pwr_4"
        )
        XCTAssertEqual(
            hugeOperation2.description,
            "metres__celsius_per_amperes__per_seconds_pwr_4"
        )
    }

    /// test abbreviation of huge operation.
    func testHugeAbbreviation3() {
        let hugeOperation3 = Operation.division(
            lhs: Operation.multiplication(
                lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
                rhs: Operation.precedence(
                    operation: Operation.division(
                        lhs: .constant(declaration: AnyUnit(TemperatureUnits.celsius)),
                        rhs: .constant(declaration: AnyUnit(CurrentUnits.amperes))
                    )
                )
            ),
            rhs: .exponentiate(
                base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: .literal(declaration: .integer(value: -4))
            )
        )
        XCTAssertEqual(
            hugeOperation3.abbreviation,
            "m__degC_per_A__per_s_pwr_neg4"
        )
        XCTAssertEqual(
            hugeOperation3.description,
            "metres__celsius_per_amperes__per_seconds_pwr_neg4"
        )
    }

    /// Test the abbreviation is correct.
    func testAbbreviation0Case() {
        let operation = Operation.division(
            lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: Operation.exponentiate(
                base: Operation.constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: Operation.literal(declaration: .integer(value: 0))
            )
        )
        XCTAssertEqual(operation.abbreviation, "m")
        XCTAssertEqual(operation.description, "metres")
    }

    /// Test the abbreviation is correct.
    func testAbbreviation1Case() {
        let operation = Operation.division(
            lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: Operation.exponentiate(
                base: Operation.constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: Operation.literal(declaration: .integer(value: 1))
            )
        )
        XCTAssertEqual(operation.abbreviation, "m_per_s")
        XCTAssertEqual(operation.description, "metres_per_seconds")
    }

    /// Test the abbreviation of the case where the unit is an inverse.
    func testAbbreviationNeg1Case() {
        let operation = Operation.division(
            lhs: .literal(declaration: .integer(value: 1)),
            rhs: Operation.constant(declaration: AnyUnit(TimeUnits.seconds))
        )
        XCTAssertEqual(operation.abbreviation, "s_pwr_neg1")
        XCTAssertEqual(operation.description, "seconds_pwr_neg1")
    }

    /// Test the abbreviation of the case where the unit is a product.
    func testAbbreviationMultiply() {
        let operation = Operation.multiplication(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: .constant(declaration: AnyUnit(TimeUnits.seconds))
        )
        XCTAssertEqual(operation.abbreviation, "m_s")
        XCTAssertEqual(operation.description, "metres_seconds")
    }

    /// Test allCases property.
    func testAllCases() {
        let operation = Operation.multiplication(
            lhs: .multiplication(
                lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
                rhs: .constant(declaration: AnyUnit(TimeUnits.seconds))
            ),
            rhs: .constant(declaration: AnyUnit(TemperatureUnits.celsius))
        )
        let result = Set(operation.allCases.map(\.abbreviation))
        let expected = Set(
            DistanceUnits.allCases.flatMap { x in
                TimeUnits.allCases.flatMap { t in
                    TemperatureUnits.allCases.map { temp in
                        "\(x.abbreviation)_\(t.abbreviation)_\(temp.abbreviation)"
                    }
                }
            }
        )
        XCTAssertEqual(result, expected)
    }

    /// Test allCases property for big unit type.
    func testHugeAllCases() {
        let result = Set(
            Operation.division(
                lhs: Operation.multiplication(
                    lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
                    rhs: Operation.precedence(
                        operation: Operation.division(
                            lhs: .constant(declaration: AnyUnit(TemperatureUnits.celsius)),
                            rhs: .constant(declaration: AnyUnit(CurrentUnits.amperes))
                        )
                    )
                ),
                rhs: .exponentiate(
                    base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                    power: .literal(declaration: .integer(value: 3))
                )
            )
            .allCases.map(\.abbreviation)
        )
        let expected = Set(
            DistanceUnits.allCases.flatMap { x in
                TemperatureUnits.allCases.flatMap { temp in
                    CurrentUnits.allCases.flatMap { i in
                        TimeUnits.allCases.map { (t: TimeUnits) -> String in
                            "\(x.abbreviation)__\(temp.abbreviation)_per_\(i.abbreviation)__per_" +
                                "\(t.abbreviation)_cub"
                        }
                    }
                }
            }
        )
        XCTAssertEqual(result, expected)
    }

    /// Test hasFloatOperation produces correct result for different operations.
    func testHasFloat() {
        let operation = Operation.multiplication(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.centimetres)),
            rhs: .literal(declaration: .integer(value: 2))
        )
        XCTAssertFalse(operation.hasFloatOperation)
        XCTAssertTrue(Operation.literal(declaration: .decimal(value: 1.0)).hasFloatOperation)
        let operation2 = Operation.division(
            lhs: .literal(declaration: .integer(value: 1)),
            rhs: .literal(declaration: .integer(value: 1000))
        )
        XCTAssertTrue(operation2.hasFloatOperation)
        let operation3 = Operation.division(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: .constant(declaration: AnyUnit(TimeUnits.seconds))
        )
        XCTAssertFalse(operation3.hasFloatOperation)
    }

    /// Test units property returns all units in the Operation.
    func testUnits() {
        let units = operation.units
        let expected = [AnyUnit(DistanceUnits.metres), AnyUnit(TimeUnits.seconds)]
        XCTAssertEqual(units, expected)
    }

}
