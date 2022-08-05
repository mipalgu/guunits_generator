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

/// A function creator that generates code for temperature conversions. This function
/// creator can handle conversions between common temperature units such as
/// Kelvin, degrees Celsius, and degrees Fahrenheit.
public struct TemperatureFunctionCreator: FunctionBodyCreator {

    /// The category of this function creator is a TemperatureUnits.
    public typealias Unit = TemperatureUnits

    /// Sign converter for converting between the same unit.
    private let signConverter = SignConverter()

    /// Default initialiser.
    public init () {}

    /// Generate a function body between all the different unit and sign types.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    /// - Returns: The function body that performs the conversion.
    public func createFunction(
        unit: TemperatureUnits, to otherUnit: TemperatureUnits, sign: Signs, otherSign: Signs
    ) -> String {
        switch (unit, otherUnit) {
        case (.celsius, .kelvin):
            return celsiusToKelvin(
                value: unit, other: otherUnit, valueSign: sign, otherSign: otherSign, operation: "+"
            )
        case (.kelvin, .celsius):
            return celsiusToKelvin(
                value: unit, other: otherUnit, valueSign: sign, otherSign: otherSign, operation: "-"
            )
        case (.celsius, .fahrenheit):
            return celsiusToFahrenheit(valueSign: sign, otherSign: otherSign)
        case (.fahrenheit, .celsius):
            return fahrenheitToCelsius(valueSign: sign, otherSign: otherSign)
        case (.kelvin, .fahrenheit):
            return kelvinToFahrenheit(valueSign: sign, otherSign: otherSign)
        case (.fahrenheit, .kelvin):
            return fahrenheitToKelvin(valueSign: sign, otherSign: otherSign)
        default:
            guard !sign.isFloatingPoint else {
                guard otherSign.isFloatingPoint else {
                    return "    return ((\(otherUnit.rawValue)_\(otherSign.rawValue)) " +
                        "(\(sign.numericType.abbreviation)_to_" +
                        "\(otherSign.numericType.abbreviation)" +
                        "((\(sign.numericType.rawValue)) (\(unit.rawValue)))));"
                }
                guard otherSign != .d else {
                    return "    return ((\(otherUnit.rawValue)_\(otherSign.rawValue)) (\(unit.rawValue)));"
                }
                guard sign != .f else {
                    return "    return ((\(otherUnit.rawValue)_\(otherSign.rawValue)) (\(unit.rawValue)));"
                }
                return "    return ((\(otherUnit.rawValue)_\(otherSign.rawValue)) " +
                        "(\(sign.numericType.abbreviation)_to_" +
                        "\(otherSign.numericType.abbreviation)" +
                        "((\(sign.numericType.rawValue)) (\(unit.rawValue)))));"
            }
            let conversion = signConverter.convert(
                unit.rawValue, otherUnit: otherUnit, from: sign, to: otherSign
            )
            return "    return \(conversion);"
        }
    }

    /// Convert celsius to fahrenheit.
    /// - Parameters:
    ///   - valueSign: The sign of the celsius parameter.
    ///   - otherSign: The sign of the fahrenheit parameter.
    /// - Returns: The function body that implements the conversion.
    private func celsiusToFahrenheit(valueSign: Signs, otherSign: Signs) -> String {
        if otherSign == .d && valueSign == .d {
            let conversion = "celsius * 1.8 + 32.0"
            return "    return ((fahrenheit_d) (\(conversion)));"
        }
        let conversion = "((((double) (celsius)) * 1.8) + 32.0)"
        let roundedConversion = round(value: conversion, from: .d, to: otherSign)
        guard otherSign != .d else {
            return "    return ((fahrenheit_\(otherSign)) (\(roundedConversion)));"
        }
        let typeLimits = otherSign.numericType.limits
        let minString = "MIN(((double) (\(typeLimits.1))), (\(roundedConversion)))"
        let maxString = "MAX(((double) (\(typeLimits.0))), \(minString))"
        return "    return ((fahrenheit_\(otherSign)) (\(maxString)));"
    }

