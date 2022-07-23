// /*
//  * TemperatureFunctionCreator.swift 
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

public struct TemperatureFunctionCreator: FunctionBodyCreator {

    public typealias Unit = TemperatureUnits

    private let signConverter = SignConverter()

    private let numericConverter = NumericTypeConverter()

    public init () {}

    public func createFunction(
        unit: TemperatureUnits, to otherUnit: TemperatureUnits, sign: Signs, otherSign: Signs
    ) -> String {
        let convert: String
        switch (unit, otherUnit) {
        case (.celsius, .kelvin):
            return celsiusToKelvin(
                value: unit, other: otherUnit, valueSign: sign, otherSign: otherSign, operation: "+"
            )
        case (.kelvin, .celsius):
            return celsiusToKelvin(
                value: unit, other: otherUnit, valueSign: sign, otherSign: otherSign, operation: "-"
            )
        default:
            fatalError("Not yet supported!")
        }
        let roundedString = round(value: convert, from: sign, to: otherSign)
        let implementation = "(\(otherUnit.rawValue)_\(otherSign.rawValue)) (\(roundedString))"
        return "    return (\(implementation));"
    }

    private func celsiusToKelvin(
        value: TemperatureUnits,
        other: TemperatureUnits,
        valueSign: Signs,
        otherSign: Signs,
        operation: String
    ) -> String {
        guard valueSign != otherSign else {
            let literal = kelvinCelsiusConvertionLiteral(sign: valueSign)
            let conversion = "\(value.rawValue) \(operation) \(literal)"
            return "    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(conversion)));"
        }
        guard valueSign.isFloatingPoint || otherSign.isFloatingPoint else {
            let conversion = "\(value.rawValue) \(operation) 273"
            let signConversion = signConverter.convert(
                conversion, otherUnit: other, from: valueSign, to: otherSign
            )
            return "    return \(signConversion);"
        }
        let conversionString = "((double) (\(value.rawValue))) \(operation) 273.15"
        let roundedString = round(
            value: conversionString, from: valueSign, to: otherSign
        )
        guard otherSign.isFloatingPoint else {
            let typeLimits = otherSign.numericType.limits
            let minString = "MIN(((double) (\(typeLimits.1))), (\(roundedString)))"
            let conversion = "MAX(((double) (\(typeLimits.0))), \(minString))"
            return "    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(conversion)));"
        }
        return "    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(roundedString)));"
    }

    private func kelvinCelsiusConvertionLiteral(sign: Signs) -> String {
        switch sign {
        case .f:
            return "273.15f"
        case .d:
            return "273.15"
        default:
            return "273"
        }
    }

    private func round(value: String, from sign: Signs, to otherSign: Signs) -> String {
        guard shouldRound(from: sign, to: otherSign) else {
            return value
        }
        return "round(\(value))"
    }

    /// Function that indicates whether a round operation needs to happen during a conversion.
    /// - Parameters:
    ///   - sign: The sign of the first parameter.
    ///   - otherSign: The sign of the second parameter.
    /// - Returns: Whether a round operation needs to occur.
    private func shouldRound(from sign: Signs, to otherSign: Signs) -> Bool {
        (sign == .d || sign == .f) && (otherSign != .d && otherSign != .f)
    }

}
