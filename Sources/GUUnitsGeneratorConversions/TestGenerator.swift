// /*
//  * TestGenerator.swift 
//  * guunits_generator 
//  *
//  * Created by Morgan McColl.
//  * Copyright © 2022 Morgan McColl. All rights reserved.
//  *
//  * Redistribution and use in source and binary forms, with or without
//  * modification, are permitted provided that the following conditions
//  * are met:
//  *
//  * 1. Redistributions of source code must retain the above copyright
//  *    notice, this list of conditions and the following disclaimer.
//  *
//  * 2. Redistributions in binary form must reproduce the above
//  *    copyright notice, this list of conditions and the following
//  *    disclaimer in the documentation and/or other materials
//  *    provided with the distribution.
//  *
//  * 3. All advertising materials mentioning features or use of this
//  *    software must display the following acknowledgement:
//  *
//  *        This product includes software developed by Morgan McColl.
//  *
//  * 4. Neither the name of the author nor the names of contributors
//  *    may be used to endorse or promote products derived from this
//  *    software without specific prior written permission.
//  *
//  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
//  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  *
//  * -----------------------------------------------------------------------
//  * This program is free software; you can redistribute it and/or
//  * modify it under the above terms or under the terms of the GNU
//  * General Public License as published by the Free Software Foundation;
//  * either version 2 of the License, or (at your option) any later version.
//  *
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program; if not, see http://www.gnu.org/licenses/
//  * or write to the Free Software Foundation, Inc., 51 Franklin Street,
//  * Fifth Floor, Boston, MA  02110-1301, USA.
//  *
//  */
// 

// swiftlint:disable file_length

/// Conforming types will generate test parameters for a specific unit.
protocol TestGenerator {

    /// Each generator works on a specific unit type.
    associatedtype UnitType: UnitProtocol where UnitType: RawRepresentable, UnitType.RawValue == String

    /// Generate the test parameters for a unit to unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: the sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: An array of test parameters suitable for testing this conversion function.
    func testParameters(
        from unit: UnitType, with sign: Signs, to otherUnit: UnitType, with otherSign: Signs
    ) -> [TestParameters]

    /// Generate test parameters for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    /// - Returns: The test parameters for test functions using this conversion.
    func testParameters(from unit: UnitType, with sign: Signs, to numeric: NumericTypes) -> [TestParameters]

    /// Generate test parameters for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    /// - Returns: Test parameters which are used to create new test functions.
    func testParameters(from numeric: NumericTypes, to unit: UnitType, with sign: Signs) -> [TestParameters]

}

/// TestGenerator Default Implementations.
extension TestGenerator {

