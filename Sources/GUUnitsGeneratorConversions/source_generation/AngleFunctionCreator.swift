/*
 * AngleFunctionCreator.swift
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

/// Struct that defines conversion functions between angle units.
public struct AngleFunctionCreator: FunctionBodyCreator {

    /// Helper object used to create sign conversion functions.
    private let signConverter = SignConverter()

    /// Default init.
    public init() {}

    /// Generates C-code that will perform a cast between different angle units.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    /// - Returns: Generated C-code that performs the conversion.
    public func createFunction(
        unit: AngleUnits, to otherUnit: AngleUnits, sign: Signs, otherSign: Signs
    ) -> String {
        switch (unit, otherUnit) {
        case (.degrees, .radians):
            guard otherSign != .d else {
                return "    return ((radians_d) (((double) (\(unit))) / 180.0 * M_PI));"
            }
            let max = "((double) (\(otherSign.numericType.limits.1)))"
            let min = "((double) (\(otherSign.numericType.limits.0)))"
            let roundString: String
            if otherSign.isFloatingPoint {
                roundString = "((radians_\(otherSign)) (castedValue / 180.0 * M_PI))"
            } else {
                roundString = "((radians_\(otherSign)) (round(castedValue / 180.0 * M_PI)))"
            }
            return """
                const double maxValue = \(max) / M_PI * 180.0;
                const double minValue = \(min) / M_PI * 180.0;
                const double castedValue = ((double) (\(unit)));
                if (castedValue > maxValue) {
                    return \(otherSign.numericType.limits.1);
                }
                if (castedValue < minValue) {
                    return \(otherSign.numericType.limits.0);
                }
                return \(roundString);
            """
        case (.radians, .degrees):
            let max = "((double) (\(otherSign.numericType.limits.1))) / 180.0 * M_PI"
            let min = "((double) (\(otherSign.numericType.limits.0))) / 180.0 * M_PI"
            let roundString: String
            if otherSign.isFloatingPoint {
                roundString = "((degrees_\(otherSign)) (castedValue / M_PI * 180.0))"
            } else {
                roundString = "((degrees_\(otherSign)) (round(castedValue / M_PI * 180.0)))"
            }
            return """
                const double maxValue = \(max);
                const double minValue = \(min);
                const double castedValue = ((double) (\(unit)));
                if (castedValue > maxValue) {
                    return \(otherSign.numericType.limits.1);
                }
                if (castedValue < minValue) {
                    return \(otherSign.numericType.limits.0);
                }
                return \(roundString);
            """
        default:
            return self.castFunc(forUnit: unit, sign: sign, otherSign: otherSign)
        }
    }

    /// Generates a standard sign conversion for identical unit types.
    /// - Parameters:
    ///   - unit: The unit to change sign.
    ///   - sign: The sign of the unit.
    ///   - otherSign: The sign to change into.
    /// - Returns: The generated C-code that performs the sign conversion.
    func castFunc(forUnit unit: Unit, sign: Signs, otherSign: Signs) -> String {
        "    return \(self.signConverter.convert("\(unit)", otherUnit: unit, from: sign, to: otherSign));"
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
