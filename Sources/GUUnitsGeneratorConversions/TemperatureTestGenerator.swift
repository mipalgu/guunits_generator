/*
* TemperatureTestGenerator.swift 
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

/// Create test cases for the C temperature unit.
struct TemperatureTestGenerator: TestGenerator {

    /// The unit type it temperature.
    typealias UnitType = TemperatureUnits

    /// The creator which will sanitise literals.
    let creator = TestFunctionBodyCreator<TemperatureUnits>()

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity

    /// Generate the test parameters for a unit to unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: the sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: An array of test parameters suitable for testing this conversion function.
    func testParameters(
        from unit: UnitType, with sign: Signs, to otherUnit: UnitType, with otherSign: Signs
    ) -> [TestParameters] {
        guard (unit != otherUnit) || (sign != otherSign) else {
            return []
        }
        var newTests: [TestParameters] = []
        switch unit {
        case .celsius:
            switch otherUnit {
            case .fahrenheit:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "25", sign: sign),
                        output: creator.sanitiseLiteral(literal: "77", sign: otherSign)
                    )
                )
                if (sign == .d || sign == .f || sign == .t) && otherSign == .u {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-20", sign: sign),
                            output: "0"
                        )
                    )
                }
                if (sign == .d || sign == .f || sign == .u) && otherSign == .t {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "1193047000", sign: sign),
                            output: "fahrenheit_\(otherSign.rawValue)(INT_MAX)"
                        )
                    )
                }
            case .kelvin:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "5", sign: sign),
                        output: creator.sanitiseLiteral(literal: "278.15", sign: otherSign)
                    )
                )
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "0", sign: sign),
                        output: creator.sanitiseLiteral(literal: "273.15", sign: otherSign)
                    )
                )
                if sign != .u {
                    newTests += [
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-272", sign: sign),
                            output: creator.sanitiseLiteral(literal: "1.15", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "1", sign: sign),
                            output: creator.sanitiseLiteral(literal: "274.15", sign: otherSign)
                        )
                    ]
                    if otherSign == .t && sign == .t {
                        newTests.append(
                            TestParameters(input: "CInt.max", output: "kelvin_t(CInt.max)")
                        )
                    } else if sign == .t {
                        newTests.append(
                            TestParameters(
                                input: "CInt.max",
                                output: "kelvin_\(otherSign.rawValue)(CInt.max) + " +
                                    "\(creator.sanitiseLiteral(literal: "273.15", sign: otherSign))"
                            )
                        )
                    }
                    if otherSign == .u {
                        newTests.append(
                            TestParameters(
                                input: sign.numericType.swiftType.limits.0,
                                output: "kelvin_u(CUnsignedInt.min)"
                            )
                        )
                    } else if sign == .t {
                        newTests.append(
                            TestParameters(
                                input: "CInt.min",
                                output: "kelvin_\(otherSign.rawValue)(CInt.min) + " +
                                    "\(creator.sanitiseLiteral(literal: "273.15", sign: otherSign))"
                            )
                        )
                    }
                    if sign == .f && otherSign != .d {
                        newTests.append(
                            TestParameters(
                                input: sign.numericType.swiftType.limits.1,
                                output: "kelvin_\(otherSign.rawValue)" +
                                    "(\(otherSign.numericType.swiftType.limits.1))"
                            )
                        )
                    }
                }
                if sign == .u && otherSign == .u {
                    newTests += [
                        TestParameters(input: "1", output: "274"),
                        TestParameters(input: "CUnsignedInt.max", output: "kelvin_u(CUnsignedInt.max)"),
                        TestParameters(input: "CUnsignedInt.min", output: "kelvin_u(CUnsignedInt.min + 273)")
                    ]
                }
                if (sign == .t || sign == .f || sign == .d) && otherSign == .u {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-300", sign: sign),
                            output: "0"
                        )
                    )
                }
                if sign != .u && otherSign != .u {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-300", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-26.85", sign: otherSign)
                        )
                    )
                }
                if sign == .u && otherSign != .u {
                    newTests += [
                        TestParameters(
                            input: "CUnsignedInt.min",
                            output: "kelvin_\(otherSign.rawValue)(CUnsignedInt.min) + " +
                                "\(creator.sanitiseLiteral(literal: "273.15", sign: otherSign))"
                        ),
                        TestParameters(
                            input: "1",
                            output: "\(creator.sanitiseLiteral(literal: "274.15", sign: otherSign))"
                        )
                    ]
                }
                if sign == .u && (otherSign == .f || otherSign == .d) {
                    newTests.append(
                        TestParameters(
                            input: "CUnsignedInt.max",
                            output: "kelvin_\(otherSign.rawValue)(CUnsignedInt.max) + 273.15"
                        )
                    )
                }
                if sign == .u && otherSign == .t {
                    newTests.append(
                        TestParameters(input: "CUnsignedInt.max", output: "kelvin_t(CInt.max)")
                    )
                }
                if sign == .t || sign == .f || sign == .d {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-273", sign: sign),
                            output: creator.sanitiseLiteral(literal: "0.15", sign: otherSign)
                        )
                    )
                    // newTests.append(
                    //     TestParameters(
                    //         input: creator.sanitiseLiteral(literal: "-274", sign: sign),
                    //         output: creator.sanitiseLiteral(literal: "-1", sign: otherSign)
                    //     )
                    // )
                }
            default:
                newTests += self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
                newTests += [
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "5", sign: sign),
                        output: creator.sanitiseLiteral(literal: "5", sign: otherSign)
                    )
                ]
            }
        case .fahrenheit:
            switch otherUnit {
            case .celsius:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "77", sign: sign),
                        output: creator.sanitiseLiteral(literal: "25", sign: otherSign)
                    )
                )
                if (sign == .u || sign == .d || sign == .f) && otherSign == .t {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "3865470600", sign: sign),
                            output: "celsius_\(otherSign.rawValue)(INT_MAX)"
                        )
                    )
                }
                if sign == .u {
                    let output = creator.sanitiseLiteral(literal: "-5", sign: otherSign)
                    newTests.append(
                        TestParameters(
                            input: "23",
                            output: "celsius_\(otherSign.rawValue)(\(output))"
                        )
                    )
                }
            case .kelvin:
                break
            default:
                newTests += self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
                newTests += [
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "5", sign: sign),
                        output: creator.sanitiseLiteral(literal: "5", sign: otherSign)
                    )
                ]
            }
        case .kelvin:
            switch otherUnit {
            case .celsius:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "273.15", sign: sign),
                        output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                    )
                )
                if otherSign != .u {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "0", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-273.15", sign: otherSign)
                        )
                    )
                }
            case .fahrenheit:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "273.15", sign: sign),
                        output: creator.sanitiseLiteral(literal: "32", sign: otherSign)
                    )
                )
            default:
                newTests += self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
                newTests += [
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "5", sign: sign),
                        output: creator.sanitiseLiteral(literal: "5", sign: otherSign)
                    )
                ]
            }
        }
        return newTests
    }

    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    /// Generate test parameters for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    /// - Returns: The test parameters for test functions using this conversion.
    func testParameters(from unit: UnitType, with sign: Signs, to numeric: NumericTypes) -> [TestParameters] {
        self.defaultParameters(from: unit, with: sign, to: numeric)
    }

    /// Generate test parameters for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    /// - Returns: Test parameters which are used to create new test functions.
    func testParameters(from numeric: NumericTypes, to unit: UnitType, with sign: Signs) -> [TestParameters] {
        self.defaultParameters(from: numeric, to: unit, with: sign)
    }

}