    /// Find the default test parameters need to test the conversion methods at the edge cases of the
    /// converting type. This function only tests a conversion between the same unit type.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit to convert from.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: An array of suitable test parameters.
    func defaultParameters(
        from unit: UnitType, with sign: Signs, to otherUnit: UnitType, with otherSign: Signs
    ) -> [TestParameters] {
        let limits = LimitStruct(unit: unit, sign: sign, otherUnit: otherUnit, otherSign: otherSign)
        var parameters: [TestParameters] = [
            TestParameters(input: limits.sanitisedZero, output: limits.otherSanitisedZero)
        ]
        guard sign != otherSign else {
            return parameters
        }
        switch sign {
        case .u:
            switch otherSign {
            case .t:
                let t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsOther)
                let t2 = TestParameters(input: limits.castedUpperLimit, output: limits.otherCastedUpperLimit)
                parameters += [t1, t2]
            default:
                let t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsOther)
                let t2 = TestParameters(input: limits.castedUpperLimit, output: limits.upperLimitAsOther)
                parameters += [t1, t2]
            }
        case .t:
            switch otherSign {
            case .u:
                let t1 = TestParameters(input: limits.castedLowerLimit, output: limits.otherCastedLowerLimit)
                let t2 = TestParameters(input: limits.castedUpperLimit, output: limits.upperLimitAsOther)
                parameters += [t1, t2]
            default:
                let t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsOther)
                let t2 = TestParameters(input: limits.castedUpperLimit, output: limits.upperLimitAsOther)
                parameters += [t1, t2]
            }
        case .f:
            switch otherSign {
            case .u, .t:
                let t1 = TestParameters(input: limits.castedLowerLimit, output: limits.otherCastedLowerLimit)
                let t2 = TestParameters(input: limits.castedUpperLimit, output: limits.otherCastedUpperLimit)
                parameters += [t1, t2]
            default:
                let t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsOther)
                let t2 = TestParameters(input: limits.castedUpperLimit, output: limits.upperLimitAsOther)
                parameters += [t1, t2]
            }
        case .d:
            let t1 = TestParameters(input: limits.castedLowerLimit, output: limits.otherCastedLowerLimit)
            let t2 = TestParameters(input: limits.castedUpperLimit, output: limits.otherCastedUpperLimit)
            parameters += [t1, t2]
        }
        return parameters
    }

    // swiftlint:disable function_body_length

    /// Find the default test parameters for a unit to numeric conversion test.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    /// - Returns: An array of test parameters used to test the conversion function.
    func defaultParameters(
        from unit: UnitType, with sign: Signs, to numeric: NumericTypes
    ) -> [TestParameters] {
        let limits = NumericLimitStruct(unit: unit, sign: sign, numeric: numeric)
        let parameters = [
            TestParameters(input: limits.sanitisedZero, output: limits.numericSanitisedZero),
            TestParameters(
                input: limits.creator.sanitiseLiteral(literal: "5", sign: sign),
                output: limits.creator.sanitiseLiteral(literal: "5", to: numeric)
            )
        ]
        let t1: TestParameters
        let t2: TestParameters
        switch sign {
        case .t:
            switch numeric {
            case .int8, .int16, .uint8, .uint16, .uint32, .uint64, .uint:
                t1 = TestParameters(
                    input: limits.castedLowerLimit, output: limits.numericCastedLowerLimit
                )
            default:
                t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsNumeric)
            }
            switch numeric {
            case .int8, .int16, .uint8, .uint16:
                t2 = TestParameters(input: limits.castedUpperLimit, output: limits.numericCastedUpperLimit)
            default:
                t2 = TestParameters(input: limits.castedUpperLimit, output: limits.upperLimitAsNumeric)
            }
        case .u:
            t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsNumeric)
            switch numeric {
            case .uint8, .uint16, .uint32, .uint, .int8, .int16, .int32, .int:
                t2 = TestParameters(input: limits.castedUpperLimit, output: limits.numericCastedUpperLimit)
            default:
                t2 = TestParameters(input: limits.castedUpperLimit, output: limits.upperLimitAsNumeric)
            }
        case .f:
            switch numeric {
            case .float, .double:
                t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsNumeric)
                t2 = TestParameters(input: limits.castedUpperLimit, output: limits.upperLimitAsNumeric)
            default:
                t1 = TestParameters(input: limits.castedLowerLimit, output: limits.numericCastedLowerLimit)
                t2 = TestParameters(input: limits.castedUpperLimit, output: limits.numericCastedUpperLimit)
            }
        case .d:
            t1 = TestParameters(input: limits.castedLowerLimit, output: limits.numericCastedLowerLimit)
            t2 = TestParameters(input: limits.castedUpperLimit, output: limits.numericCastedUpperLimit)
        }
        return parameters + [t1, t2]
    }

    /// Find the default parameters for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    /// - Returns: An array of test parameters which are used to test the conversion function.
    func defaultParameters(
        from numeric: NumericTypes, to unit: UnitType, with sign: Signs
    ) -> [TestParameters] {
        let limits = NumericLimitStruct(unit: unit, sign: sign, numeric: numeric)
        let parameters = [
            TestParameters(input: limits.numericSanitisedZero, output: limits.sanitisedZero),
            TestParameters(
                input: limits.creator.sanitiseLiteral(literal: "5", to: numeric),
                output: limits.creator.sanitiseLiteral(literal: "5", sign: sign)
            )
        ]
        guard sign.numericType != numeric else {
            return parameters
        }
        let t1: TestParameters
        let t2: TestParameters
        switch sign {
        case .t:
            switch numeric {
            case .float, .double, .int32, .int, .int64:
                t1 = TestParameters(input: limits.numericCastedLowerLimit, output: limits.castedLowerLimit)
            case .uint8, .uint16, .uint32, .uint, .uint64, .int8, .int16:
                t1 = TestParameters(
                    input: limits.numericCastedLowerLimit, output: limits.numericLowerLimitAsUnit
                )
            }
            switch numeric {
            case .float, .double, .uint64, .int64, .int32, .uint32, .int, .uint:
                t2 = TestParameters(input: limits.numericCastedUpperLimit, output: limits.castedUpperLimit)
            case .uint8, .uint16, .int8, .int16:
                t2 = TestParameters(
                    input: limits.numericCastedUpperLimit, output: limits.numericUpperLimitAsUnit
                )
            }
        case .u:
            t1 = TestParameters(input: limits.numericCastedLowerLimit, output: limits.castedLowerLimit)
            switch numeric {
            case .uint64, .uint, .uint32, .float, .double, .int64:
                t2 = TestParameters(input: limits.numericCastedUpperLimit, output: limits.castedUpperLimit)
            case .int32, .int, .int16, .int8, .uint16, .uint8:
                t2 = TestParameters(
                    input: limits.numericCastedUpperLimit, output: limits.numericUpperLimitAsUnit
                )
            }
        case .f:
            switch numeric {
            case .float, .double:
                t1 = TestParameters(input: limits.numericCastedLowerLimit, output: limits.castedLowerLimit)
            case .int8, .int16, .int32, .int, .int64, .uint8, .uint16, .uint32, .uint, .uint64:
                t1 = TestParameters(
                    input: limits.numericCastedLowerLimit, output: limits.numericLowerLimitAsUnit
                )
            }
            switch numeric {
            case .float, .double:
                t2 = TestParameters(input: limits.numericCastedUpperLimit, output: limits.castedUpperLimit)
            case .int8, .int16, .int32, .int, .int64, .uint8, .uint16, .uint32, .uint, .uint64:
                t2 = TestParameters(
                    input: limits.numericCastedUpperLimit, output: limits.numericUpperLimitAsUnit
                )
            }
        case .d:
            t1 = TestParameters(input: limits.numericCastedLowerLimit, output: limits.numericLowerLimitAsUnit)
            t2 = TestParameters(input: limits.numericCastedUpperLimit, output: limits.numericUpperLimitAsUnit)
        }
        return parameters + [t1, t2]
    }

    // swiftlint:enable function_body_length

}

