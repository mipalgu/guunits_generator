// DistanceTestGeneratorCMMMTests.swift 
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

/// Test class for DistanceTestGenerator cm -> mm conversions.
final class DistanceTestGeneratorCMMMTests: XCTestCase, TestParameterTestable, TestConversionTestable {

    /// The generator under test.
    let generator = GradualTestGenerator<DistanceUnits>(unitDifference: [
        .millimetres: 10,
        .centimetres: 100
    ])

    /// All the test cases.
    var conversions: [ConversionTest<DistanceUnits>] {
        [
            ConversionTest(unit: .centimetres, sign: .t, otherUnit: .millimetres, otherSign: .t, parameters: [
                TestParameters(input: "CInt.min", output: "millimetres_t(CInt.min)"),
                TestParameters(input: "CInt.max", output: "millimetres_t(CInt.max)")
            ]),
            ConversionTest(unit: .centimetres, sign: .t, otherUnit: .millimetres, otherSign: .u, parameters: [
                TestParameters(input: "CInt.min", output: "0"),
                TestParameters(input: "CInt.max", output: "millimetres_u(CUnsignedInt.max)")
            ]),
            ConversionTest(unit: .centimetres, sign: .t, otherUnit: .millimetres, otherSign: .f, parameters: [
                TestParameters(input: "CInt.min", output: "millimetres_f(CInt.min) * 10.0"),
                TestParameters(input: "CInt.max", output: "millimetres_f(CInt.max) * 10.0")
            ]),
            ConversionTest(unit: .centimetres, sign: .t, otherUnit: .millimetres, otherSign: .d, parameters: [
                TestParameters(input: "CInt.min", output: "millimetres_d(CInt.min) * 10.0"),
                TestParameters(input: "CInt.max", output: "millimetres_d(CInt.max) * 10.0")
            ]),
            ConversionTest(unit: .centimetres, sign: .u, otherUnit: .millimetres, otherSign: .t, parameters: [
                TestParameters(input: "CUnsignedInt.min", output: "millimetres_t(CUnsignedInt.min) * 10"),
                TestParameters(input: "CUnsignedInt.max", output: "millimetres_t(CInt.max)")
            ]),
            ConversionTest(unit: .centimetres, sign: .u, otherUnit: .millimetres, otherSign: .u, parameters: [
                TestParameters(input: "CUnsignedInt.min", output: "millimetres_u(CUnsignedInt.min)"),
                TestParameters(input: "CUnsignedInt.max", output: "millimetres_u(CUnsignedInt.max)")
            ]),
            ConversionTest(unit: .centimetres, sign: .u, otherUnit: .millimetres, otherSign: .f, parameters: [
                TestParameters(input: "CUnsignedInt.min", output: "millimetres_f(CUnsignedInt.min) * 10.0"),
                TestParameters(input: "CUnsignedInt.max", output: "millimetres_f(CUnsignedInt.max) * 10.0")
            ]),
            ConversionTest(unit: .centimetres, sign: .u, otherUnit: .millimetres, otherSign: .d, parameters: [
                TestParameters(input: "CUnsignedInt.min", output: "millimetres_d(CUnsignedInt.min) * 10.0"),
                TestParameters(input: "CUnsignedInt.max", output: "millimetres_d(CUnsignedInt.max) * 10.0")
            ]),
            ConversionTest(unit: .centimetres, sign: .f, otherUnit: .millimetres, otherSign: .t, parameters: [
                TestParameters(input: "-Float.greatestFiniteMagnitude", output: "millimetres_t(CInt.min)"),
                TestParameters(input: "Float.greatestFiniteMagnitude", output: "millimetres_t(CInt.max)")
            ]),
            ConversionTest(unit: .centimetres, sign: .f, otherUnit: .millimetres, otherSign: .u, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude", output: "millimetres_u(CUnsignedInt.min)"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude", output: "millimetres_u(CUnsignedInt.max)"
                )
            ]),
            ConversionTest(unit: .centimetres, sign: .f, otherUnit: .millimetres, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude",
                    output: "millimetres_f(-Float.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude",
                    output: "millimetres_f(Float.greatestFiniteMagnitude)"
                )
            ]),
            ConversionTest(unit: .centimetres, sign: .f, otherUnit: .millimetres, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude",
                    output: "millimetres_d(-Float.greatestFiniteMagnitude) * 10.0"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude",
                    output: "millimetres_d(Float.greatestFiniteMagnitude) * 10.0"
                )
            ]),
            ConversionTest(unit: .centimetres, sign: .d, otherUnit: .millimetres, otherSign: .t, parameters: [
                TestParameters(input: "-Double.greatestFiniteMagnitude", output: "millimetres_t(CInt.min)"),
                TestParameters(input: "Double.greatestFiniteMagnitude", output: "millimetres_t(CInt.max)")
            ]),
            ConversionTest(unit: .centimetres, sign: .d, otherUnit: .millimetres, otherSign: .u, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude", output: "millimetres_u(CUnsignedInt.min)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude", output: "millimetres_u(CUnsignedInt.max)"
                )
            ]),
            ConversionTest(unit: .centimetres, sign: .d, otherUnit: .millimetres, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude",
                    output: "millimetres_f(-Float.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude",
                    output: "millimetres_f(Float.greatestFiniteMagnitude)"
                )
            ]),
            ConversionTest(unit: .centimetres, sign: .d, otherUnit: .millimetres, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude",
                    output: "millimetres_d(-Double.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude",
                    output: "millimetres_d(Double.greatestFiniteMagnitude)"
                )
            ])
        ]
    }

    /// Perform all tests.
    func testAll() {
        conversions.forEach {
            self.doTest(conversion: $0)
        }
    }

    // swiftlint:disable function_body_length

    /// The default test parameters for this conversion.
    /// - Parameters:
    ///   - sign: The sign to convert from.
    ///   - otherSign: The sign to convert to.
    ///   - additional: The default parameters.
    /// - Returns: All the test parameters expected from the conversion.
    func expected(
        from sign: Signs, to otherSign: Signs, additional: Set<TestParameters>
    ) -> Set<TestParameters> {
        let creator = TestFunctionBodyCreator<DistanceUnits>()
        let scaleFactor = creator.sanitiseLiteral(literal: "10", sign: otherSign)
        var newTests: Set<TestParameters> = additional.union(Set([
            TestParameters(
                input: creator.sanitiseLiteral(literal: "15", sign: sign),
                output: "millimetres_" +
                    "\(otherSign)(\(creator.sanitiseLiteral(literal: "15.0", sign: otherSign)))" +
                    " * \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "25", sign: sign),
                output: "millimetres_" +
                    "\(otherSign)(\(creator.sanitiseLiteral(literal: "25", sign: otherSign)))" +
                    " * \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "250", sign: sign),
                output: "millimetres_" +
                    "\(otherSign)(\(creator.sanitiseLiteral(literal: "250", sign: otherSign)))" +
                    " * \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "0", sign: sign),
                output: "millimetres_" +
                    "\(otherSign)(\(creator.sanitiseLiteral(literal: "0", sign: otherSign)))" +
                    " * \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "2500", sign: sign),
                output: "millimetres_" +
                    "\(otherSign)(\(creator.sanitiseLiteral(literal: "2500", sign: otherSign)))" +
                    " * \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "25000", sign: sign),
                output: "millimetres_" +
                    "\(otherSign)(\(creator.sanitiseLiteral(literal: "25000", sign: otherSign)))" +
                    " * \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "250000", sign: sign),
                output: "millimetres_\(otherSign)" +
                    "(\(creator.sanitiseLiteral(literal: "250000", sign: otherSign)))" +
                    " * \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "2500000", sign: sign),
                output: "millimetres_\(otherSign)" +
                    "(\(creator.sanitiseLiteral(literal: "2500000", sign: otherSign)))" +
                    " * \(scaleFactor)"
            )
        ]))
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests = newTests.union(Set([
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-323", sign: sign),
                    output: "millimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-323", sign: otherSign)))" +
                        " * \(scaleFactor)"
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-10", sign: sign),
                    output: "millimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-10", sign: otherSign)))" +
                        " * \(scaleFactor)"
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-1000", sign: sign),
                    output: "millimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-1000", sign: otherSign)))" +
                        " * \(scaleFactor)"
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-5", sign: sign),
                    output: "millimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-5", sign: otherSign)))" +
                        " * \(scaleFactor)"
                )
            ]))
        }
        if sign.numericType.isSigned && !otherSign.numericType.isSigned {
            newTests = newTests.union(Set([
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-323", sign: sign),
                    output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-10", sign: sign),
                    output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-1000", sign: sign),
                    output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-6", sign: sign),
                    output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                )
            ]))
        }
        return newTests
    }

    // swiftlint:enable function_body_length

}
