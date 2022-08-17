// TemperatureTestGeneratorKToDegFTests.swift 
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

/// Test class for TemperatureTestGenerator K to degF conversions.
final class TemperatureTestGeneratorKToDegFTests: XCTestCase, TestParameterTestable, TestConversionTestable {

    /// Helper object for sanitising literal strings.
    let creator = TestFunctionBodyCreator<TemperatureUnits>()

    /// The generator under test.
    let generator = TemperatureTestGenerator()

    /// All conversions to test.
    var conversions: [ConversionTest<TemperatureUnits>] {
        [
            ConversionTest(unit: .kelvin, sign: .t, otherUnit: .fahrenheit, otherSign: .t, parameters: [
                TestParameters(input: "CInt.min", output: "CInt.min"),
                TestParameters(input: "CInt.max", output: "CInt.max")
            ])
        ]
    }

    /// Test all conversions.
    func testAll() {
        conversions.forEach {
            doTest(conversion: $0)
        }
    }

    /// The default test parameters for this conversion.
    /// - Parameters:
    ///   - sign: The sign to convert from.
    ///   - otherSign: The sign to convert to.
    ///   - additional: The default parameters.
    /// - Returns: All the test parameters expected from the conversion.
    func expected(
        from sign: Signs, to otherSign: Signs, additional: Set<TestParameters>
    ) -> Set<TestParameters> {
        let f: (String) -> TestParameters = {
            TestParameters(
                input: self.creator.sanitiseLiteral(literal: $0, sign: sign),
                output: self.conversion(value: $0, sign: sign, otherSign: otherSign)
            )
        }
        var newTests: Set<TestParameters> = additional.union(
            Set(
                [
                    "250",
                    "2500",
                    "25000",
                    "250000",
                    "2500000",
                    "273.15",
                    "300",
                    "100"
                ].map(f)
            )
        )
        if otherSign.numericType.isSigned {
            newTests = newTests.union(
                Set(
                    ["0", "20", "10", "15", "12", "25"].map(f)
                )
            )
        }
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests = newTests.union(
                Set(
                    ["-250", "-2500", "-25000", "-250000", "-2500000", "-40"].map(f)
                )
            )
        }
        if sign.numericType.isSigned && !otherSign.numericType.isSigned {
            newTests = newTests.union(
                Set(
                    ["-2500", "-25000", "-250000", "-2500000"].map {
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: $0, sign: sign),
                            output: "CUnsignedInt.min"
                        )
                    }
                )
            )
        }
        return newTests
    }

    /// Produces a string representing a degrees to radians conversion.
    /// - Parameters:
    ///   - value: The value to convert.
    ///   - sign: The sign of the value.
    ///   - otherSign: The sign of the converted value.
    /// - Returns: A string performing the conversion.
    private func conversion(value: String, sign: Signs, otherSign: Signs) -> String {
        let literal = creator.sanitiseLiteral(literal: value, sign: sign)
        let calculation = "(Double(\(literal)) - 273.15) * 1.8 + 32.0"
        guard otherSign.isFloatingPoint else {
            return "fahrenheit_\(otherSign)((\(calculation)).rounded())"
        }
        return "fahrenheit_\(otherSign)(\(calculation))"
    }

}