/// Provides helper properties for common unit conversion used in a test function.
private struct LimitStruct<UnitType> where
    UnitType: UnitProtocol,
    UnitType: RawRepresentable,
    UnitType.RawValue == String {

    /// Helper object to sanitise literals.
    let creator = TestFunctionBodyCreator<UnitType>()

    /// The unit to convert from.
    let unit: UnitType

    /// The sign of the unit.
    let sign: Signs

    /// The unit to convert to.
    let otherUnit: UnitType

    /// The sign of the unit to convert to.
    let otherSign: Signs

    /// A zero literal expressed as a unit.
    var sanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: sign)
    }

    /// A zero literal expressed as the other unit type.
    var otherSanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: otherSign)
    }

    /// The C unit type.
    private var unitType: String {
        "\(unit.rawValue)_\(sign.rawValue)"
    }

    /// The limits of the unit expressed using swift types. The tuple represents
    /// (min, max) values.
    private var limits: (String, String) {
        sign.numericType.swiftType.limits
    }

    /// The lower limit of the unit.
    private var lowerLimit: String {
        limits.0
    }

    /// The upper limit of the unit.
    private var upperLimit: String {
        limits.1
    }

    /// The lower limit expressed as the unit type.
    var castedLowerLimit: String {
        "\(unitType)(\(lowerLimit))"
    }

    /// The upper limit expressed as the unit type.
    var castedUpperLimit: String {
        "\(unitType)(\(upperLimit))"
    }

    /// The other unit C type.
    private var otherUnitType: String {
        "\(unit.rawValue)_\(otherSign.rawValue)"
    }

    /// The lower limit expressed using the other sign.
    private var sanitisedLowerLimit: String {
        creator.sanitiseLiteral(literal: lowerLimit, sign: otherSign)
    }

    /// The upper limit expressed using the other sign.
    private var sanitisedUpperLimit: String {
        creator.sanitiseLiteral(literal: upperLimit, sign: otherSign)
    }

    /// The lower limit expressed as the other unit type.
    var lowerLimitAsOther: String {
        "\(otherUnitType)(\(sanitisedLowerLimit))"
    }

    /// The upper limit expressed as the other unit type.
    var upperLimitAsOther: String {
        "\(otherUnitType)(\(sanitisedUpperLimit))"
    }

    /// The other units limits.
    private var otherLimits: (String, String) {
        otherSign.numericType.swiftType.limits
    }

    /// The other units lower limit.
    private var otherLowerLimit: String {
        otherLimits.0
    }

    /// The other units upper limit.
    private var otherUpperLimit: String {
        otherLimits.1
    }

    /// The other units lower limit casted to the other unit type.
    var otherCastedLowerLimit: String {
        "\(otherUnitType)(\(otherLowerLimit))"
    }

    /// The other units upper limit casted to the other unit type.
    var otherCastedUpperLimit: String {
        "\(otherUnitType)(\(otherUpperLimit))"
    }

}

