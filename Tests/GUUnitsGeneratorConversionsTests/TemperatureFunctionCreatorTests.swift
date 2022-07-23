// /*
//  * TemperatureFunctionCreatorTests.swift 
//  * guunits_generator 
//  *
//  * Created by Morgan McColl.
//  * Copyright © 2022 Morgan McColl. All rights reserved.
//  *
//  * Redistribution and use in source and binary forms, with or without
//  * modification, are permitted provided that the following conditions
//  * are met:
//  *
//  * 1. Redistributions of source code must retain the above copyright
//  *    notice, this list of conditions and the following disclaimer.
//  *
//  * 2. Redistributions in binary form must reproduce the above
//  *    copyright notice, this list of conditions and the following
//  *    disclaimer in the documentation and/or other materials
//  *    provided with the distribution.
//  *
//  * 3. All advertising materials mentioning features or use of this
//  *    software must display the following acknowledgement:
//  *
//  *        This product includes software developed by Morgan McColl.
//  *
//  * 4. Neither the name of the author nor the names of contributors
//  *    may be used to endorse or promote products derived from this
//  *    software without specific prior written permission.
//  *
//  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
//  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  *
//  * -----------------------------------------------------------------------
//  * This program is free software; you can redistribute it and/or
//  * modify it under the above terms or under the terms of the GNU
//  * General Public License as published by the Free Software Foundation;
//  * either version 2 of the License, or (at your option) any later version.
//  *
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program; if not, see http://www.gnu.org/licenses/
//  * or write to the Free Software Foundation, Inc., 51 Franklin Street,
//  * Fifth Floor, Boston, MA  02110-1301, USA.
//  *
//  */
// 

@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for TemperatureFunctionCreator.
final class TemperatureFunctionCreatorTests: XCTestCase {

    /// The creator being tested.
    let creator = TemperatureFunctionCreator()

    func testCelsiusToKelvinInteger() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .t, otherSign: .t)
        let expected = "    return ((kelvin_t) (celsius + 273));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinIntegerToUnsigned() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .t, otherSign: .u)
        let expected = "    return ((kelvin_u) ((celsius + 273) < 0 ? 0 : celsius + 273));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinIntegerToFloat() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .t, otherSign: .f)
        let expected = "    return ((kelvin_f) (((double) (celsius)) + 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinIntegerToDouble() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .t, otherSign: .d)
        let expected = "    return ((kelvin_d) (((double) (celsius)) + 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinFloat() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .f, otherSign: .f)
        let expected = "    return ((kelvin_f) (celsius + 273.15f));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinFloatToInteger() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .f, otherSign: .t)
        let minString = "MIN(((double) (INT_MAX)), (round(((double) (celsius)) + 273.15)))"
        let expected = "    return ((kelvin_t) (MAX(((double) (INT_MIN)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinFloatToUnsigned() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .f, otherSign: .u)
        let minString = "MIN(((double) (UINT_MAX)), (round(((double) (celsius)) + 273.15)))"
        let expected = "    return ((kelvin_u) (MAX(((double) (0)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinFloatToDouble() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .f, otherSign: .d)
        let expected = "    return ((kelvin_d) (((double) (celsius)) + 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinDouble() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .d, otherSign: .d)
        let expected = "    return ((kelvin_d) (celsius + 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinUnsigned() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .u, otherSign: .u)
        let expected = "    return ((kelvin_u) (celsius + 273));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinUnsignedToInteger() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .u, otherSign: .t)
        let comparison = "((unsigned int) (INT_MAX))"
        let addition = "celsius + 273"
        let ternary = "((\(addition)) > \(comparison) ? \(comparison) : \(addition))"
        let expected = "    return ((kelvin_t) \(ternary));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .t, otherSign: .t)
        let expected = "    return ((celsius_t) (kelvin - 273));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusIntegerToUnsigned() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .t, otherSign: .u)
        let expected = "    return ((celsius_u) ((kelvin - 273) < 0 ? 0 : kelvin - 273));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusIntegerToFloat() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .t, otherSign: .f)
        let expected = "    return ((celsius_f) (((double) (kelvin)) - 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusIntegerToDouble() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .t, otherSign: .d)
        let expected = "    return ((celsius_d) (((double) (kelvin)) - 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusFloat() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .f, otherSign: .f)
        let expected = "    return ((celsius_f) (kelvin - 273.15f));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusFloatToInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .f, otherSign: .t)
        let minString = "MIN(((double) (INT_MAX)), (round(((double) (kelvin)) - 273.15)))"
        let expected = "    return ((celsius_t) (MAX(((double) (INT_MIN)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusFloatToUnsigned() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .f, otherSign: .u)
        let minString = "MIN(((double) (UINT_MAX)), (round(((double) (kelvin)) - 273.15)))"
        let expected = "    return ((celsius_u) (MAX(((double) (0)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusFloatToDouble() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .f, otherSign: .d)
        let expected = "    return ((celsius_d) (((double) (kelvin)) - 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusDouble() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .d, otherSign: .d)
        let expected = "    return ((celsius_d) (kelvin - 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusUnsigned() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .u, otherSign: .u)
        let expected = "    return ((celsius_u) (kelvin - 273));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusUnsignedToInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .u, otherSign: .t)
        let comparison = "((unsigned int) (INT_MAX))"
        let addition = "kelvin - 273"
        let ternary = "((\(addition)) > \(comparison) ? \(comparison) : \(addition))"
        let expected = "    return ((celsius_t) \(ternary));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToFahrenheitInteger() {
        let result = creator.createFunction(unit: .celsius, to: .fahrenheit, sign: .t, otherSign: .t)
        let minString = "MIN(((double) (INT_MAX)), (round(((((double) (celsius)) * 1.8) + 32.0))))"
        let expected = "    return ((fahrenheit_t) (MAX(((double) (INT_MIN)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToFahrenheitDouble() {
        let result = creator.createFunction(unit: .celsius, to: .fahrenheit, sign: .d, otherSign: .d)
        let expected = "    return ((fahrenheit_d) (celsius * 1.8 + 32.0));"
        XCTAssertEqual(result, expected)
    }

    func testFahrenheitToCelsiusInteger() {
        let result = creator.createFunction(unit: .fahrenheit, to: .celsius, sign: .t, otherSign: .t)
        let conversion = "(((double) (fahrenheit)) - 32.0) * (5.0 / 9.0)"
        let minString = "MIN(((double) (INT_MAX)), (round(\(conversion))))"
        let expected = "    return ((celsius_t) (MAX(((double) (INT_MIN)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testFahrenheitToCelsiusDouble() {
        let result = creator.createFunction(unit: .fahrenheit, to: .celsius, sign: .d, otherSign: .d)
        let conversion = "(fahrenheit - 32.0) * (5.0 / 9.0)"
        let expected = "    return ((celsius_d) (\(conversion)));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToFahrenheitDouble() {
        let result = creator.createFunction(unit: .kelvin, to: .fahrenheit, sign: .d, otherSign: .d)
        let conversion = "(kelvin - 305.15) * (5.0 / 9.0)"
        let expected = "    return ((fahrenheit_d) (\(conversion)));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToFahrenheitInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .fahrenheit, sign: .t, otherSign: .t)
        let conversion = "(((double) (kelvin)) - 305.15) * (5.0 / 9.0)"
        let minString = "MIN(((double) (INT_MAX)), (round(\(conversion))))"
        let expected = "    return ((fahrenheit_t) (MAX(((double) (INT_MIN)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

}
