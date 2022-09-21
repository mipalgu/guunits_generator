// AccelerationTestGeneratorGToMps2Tests.swift 
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

/// Test class for AccelerationTestGenerator g -> mps2 conversions.
final class AccelerationTestGeneratorGToMps2Tests: XCTestCase, TestParameterTestable, TestConversionTestable {

    /// Helper object for sanitising literal strings.
    let creator = TestFunctionBodyCreator<AccelerationUnits>()

    /// The generator under test.
    let generator = AccelerationTestGenerator()

    /// All conversion test parameters to test.
    var conversions: [ConversionTest<AccelerationUnits>] {
        [
            ConversionTest(unit: .gs, sign: .t, otherUnit: .metresPerSecond2, otherSign: .t, parameters: [
                TestParameters(input: "CInt.min", output: "CInt.min"),
                TestParameters(input: "CInt.max", output: "CInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .t, otherUnit: .metresPerSecond2, otherSign: .u, parameters: [
                TestParameters(input: "CInt.min", output: "CUnsignedInt.min"),
                TestParameters(input: "CInt.max", output: "CUnsignedInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .t, otherUnit: .metresPerSecond2, otherSign: .f, parameters: [
                TestParameters(
                    input: "CInt.min", output: conversion(value: "CInt.min", sign: .t, otherSign: .f)
                ),
                TestParameters(
                    input: "CInt.max", output: conversion(value: "CInt.max", sign: .t, otherSign: .f)
                )
            ]),
            ConversionTest(unit: .gs, sign: .t, otherUnit: .metresPerSecond2, otherSign: .d, parameters: [
                TestParameters(
                    input: "CInt.min", output: conversion(value: "CInt.min", sign: .t, otherSign: .d)
                ),
                TestParameters(
                    input: "CInt.max", output: conversion(value: "CInt.max", sign: .t, otherSign: .d)
                )
            ]),
            ConversionTest(unit: .gs, sign: .u, otherUnit: .metresPerSecond2, otherSign: .t, parameters: [
                TestParameters(input: "CUnsignedInt.min", output: "metresPerSecond2_t(CUnsignedInt.min)"),
                TestParameters(input: "CUnsignedInt.max", output: "CInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .u, otherUnit: .metresPerSecond2, otherSign: .u, parameters: [
                TestParameters(input: "CUnsignedInt.min", output: "CUnsignedInt.min"),
                TestParameters(input: "CUnsignedInt.max", output: "CUnsignedInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .u, otherUnit: .metresPerSecond2, otherSign: .f, parameters: [
                TestParameters(
                    input: "CUnsignedInt.min", output: "metresPerSecond2_f(CUnsignedInt.min)"
                ),
                TestParameters(
                    input: "CUnsignedInt.max",
                    output: conversion(value: "CUnsignedInt.max", sign: .u, otherSign: .f)
                )
            ]),
            ConversionTest(unit: .gs, sign: .u, otherUnit: .metresPerSecond2, otherSign: .d, parameters: [
                TestParameters(
                    input: "CUnsignedInt.min", output: "metresPerSecond2_d(CUnsignedInt.min)"
                ),
                TestParameters(
                    input: "CUnsignedInt.max",
                    output: conversion(value: "CUnsignedInt.max", sign: .u, otherSign: .d)
                )
            ]),
            ConversionTest(unit: .gs, sign: .f, otherUnit: .metresPerSecond2, otherSign: .t, parameters: [
                TestParameters(input: "-Float.greatestFiniteMagnitude", output: "CInt.min"),
                TestParameters(input: "Float.greatestFiniteMagnitude", output: "CInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .f, otherUnit: .metresPerSecond2, otherSign: .u, parameters: [
                TestParameters(input: "-Float.greatestFiniteMagnitude", output: "CUnsignedInt.min"),
                TestParameters(input: "Float.greatestFiniteMagnitude", output: "CUnsignedInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .f, otherUnit: .metresPerSecond2, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude", output: "-Float.greatestFiniteMagnitude"
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude", output: "Float.greatestFiniteMagnitude"
                )
            ]),
            ConversionTest(unit: .gs, sign: .f, otherUnit: .metresPerSecond2, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Float.greatestFiniteMagnitude",
                    output: conversion(value: "-Float.greatestFiniteMagnitude", sign: .f, otherSign: .d)
                ),
                TestParameters(
                    input: "Float.greatestFiniteMagnitude",
                    output: conversion(value: "Float.greatestFiniteMagnitude", sign: .f, otherSign: .d)
                )
            ]),
            ConversionTest(unit: .gs, sign: .d, otherUnit: .metresPerSecond2, otherSign: .t, parameters: [
                TestParameters(input: "-Double.greatestFiniteMagnitude", output: "CInt.min"),
                TestParameters(input: "Double.greatestFiniteMagnitude", output: "CInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .d, otherUnit: .metresPerSecond2, otherSign: .u, parameters: [
                TestParameters(input: "-Double.greatestFiniteMagnitude", output: "CUnsignedInt.min"),
                TestParameters(input: "Double.greatestFiniteMagnitude", output: "CUnsignedInt.max")
            ]),
            ConversionTest(unit: .gs, sign: .d, otherUnit: .metresPerSecond2, otherSign: .f, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude", output: "-Float.greatestFiniteMagnitude"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude", output: "Float.greatestFiniteMagnitude"
                )
            ]),
            ConversionTest(unit: .gs, sign: .d, otherUnit: .metresPerSecond2, otherSign: .d, parameters: [
                TestParameters(
                    input: "-Double.greatestFiniteMagnitude",
                    output: "-Double.greatestFiniteMagnitude"
                ),
                TestParameters(
                    input: "Double.greatestFiniteMagnitude",
                    output: "Double.greatestFiniteMagnitude"
                )
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
                    "0",
                    "2500",
                    "25000",
                    "250000",
                    "2500000",
                    "9.807",
                    "360",
                    "19.614",
                    "98.07",
                    "980.7",
                    "9807"
                ].map(f)
            )
        )
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests = newTests.union(
                Set(
                    (
                        ["-9.807", "-98.07", "-980.7", "-9807"] +
                        ["-250", "-2500", "-25000", "-250000", "-2500000"]
                    ).map(f)
                )
            )
        }
        if sign.numericType.isSigned && !otherSign.numericType.isSigned {
            newTests = newTests.union(
                Set(
                    (
                        ["-9.807", "-98.07", "-980.7", "-9807"] +
                        ["-250", "-2500", "-25000", "-250000", "-2500000"]
                    ).map {
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: $0, sign: sign),
                            output: "0"
                        )
                    }
                )
            )
        }
        return newTests
    }

    /// Produces a string representing a metresPerSecond2 to g's conversion.
    /// - Parameters:
    ///   - value: The value to convert.
    ///   - sign: The sign of the value.
    ///   - otherSign: The sign of the converted value.
    /// - Returns: A string performing the conversion.
    private func conversion(value: String, sign: Signs, otherSign: Signs) -> String {
        guard sign != .d else {
            let literal = self.creator.sanitiseLiteral(literal: value, to: .double)
            let calculation = "\(literal) * 9.807"
            guard otherSign.isFloatingPoint else {
                return "metresPerSecond2_\(otherSign)((\(calculation)).rounded())"
            }
            return "metresPerSecond2_\(otherSign)(\(calculation))"
        }
        let literal = creator.sanitiseLiteral(literal: value, sign: sign)
        guard otherSign.isFloatingPoint else {
            return "metresPerSecond2_\(otherSign)((Double(\(literal)) * 9.807).rounded())"
        }
        return "metresPerSecond2_\(otherSign)(Double(\(literal)) * 9.807)"
    }

}
