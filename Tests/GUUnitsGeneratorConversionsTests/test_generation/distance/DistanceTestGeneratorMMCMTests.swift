// DistanceTestGeneratorTests.swift 
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

/// Test class for DistanceTestGenerator millimetre to centimetre tests.
final class DistanceTestGeneratorMMCMTests: XCTestCase, TestParameterTestable, TestConversionTestable {

    /// The generator under test.
    let generator = GradualTestGenerator<DistanceUnits>(unitDifference: [
        .millimetres: 10,
        .centimetres: 100
    ])

    /// All the test cases.
    var conversions: [ConversionTest<DistanceUnits>] {
        [
            ConversionTest(unit: .millimetres, sign: .t, otherUnit: .centimetres, otherSign: .t, parameters: [
                TestParameters(input: "CInt.min", output: "centimetres_t(CInt.min) / 10"),
                TestParameters(input: "CInt.max", output: "centimetres_t(CInt.max) / 10")
            ])
        ]
    }

    func testAll() {
        // conversions.forEach {
        //     self.doTest(conversion: $0)
        // }
        self.doTest(conversion: conversions[0])
    }

    func expected(
        from sign: Signs, to otherSign: Signs, additional: Set<TestParameters>
    ) -> Set<TestParameters> {
        let creator = TestFunctionBodyCreator<DistanceUnits>()
        let scaleFactor = creator.sanitiseLiteral(literal: "10", sign: otherSign)
        var newTests: Set<TestParameters> = additional.union(Set([
            TestParameters(
                input: creator.sanitiseLiteral(literal: "15", sign: sign),
                output: "centimetres_\(otherSign)(\(creator.sanitiseLiteral(literal: "15", sign: sign)))" +
                    " / \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "25", sign: sign),
                output: "centimetres_\(otherSign)(\(creator.sanitiseLiteral(literal: "25", sign: sign)))" +
                    " / \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "250", sign: sign),
                output: "centimetres_\(otherSign)(\(creator.sanitiseLiteral(literal: "250", sign: sign)))" +
                    " / \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "0", sign: sign),
                output: "centimetres_\(otherSign)(\(creator.sanitiseLiteral(literal: "0", sign: sign)))" +
                    " / \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "2500", sign: sign),
                output: "centimetres_\(otherSign)(\(creator.sanitiseLiteral(literal: "2500", sign: sign)))" +
                    " / \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "25000", sign: sign),
                output: "centimetres_\(otherSign)(\(creator.sanitiseLiteral(literal: "25000", sign: sign)))" +
                    " / \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "250000", sign: sign),
                output: "centimetres_\(otherSign)" +
                    "(\(creator.sanitiseLiteral(literal: "250000", sign: sign)))" +
                    " / \(scaleFactor)"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "2500000", sign: sign),
                output: "centimetres_\(otherSign)" +
                    "(\(creator.sanitiseLiteral(literal: "2500000", sign: sign)))" +
                    " / \(scaleFactor)"
            )
        ]))
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests = newTests.union(Set([
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-323", sign: sign),
                    output: "centimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-323", sign: sign)))" +
                        " / \(scaleFactor)"
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-10", sign: sign),
                    output: "centimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-10", sign: sign)))" +
                        " / \(scaleFactor)"
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-1000", sign: sign),
                    output: "centimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-1000", sign: sign)))" +
                        " / \(scaleFactor)"
                ),
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "-5", sign: sign),
                    output: "centimetres_" +
                        "\(otherSign)(\(creator.sanitiseLiteral(literal: "-5", sign: sign)))" +
                        " / \(scaleFactor)"
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

}
