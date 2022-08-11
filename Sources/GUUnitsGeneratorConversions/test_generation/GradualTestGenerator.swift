// GradualTestGenerator.swift 
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

/// Struct used to generate test parameters for units that are convertable using
/// constant factors. e.g. 10 millimetres in a centimetre.
struct GradualTestGenerator<Unit>: TestGenerator where
    Unit: UnitProtocol, Unit: RawRepresentable, Unit.RawValue == String {

    /// The creator which will sanitise literals.
    let creator = TestFunctionBodyCreator<Unit>()

    /// The magnitude difference between a unit type and the next unit type. Example, for
    /// a unit type of metres, centimetres should be set to 100 since there
    /// are 100 centimetres in a metre.
    private(set) var unitDifference: [Unit: Int]

    // swiftlint:disable function_body_length

    /// Create test parameters for a unit to unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: An array of test parameters for the conversion function.
    func testParameters(
        from unit: Unit, with sign: Signs, to otherUnit: Unit, with otherSign: Signs
    ) -> [TestParameters] {
        guard unit != otherUnit else {
            return self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign) + [
                TestParameters(
                    input: creator.sanitiseLiteral(literal: "5", sign: sign),
                    output: creator.sanitiseLiteral(literal: "5", sign: otherSign)
                )
            ]
        }
        let allCases = Array(Unit.allCases)
        guard
            let index = allCases.firstIndex(where: { $0 == unit }),
            let otherIndex = allCases.firstIndex(where: { $0 == otherUnit })
        else {
            return []
        }
        let scaleFactor = findScaleFactor(allCases: allCases, index: index, otherIndex: otherIndex)
        let isDividing = index < otherIndex
        let operation = isDividing ? "/" : "*"
        let sanitisedScaleFactor = creator.sanitiseLiteral(literal: "\(scaleFactor)", sign: otherSign)
        var newTests: [TestParameters] = ["15", "25", "250", "0", "2500", "25000", "250000", "2500000"].map {
            createTestCase(
                from: sign,
                to: otherUnit,
                with: otherSign,
                testInput: $0,
                scaleFactor: sanitisedScaleFactor,
                operation: operation
            )
        }
        if sign.numericType.isSigned && otherSign.numericType.isSigned {
            newTests += ["-323", "-10", "-1000", "-5"].map {
                createTestCase(
                    from: sign,
                    to: otherUnit,
                    with: otherSign,
                    testInput: $0,
                    scaleFactor: sanitisedScaleFactor,
                    operation: operation
                )
            }
        }
        if sign.numericType.isSigned && !otherSign.numericType.isSigned {
            newTests += ["-323", "-10", "-1000", "-6"].map {
                TestParameters(
                    input: creator.sanitiseLiteral(literal: $0, sign: sign),
                    output: creator.sanitiseLiteral(literal: "0", sign: otherSign)
                )
            }
        }
        let lowerLimit = sign.numericType.swiftType.limits.0
        let upperLimit = sign.numericType.swiftType.limits.1
        guard sign != otherSign else {
            if isDividing {
                guard sign != .u else {
                    newTests += [
                        TestParameters(
                            input: "\(lowerLimit)",
                            output: "\(otherUnit)_\(otherSign)(\(lowerLimit))"
                        ),
                        TestParameters(
                            input: "\(upperLimit)",
                            output: "\(otherUnit)_\(otherSign)(\(upperLimit))" +
                                " \(operation) \(sanitisedScaleFactor)"
                        )
                    ]
                    return newTests
                }
                newTests += [
                    TestParameters(
                        input: "\(lowerLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(lowerLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    ),
                    TestParameters(
                        input: "\(upperLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(upperLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    )
                ]
            } else {
                newTests += [
                    TestParameters(
                        input: "\(lowerLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(lowerLimit))"
                    ),
                    TestParameters(
                        input: "\(upperLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(upperLimit))"
                    )
                ]
            }
            return newTests
        }
        switch sign {
        case .t:
            switch otherSign {
            case .u:
                newTests += [
                    TestParameters(
                        input: "\(lowerLimit)",
                        output: "0"
                    ),
                    TestParameters(
                        input: "\(upperLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(upperLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    )
                ]
            default:
                newTests += [
                    TestParameters(
                        input: "\(lowerLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(lowerLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    ),
                    TestParameters(
                        input: "\(upperLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(upperLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    )
                ]
            }
        case .u:
            newTests += [
                TestParameters(
                    input: lowerLimit,
                    output: "\(otherUnit)_\(otherSign)(\(lowerLimit))" +
                        " \(operation) \(sanitisedScaleFactor)"
                )
            ]
            switch otherSign {
            case .t:
                let uintIntFactor = Int(UInt.max / UInt(Int.max))
                if scaleFactor > uintIntFactor {
                    newTests += [
                        TestParameters(
                            input: upperLimit,
                            output: "\(otherUnit)_\(otherSign)(\(upperLimit)" +
                                " \(operation) \(sanitisedScaleFactor))"
                        )
                    ]
                } else {
                    newTests += [
                        TestParameters(
                            input: upperLimit,
                            output: otherSign.numericType.swiftType.limits.1
                        )
                    ]
                }
            default:
                newTests += [
                    TestParameters(
                        input: "\(upperLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(upperLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    )
                ]
            }
        case .f:
            switch otherSign {
            case .d:
                newTests += [
                    TestParameters(
                        input: "\(lowerLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(lowerLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    ),
                    TestParameters(
                        input: "\(upperLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(upperLimit))" +
                            " \(operation) \(sanitisedScaleFactor)"
                    )
                ]
            default:
                newTests += [
                    TestParameters(
                        input: "\(lowerLimit)",
                        output: "\(otherUnit)_\(otherSign)(\(otherSign.numericType.swiftType.limits.0))"
                    ),
                    TestParameters(
                        input: upperLimit,
                        output: "\(otherUnit)_\(otherSign)(\(otherSign.numericType.swiftType.limits.1))"
                    )
                ]
            }
        case .d:
            newTests += [
                TestParameters(
                    input: "\(lowerLimit)",
                    output: "\(otherUnit)_\(otherSign)(\(otherSign.numericType.swiftType.limits.0))"
                ),
                TestParameters(
                    input: upperLimit,
                    output: "\(otherUnit)_\(otherSign)(\(otherSign.numericType.swiftType.limits.1))"
                )
            ]
        }
        return newTests
    }

    // swiftlint:enable function_body_length

    /// Create test parameters for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    /// - Returns: The test parameters testing the conversion.
    func testParameters(from unit: Unit, with sign: Signs, to numeric: NumericTypes) -> [TestParameters] {
        self.defaultParameters(from: unit, with: sign, to: numeric)
    }

    /// Create test parameters for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit type to convert to.
    ///   - sign: The sign of the unit type to convert to.
    /// - Returns: An array of test parameters testing the conversion function.
    func testParameters(from numeric: NumericTypes, to unit: Unit, with sign: Signs) -> [TestParameters] {
        self.defaultParameters(from: numeric, to: unit, with: sign)
    }

    /// Find the scale factor for a unit to unit conversion. This function delegates to calculateScaleFactor.
    /// - Parameters:
    ///   - allCases: An array of all units.
    ///   - index: The index of the unit converting from.
    ///   - otherIndex: The index of the unit converting to.
    /// - Returns: The scale factor as an int.
    private func findScaleFactor(allCases: [Unit], index: Int, otherIndex: Int) -> Int {
        guard index > otherIndex else {
            return self.calculateScaleFactor(allCases: allCases, lowerIndex: index, upperIndex: otherIndex)
        }
        return self.calculateScaleFactor(allCases: allCases, lowerIndex: otherIndex, upperIndex: index)
    }

    /// Calculate the scale factor for a unit to unit conversion.
    /// - Parameters:
    ///   - allCases: An array of all units.
    ///   - lowerIndex: The index of the unit converting from.
    ///   - upperIndex: The index of the unit converting to.
    /// - Returns: The scale factor between the units.
    private func calculateScaleFactor(allCases: [Unit], lowerIndex: Int, upperIndex: Int) -> Int {
        guard lowerIndex < upperIndex else {
            return 1
        }
        return allCases[(lowerIndex)...(upperIndex - 1)].reduce(1) {
            guard let newFactor = unitDifference[$1] else {
                return $0
            }
            return $0 * newFactor
        }
    }

    // swiftlint:disable function_parameter_count

    /// Creates a test case for a unit conversion.
    /// - Parameters:
    ///   - sign: The sign of the unit converting from.
    ///   - otherUnit: The unit converting to.
    ///   - otherSign: The sign of the unit converting to.
    ///   - testInput: The input test parameter.
    ///   - scaleFactor: The scale factor between the units.
    ///   - operation: Whether we need to divide or multiple to convert the units.
    /// - Returns: A test case that tests the conversion function for the given testInput.
    private func createTestCase(
        from sign: Signs,
        to otherUnit: Unit,
        with otherSign: Signs,
        testInput: String,
        scaleFactor: String,
        operation: String
    ) -> TestParameters {
        let sanitisedLiteral = creator.sanitiseLiteral(literal: testInput, sign: sign)
        return TestParameters(
            input: sanitisedLiteral,
            output: "\(otherUnit)_\(otherSign)(\(sanitisedLiteral)) \(operation) \(scaleFactor)"
        )
    }

    // swiftlint:enable function_parameter_count

}