    /// Convert celsius to Kelvin or Kelvin to celsius.
    /// - Parameters:
    ///   - value: The unit to convert from.
    ///   - other: The unit to convert to.
    ///   - valueSign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    ///   - operation: + for celsius -> kelvin, minus for kelvin -> celsius. 
    /// - Returns: The conversion function body.
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
            guard operation == "-" else {
                let maxLimit = valueSign.numericType.limits.1
                return """
                    if (\(value) > (\(maxLimit) - \(literal))) {
                        return ((\(other.rawValue)_\(otherSign.rawValue)) (\(maxLimit)));
                    }
                    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(conversion)));
                """
            }
            let minLimit = valueSign.numericType.limits.0
            return """
                if (\(value) < (\(minLimit) + \(literal))) {
                    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(minLimit)));
                }
                return ((\(other.rawValue)_\(otherSign.rawValue)) (\(conversion)));
            """
        }
        if valueSign == .u && otherSign == .t && operation == "-" {
            let signConversion = signConverter.convert(value.rawValue, otherUnit: value, from: .u, to: .t)
            let conversion = "\(signConversion) \(operation) 273"
            return "    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(conversion)));"
        }
        if valueSign == .t && otherSign == .u && operation == "+" {
            let signConversion = signConverter.convert(value.rawValue, otherUnit: value, from: .t, to: .u)
            let conversion = "\(signConversion) \(operation) 273"
            let signConversion2 = signConverter.convert(
                "\(value.rawValue) + 273", otherUnit: value, from: .t, to: .u
            )
            return """
                if (\(value) > 0) {
                    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(conversion)));
                }
                return ((\(other.rawValue)_\(otherSign.rawValue)) (\(signConversion2)));
            """
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

    /// Convert fahrenheit to celsius.
    /// - Parameters:
    ///   - valueSign: The sign of the fahrenheit parameter.
    ///   - otherSign: The sign of the celsius parameter.
    /// - Returns: The function body that implements the conversion.
    private func fahrenheitToCelsius(valueSign: Signs, otherSign: Signs) -> String {
        performDownConversion(
            value: .fahrenheit,
            other: .celsius,
            valueSign: valueSign,
            otherSign: otherSign,
            literal: "32.0"
        )
    }

    /// Convert fahrenheit to kelvin.
    /// - Parameters:
    ///   - valueSign: The sign of the fahrenheit parameter.
    ///   - otherSign: The sign of the kelvin parameter.
    /// - Returns: The function body that implements the conversion.
    private func fahrenheitToKelvin(valueSign: Signs, otherSign: Signs) -> String {
        if valueSign == .d && otherSign == .d {
            let conversion = "(fahrenheit - 32.0) * (5.0 / 9.0) + 273.15"
            return "    return ((kelvin_d) (\(conversion)));"
        }
        let conversion = "(((double) (fahrenheit)) - 32.0) * (5.0 / 9.0) + 273.15"
        let roundedConversion = round(value: conversion, from: .d, to: otherSign)
        let typeLimits = otherSign.numericType.limits
        let minString = "MIN(((double) (\(typeLimits.1))), (\(roundedConversion)))"
        let maxString = "MAX(((double) (\(typeLimits.0))), \(minString))"
        return "    return ((kelvin_\(otherSign)) (\(maxString)));"
    }

    /// A literal representation of the difference between kelvin and celsius (273.15 degrees).
    /// - Parameter sign: The sign of the literal.
    /// - Returns: The C-literal formatted to match the sign.
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

    /// Convert kelvin to fahrenheit.
    /// - Parameters:
    ///   - valueSign: The sign of the kelvin parameter.
    ///   - otherSign: The sign of the fahrenheit parameter.
    /// - Returns: The function body that implements the conversion.
    private func kelvinToFahrenheit(valueSign: Signs, otherSign: Signs) -> String {
        if valueSign == .d && otherSign == .d {
            let conversion = "(kelvin - 273.15) * 1.8 + 32.0"
            return "    return ((fahrenheit_d) (\(conversion)));"
        }
        let conversion = "(((double) (kelvin)) - 273.15) * 1.8 + 32.0"
        let roundedConversion = round(value: conversion, from: .d, to: otherSign)
        let typeLimits = otherSign.numericType.limits
        let minString = "MIN(((double) (\(typeLimits.1))), (\(roundedConversion)))"
        let maxString = "MAX(((double) (\(typeLimits.0))), \(minString))"
        return "    return ((fahrenheit_\(otherSign)) (\(maxString)));"
    }

    /// Implement conversion function for a type that loses precision.
    /// - Parameters:
    ///   - value: The unit to convert from.
    ///   - other: The unit to convert to.
    ///   - valueSign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    ///   - literal: The literal to perform a magnitude change between the 2 types.
    ///              273.15 for kelvin -> celsius, 32 for celsius -> kelvin.
    /// - Returns: The conversion function body.
    private func performDownConversion(
        value: TemperatureUnits,
        other: TemperatureUnits,
        valueSign: Signs,
        otherSign: Signs,
        literal: String
    ) -> String {
        if otherSign == .d && valueSign == .d {
            let conversion = "(\(value.rawValue) - \(literal)) * (5.0 / 9.0)"
            return "    return ((\(other.rawValue)_d) (\(conversion)));"
        }
        let conversion = "(((double) (\(value.rawValue))) - \(literal)) * (5.0 / 9.0)"
        let roundedConversion = round(value: conversion, from: .d, to: otherSign)
        let typeLimits = otherSign.numericType.limits
        let minString = "MIN(((double) (\(typeLimits.1))), (\(roundedConversion)))"
        let maxString = "MAX(((double) (\(typeLimits.0))), \(minString))"
        return "    return ((\(other.rawValue)_\(otherSign)) (\(maxString)));"
    }

    /// Checks if a conversion needs to a round operation and includes it if necessary.
    /// - Parameters:
    ///   - value: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: The code with a round of operation if needed, otherwise the original value.
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