/// A helper struct creating common representations of variables used in a
/// unit to numeric (or vice versa) conversion.
private struct NumericLimitStruct<UnitType> where
    UnitType: UnitProtocol,
    UnitType: RawRepresentable,
    UnitType.RawValue == String {

    /// A helper object used to sanitise literal strings.
    let creator = TestFunctionBodyCreator<UnitType>()

    /// The unit used in the conversion.
    let unit: UnitType

    /// The sign of the unit.
    let sign: Signs

    /// The numeric type used in the conversion.
    let numeric: NumericTypes

    /// The 0 literal expressed as the units sign.
    var sanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: sign)
    }

    /// The 0 literal expressed as the numeric type.
    var numericSanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", to: numeric)
    }

    /// The unit C type.
    private var unitType: String {
        "\(unit.rawValue)_\(sign.rawValue)"
    }

    /// The limits of the units underlying C-type.
    private var limits: (String, String) {
        sign.numericType.swiftType.limits
    }

    /// The lower limit of the unit.
    private var lowerLimit: String {
        limits.0
    }

    /// The upper limit of the unit.
    private var upperLimit: String {
        limits.1
    }

    /// The lower limit casted to the unit type.
    var castedLowerLimit: String {
        "\(unitType)(\(lowerLimit))"
    }

    /// The upper limit casted to the unit type.
    var castedUpperLimit: String {
        "\(unitType)(\(upperLimit))"
    }

    /// The numeric C-equivalent swift type.
    private var numericUnitType: String {
        numeric.swiftType.rawValue
    }

    /// The sanitised lower limit.
    private var sanitisedLowerLimit: String {
        creator.sanitiseLiteral(literal: lowerLimit, to: numeric)
    }

    /// The sanitised upper limit.
    private var sanitisedUpperLimit: String {
        creator.sanitiseLiteral(literal: upperLimit, to: numeric)
    }

    /// The lower limit casted to the numeric type.
    var lowerLimitAsNumeric: String {
        "\(numericUnitType)(\(sanitisedLowerLimit))"
    }

    /// The upper limit casted to the numeric type.
    var upperLimitAsNumeric: String {
        "\(numericUnitType)(\(sanitisedUpperLimit))"
    }

    /// The numeric types limits.
    private var numericLimits: (String, String) {
        numeric.swiftType.limits
    }

    /// The numeric lower limit.
    private var numericLowerLimit: String {
        numericLimits.0
    }

    /// The numeric upper limit.
    private var numericUpperLimit: String {
        numericLimits.1
    }

    /// The numeric lower limit expressed as a numeric unit type.
    var numericCastedLowerLimit: String {
        "\(numericUnitType)(\(numericLowerLimit))"
    }

    /// The numeric upper limit expressed as the swift numeric type.
    var numericCastedUpperLimit: String {
        "\(numericUnitType)(\(numericUpperLimit))"
    }

    /// The numeric lower limit casted to the unit type.
    var numericLowerLimitAsUnit: String {
        "\(unitType)(\(numericLowerLimit))"
    }

    /// The numeric upper limit casted to the unit type.
    var numericUpperLimitAsUnit: String {
        "\(unitType)(\(numericUpperLimit))"
    }

}

// swiftlint:enable file_length
