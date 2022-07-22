/*
 * NumericTypeConverter.swift
 * guunits_generator
 *
 * Created by Callum McColl on 21/6/19.
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

/// A struct for converting between numeric types and unit types.
public struct NumericTypeConverter: NumericConverterProtocol {

    /// Default init.
    public init() {}

    /// Convert a numeric typed value into a unit type.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - type: The type of the value.
    ///   - unit: The unit type to convert into.
    ///   - sign: The sign of the new unit type.
    /// - Returns: Generated C-code that converts str into the new unit.
    public func convert<Unit: UnitProtocol>(
        _ str: String,
        from type: NumericTypes,
        to unit: Unit,
        sign: Signs
    ) -> String {
        self.convert(
            str,
            from: type,
            to: sign.numericType,
            currentType: type.rawValue,
            resultType: "\(unit)_\(sign.rawValue)"
        )
    }

    /// Convert a unit value into an underlying numeric type.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - unit: The unit of the value.
    ///   - sign: The sign of the unit.
    ///   - type: The numeric type to convert into.
    /// - Returns: Generated C-code that converts str to the numeric type.
    public func convert<Unit: UnitProtocol>(
        _ str: String,
        from unit: Unit,
        sign: Signs,
        to type: NumericTypes
    ) -> String {
        self.convert(
            str,
            from: sign.numericType,
            to: type,
            currentType: "\(unit)_\(sign.rawValue)",
            resultType: type.rawValue
        )
    }

    /// Helper method that represents both sides of the conversion as numeric types.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - type: The numeric type of the str.
    ///   - otherType: The numeric type to convert into.
    ///   - currentType: The c-representation of the current unit type.
    ///   - resultType: The c-representation of the new result type.
    /// - Returns: Generated C-code that creates a cast between different types.
    private func convert(
        _ str: String,
        from type: NumericTypes,
        to otherType: NumericTypes,
        currentType: String,
        resultType: String
    ) -> String {
        if type == otherType {
            return self.cast(str, to: resultType)
        }
        if type.isFloat && otherType.isFloat {
            return self.cast(str, to: resultType)
        }
        if type.isFloat != otherType.isFloat {
            var converted = self.convertFloat(str, from: type, currentType: currentType, to: otherType)
            if type.isFloat {
                converted = otherType.isSigned
                    ? converted
                    : self.convertSign(converted, from: .int, currentType: currentType, to: otherType)
            } else {
                converted = type.isSigned
                    ? converted
                    : self.convertSign(converted, from: type, currentType: currentType, to: .int)
            }
            return self.cast(converted, to: resultType)
        }
        if type.isSigned == otherType.isSigned {
            return self.cast(
                self.convertSize(str, from: type, currentType: currentType, to: otherType), to: resultType
            )
        }
        let limitSign = self.convertSign(str, from: type, currentType: currentType, to: otherType)
        return self.cast(limitSign, to: resultType)
    }

    /// C-Style cast helper function. This function generates C-code that performs a cast.
    /// - Parameters:
    ///   - str: The value to cast.
    ///   - type: The type to cast into.
    /// - Returns: The C-code that performs the cast.
    private func cast(_ str: String, to type: String) -> String {
        "((\(type)) (\(str)))"
    }

    /// Method that casts float correctly.
    /// - Parameters:
    ///   - str: The value to cast.
    ///   - type: The numeric type of str.
    ///   - currentType: The current c-representation of the unit type of str.
    ///   - otherType: The numeric type to cast into.
    /// - Returns: The c-code that performs the cast.
    private func convertFloat(
        _ str: String,
        from type: NumericTypes,
        currentType: String,
        to otherType: NumericTypes
    ) -> String {
        if type.isFloat && !otherType.isFloat {
            return self.cast(
                "round(\(type != .double ? self.cast(str, to: "double") : str))",
                to: currentType
            )
        }
        return str
    }

    /// Method for casting signed integer values. This function clamps values within the size of the
    /// underlying integer type.
    /// - Parameters:
    ///   - str: The value to cast.
    ///   - type: The numeric type of str.
    ///   - currentType: The c-representation of the type of str.
    ///   - otherType: The numeric type to cast into.
    /// - Returns: The C-code that performs the cast.
    private func convertSign(
        _ str: String,
        from type: NumericTypes,
        currentType: String,
        to otherType: NumericTypes
    ) -> String {
        let (_, max) = otherType.limits
        if type.isSigned {
            return "MAX(\(self.cast("0", to: currentType)), \(str))"
        }
        if otherType.opposite.largerThan(type) {
            return str
        }
        return "MIN(\(self.cast(max, to: currentType)), \(str))"
    }

    /// Method for casting between different sized types. This method clamps the value
    /// into the bounds of the new type.
    /// - Parameters:
    ///   - str: The value to cast.
    ///   - type: The numeric type of str.
    ///   - currentType: The c-representation of the type of str.
    ///   - otherType: The numeric type to cast into.
    /// - Returns: The generated c-code that performs the cast.
    private func convertSize(
        _ str: String,
        from type: NumericTypes,
        currentType: String,
        to otherType: NumericTypes
    ) -> String {
        if otherType.largerThan(type) {
            return str
        }
        let (min, max) = otherType.limits
        return "MIN(\(self.cast(max, to: currentType)), MAX(\(self.cast(min, to: currentType)), \(str)))"
    }

}
