/*
 * TemperatureFunctionCreator.swift 
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
        let typeLimits = otherSign.numericType.limits
        guard !(otherSign == .d && valueSign == .d) else {
            return """
                const celsius_d upperLimit = nexttoward((\(typeLimits.1) - 32.0) / 1.8, 0.0);
                const celsius_d lowerLimit = nexttoward((\(typeLimits.0)) / 1.8, 0.0);
                if (celsius > upperLimit) {
                    return ((fahrenheit_d) (\(typeLimits.1)));
                } else if (celsius < lowerLimit) {
                    return ((fahrenheit_d) (\(typeLimits.0)));
                }
                return ((fahrenheit_d) (celsius * 1.8 + 32.0));
            """
        }
        let conversion = round(value: "((double) (celsius)) * 1.8 + 32.0", from: .d, to: otherSign)
        guard !(valueSign != .d && otherSign == .d) else {
            return "    return ((fahrenheit_d) (\(conversion)));"
        }
        return """
            const double upperLimit = nexttoward(((double) (\(typeLimits.1))), 0.0);
            const double lowerLimit = nexttoward(((double) (\(typeLimits.0))), 0.0);
            const double conversion = \(conversion);
            if (conversion > upperLimit) {
                return \(typeLimits.1);
            }
            if (conversion < lowerLimit) {
                return \(typeLimits.0);
            }
            return ((fahrenheit_\(otherSign)) (conversion));
        """
    }

    // swiftlint:disable function_body_length

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
            let signConversion = signConverter.convert(
                "\(value.rawValue) - 273", otherUnit: value, from: .u, to: .t
            )
            let lowerLimit = valueSign.numericType.limits.0
            return """
                if (\(value) < (\(lowerLimit) + 273)) {
                    return (((\(other.rawValue)_\(otherSign.rawValue)) (\(value))) - 273);
                }
                return ((\(other.rawValue)_\(otherSign.rawValue)) (\(signConversion)));
            """
        }
        if valueSign == .u && otherSign == .t && operation == "+" {
            return """
                if (celsius > (\(otherSign.numericType.limits.1) - 273)) {
                    return ((kelvin_t) (\(otherSign.numericType.limits.1)));
                }
                return ((kelvin_t) (\(value.rawValue) + 273));
            """
        }
        if valueSign == .t && otherSign == .u && operation == "+" {
            return """
                if (\(value) < -273) {
                    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(otherSign.numericType.limits.0)));
                }
                if (\(value) < 0) {
                    return ((\(other.rawValue)_\(otherSign.rawValue)) (\(value) + 273));
                }
                return (((\(other.rawValue)_\(otherSign.rawValue)) (\(value))) + 273);
            """
        }
        if valueSign == .t && otherSign == .u && operation == "-" {
            return """
                if (\(value) < 273) {
                    return ((\(other)_\(otherSign)) (\(otherSign.numericType.limits.0)));
                }
                return ((\(other.rawValue)_\(otherSign.rawValue)) (\(value) - 273));
            """
        }
        guard valueSign.isFloatingPoint || otherSign.isFloatingPoint else {
            let conversion = "\(value.rawValue) \(operation) 273"
            let signConversion = signConverter.convert(
                conversion, otherUnit: other, from: valueSign, to: otherSign
            )
            return "    return \(signConversion);"
        }
        if (valueSign == .f && otherSign != .d) || valueSign == .d {
            let literal = valueSign == .f ? "273.15f" : "273.15"
            let lowerLimit = otherSign.numericType.limits.0
            let upperLimit = otherSign.numericType.limits.1
            guard operation == "-" else {
                let conversionString = round(value: "\(value) + \(literal)", from: valueSign, to: otherSign)
                return """
                    const \(value)_\(valueSign) upperLimit = ((\(value)_\(valueSign)) (\(upperLimit)));
                    const \(value)_\(valueSign) lowerLimit = ((\(value)_\(valueSign)) (\(lowerLimit)));
                    if (\(value) > (upperLimit - \(literal))) {
                        return ((\(other)_\(otherSign)) (\(upperLimit)));
                    } else if (\(value) < (lowerLimit - \(literal))) {
                        return ((\(other)_\(otherSign)) (\(lowerLimit)));
                    }
                    return ((\(other)_\(otherSign)) (\(conversionString)));
                """
            }
            let conversionString = round(value: "\(value) - \(literal)", from: valueSign, to: otherSign)
            return """
                const \(value)_\(valueSign) upperLimit = ((\(value)_\(valueSign)) (\(upperLimit)));
                const \(value)_\(valueSign) lowerLimit = ((\(value)_\(valueSign)) (\(lowerLimit)));
                if (\(value) < (lowerLimit + \(literal))) {
                    return ((\(other)_\(otherSign)) (\(lowerLimit)));
                } else if (\(value) > (upperLimit + \(literal))) {
                    return ((\(other)_\(otherSign)) (\(upperLimit)));
                }
                return ((\(other)_\(otherSign)) (\(conversionString)));
            """
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

    // swiftlint:enable function_body_length

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
        let scaleFactor = "const double scaleFactor = 5.0 / 9.0;"
        if valueSign == .d && otherSign == .d {
            return """
                \(scaleFactor)
                return ((kelvin_d) (fahrenheit * scaleFactor - 32.0 * scaleFactor + 273.15));
            """
        }
        let conversion = "((double) (fahrenheit)) * scaleFactor - 32.0 * scaleFactor + 273.15"
        let roundedConversion = round(value: conversion, from: .d, to: otherSign)
        let typeLimits = otherSign.numericType.limits
        let minString = "MIN(((double) (\(typeLimits.1))), (\(roundedConversion)))"
        let maxString = "MAX(((double) (\(typeLimits.0))), \(minString))"
        return """
            \(scaleFactor)
            return ((kelvin_\(otherSign)) (\(maxString)));
        """
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
        let conversion = "(value - 273.15) * 1.8 + 32.0"
        let roundedConversion = round(value: conversion, from: .d, to: otherSign)
        let upperLimit = otherSign.numericType.limits.1
        let lowerLimit = otherSign.numericType.limits.0
        let max = "(((double) (\(upperLimit))) - 32.0) / 1.8 + 273.15"
        let min = "((double) (\(lowerLimit))) / 1.8 - 32.0 / 1.8 + 273.15"
        return """
            const double maxValue = \(max);
            const double minValue = \(min);
            const double value = ((double) (kelvin));
            if (value > maxValue) {
                return \(upperLimit);
            }
            if (value < minValue) {
                return \(lowerLimit);
            }
            return ((fahrenheit_\(otherSign)) (\(roundedConversion)));
        """
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
            let conversion = "\(value.rawValue) * (5.0 / 9.0) - \(literal) * (5.0 / 9.0)"
            return "    return ((\(other.rawValue)_d) (\(conversion)));"
        }
        let conversion = "((double) (\(value.rawValue))) * (5.0 / 9.0) - \(literal) * (5.0 / 9.0)"
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
        guard sign == .d else {
            return "roundf(\(value))"
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
