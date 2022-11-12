/*
 * TestFunctionBodyCreatorTests.swift 
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

/// Test class for TestFunctionBodyCreator.
final class TestFunctionBodyCreatorTests: XCTestCase {

    /// The creator being tested.
    let creator = TestFunctionBodyCreator<DistanceUnits>()

    /// Test generate function for unit to unit conversion.
    func testGenerateFunctionUnits() {
        let result = creator.generateFunction(
            from: .centimetres,
            with: .f,
            to: .centimetres,
            with: .u,
            using: [TestParameters(input: "53.0", output: "53")]
        )
        let expected = "XCTAssertEqual(cm_f_to_cm_u(53.0), 53)"
        XCTAssertEqual(result, expected)
    }

    /// Test generate function for unit to numeric conversion.
    func testGenerateFunctionUnitsToNumeric() {
        let result = creator.generateFunction(
            from: .centimetres, with: .t, to: .float, using: [TestParameters(input: "10", output: "10.0")]
        )
        let expected = """
        let result = cm_t_to_f(10)
        let expected: Float = 10.0
        let tolerance: Float = 0.99
        if result > expected {
            XCTAssertLessThanOrEqual(result - expected, tolerance)
        } else {
            XCTAssertLessThanOrEqual(expected - result, tolerance)
        }
        """
        XCTAssertEqual(result, expected)
    }

    /// Test generate function for numeric to unit conversion.
    func testGenerateFunctionNumericToUnits() {
        let result = creator.generateFunction(
            from: .int16, to: .millimetres, with: .u, using: [TestParameters(input: "125", output: "125")]
        )
        let expected = "XCTAssertEqual(i16_to_mm_u(125), 125)"
        XCTAssertEqual(result, expected)
    }

    /// Test Integer Literal -> Double
    func testSanitiseLiteralForIntegerLiteralToDouble() {
        let result = creator.sanitiseLiteral(literal: "5", sign: .d)
        XCTAssertEqual(result, "5.0")
    }

    /// Test Integer Literal -> Unsigned
    func testSanitiseLiteralForIntegerLiteralToUnsigned() {
        let result = creator.sanitiseLiteral(literal: "5", sign: .u)
        XCTAssertEqual(result, "5")
    }

    /// Test Integer Literal -> Float
    func testSanitiseLiteralForIntegerLiteralToFloat() {
        let result = creator.sanitiseLiteral(literal: "5", sign: .f)
        XCTAssertEqual(result, "5.0")
    }

    /// Test String Literal -> Unsigned
    func testSanitiseLiteralForStringLiteralToUnsigned() {
        let result = creator.sanitiseLiteral(literal: "UINT_MAX", sign: .f)
        XCTAssertEqual(result, "UINT_MAX")
    }

    /// Test Double Literal -> Integer
    func testSanitiseLiteralForDoubleLiteralToInteger() {
        let result = creator.sanitiseLiteral(literal: "5.0", sign: .t)
        XCTAssertEqual(result, "5")
    }

    /// Test Double Literal -> Float
    func testSanitiseLiteralForDoubleLiteralToFloat() {
        let result = creator.sanitiseLiteral(literal: "5.0", sign: .f)
        XCTAssertEqual(result, "5.0")
    }

    /// Test empty literal.
    func testSanitiseLiteralForEmptyString() {
        let result = creator.sanitiseLiteral(literal: "", sign: .d)
        XCTAssertEqual(result, "")
    }

    /// Test negative non-numeric input.
    func testSanitiseLiteralForNegativeFloatToDouble() {
        let result = creator.sanitiseLiteral(literal: "-Float.greatestFiniteMagnitude", to: .double)
        let expected = "-Float.greatestFiniteMagnitude"
        XCTAssertEqual(result, expected)
    }

    /// Test sanitise literal performs round correctly.
    func testSanitiseLiteralRounding() {
        let result = creator.sanitiseLiteral(literal: "-23.75", sign: .t)
        XCTAssertEqual(result, "-24")
        let result2 = creator.sanitiseLiteral(literal: "23.75", sign: .t)
        XCTAssertEqual(result2, "24")
        let result3 = creator.sanitiseLiteral(literal: "23.25", sign: .u)
        XCTAssertEqual(result3, "23")
        let result4 = creator.sanitiseLiteral(literal: "23.25", sign: .t)
        XCTAssertEqual(result4, "23")
        let result5 = creator.sanitiseLiteral(literal: "23.75", sign: .u)
        XCTAssertEqual(result5, "24")
        let result6 = creator.sanitiseLiteral(literal: "-23.25", sign: .t)
        XCTAssertEqual(result6, "-23")
    }

}
