/*
 * TemperatureFunctionCreatorTests.swift 
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

/// Test class for TemperatureFunctionCreator.
final class TemperatureFunctionCreatorTests: XCTestCase {

    /// The creator being tested.
    let creator = TemperatureFunctionCreator()

    // swiftlint:disable missing_docs

    func testCelsiusToKelvinInteger() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .t, otherSign: .t)
        let expected = """
            if (celsius > (9223372036854775807 - 273)) {
                return ((kelvin_t) (9223372036854775807));
            }
            return ((kelvin_t) (celsius + 273));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinIntegerToUnsigned() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .t, otherSign: .u)
        let expected = """
            if (celsius < -273) {
                return ((kelvin_u) (0));
            }
            if (celsius < 0) {
                return ((kelvin_u) (celsius + 273));
            }
            return (((kelvin_u) (celsius)) + 273);
        """
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
        let expected = """
            if (celsius > (FLT_MAX - 273.15f)) {
                return ((kelvin_f) (FLT_MAX));
            }
            return ((kelvin_f) (celsius + 273.15f));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinFloatToInteger() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .f, otherSign: .t)
        let expected = """
            const celsius_f upperLimit = ((celsius_f) (9223372036854775807));
            const celsius_f lowerLimit = ((celsius_f) (-9223372036854775807 - 1));
            if (celsius > (upperLimit - 273.15f)) {
                return ((kelvin_t) (9223372036854775807));
            } else if (celsius < (lowerLimit - 273.15f)) {
                return ((kelvin_t) (-9223372036854775807 - 1));
            }
            return ((kelvin_t) (roundf(celsius + 273.15f)));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinFloatToUnsigned() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .f, otherSign: .u)
        let expected = """
            const celsius_f upperLimit = ((celsius_f) (18446744073709551615U));
            const celsius_f lowerLimit = ((celsius_f) (0));
            if (celsius > (upperLimit - 273.15f)) {
                return ((kelvin_u) (18446744073709551615U));
            } else if (celsius < (lowerLimit - 273.15f)) {
                return ((kelvin_u) (0));
            }
            return ((kelvin_u) (roundf(celsius + 273.15f)));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinFloatToDouble() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .f, otherSign: .d)
        let expected = "    return ((kelvin_d) (((double) (celsius)) + 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinDouble() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .d, otherSign: .d)
        let expected = """
            if (celsius > (DBL_MAX - 273.15)) {
                return ((kelvin_d) (DBL_MAX));
            }
            return ((kelvin_d) (celsius + 273.15));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinUnsigned() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .u, otherSign: .u)
        let expected = """
            if (celsius > (18446744073709551615U - 273)) {
                return ((kelvin_u) (18446744073709551615U));
            }
            return ((kelvin_u) (celsius + 273));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToKelvinUnsignedToInteger() {
        let result = creator.createFunction(unit: .celsius, to: .kelvin, sign: .u, otherSign: .t)
        let expected = """
            if (celsius > (9223372036854775807 - 273)) {
                return ((kelvin_t) (9223372036854775807));
            }
            return ((kelvin_t) (celsius + 273));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .t, otherSign: .t)
        let expected = """
            if (kelvin < (-9223372036854775807 - 1 + 273)) {
                return ((celsius_t) (-9223372036854775807 - 1));
            }
            return ((celsius_t) (kelvin - 273));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusIntegerToUnsigned() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .t, otherSign: .u)
        let expected = """
            if (kelvin < 273) {
                return ((celsius_u) (0));
            }
            return ((celsius_u) (kelvin - 273));
        """
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
        let expected = """
            if (kelvin < (-FLT_MAX + 273.15f)) {
                return ((celsius_f) (-FLT_MAX));
            }
            return ((celsius_f) (kelvin - 273.15f));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusFloatToInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .f, otherSign: .t)
        let expected = """
            const kelvin_f upperLimit = ((kelvin_f) (9223372036854775807));
            const kelvin_f lowerLimit = ((kelvin_f) (-9223372036854775807 - 1));
            if (kelvin < (lowerLimit + 273.15f)) {
                return ((celsius_t) (-9223372036854775807 - 1));
            } else if (kelvin > (upperLimit + 273.15f)) {
                return ((celsius_t) (9223372036854775807));
            }
            return ((celsius_t) (roundf(kelvin - 273.15f)));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusFloatToUnsigned() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .f, otherSign: .u)
        let expected = """
            const kelvin_f upperLimit = ((kelvin_f) (18446744073709551615U));
            const kelvin_f lowerLimit = ((kelvin_f) (0));
            if (kelvin < (lowerLimit + 273.15f)) {
                return ((celsius_u) (0));
            } else if (kelvin > (upperLimit + 273.15f)) {
                return ((celsius_u) (18446744073709551615U));
            }
            return ((celsius_u) (roundf(kelvin - 273.15f)));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusFloatToDouble() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .f, otherSign: .d)
        let expected = "    return ((celsius_d) (((double) (kelvin)) - 273.15));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusDouble() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .d, otherSign: .d)
        let expected = """
            if (kelvin < (-DBL_MAX + 273.15)) {
                return ((celsius_d) (-DBL_MAX));
            }
            return ((celsius_d) (kelvin - 273.15));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusUnsigned() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .u, otherSign: .u)
        let expected = """
            if (kelvin < (0 + 273)) {
                return ((celsius_u) (0));
            }
            return ((celsius_u) (kelvin - 273));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToCelsiusUnsignedToInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .celsius, sign: .u, otherSign: .t)
        let comparison = "((uint64_t) (9223372036854775807))"
        let ternary = "((kelvin - 273) > \(comparison) ? \(comparison) : kelvin - 273)"
        let conversion = "((kelvin_t) \(ternary))"
        let expected = """
            if (kelvin < (0 + 273)) {
                return (((celsius_t) (kelvin)) - 273);
            }
            return ((celsius_t) (\(conversion)));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToFahrenheitInteger() {
        let result = creator.createFunction(unit: .celsius, to: .fahrenheit, sign: .t, otherSign: .t)
        let minString = "MIN(((double) (9223372036854775807)), " +
            "(round(((((double) (celsius)) * 1.8) + 32.0))))"
        let expected = "    return ((fahrenheit_t) (MAX(((double) " +
            "(-9223372036854775807 - 1)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToFahrenheitDouble() {
        let result = creator.createFunction(unit: .celsius, to: .fahrenheit, sign: .d, otherSign: .d)
        let expected = """
            const celsius_d upperLimit = nexttoward((DBL_MAX - 32.0) / 1.8, 0.0);
            const celsius_d lowerLimit = nexttoward((-DBL_MAX) / 1.8, 0.0);
            if (celsius > upperLimit) {
                return ((fahrenheit_d) (DBL_MAX));
            } else if (celsius < lowerLimit) {
                return ((fahrenheit_d) (-DBL_MAX));
            }
            return ((fahrenheit_d) (celsius * 1.8 + 32.0));
        """
        XCTAssertEqual(result, expected)
    }

    func testFahrenheitToCelsiusInteger() {
        let result = creator.createFunction(unit: .fahrenheit, to: .celsius, sign: .t, otherSign: .t)
        let conversion = "((double) (fahrenheit)) * (5.0 / 9.0) - 32.0 * (5.0 / 9.0)"
        let minString = "MIN(((double) (9223372036854775807)), (round(\(conversion))))"
        let expected = "    return ((celsius_t) (MAX(((double) (-9223372036854775807 - 1)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testFahrenheitToCelsiusDouble() {
        let result = creator.createFunction(unit: .fahrenheit, to: .celsius, sign: .d, otherSign: .d)
        let conversion = "fahrenheit * (5.0 / 9.0) - 32.0 * (5.0 / 9.0)"
        let expected = "    return ((celsius_d) (\(conversion)));"
        XCTAssertEqual(result, expected)
    }

    func testFahrenheitToKelvinDouble() {
        let result = creator.createFunction(unit: .fahrenheit, to: .kelvin, sign: .d, otherSign: .d)
        let conversion = "(fahrenheit - 32.0) * (5.0 / 9.0) + 273.15"
        let expected = "    return ((kelvin_d) (\(conversion)));"
        XCTAssertEqual(result, expected)
    }

    func testFahrenheitToKelvinInteger() {
        let result = creator.createFunction(unit: .fahrenheit, to: .kelvin, sign: .t, otherSign: .t)
        let conversion = "(((double) (fahrenheit)) - 32.0) * (5.0 / 9.0) + 273.15"
        let minString = "MIN(((double) (9223372036854775807)), (round(\(conversion))))"
        let expected = "    return ((kelvin_t) (MAX(((double) (-9223372036854775807 - 1)), \(minString))));"
        XCTAssertEqual(result, expected)
    }

    func testKelvinToFahrenheitDouble() {
        let result = creator.createFunction(unit: .kelvin, to: .fahrenheit, sign: .d, otherSign: .d)
        let expected = """
            const double maxValue = (((double) (DBL_MAX)) - 32.0) / 1.8 + 273.15;
            const double minValue = ((double) (-DBL_MAX)) / 1.8 - 32.0 / 1.8 + 273.15;
            const double value = ((double) (kelvin));
            if (value > maxValue) {
                return DBL_MAX;
            }
            if (value < minValue) {
                return -DBL_MAX;
            }
            return ((fahrenheit_d) ((value - 273.15) * 1.8 + 32.0));
        """
        XCTAssertEqual(result, expected)
    }

    func testKelvinToFahrenheitInteger() {
        let result = creator.createFunction(unit: .kelvin, to: .fahrenheit, sign: .t, otherSign: .t)
        let expected = """
            const double maxValue = (((double) (9223372036854775807)) - 32.0) / 1.8 + 273.15;
            const double minValue = ((double) (-9223372036854775807 - 1)) / 1.8 - 32.0 / 1.8 + 273.15;
            const double value = ((double) (kelvin));
            if (value > maxValue) {
                return 9223372036854775807;
            }
            if (value < minValue) {
                return -9223372036854775807 - 1;
            }
            return ((fahrenheit_t) (round((value - 273.15) * 1.8 + 32.0)));
        """
        XCTAssertEqual(result, expected)
    }

    func testCelsiusToCelsiusIntegerToUnsigned() {
        let result = creator.createFunction(unit: .celsius, to: .celsius, sign: .t, otherSign: .u)
        let expected = "    return ((celsius_u) ((celsius) < 0 ? 0 : celsius));"
        XCTAssertEqual(result, expected)
    }

    // swiftlint:enable missing_docs

}
