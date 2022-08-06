// TemperatureTestGeneratorDegCKTests.swift 
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

/// TemperatureTestGenerator Test class for Celsius to Kelvin conversions.
final class TemperatureTestGeneratorDegCKTests: XCTestCase, TestParameterTestable {

    /// The generator to test.
    let generator = TemperatureTestGenerator()

    // swiftlint:disable missing_docs

    func testCelsiusUToKelvinU() {
        let result = generator.testParameters(from: .celsius, with: .u, to: .kelvin, with: .u)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273"),
            TestParameters(input: "1", output: "274"),
            TestParameters(input: "CUnsignedInt.min", output: "kelvin_u(CUnsignedInt.min + 273)"),
            TestParameters(input: "CUnsignedInt.max", output: "kelvin_u(CUnsignedInt.max)"),
            TestParameters(input: "5", output: "278")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusTToKelvinU() {
        let result = generator.testParameters(from: .celsius, with: .t, to: .kelvin, with: .u)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273"),
            TestParameters(input: "1", output: "274"),
            TestParameters(input: "-273", output: "0"),
            TestParameters(input: "-272", output: "1"),
            TestParameters(input: "CInt.min", output: "kelvin_u(CUnsignedInt.min)"),
            TestParameters(input: "CInt.max", output: "kelvin_u(CInt.max) + 273"),
            TestParameters(input: "5", output: "278"),
            TestParameters(input: "-300", output: "0")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToKelvinU() {
        let result = generator.testParameters(from: .celsius, with: .f, to: .kelvin, with: .u)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273"),
            TestParameters(input: "1.0", output: "274"),
            TestParameters(input: "-273.0", output: "0"),
            TestParameters(input: "-272.0", output: "1"),
            TestParameters(input: "-Float.greatestFiniteMagnitude", output: "kelvin_u(CUnsignedInt.min)"),
            TestParameters(input: "Float.greatestFiniteMagnitude", output: "kelvin_u(CUnsignedInt.max)"),
            TestParameters(input: "5.0", output: "278"),
            TestParameters(input: "-300.0", output: "0")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusDToKelvinU() {
        let result = generator.testParameters(from: .celsius, with: .d, to: .kelvin, with: .u)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273"),
            TestParameters(input: "1.0", output: "274"),
            TestParameters(input: "-273.0", output: "0"),
            TestParameters(input: "-272.0", output: "1"),
            TestParameters(input: "-Double.greatestFiniteMagnitude", output: "kelvin_u(CUnsignedInt.min)"),
            TestParameters(input: "Double.greatestFiniteMagnitude", output: "kelvin_u(CUnsignedInt.max)"),
            TestParameters(input: "5.0", output: "278"),
            TestParameters(input: "-300.0", output: "0")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusUToKelvinT() {
        let result = generator.testParameters(from: .celsius, with: .u, to: .kelvin, with: .t)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273"),
            TestParameters(input: "1", output: "274"),
            TestParameters(input: "CUnsignedInt.min", output: "kelvin_t(CUnsignedInt.min) + 273"),
            TestParameters(input: "CUnsignedInt.max", output: "kelvin_t(CInt.max)"),
            TestParameters(input: "5", output: "278")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusTToKelvinT() {
        let result = generator.testParameters(from: .celsius, with: .t, to: .kelvin, with: .t)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273"),
            TestParameters(input: "1", output: "274"),
            TestParameters(input: "-273", output: "0"),
            TestParameters(input: "-272", output: "1"),
            TestParameters(input: "CInt.min", output: "kelvin_t(CInt.min) + 273"),
            TestParameters(input: "CInt.max", output: "kelvin_t(CInt.max)"),
            TestParameters(input: "5", output: "278"),
            TestParameters(input: "-300", output: "-27")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToKelvinT() {
        let result = generator.testParameters(from: .celsius, with: .f, to: .kelvin, with: .t)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273"),
            TestParameters(input: "1.0", output: "274"),
            TestParameters(input: "-273.0", output: "0"),
            TestParameters(input: "-272.0", output: "1"),
            TestParameters(input: "-Float.greatestFiniteMagnitude", output: "kelvin_t(CInt.min)"),
            TestParameters(input: "Float.greatestFiniteMagnitude", output: "kelvin_t(CInt.max)"),
            TestParameters(input: "5.0", output: "278"),
            TestParameters(input: "-300.0", output: "-27")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusDToKelvinT() {
        let result = generator.testParameters(from: .celsius, with: .d, to: .kelvin, with: .t)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273"),
            TestParameters(input: "1.0", output: "274"),
            TestParameters(input: "-273.0", output: "0"),
            TestParameters(input: "-272.0", output: "1"),
            TestParameters(input: "-Double.greatestFiniteMagnitude", output: "kelvin_t(CInt.min)"),
            TestParameters(input: "Double.greatestFiniteMagnitude", output: "kelvin_t(CInt.max)"),
            TestParameters(input: "5.0", output: "278"),
            TestParameters(input: "-300.0", output: "-27")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusUToKelvinF() {
        let result = generator.testParameters(from: .celsius, with: .u, to: .kelvin, with: .f)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273.15"),
            TestParameters(input: "1", output: "274.15"),
            TestParameters(input: "CUnsignedInt.min", output: "kelvin_f(CUnsignedInt.min) + 273.15"),
            TestParameters(input: "CUnsignedInt.max", output: "kelvin_f(CUnsignedInt.max) + 273.15"),
            TestParameters(input: "5", output: "278.15")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusTToKelvinF() {
        let result = generator.testParameters(from: .celsius, with: .t, to: .kelvin, with: .f)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273.15"),
            TestParameters(input: "1", output: "274.15"),
            TestParameters(input: "-273", output: "0.15"),
            TestParameters(input: "-272", output: "1.15"),
            TestParameters(input: "CInt.min", output: "kelvin_f(CInt.min) + 273.15"),
            TestParameters(input: "CInt.max", output: "kelvin_f(CInt.max) + 273.15"),
            TestParameters(input: "5", output: "278.15"),
            TestParameters(input: "-300", output: "-26.85")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToKelvinF() {
        let result = generator.testParameters(from: .celsius, with: .f, to: .kelvin, with: .f)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273.15"),
            TestParameters(input: "1.0", output: "274.15"),
            TestParameters(input: "-273.0", output: "0.15"),
            TestParameters(input: "-272.0", output: "1.15"),
            TestParameters(
                input: "-Float.greatestFiniteMagnitude",
                output: "kelvin_f(-Float.greatestFiniteMagnitude) + 273.15"
            ),
            TestParameters(
                input: "Float.greatestFiniteMagnitude", output: "kelvin_f(Float.greatestFiniteMagnitude)"
            ),
            TestParameters(input: "5.0", output: "278.15"),
            TestParameters(input: "-300.0", output: "-26.85")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusDToKelvinF() {
        let result = generator.testParameters(from: .celsius, with: .d, to: .kelvin, with: .f)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273.15"),
            TestParameters(input: "1.0", output: "274.15"),
            TestParameters(input: "-273.0", output: "0.15"),
            TestParameters(input: "-272.0", output: "1.15"),
            TestParameters(
                input: "-Double.greatestFiniteMagnitude",
                output: "kelvin_f(-Float.greatestFiniteMagnitude)"
            ),
            TestParameters(
                input: "Double.greatestFiniteMagnitude", output: "kelvin_f(Float.greatestFiniteMagnitude)"
            ),
            TestParameters(input: "5.0", output: "278.15"),
            TestParameters(input: "-300.0", output: "-26.85")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusUToKelvinD() {
        let result = generator.testParameters(from: .celsius, with: .u, to: .kelvin, with: .d)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273.15"),
            TestParameters(input: "1", output: "274.15"),
            TestParameters(input: "CUnsignedInt.min", output: "kelvin_d(CUnsignedInt.min) + 273.15"),
            TestParameters(input: "CUnsignedInt.max", output: "kelvin_d(CUnsignedInt.max) + 273.15"),
            TestParameters(input: "5", output: "278.15")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusTToKelvinD() {
        let result = generator.testParameters(from: .celsius, with: .t, to: .kelvin, with: .d)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "273.15"),
            TestParameters(input: "1", output: "274.15"),
            TestParameters(input: "-273", output: "0.15"),
            TestParameters(input: "-272", output: "1.15"),
            TestParameters(input: "CInt.min", output: "kelvin_d(CInt.min) + 273.15"),
            TestParameters(input: "CInt.max", output: "kelvin_d(CInt.max) + 273.15"),
            TestParameters(input: "5", output: "278.15"),
            TestParameters(input: "-300", output: "-26.85")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToKelvinD() {
        let result = generator.testParameters(from: .celsius, with: .f, to: .kelvin, with: .d)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273.15"),
            TestParameters(input: "1.0", output: "274.15"),
            TestParameters(input: "-273.0", output: "0.15"),
            TestParameters(input: "-272.0", output: "1.15"),
            TestParameters(
                input: "-Float.greatestFiniteMagnitude",
                output: "kelvin_d(-Float.greatestFiniteMagnitude) + 273.15"
            ),
            TestParameters(
                input: "Float.greatestFiniteMagnitude",
                output: "kelvin_d(Float.greatestFiniteMagnitude) + 273.15"
            ),
            TestParameters(input: "5.0", output: "278.15"),
            TestParameters(input: "-300.0", output: "-26.85")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusDToKelvinD() {
        let result = generator.testParameters(from: .celsius, with: .d, to: .kelvin, with: .d)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "273.15"),
            TestParameters(input: "1.0", output: "274.15"),
            TestParameters(input: "-273.0", output: "0.15"),
            TestParameters(input: "-272.0", output: "1.15"),
            TestParameters(
                input: "-Double.greatestFiniteMagnitude",
                output: "kelvin_d(-Double.greatestFiniteMagnitude) + 273.15"
            ),
            TestParameters(
                input: "Double.greatestFiniteMagnitude",
                output: "kelvin_d(Double.greatestFiniteMagnitude)"
            ),
            TestParameters(input: "5.0", output: "278.15"),
            TestParameters(input: "-300.0", output: "-26.85")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    // swiftlint:enable missing_docs

}
