/*
 * GradualFunctionCreator.swift
 * guunits_generator
 *
 * Created by Callum McColl on 15/6/19.
 * Copyright © 2019 Callum McColl. All rights reserved.
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
 *        This product includes software developed by Callum McColl.
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

/// A function body creator that converts between different units by scaling
/// the magnitude of one unit by a constant value. Examples of this type of
/// behaviour is seen in SI units where kilo is 1000 times smaller than the
/// Mega prefix.
public struct GradualFunctionCreator<Unit: UnitProtocol>: FunctionBodyCreator
    where Unit.AllCases.Index == Int {

    /// The magnitude difference between a unit type and the next unit type. Example, for
    /// a unit type of metres, centimetres should be set to 100 since there
    /// are 100 centimetres in a metre.
    private(set) var unitDifference: [Unit: Int]

    /// Helper used to create function definitions.
    private let helpers: FunctionHelpers<Unit> = FunctionHelpers()

    /// Converter that implements conversion functions for the same unit type.
    private let signConverter = SignConverter()

    /// Creates a function body for units that are directly related to each through constant magnitude
    /// changes.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to conver to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    /// - Returns: The function body that implements the conversion function.
    public func createFunction(unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs) -> String {
        let allCases = Unit.allCases
        if unit == otherUnit {
            return self.castFunc(forUnit: unit, sign: sign, otherSign: otherSign)
        }
        guard
            let unitIndex = allCases.firstIndex(where: { $0 == unit }),
            let otherUnitIndex = allCases.firstIndex(where: { $0 == otherUnit })
            else {
                fatalError("Unable to fetch index of \(unit) or \(otherUnit)")
        }
        let increasing = unitIndex < otherUnitIndex
        let smallest = increasing ? unitIndex : otherUnitIndex
        let biggest = increasing ? otherUnitIndex : unitIndex
        let cases = allCases.dropFirst(smallest).dropLast(allCases.count - biggest)
        let difference = cases.reduce(1) { $0 * (self.unitDifference[$1] ?? 1) }
        return increasing
            ? self.increasingFunc(
                forUnit: unit,
                to: otherUnit,
                sign: sign,
                otherSign: otherSign,
                andValue: difference
            )
            : self.decreasingFunc(
                forUnit: unit,
                to: otherUnit,
                sign: sign,
                otherSign: otherSign,
                andValue: difference
            )
    }

    /// Helper function for casting within the same unit type.
    /// - Parameters:
    ///   - unit: The unit to cast from.
    ///   - sign: The sign of the unit.
    ///   - otherSign: The sign to cast too.
    /// - Returns: The function body for conversions of this type.
    func castFunc(forUnit unit: Unit, sign: Signs, otherSign: Signs) -> String {
        let gen = self.signConverter.convert("\(unit)", otherUnit: unit, from: sign, to: otherSign)
        return "    return \(gen);"
    }

    /// Creates a conversion function that performs a cast to a unit with a lower resolution.
    /// - Parameters:
    ///   - unit: The unit to cast from.
    ///   - otherUnit: The unit to cast to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    ///   - value: The literal value to decrease by.
    /// - Returns: A function body that performs the unit conversion.
    private func increasingFunc(
        forUnit unit: Unit,
        to otherUnit: Unit,
        sign: Signs,
        otherSign: Signs,
        andValue value: Int
    ) -> String {
        let otherValue = self.helpers.modify(value: value, forSign: otherSign)
        let value = self.helpers.modify(value: value, forSign: sign)
        let conversion = signConverter.convert(
            "conversion", otherUnit: otherUnit, from: sign, to: otherSign
        )
        switch (sign, otherSign) {
        case (.t, .u):
            return """
                if (\(unit) < \(otherSign.numericType.limits.0)) {
                    return \(otherSign.numericType.limits.0);
                }
                return ((\(otherUnit)_\(otherSign)) (\(unit) / \(value)));
            """
        case (.u, .t):
            return """
                const \(unit)_\(sign) conversion = \(unit) / \(value);
                return \(conversion);
            """
        case (.t, _), (.u, _), (.f, .f), (.d, .d):
            return "    return ((\(otherUnit)_\(otherSign)) (\(unit) / \(value)));"
        case (.f, .d):
            return "    return (((\(otherUnit)_\(otherSign)) (\(unit))) / \(otherValue));"
        case (.f, _), (.d, _):
            return """
                const \(unit)_\(sign) conversion = \(unit) / \(value);
                return \(conversion);
            """
        }
    }

    // swiftlint:disable function_body_length

    /// Creates a conversion function that performs a cast to a unit with a higher resolution.
    /// - Parameters:
    ///   - unit: The unit to cast from.
    ///   - otherUnit: The unit to cast to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    ///   - difference: The magnitude difference to the next unit.
    /// - Returns: 
    private func decreasingFunc(
        forUnit unit: Unit,
        to otherUnit: Unit,
        sign: Signs,
        otherSign: Signs,
        andValue difference: Int
    ) -> String {
        let value = self.helpers.modify(value: difference, forSign: sign)
        let otherValue = self.helpers.modify(value: difference, forSign: otherSign)
        let unitAsOther = "((\(otherUnit)_\(otherSign)) (\(unit)))"
        let unitAsOtherName = "other\(unit.description.capitalized)"
        switch (sign, otherSign) {
        case (.u, .u):
            let upperLimit = sign.numericType.limits.1
            return """
                if (\(unit) > \(upperLimit) / \(value)) {
                    return \(upperLimit);
                }
                return \(unitAsOther) * \(otherValue);
            """
        case (.t, .t), (.f, .f), (.d, .d):
            let upperLimit = sign.numericType.limits.1
            let lowerLimit = sign.numericType.limits.0
            return """
                if (\(unit) < \(lowerLimit) / \(value)) {
                    return \(lowerLimit);
                }
                if (\(unit) > \(upperLimit) / \(value)) {
                    return \(upperLimit);
                }
                return \(unitAsOther) * \(otherValue);
            """
        case (.t, .u):
            let maxLimit = "\(otherSign.numericType.limits.1) / \(otherValue)"
            return """
                if (\(unit) < \(otherSign.numericType.limits.0)) {
                    return \(otherSign.numericType.limits.0);
                }
                const \(otherUnit)_\(otherSign) \(unitAsOtherName) = \(unitAsOther);
                if (\(unitAsOtherName) > \(maxLimit)) {
                    return \(otherSign.numericType.limits.1);
                }
                return \(unitAsOtherName) * \(otherValue);
            """
        case (.u, .t):
            let maxLimit = "\(otherSign.numericType.limits.1) / \(otherValue)"
            let castedMaxLimit = "((\(unit)_\(sign)) (\(maxLimit)))"
            return """
                if (\(unit) > \(castedMaxLimit)) {
                    return \(otherSign.numericType.limits.1);
                }
                return ((\(otherUnit)_\(otherSign)) (\(unit) * \(value)));
            """
        case (.f, .d):
            return "    return ((\(otherUnit)_\(otherSign)) (\(unit))) * \(otherValue);"
        case (.d, _), (.f, _):
            let maxLimit = "((\(unit)_\(sign)) (\(otherSign.numericType.limits.1))) / \(value)"
            let minLimit = "((\(unit)_\(sign)) (\(otherSign.numericType.limits.0))) / \(value)"
            return """
                if (\(unit) > \(maxLimit)) {
                    return \(otherSign.numericType.limits.1);
                }
                if (\(unit) < \(minLimit)) {
                    return \(otherSign.numericType.limits.0);
                }
                return ((\(otherUnit)_\(otherSign)) (\(unit) * \(value)));
            """
        case (_, .f), (_, .d):
            return "    return ((\(otherUnit)_\(otherSign)) (\(unit))) * \(otherValue);"
        }
    }

    // swiftlint:enable function_body_length

}
