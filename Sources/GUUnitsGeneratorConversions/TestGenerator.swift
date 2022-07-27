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

protocol TestGenerator {

    associatedtype UnitType: UnitProtocol where UnitType: RawRepresentable, UnitType.RawValue == String

    func testParameters(
        from unit: UnitType, with sign: Signs, to otherUnit: UnitType, with otherSign: Signs
    ) -> [TestParameters]

    func testParameters(from unit: UnitType, with sign: Signs, to numeric: NumericTypes) -> [TestParameters]

    func testParameters(from numeric: NumericTypes, to unit: UnitType, with sign: Signs) -> [TestParameters]

}

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
        var parameters = [TestParameters(input: limits.sanitisedZero, output: limits.otherSanitisedZero)]
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

    func defaultParameters(
        from unit: UnitType, with sign: Signs, to numeric: NumericTypes
    ) -> [TestParameters] {
        let limits = NumericLimitStruct(unit: unit, sign: sign, numeric: numeric)
        let parameters = [TestParameters(input: limits.sanitisedZero, output: limits.numericSanitisedZero)]
        guard sign.numericType != numeric else {
            return parameters
        }
        let t1: TestParameters
        let t2: TestParameters
        switch sign {
        case .t:
            switch numeric {
            case .int8, .int16, .int32, .int, .uint8, .uint16, .uint32, .uint64, .uint:
                t1 = TestParameters(
                    input: limits.castedLowerLimit, output: limits.numericCastedLowerLimit
                )
            default:
                t1 = TestParameters(input: limits.castedLowerLimit, output: limits.lowerLimitAsNumeric)
            }
            switch numeric {
            case .int8, .int16, .int32, .int, .uint8, .uint16:
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

    func defaultParameters(
        from numeric: NumericTypes, to unit: UnitType, with sign: Signs
    ) -> [TestParameters] {
        let limits = NumericLimitStruct(unit: unit, sign: sign, numeric: numeric)
        let parameters = [TestParameters(input: limits.numericSanitisedZero, output: limits.sanitisedZero)]
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
            t1 = TestParameters(input: limits.numericCastedLowerLimit, output: limits.castedLowerLimit)
            t2 = TestParameters(input: limits.numericCastedUpperLimit, output: limits.castedUpperLimit)
        }
        return parameters + [t1, t2]
    }

}

private struct LimitStruct<UnitType> where
    UnitType: UnitProtocol,
    UnitType: RawRepresentable,
    UnitType.RawValue == String {

    private let creator = TestFunctionBodyCreator<UnitType>()

    let unit: UnitType

    let sign: Signs

    let otherUnit: UnitType

    let otherSign: Signs

    var sanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: sign)
    }

    var otherSanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: otherSign)
    }

    private var unitType: String {
        "\(unit.rawValue)_\(sign.rawValue)"
    }

    private var limits: (String, String) {
        sign.numericType.limits
    }

    private var lowerLimit: String {
        limits.0
    }

    private var upperLimit: String {
        limits.1
    }

    var castedLowerLimit: String {
        "((\(unitType)) (\(lowerLimit)))"
    }

    var castedUpperLimit: String {
        "((\(unitType)) (\(upperLimit)))"
    }

    private var otherUnitType: String {
        "\(unit.rawValue)_\(otherSign.rawValue)"
    }

    private var sanitisedLowerLimit: String {
        creator.sanitiseLiteral(literal: lowerLimit, sign: otherSign)
    }

    private var sanitisedUpperLimit: String {
        creator.sanitiseLiteral(literal: upperLimit, sign: otherSign)
    }

    var lowerLimitAsOther: String {
        "((\(otherUnitType)) (\(sanitisedLowerLimit)))"
    }
    var upperLimitAsOther: String {
        "((\(otherUnitType)) (\(sanitisedUpperLimit)))"
    }

    private var otherLimits: (String, String) {
        otherSign.numericType.limits
    }

    private var otherLowerLimit: String {
        otherLimits.0
    }

    private var otherUpperLimit: String {
        otherLimits.1
    }

    var otherCastedLowerLimit: String {
        "((\(otherUnitType)) (\(otherLowerLimit)))"
    }

    var otherCastedUpperLimit: String {
        "((\(otherUnitType)) (\(otherUpperLimit)))"
    }

}

private struct NumericLimitStruct<UnitType> where
    UnitType: UnitProtocol,
    UnitType: RawRepresentable,
    UnitType.RawValue == String {

    private let creator = TestFunctionBodyCreator<UnitType>()

    let unit: UnitType

    let sign: Signs

    let numeric: NumericTypes

    var sanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", sign: sign)
    }

    var numericSanitisedZero: String {
        creator.sanitiseLiteral(literal: "0", to: numeric)
    }

    private var unitType: String {
        "\(unit.rawValue)_\(sign.rawValue)"
    }

    private var limits: (String, String) {
        sign.numericType.limits
    }

    private var lowerLimit: String {
        limits.0
    }

    private var upperLimit: String {
        limits.1
    }

    var castedLowerLimit: String {
        "((\(unitType)) (\(lowerLimit)))"
    }

    var castedUpperLimit: String {
        "((\(unitType)) (\(upperLimit)))"
    }

    private var numericUnitType: String {
        numeric.rawValue
    }

    private var sanitisedLowerLimit: String {
        creator.sanitiseLiteral(literal: lowerLimit, to: numeric)
    }

    private var sanitisedUpperLimit: String {
        creator.sanitiseLiteral(literal: upperLimit, to: numeric)
    }

    var lowerLimitAsNumeric: String {
        "((\(numericUnitType)) (\(sanitisedLowerLimit)))"
    }
    var upperLimitAsNumeric: String {
        "((\(numericUnitType)) (\(sanitisedUpperLimit)))"
    }

    private var numericLimits: (String, String) {
        numeric.limits
    }

    private var numericLowerLimit: String {
        numericLimits.0
    }

    private var numericUpperLimit: String {
        numericLimits.1
    }

    var numericCastedLowerLimit: String {
        "((\(numericUnitType)) (\(numericLowerLimit)))"
    }

    var numericCastedUpperLimit: String {
        "((\(numericUnitType)) (\(numericUpperLimit)))"
    }

    var numericLowerLimitAsUnit: String {
        "((\(unitType)) (\(numericLowerLimit)))"
    }

    var numericUpperLimitAsUnit: String {
        "((\(unitType)) (\(numericUpperLimit)))"
    }

}
