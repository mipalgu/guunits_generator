// AccelerationFunctionCreator.swift 
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

/// Struct that creates conversion functions between acceleration units.
public struct AccelerationFunctionCreator: FunctionBodyCreator {

    /// Helper object used to create sign conversion functions.
    private let signConverter = SignConverter()

    /// Default init.
    public init() {}

    // swiftlint:disable function_body_length

    /// Generates C-code that will perform a cast between different acceleration units.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    /// - Returns: Generated C-code that performs the conversion.
    public func createFunction(
        unit: AccelerationUnits, to otherUnit: AccelerationUnits, sign: Signs, otherSign: Signs
    ) -> String {
        switch(unit, otherUnit) {
        case (.metresPerSecond2, .g):
            guard otherSign != .d else {
                return "    return ((\(otherUnit)_\(otherSign)) (((double) (\(unit))) / 9.807));"
            }
            let max = "((double) (\(otherSign.numericType.limits.1)))"
            let min = "((double) (\(otherSign.numericType.limits.0)))"
            let conversion = "value / 9.807"
            let roundedString = otherSign.isFloatingPoint ? conversion : "round(\(conversion))"
            return """
                const double maxValue = \(max) * 9.807;
                const double minValue = \(min) * 9.807;
                const double value = ((double) (\(unit)));
                if (value > maxValue) {
                    return \(otherSign.numericType.limits.1);
                }
                if (value < minValue) {
                    return \(otherSign.numericType.limits.0);
                }
                return ((\(otherUnit)_\(otherSign)) (\(roundedString)));
            """
        case (.g, .metresPerSecond2):
            if sign != .d && otherSign == .d {
                return "    return ((\(otherUnit)_\(otherSign)) (((double) (\(unit))) * 9.807));"
            }
            let max = "((double) (\(otherSign.numericType.limits.1))) / 9.807"
            let min = "((double) (\(otherSign.numericType.limits.0))) / 9.807"
            let roundedString = otherSign.isFloatingPoint ? "value * 9.807" : "round(value * 9.807)"
            return """
                const double maxValue = \(max);
                const double minValue = \(min);
                const double value = ((double) (\(unit)));
                if (value > maxValue) {
                    return \(otherSign.numericType.limits.1);
                }
                if (value < minValue) {
                    return \(otherSign.numericType.limits.0);
                }
                return ((\(otherUnit)_\(otherSign)) (\(roundedString)));
            """
        default:
            let conversion = signConverter.convert(
                unit.rawValue, otherUnit: otherUnit, from: sign, to: otherSign
            )
            return "    return \(conversion);"
        }
    }

    // swiftlint:enable function_body_length

}
