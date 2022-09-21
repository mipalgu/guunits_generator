// TemperatureTestGeneratorKDegCTests.swift 
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

/// Test class for Kelvin to celsius conversions.
final class TemperatureTestGeneratorKDegCTests: XCTestCase, TestParameterTestable, TestConversionTestable {

    /// The generator under test.
    let generator = TemperatureTestGenerator()

    /// The conversions to test.
    var conversions: [ConversionTest<TemperatureUnits>] {
        [
            ConversionTest(unit: .kelvin, sign: .t, otherUnit: .celsius, otherSign: .t, parameters: [
                TestParameters(input: "CLong.min", output: "celsius_t(CLong.min)"),
                TestParameters(input: "CLong.max", output: "celsius_t(CLong.max) - 273")
            ]),
            ConversionTest(unit: .kelvin, sign: .t, otherUnit: .celsius, otherSign: .u, parameters: [
                TestParameters(input: "CLong.min", output: "celsius_u(CUnsignedLong.min)"),
                TestParameters(input: "CLong.max", output: "celsius_u(CLong.max) - 273")
            ]),
            ConversionTest(unit: .kelvin, sign: .t, otherUnit: .celsius, otherSign: .d, parameters: [
                TestParameters(input: "CLong.min", output: "celsius_d(CLong.min) - 273.15"),
                TestParameters(input: "CLong.max", output: "celsius_d(CLong.max) - 273.15")
            ]),
            ConversionTest(unit: .kelvin, sign: .t, otherUnit: .celsius, otherSign: .f, parameters: [
                TestParameters(input: "CLong.min", output: "celsius_f(CLong.min) - 273.15"),
                TestParameters(input: "CLong.max", output: "celsius_f(CLong.max) - 273.15")
            ]),
            ConversionTest(unit: .kelvin, sign: .u, otherUnit: .celsius, otherSign: .t, parameters: [
                TestParameters(input: "CUnsignedLong.min", output: "celsius_t(CUnsignedLong.min) - 273"),
                TestParameters(input: "CUnsignedLong.max", output: "celsius_t(CLong.max)")
            ]),
            ConversionTest(unit: .kelvin, sign: .u, otherUnit: .celsius, otherSign: .u, parameters: [
                TestParameters(input: "CUnsignedLong.min", output: "celsius_u(CUnsignedLong.min)"),
                TestParameters(input: "CUnsignedLong.max", output: "celsius_u(CUnsignedLong.max) - 273")
            ]),
            ConversionTest(unit: .kelvin, sign: .u, otherUnit: .celsius, otherSign: .f, parameters: [
                TestParameters(input: "CUnsignedLong.min", output: "celsius_f(CUnsignedLong.min) - 273.15"),
                TestParameters(input: "CUnsignedLong.max", output: "celsius_f(CUnsignedLong.max) - 273.15")
            ]),
            ConversionTest(unit: .kelvin, sign: .u, otherUnit: .celsius, otherSign: .d, parameters: [
                TestParameters(input: "CUnsignedLong.min", output: "celsius_d(CUnsignedLong.min) - 273.15"),
                TestParameters(input: "CUnsignedLong.max", output: "celsius_d(CUnsignedLong.max) - 273.15")
            ]),
            ConversionTest(unit: .kelvin, sign: .f, otherUnit: .celsius, otherSign: .t, parameters: [
                TestParameters(input: "-Float.greatestFiniteMagnitude", output: "celsius_t(CLong.min)"),
                TestParameters(input: "Float.greatestFiniteMagnitude", output: "celsius_t(CLong.max)")
            ]),
            ConversionTest(unit: .kelvin, sign: .f, otherUnit: .celsius, otherSign: .u, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude", output: "celsius_u(CUnsignedLong.min)"
                ),
                TestParameters(input: "Float.greatestFiniteMagnitude", output: "celsius_u(CUnsignedLong.max)")
            ]),
            ConversionTest(unit: .kelvin, sign: .f, otherUnit: .celsius, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude",
                    output: "celsius_f(-Float.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude",
                    output: "celsius_f(Float.greatestFiniteMagnitude) - 273.15"
                )
            ]),
            ConversionTest(unit: .kelvin, sign: .f, otherUnit: .celsius, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude",
                    output: "celsius_d(-Float.greatestFiniteMagnitude) - 273.15"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude",
                    output: "celsius_d(Float.greatestFiniteMagnitude) - 273.15"
                )
            ]),
            ConversionTest(unit: .kelvin, sign: .d, otherUnit: .celsius, otherSign: .t, parameters: [
                TestParameters(input: "-Double.greatestFiniteMagnitude", output: "celsius_t(CLong.min)"),
                TestParameters(input: "Double.greatestFiniteMagnitude", output: "celsius_t(CLong.max)")
            ]),
            ConversionTest(unit: .kelvin, sign: .d, otherUnit: .celsius, otherSign: .u, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude", output: "celsius_u(CUnsignedLong.min)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude", output: "celsius_u(CUnsignedLong.max)"
                )
            ]),
            ConversionTest(unit: .kelvin, sign: .d, otherUnit: .celsius, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude",
                    output: "celsius_f(-Float.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude",
                    output: "celsius_f(Float.greatestFiniteMagnitude)"
                )
            ]),
            ConversionTest(unit: .kelvin, sign: .d, otherUnit: .celsius, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude",
                    output: "celsius_d(-Double.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude",
                    output: "celsius_d(Double.greatestFiniteMagnitude) - 273.15"
                )
            ])
        ]
    }

    /// Perform the tests.
    func testConversions() {
        conversions.forEach {
            self.doTest(conversion: $0)
        }
    }

    /// Create default test parameters for a conversion from Kelvin to Celsius.
    /// - Parameters:
    ///   - sign: The sign of the kelvin parameter.
    ///   - otherSign: The sign of the celsius parameter.
    ///   - additional: Additional tests.
    /// - Returns: A set of all test cases to be tested against the conversion function.
    func expected(
        from sign: Signs, to otherSign: Signs, additional: Set<TestParameters>
    ) -> Set<TestParameters> {
        let creator = TestFunctionBodyCreator<TemperatureUnits>()
        var newTests: Set<TestParameters> = additional.union(
            Set<TestParameters>(
                [
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "273.15", sign: sign),
                        output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                    ),
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "274", sign: sign),
                        output: creator.sanitiseLiteral(literal: "0.85", sign: otherSign)
                    )
                ]
            )
        )
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests.insert(
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-300", sign: sign),
                    output: creator.sanitiseLiteral(literal: "-573.15", sign: otherSign)
                )
            )
        }
        if otherSign.numericType.isSigned {
            newTests = newTests.union(
                Set<TestParameters>(
                    [
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "1.0", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-272.15", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "5.0", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-268.15", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "0", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-273.15", sign: otherSign)
                        )
                    ]
                )
            )
        }
        return newTests
    }

}
