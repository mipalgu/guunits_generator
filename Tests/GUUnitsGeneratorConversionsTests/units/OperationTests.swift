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

    /// Test the abbreviation is correct.
    func testAbbreviation() {
        let operation = Operation.division(
        lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
        rhs: Operation.exponentiate(
            base: Operation.constant(declaration: AnyUnit(TimeUnits.seconds)),
            power: Operation.literal(declaration: 2)
        )
    )
        XCTAssertEqual(operation.abbreviation, "m_per_s_sq")
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
            base: .constant(declaration: AnyUnit(TimeUnits.seconds)), power: .literal(declaration: 3)
        )
    )
        XCTAssertEqual(
            hugeOperation.abbreviation,
            "m__degC_per_A__per_s_cub"
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
            base: .constant(declaration: AnyUnit(TimeUnits.seconds)), power: .literal(declaration: 4)
        )
    )
        XCTAssertEqual(
            hugeOperation2.abbreviation,
            "m__degC_per_A__per_s_pwr_4"
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
            base: .constant(declaration: AnyUnit(TimeUnits.seconds)), power: .literal(declaration: -4)
        )
    )
        XCTAssertEqual(
            hugeOperation3.abbreviation,
            "m__degC_per_A__per_s_pwr_neg4"
        )
    }

    /// Test the abbreviation is correct.
    func testAbbreviation0Case() {
        let operation = Operation.division(
        lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
        rhs: Operation.exponentiate(
            base: Operation.constant(declaration: AnyUnit(TimeUnits.seconds)),
            power: Operation.literal(declaration: 0)
        )
    )
        XCTAssertEqual(operation.abbreviation, "m")
    }

    /// Test the abbreviation is correct.
    func testAbbreviation1Case() {
        let operation = Operation.division(
        lhs: Operation.constant(declaration: AnyUnit(DistanceUnits.metres)),
        rhs: Operation.exponentiate(
            base: Operation.constant(declaration: AnyUnit(TimeUnits.seconds)),
            power: Operation.literal(declaration: 1)
        )
    )
        XCTAssertEqual(operation.abbreviation, "m_per_s")
    }

    /// Test the abbreviation of the case where the unit is an inverse.
    func testAbbreviationNeg1Case() {
        let operation = Operation.division(
            lhs: .literal(declaration: 1),
            rhs: Operation.constant(declaration: AnyUnit(TimeUnits.seconds))
        )
        XCTAssertEqual(operation.abbreviation, "s_pwr_neg1")
    }

}
