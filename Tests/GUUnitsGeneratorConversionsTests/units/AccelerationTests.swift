// AccelerationUnitsTests.swift 
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

/// Test class for ``Acceleration``.
final class AccelerationTests: XCTestCase {

    /// Test the base unit matches the Acceleration SI unit.
    func testBaseUnit() {
        let result = Acceleration.baseUnit
        let expected = Operation.division(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: .exponentiate(
                base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: .literal(declaration: .integer(value: 2))
            )
        )
        XCTAssertEqual(result, expected)
    }

    /// Test that the test parameters match the default parameters.
    func testTestParameters() {
        XCTAssertEqual(Acceleration.testParameters, Acceleration.defaultParameters)
    }

    /// Test init sets properties correctly.
    func testInit() {
        let acceleration = Acceleration(unit: Acceleration.baseUnit)
        XCTAssertEqual(acceleration.unit, Acceleration.baseUnit)
    }

    /// Test metresPerSecond2 is set correctly.
    func testMetresPerSecond2() {
        let result = Acceleration.metresPerSecond2
        let expected = AnyUnit(
            Acceleration(
                unit: .division(
                    lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
                    rhs: .exponentiate(
                        base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                        power: .literal(declaration: .integer(value: 2))
                    )
                )
            )
        )
        XCTAssertEqual(result, expected)
    }

    /// Test relationships contain the operation to Earth G.
    func testRelationships() {
        let result = Acceleration.relationships
        let mps2 = Operation.division(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: .exponentiate(
                base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: .literal(declaration: .integer(value: 2))
            )
        )
        let operation = Operation.division(
            lhs: .constant(declaration: Acceleration.metresPerSecond2),
            rhs: .literal(declaration: .decimal(value: Double.earthAcceleration))
        )
        let target = AnyUnit(ReferenceAcceleration.earthG)
        let expected = Acceleration.allCases.map {
            let unit = AnyUnit($0)
            guard unit != Acceleration.metresPerSecond2 else {
                return Relation(
                    source: unit, target: target, operation: operation
                )
            }
            let newOperation = operation.replace(
                convertibles: [Acceleration.metresPerSecond2: $0.conversion(to: Acceleration(unit: mps2))]
            )
            return Relation(source: unit, target: target, operation: newOperation)
        }
        XCTAssertEqual(result, expected)
    }

}
