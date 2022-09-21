// TemperatureTestGeneratorDegCDegFTests.swift 
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

/// Test class for TemperatureTestGenerator celsius to Fahrenheit conversions.
final class TemperatureTestGeneratorDegCDegFTests: XCTestCase, TestParameterTestable, TestConversionTestable {

    /// The generator under test.
    let generator = TemperatureTestGenerator()

    /// All the test cases.
    var conversions: [ConversionTest<TemperatureUnits>] {
        [
            ConversionTest(unit: .celsius, sign: .t, otherUnit: .fahrenheit, otherSign: .t, parameters: [
                TestParameters(input: "CLong.min", output: "fahrenheit_t(CLong.min)"),
                TestParameters(input: "CLong.max", output: "fahrenheit_t(CLong.max)")
            ]),
            ConversionTest(unit: .celsius, sign: .t, otherUnit: .fahrenheit, otherSign: .u, parameters: [
                TestParameters(input: "CLong.min", output: "fahrenheit_u(CUnsignedLong.min)"),
                TestParameters(
                    input: "CLong.max", output: "fahrenheit_u((Double(CLong.max) * 1.8 + 32.0).rounded())"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .t, otherUnit: .fahrenheit, otherSign: .f, parameters: [
                TestParameters(input: "CLong.min", output: "fahrenheit_f(Double(CLong.min) * 1.8 + 32.0)"),
                TestParameters(input: "CLong.max", output: "fahrenheit_f(Double(CLong.max) * 1.8 + 32.0)")
            ]),
            ConversionTest(unit: .celsius, sign: .t, otherUnit: .fahrenheit, otherSign: .d, parameters: [
                TestParameters(input: "CLong.min", output: "fahrenheit_d(Double(CLong.min) * 1.8 + 32.0)"),
                TestParameters(input: "CLong.max", output: "fahrenheit_d(Double(CLong.max) * 1.8 + 32.0)")
            ]),
            ConversionTest(unit: .celsius, sign: .u, otherUnit: .fahrenheit, otherSign: .t, parameters: [
                TestParameters(
                    input: "CUnsignedLong.min",
                    output: "fahrenheit_t((Double(CUnsignedLong.min) * 1.8 + 32.0).rounded())"
                ),
                TestParameters(input: "CUnsignedLong.max", output: "fahrenheit_t(CLong.max)")
            ]),
            ConversionTest(unit: .celsius, sign: .u, otherUnit: .fahrenheit, otherSign: .u, parameters: [
                // 0 -> 32 is already tested in default tests.
                TestParameters(input: "CUnsignedLong.max", output: "fahrenheit_u(CUnsignedLong.max)")
            ]),
            ConversionTest(unit: .celsius, sign: .u, otherUnit: .fahrenheit, otherSign: .f, parameters: [
                TestParameters(
                    input: "CUnsignedLong.min", output: "fahrenheit_f(Double(CUnsignedLong.min) * 1.8 + 32.0)"
                ),
                TestParameters(
                    input: "CUnsignedLong.max", output: "fahrenheit_f(Double(CUnsignedLong.max) * 1.8 + 32.0)"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .u, otherUnit: .fahrenheit, otherSign: .d, parameters: [
                TestParameters(
                    input: "CUnsignedLong.min", output: "fahrenheit_d(Double(CUnsignedLong.min) * 1.8 + 32.0)"
                ),
                TestParameters(
                    input: "CUnsignedLong.max", output: "fahrenheit_d(Double(CUnsignedLong.max) * 1.8 + 32.0)"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .f, otherUnit: .fahrenheit, otherSign: .t, parameters: [
                TestParameters(input: "-Float.greatestFiniteMagnitude", output: "fahrenheit_t(CLong.min)"),
                TestParameters(input: "Float.greatestFiniteMagnitude", output: "fahrenheit_t(CLong.max)")
            ]),
            ConversionTest(unit: .celsius, sign: .f, otherUnit: .fahrenheit, otherSign: .u, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude", output: "fahrenheit_u(CUnsignedLong.min)"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude", output: "fahrenheit_u(CUnsignedLong.max)"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .f, otherUnit: .fahrenheit, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude",
                    output: "fahrenheit_f(-Float.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude",
                    output: "fahrenheit_f(Float.greatestFiniteMagnitude)"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .f, otherUnit: .fahrenheit, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude",
                    output: "fahrenheit_d(Double(-Float.greatestFiniteMagnitude) * 1.8 + 32.0)"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude",
                    output: "fahrenheit_d(Double(Float.greatestFiniteMagnitude) * 1.8 + 32.0)"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .d, otherUnit: .fahrenheit, otherSign: .t, parameters: [
                TestParameters(input: "-Double.greatestFiniteMagnitude", output: "fahrenheit_t(CLong.min)"),
                TestParameters(input: "Double.greatestFiniteMagnitude", output: "fahrenheit_t(CLong.max)")
            ]),
            ConversionTest(unit: .celsius, sign: .d, otherUnit: .fahrenheit, otherSign: .u, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude", output: "fahrenheit_u(CUnsignedLong.min)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude", output: "fahrenheit_u(CUnsignedLong.max)"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .d, otherUnit: .fahrenheit, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude",
                    output: "fahrenheit_f(-Float.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude",
                    output: "fahrenheit_f(Float.greatestFiniteMagnitude)"
                )
            ]),
            ConversionTest(unit: .celsius, sign: .d, otherUnit: .fahrenheit, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude",
                    output: "fahrenheit_d(-Double.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude",
                    output: "fahrenheit_d(Double.greatestFiniteMagnitude)"
                )
            ])
        ]
    }

    /// Test all conversion functions against their respective test cases.
    func testAll() {
        conversions.forEach {
            self.doTest(conversion: $0)
        }
    }

    /// Create default test parameters for a celsius to fahrenheit conversion.
    /// - Parameters:
    ///   - sign: The sign of the celsius parameter.
    ///   - otherSign: The sign of the fahrenheit parameter.
    ///   - additional: Additional tests.
    /// - Returns: A set of default test cases to be tested against the conversion function.
    func expected(
        from sign: Signs, to otherSign: Signs, additional: Set<TestParameters>
    ) -> Set<TestParameters> {
        let creator = TestFunctionBodyCreator<TemperatureUnits>()
        var newTests: Set<TestParameters> = additional.union(
            Set(
                [
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "0", sign: sign),
                        output: creator.sanitiseLiteral(literal: "32", sign: otherSign)
                    ),
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "0.85", sign: sign),
                        output: creator.sanitiseLiteral(literal: "33.53", sign: otherSign)
                    ),
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "25", sign: sign),
                        output: creator.sanitiseLiteral(literal: "77", sign: otherSign)
                    ),
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "2", sign: sign),
                        output: creator.sanitiseLiteral(literal: "35.6", sign: otherSign)
                    )
                ]
            )
        )
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests = newTests.union(
                Set(
                    [
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-573.01", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-999.418", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-272.15", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-457.87", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-268", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-450.40", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-273.03", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-459.454", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-20", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-4", sign: otherSign)
                        )
                    ]
                )
            )
        }
        return newTests
    }

}
