// AngleTestGenerator.swift 
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

/// Struct that creates test parameters for angle conversions.
struct AngleTestGenerator: TestGenerator {

    /// The unit type is AngleUnits.
    typealias UnitType = AngleUnits

    /// The creator which will sanitise literals.
    let creator = TestFunctionBodyCreator<AngleUnits>()

    // swiftlint:disable function_body_length

    /// Generate the test parameters for a unit to unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: the sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: An array of test parameters suitable for testing this conversion function.
    func testParameters(
        from unit: AngleUnits, with sign: Signs, to otherUnit: AngleUnits, with otherSign: Signs
    ) -> [TestParameters] {
        guard (unit != otherUnit) || (sign != otherSign) else {
            return []
        }
        guard unit != otherUnit else {
            return self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
        }
        var newTests: [TestParameters] = [
            "250", "0", "2500", "25000", "250000", "2500000", "3.14", "180", "360", "6.28", "90.0", "1.57"
        ].map { testCase(value: $0, from: unit, with: sign, to: otherUnit, with: otherSign) }
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests += (
                ["-1.57", "-90", "-6.28", "-360", "-180", "-3.14"] +
                ["-250", "-2500", "-25000", "-250000", "-2500000"]
            ).map { testCase(value: $0, from: unit, with: sign, to: otherUnit, with: otherSign) }
        }
        if sign.numericType.isSigned && !otherSign.numericType.isSigned {
            newTests += (
                ["-1.57", "-90", "-6.28", "-360", "-180", "-3.14"] +
                ["-250", "-2500", "-25000", "-250000", "-2500000"]
            ).map {
                TestParameters(
                    input: creator.sanitiseLiteral(literal: $0, sign: sign),
                    output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                )
            }
        }
        let lowerLimit = sign.numericType.swiftType.limits.0
        let upperLimit = sign.numericType.swiftType.limits.1
        let otherLowerLimit = otherSign.numericType.swiftType.limits.0
        let otherUpperLimit = otherSign.numericType.swiftType.limits.1
        let lowerLimitAsOther = "\(otherUnit)_\(otherSign)(\(lowerLimit))"
        guard sign != otherSign else {
            if unit == .radians {
                newTests += [
                    TestParameters(input: lowerLimit, output: otherLowerLimit),
                    TestParameters(input: upperLimit, output: otherUpperLimit)
                ]
            } else {
                newTests += [
                    testCase(value: lowerLimit, from: unit, with: sign, to: otherUnit, with: otherSign),
                    testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                ]
            }
            return newTests
        }
        guard unit == .radians else {
            switch (sign, otherSign) {
            case (.t, .u):
                newTests += [
                    TestParameters(input: lowerLimit, output: otherLowerLimit),
                    testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                ]
            case (.u, .t):
                newTests += [
                    TestParameters(input: lowerLimit, output: lowerLimitAsOther),
                    testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                ]
            case (.f, .t), (.f, .u), (.d, _):
                newTests += [
                    TestParameters(input: lowerLimit, output: otherLowerLimit),
                    TestParameters(input: upperLimit, output: otherUpperLimit)
                ]
            default:
                newTests += [
                    testCase(value: lowerLimit, from: unit, with: sign, to: otherUnit, with: otherSign),
                    testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                ]
            }
            return newTests
        }
        switch (sign, otherSign) {
        case (.t, .u), (.f, .t), (.f, .u), (.d, _):
            newTests += [
                TestParameters(input: lowerLimit, output: otherLowerLimit),
                TestParameters(input: upperLimit, output: otherUpperLimit)
            ]
        case (.u, .t):
            newTests += [
                TestParameters(input: lowerLimit, output: lowerLimitAsOther),
                TestParameters(input: upperLimit, output: otherUpperLimit)
            ]
        case (.t, _), (.u, _), (.f, .d):
            newTests += [
                testCase(value: lowerLimit, from: unit, with: sign, to: otherUnit, with: otherSign),
                testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
            ]
        default:
            fatalError("Duplicate signs \(sign), \(otherSign)")
        }
        return newTests
    }

    // swiftlint:enable function_body_length

    /// Generate test parameters for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    /// - Returns: The test parameters for test functions using this conversion.
    func testParameters(
        from unit: AngleUnits, with sign: Signs, to numeric: NumericTypes
    ) -> [TestParameters] {
        self.defaultParameters(from: unit, with: sign, to: numeric)
    }

    /// Generate test parameters for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    /// - Returns: Test parameters which are used to create new test functions.
    func testParameters(
        from numeric: NumericTypes, to unit: AngleUnits, with sign: Signs
    ) -> [TestParameters] {
        self.defaultParameters(from: numeric, to: unit, with: sign)
    }

    /// Creates a Test parameters for a conversion function.
    /// - Parameters:
    ///   - value: The value to convert.
    ///   - unit: The unit of the value.
    ///   - sign: The sign of the value.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: Produces a test parameter that tests the conversion.
    private func testCase(
        value: String,
        from unit: AngleUnits,
        with sign: Signs,
        to otherUnit: AngleUnits,
        with otherSign: Signs
    ) -> TestParameters {
        let calculation: String
        let literal = creator.sanitiseLiteral(literal: value, sign: sign)
        switch (unit, otherUnit) {
        case (.radians, .degrees):
            if sign == .d {
                calculation = "\(creator.sanitiseLiteral(literal: value, to: .double)) / Double.pi * 180.0"
            } else {
                calculation = "Double(\(literal)) / Double.pi * 180.0"
            }
        case (.degrees, .radians):
            if sign == .d {
                calculation = "\(creator.sanitiseLiteral(literal: value, to: .double)) / 180.0 * Double.pi"
            } else {
                calculation = "Double(\(literal)) / 180.0 * Double.pi"
            }
        default:
            fatalError("Same unit type not supported in this function!")
        }
        guard otherSign.isFloatingPoint else {
            return TestParameters(
            input: literal,
            output: "\(otherUnit)_\(otherSign)((\(calculation)).rounded())"
        )
        }
        return TestParameters(
            input: literal,
            output: "\(otherUnit)_\(otherSign)(\(calculation))"
        )
    }

}
