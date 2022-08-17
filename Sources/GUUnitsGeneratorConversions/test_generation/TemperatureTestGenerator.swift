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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Create test cases for the C temperature unit.
struct TemperatureTestGenerator: TestGenerator {

    /// The unit type is temperature.
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
        guard unit != otherUnit else {
            return self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign) + [
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "5", sign: sign),
                    output: creator.sanitiseLiteral(literal: "5", sign: otherSign)
                )
            ]
        }
        var newTests: [TestParameters] = []
        switch unit {
        case .celsius:
            switch otherUnit {
            case .fahrenheit:
                newTests += [
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
                if sign.numericType.isSigned {
                    if otherSign.numericType.isSigned {
                        newTests += [
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
                    }
                }
                let lowerLimit = sign.numericType.swiftType.limits.0
                let upperLimit = sign.numericType.swiftType.limits.1
                guard sign != otherSign else {
                    if sign != .u {
                        newTests.append(
                            TestParameters(
                                input: lowerLimit,
                                output: "fahrenheit_\(otherSign)(\(lowerLimit))"
                            )
                        )
                    }
                    newTests.append(
                        TestParameters(
                            input: upperLimit,
                            output: "fahrenheit_\(otherSign)(\(upperLimit))"
                        )
                    )
                    break
                }
                let otherLowerLimit = otherSign.numericType.swiftType.limits.0
                let otherUpperLimit = otherSign.numericType.swiftType.limits.1
                let calculation: (String) -> String = {
                    guard otherSign.isFloatingPoint else {
                        return "(Double(\($0)) * 1.8 + 32.0).rounded()"
                    }
                    return "Double(\($0)) * 1.8 + 32.0"
                }
                switch sign {
                case .t:
                    if otherSign == .u {
                        newTests.append(
                            TestParameters(
                                input: lowerLimit,
                                output: "fahrenheit_u(\(otherLowerLimit))"
                            )
                        )
                    } else {
                        newTests.append(
                            TestParameters(
                                input: lowerLimit,
                                output: "fahrenheit_\(otherSign)(\(calculation(lowerLimit)))"
                            )
                        )
                    }
                    newTests.append(
                        TestParameters(
                            input: upperLimit,
                            output: "fahrenheit_\(otherSign)(\(calculation(upperLimit)))"
                        )
                    )
                case .u:
                    newTests.append(
                        TestParameters(
                            input: lowerLimit,
                            output: "fahrenheit_\(otherSign)(\(calculation(lowerLimit)))"
                        )
                    )
                    if otherSign == .t {
                        newTests.append(
                            TestParameters(
                                input: upperLimit,
                                output: "fahrenheit_\(otherSign)(\(otherUpperLimit))"
                            )
                        )
                    } else {
                        newTests.append(
                            TestParameters(
                                input: upperLimit,
                                output: "fahrenheit_\(otherSign)(\(calculation(upperLimit)))"
                            )
                        )
                    }
                case .f:
                    let lowerOutput = otherSign == .d ?
                        "fahrenheit_\(otherSign)(\(calculation(lowerLimit)))" :
                        "fahrenheit_\(otherSign)(\(otherLowerLimit))"
                    let upperOutput = otherSign == .d ?
                        "fahrenheit_\(otherSign)(\(calculation(upperLimit)))" :
                        "fahrenheit_\(otherSign)(\(otherUpperLimit))"
                    newTests += [
                        TestParameters(input: lowerLimit, output: lowerOutput),
                        TestParameters(input: upperLimit, output: upperOutput)
                    ]
                case .d:
                    newTests += [
                        TestParameters(
                            input: lowerLimit, output: "fahrenheit_\(otherSign)(\(otherLowerLimit))"
                        ),
                        TestParameters(
                            input: upperLimit, output: "fahrenheit_\(otherSign)(\(otherUpperLimit))"
                        )
                    ]
                }
            case .kelvin:
                newTests += [
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "5", sign: sign),
                        output: creator.sanitiseLiteral(literal: "278.15", sign: otherSign)
                    ),
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "0", sign: sign),
                        output: creator.sanitiseLiteral(literal: "273.15", sign: otherSign)
                    ),
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "1", sign: sign),
                        output: creator.sanitiseLiteral(literal: "274.15", sign: otherSign)
                    )
                ]
                if sign.numericType.isSigned {
                    newTests += [
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-272", sign: sign),
                            output: creator.sanitiseLiteral(literal: "1.15", sign: otherSign)
                        ),
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-273", sign: sign),
                            output: creator.sanitiseLiteral(literal: "0.15", sign: otherSign)
                        )
                    ]
                }
                guard sign != otherSign else {
                    newTests += [
                        TestParameters(
                            input: sign.numericType.swiftType.limits.0,
                            output: "kelvin_\(otherSign.rawValue)" +
                            "(\(otherSign.numericType.swiftType.limits.0)) + " +
                                creator.sanitiseLiteral(literal: "273.15", sign: otherSign)
                        ),
                        TestParameters(
                            input: sign.numericType.swiftType.limits.1,
                            output: "kelvin_\(otherSign.rawValue)" +
                                "(\(otherSign.numericType.swiftType.limits.1))"
                        )
                    ]
                    if sign.numericType.isSigned {
                        newTests.append(
                            TestParameters(
                                input: creator.sanitiseLiteral(literal: "-300", sign: sign),
                                output: creator.sanitiseLiteral(literal: "-26.85", sign: otherSign)
                            )
                        )
                    }
                    break
                }
                if sign != .u {
                    if sign == .t {
                        newTests.append(
                            TestParameters(
                                input: "CInt.max",
                                output: "kelvin_\(otherSign.rawValue)(CInt.max) + " +
                                    "\(creator.sanitiseLiteral(literal: "273.15", sign: otherSign))"
                            )
                        )
                    }
                    if sign == .t && otherSign != .u {
                        newTests.append(
                            TestParameters(
                                input: "CInt.min",
                                output: "kelvin_\(otherSign.rawValue)(CInt.min) + " +
                                    "\(creator.sanitiseLiteral(literal: "273.15", sign: otherSign))"
                            )
                        )
                    } else if sign == .t && otherSign == .u {
                        newTests.append(
                            TestParameters(
                                input: "CInt.min",
                                output: "kelvin_u(CUnsignedInt.min)"
                            )
                        )
                    }
                    if (sign == .f && otherSign != .d) || sign == .d {
                        if (sign == .d && otherSign != .d) || (sign == .f && otherSign != .f) {
                            newTests.append(
                                TestParameters(
                                    input: sign.numericType.swiftType.limits.0,
                                    output: "kelvin_\(otherSign.rawValue)" +
                                        "(\(otherSign.numericType.swiftType.limits.0))"
                                )
                            )
                        }
                        newTests += [
                            TestParameters(
                                input: sign.numericType.swiftType.limits.1,
                                output: "kelvin_\(otherSign.rawValue)" +
                                    "(\(otherSign.numericType.swiftType.limits.1))"
                            )
                        ]
                    }
                    if sign == .f && otherSign == .d {
                        newTests += [
                            TestParameters(
                                input: sign.numericType.swiftType.limits.0,
                                output: "kelvin_\(otherSign.rawValue)" +
                                    "(\(sign.numericType.swiftType.limits.0)) + 273.15"
                            ),
                            TestParameters(
                                input: sign.numericType.swiftType.limits.1,
                                output: "kelvin_\(otherSign.rawValue)" +
                                    "(\(sign.numericType.swiftType.limits.1)) + 273.15"
                            )
                        ]
                    }
                }
                if sign != .u && otherSign == .u {
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
            newTests += [
                "250",
                "2500",
                "25000",
                "250000",
                "2500000",
                "32",
                "523.67",
                "100"
            ].map {
                testCase(value: $0, from: unit, with: sign, to: otherUnit, with: otherSign)
            }
            if otherSign.numericType.isSigned {
                newTests += ["0", "20", "10", "15", "12", "25"].map {
                    testCase(value: $0, from: unit, with: sign, to: otherUnit, with: otherSign)
                }
                if sign.numericType.isSigned {
                    newTests += ["-250", "-2500", "-25000", "-250000", "-2500000", "-40"].map {
                        testCase(value: $0, from: unit, with: sign, to: otherUnit, with: otherSign)
                    }
                }
            }
            if sign.numericType.isSigned && !otherSign.numericType.isSigned {
                newTests += ["-250", "-2500", "-25000", "-250000", "-2500000", "-40"].map {
                    let literal = creator.sanitiseLiteral(literal: $0, sign: sign)
                    return TestParameters(input: literal, output: otherSign.numericType.swiftType.limits.0)
                }
            }
            let lowerLimit = sign.numericType.swiftType.limits.0
            let upperLimit = sign.numericType.swiftType.limits.1
            let otherLowerLimit = otherSign.numericType.swiftType.limits.0
            let otherUpperLimit = otherSign.numericType.swiftType.limits.1
            guard sign != otherSign else {
                if sign == .u {
                    newTests += [
                        TestParameters(input: lowerLimit, output: otherLowerLimit),
                        testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                    ]
                } else {
                    newTests += [
                        testCase(value: lowerLimit, from: unit, with: sign, to: otherUnit, with: otherSign),
                        testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                    ]
                }
                return newTests
            }
            switch otherUnit {
            case .celsius:
                switch (sign, otherSign) {
                case (.t, .u):
                    newTests += [
                        TestParameters(input: lowerLimit, output: otherLowerLimit),
                        testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                    ]
                case (.u, .t):
                    newTests += [
                        testCase(value: lowerLimit, from: unit, with: sign, to: otherUnit, with: otherSign),
                        TestParameters(input: upperLimit, output: otherUpperLimit)
                    ]
                case (.f, .d):
                    newTests += [
                        testCase(value: lowerLimit, from: unit, with: sign, to: otherUnit, with: otherSign),
                        testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                    ]
                case (.d, _), (.f, _):
                    newTests += [
                        TestParameters(input: lowerLimit, output: otherLowerLimit),
                        TestParameters(input: upperLimit, output: otherUpperLimit)
                    ]
                case (_, .f), (_, .d):
                    newTests += [
                        testCase(value: lowerLimit, from: unit, with: sign, to: otherUnit, with: otherSign),
                        testCase(value: upperLimit, from: unit, with: sign, to: otherUnit, with: otherSign)
                    ]
                default:
                    break
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
                newTests += [
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "273.15", sign: sign),
                        output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                    ),
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "274.0", sign: sign),
                        output: creator.sanitiseLiteral(literal: "0.85", sign: otherSign)
                    )
                ]
                if otherSign.numericType.isSigned {
                    newTests += [
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
                }
                if sign.numericType.isSigned && otherSign.numericType.isSigned {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-300", sign: sign),
                            output: creator.sanitiseLiteral(literal: "-573.15", sign: otherSign)
                        )
                    )
                }
                guard sign != otherSign else {
                    newTests += [
                        TestParameters(
                            input: sign.numericType.swiftType.limits.0,
                            output: "\(otherUnit)_\(otherSign)(\(otherSign.numericType.swiftType.limits.0))"
                        ),
                        TestParameters(
                            input: sign.numericType.swiftType.limits.1,
                            output: "\(otherUnit)_\(otherSign)(\(otherSign.numericType.swiftType.limits.1))" +
                                " - \(creator.sanitiseLiteral(literal: "273.15", sign: otherSign))"
                        )
                    ]
                    break
                }
                let lowerLimit = sign.numericType.swiftType.limits.0
                let upperLimit = sign.numericType.swiftType.limits.1
                let otherLowerLimit = otherSign.numericType.swiftType.limits.0
                let otherUpperLimit = otherSign.numericType.swiftType.limits.1
                let literal = creator.sanitiseLiteral(literal: "273.15", sign: otherSign)
                switch sign {
                case .t:
                    if otherSign == .u {
                        newTests.append(
                            TestParameters(
                                input: lowerLimit,
                                output: "celsius_u(\(otherLowerLimit))"
                            )
                        )
                    } else {
                        newTests.append(
                            TestParameters(
                                input: lowerLimit,
                                output: "celsius_\(otherSign)(\(lowerLimit)) - \(literal)"
                            )
                        )
                    }
                    newTests.append(
                        TestParameters(
                            input: upperLimit,
                            output: "celsius_\(otherSign)(\(upperLimit)) - \(literal)"
                        )
                    )
                case .u:
                    newTests.append(
                        TestParameters(
                            input: lowerLimit,
                            output: "celsius_\(otherSign)(\(lowerLimit)) - \(literal)"
                        )
                    )
                    if otherSign == .t {
                        newTests.append(
                            TestParameters(
                                input: upperLimit,
                                output: "celsius_\(otherSign)(\(otherUpperLimit))"
                            )
                        )
                    } else {
                        newTests.append(
                            TestParameters(
                                input: upperLimit,
                                output: "celsius_\(otherSign)(\(upperLimit)) - \(literal)"
                            )
                        )
                    }
                case .f:
                    let lowerOutput = otherSign == .d ? "celsius_\(otherSign)(\(lowerLimit)) - \(literal)" :
                        "celsius_\(otherSign)(\(otherLowerLimit))"
                    let upperOutput = otherSign == .d ? "celsius_\(otherSign)(\(upperLimit)) - \(literal)" :
                        "celsius_\(otherSign)(\(otherUpperLimit))"
                    newTests += [
                        TestParameters(input: lowerLimit, output: lowerOutput),
                        TestParameters(input: upperLimit, output: upperOutput)
                    ]
                case .d:
                    newTests += [
                        TestParameters(input: lowerLimit, output: "celsius_\(otherSign)(\(otherLowerLimit))"),
                        TestParameters(input: upperLimit, output: "celsius_\(otherSign)(\(otherUpperLimit))")
                    ]
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
        from unit: TemperatureUnits,
        with sign: Signs,
        to otherUnit: TemperatureUnits,
        with otherSign: Signs
    ) -> TestParameters {
        let calculation: String
        let literal = creator.sanitiseLiteral(literal: value, sign: sign)
        switch (unit, otherUnit) {
        case (.fahrenheit, .celsius):
            calculation = "Double(\(literal)) * (5.0 / 9.0) - 32.0 * (5.0 / 9.0)"
        case (.celsius, .fahrenheit):
            calculation = "Double(\(literal)) * 1.8 + 32.0"
        case (.celsius, .kelvin):
            calculation = "Double(\(literal)) + 273.15"
        case (.kelvin, .celsius):
            calculation = "Double(\(literal)) - 273.15"
        case (.kelvin, .fahrenheit):
            calculation = "(Double(\(literal)) - 273.15) * 1.8 + 32.0"
        case (.fahrenheit, .kelvin):
            calculation = "(Double(\(literal)) * (5.0 / 9.0)) - (32.0 * (5.0 / 9.0)) + 273.15"
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

// swiftlint:enable type_body_length
// swiftlint:enable file_length
