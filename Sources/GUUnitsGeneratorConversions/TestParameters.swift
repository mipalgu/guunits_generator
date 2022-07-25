// /*
//  * TestParameters.swift 
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

/// Class for storing expected test result from an input.
struct TestParameters: Hashable, Codable, Sendable {

    /// The input into the test.
    let input: String

    /// The expected output of the test.
    let output: String

    // swiftlint:disable function_body_length
    // Disable function body length since I don't want to create multiple static functions.

    /// Find the default test parameters need to test the conversion methods at the edge cases of the
    /// converting type. This function only tests a conversion between the same unit type.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit to convert from.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: An array of suitable test parameters.
    static func limitParameters<Unit: UnitProtocol>(
        for unit: Unit, with sign: Signs, to otherSign: Signs
    ) -> [TestParameters] where Unit: RawRepresentable, Unit.RawValue == String {
        guard sign != otherSign else {
            return []
        }
        let creator = TestFunctionBodyCreator<Unit>()
        let unitType = "\(unit.rawValue)_\(sign.rawValue)"
        let limits = sign.numericType.limits
        let lowerLimit = limits.0
        let upperLimit = limits.1
        let castedLowerLimit = "((\(unitType)) (\(lowerLimit)))"
        let castedUpperLimit = "((\(unitType)) (\(upperLimit)))"
        let otherUnitType = "\(unit.rawValue)_\(otherSign.rawValue)"
        let sanitisedLowerLimit = creator.sanitiseLiteral(literal: lowerLimit, sign: otherSign)
        let sanitisedUpperLimit = creator.sanitiseLiteral(literal: upperLimit, sign: otherSign)
        let lowerLimitAsOther = "((\(otherUnitType)) (\(sanitisedLowerLimit)))"
        let upperLimitAsOther = "((\(otherUnitType)) (\(sanitisedUpperLimit)))"
        let otherLimits = otherSign.numericType.limits
        let otherLowerLimit = otherLimits.0
        let otherUpperLimit = otherLimits.1
        let otherCastedLowerLimit = "((\(otherUnitType)) (\(otherLowerLimit)))"
        let otherCastedUpperLimit = "((\(otherUnitType)) (\(otherUpperLimit)))"
        switch sign {
        case .u:
            switch otherSign {
            case .t:
                let t1 = TestParameters(input: castedLowerLimit, output: lowerLimitAsOther)
                let t2 = TestParameters(input: castedUpperLimit, output: otherCastedUpperLimit)
                return [t1, t2]
            default:
                let t1 = TestParameters(input: castedLowerLimit, output: lowerLimitAsOther)
                let t2 = TestParameters(input: castedUpperLimit, output: upperLimitAsOther)
                return [t1, t2]
            }
        case .t:
            switch otherSign {
            case .u:
                let t1 = TestParameters(input: castedLowerLimit, output: otherCastedLowerLimit)
                let t2 = TestParameters(input: castedUpperLimit, output: upperLimitAsOther)
                return [t1, t2]
            default:
                let t1 = TestParameters(input: castedLowerLimit, output: lowerLimitAsOther)
                let t2 = TestParameters(input: castedUpperLimit, output: upperLimitAsOther)
                return [t1, t2]
            }
        case .f:
            switch otherSign {
            case .u, .t:
                let t1 = TestParameters(input: castedLowerLimit, output: otherCastedLowerLimit)
                let t2 = TestParameters(input: castedUpperLimit, output: otherCastedUpperLimit)
                return [t1, t2]
            default:
                let t1 = TestParameters(input: castedLowerLimit, output: lowerLimitAsOther)
                let t2 = TestParameters(input: castedUpperLimit, output: upperLimitAsOther)
                return [t1, t2]
            }
        case .d:
            let t1 = TestParameters(input: castedLowerLimit, output: otherCastedLowerLimit)
            let t2 = TestParameters(input: castedUpperLimit, output: otherCastedUpperLimit)
            return [t1, t2]
        }
    }

    // swiftlint:enable function_body_length

}
