/*
 * TemperatureUnitsTests.swift 
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

@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for TemperatureUnits.
final class TemperatureUnitsTests: XCTestCase, UnitsTestable {

    /// Test celsius.
    func testCelsius() {
        assert(
            value: TemperatureUnits.celsius, rawValue: "celsius", abbreviation: "degC", description: "celsius"
        )
    }

    /// Test fahrenheit
    func testFahrenheit() {
        assert(
            value: TemperatureUnits.fahrenheit,
            rawValue: "fahrenheit",
            abbreviation: "degF",
            description: "fahrenheit"
        )
    }

    /// Test kelvin
    func testKelvin() {
        assert(value: TemperatureUnits.kelvin, rawValue: "kelvin", abbreviation: "K", description: "kelvin")
    }

    /// Test same conversion produces constant operation.
    func testSameConversion() {
        let celsius = TemperatureUnits.celsius
        let fahrenheit = TemperatureUnits.fahrenheit
        let kelvin = TemperatureUnits.kelvin
        XCTAssertEqual(celsius.conversion(to: .celsius), .constant(declaration: AnyUnit(celsius)))
        XCTAssertEqual(fahrenheit.conversion(to: .fahrenheit), .constant(declaration: AnyUnit(fahrenheit)))
        XCTAssertEqual(kelvin.conversion(to: .kelvin), .constant(declaration: AnyUnit(kelvin)))
    }

    /// Test celsius to Kelvin conversion is correct.
    func testCelsiusToKelvinConversion() {
        let unit = TemperatureUnits.celsius
        let expected = Operation.addition(
            lhs: .constant(declaration: AnyUnit(unit)),
            rhs: .literal(declaration: .decimal(value: 273.15))
        )
        XCTAssertEqual(expected, unit.conversion(to: .kelvin))
    }

    /// Test celsius to fahrenheit conversion is correct.
    func testCelsiusToFahrenheitConversion() {
        let unit = TemperatureUnits.celsius
        let expected = Operation.addition(
            lhs: .multiplication(
                lhs: .constant(declaration: AnyUnit(unit)),
                rhs: .literal(declaration: .decimal(value: 1.8))
            ),
            rhs: .literal(declaration: .integer(value: 32))
        )
        XCTAssertEqual(expected, unit.conversion(to: .fahrenheit))
    }

    /// Test kelvin to celsius conversion is correct.
    func testKelvinToCelsiusConversion() {
        let unit = TemperatureUnits.kelvin
        let expected = Operation.subtraction(
            lhs: .constant(declaration: AnyUnit(unit)), rhs: .literal(declaration: .decimal(value: 273.15))
        )
        XCTAssertEqual(expected, unit.conversion(to: .celsius))
    }

    /// Test kelvin to fahrenheit conversion is correct.
    func testKelvinToFahrenheitConversion() {
        let unit = TemperatureUnits.kelvin
        let expected = Operation.addition(
            lhs: .multiplication(
                lhs: .precedence(
                    operation: .subtraction(
                        lhs: .constant(declaration: AnyUnit(unit)),
                        rhs: .literal(declaration: .decimal(value: 273.15))
                    )
                ),
                rhs: .literal(declaration: .decimal(value: 1.8))
            ),
            rhs: .literal(declaration: .integer(value: 32))
        )
        XCTAssertEqual(expected, unit.conversion(to: .fahrenheit))
    }

    /// Test fahrenheit to celsius conversion is correct.
    func testFahrenheitToCelsiusConversion() {
        let unit = TemperatureUnits.fahrenheit
        let expected = Operation.multiplication(
            lhs: .precedence(
                operation: .subtraction(
                    lhs: .constant(declaration: AnyUnit(unit)),
                    rhs: .literal(declaration: .integer(value: 32))
                )
            ),
            rhs: .division(
                lhs: .literal(declaration: .integer(value: 5)),
                rhs: .literal(declaration: .integer(value: 9))
            )
        )
        XCTAssertEqual(expected, unit.conversion(to: .celsius))
    }

    /// Test fahrenheit to Kelvin conversion is correct.
    func testFahrenheitToKelvinConversion() {
        let unit = TemperatureUnits.fahrenheit
        let expected = Operation.addition(
            lhs: .multiplication(
                lhs: .precedence(
                    operation: .subtraction(
                        lhs: .constant(declaration: AnyUnit(unit)),
                        rhs: .literal(declaration: .integer(value: 32))
                    )
                ),
                rhs: .division(
                    lhs: .literal(declaration: .integer(value: 5)),
                    rhs: .literal(declaration: .integer(value: 9))
                )
            ),
            rhs: .literal(declaration: .decimal(value: 273.15))
        )
        XCTAssertEqual(expected, unit.conversion(to: .kelvin))
    }

}
