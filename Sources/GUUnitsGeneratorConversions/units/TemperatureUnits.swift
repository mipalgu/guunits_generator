/*
 * TemperatureUnits.swift 
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

/// Category for temperature units.
public enum TemperatureUnits: String {

    /// Data representation as degrees Celsius (degC)
    case celsius

    /// Data representation as degrees Fahrenheit (degF)
    case fahrenheit

    /// Data representation as Kelvin (K)
    case kelvin

}

/// UnitProtocol conformance.
extension TemperatureUnits: UnitProtocol {

    /// The abbreviation of this temperature unit.
    public var abbreviation: String {
        switch self {
        case .celsius:
            return "degC"
        case .fahrenheit:
            return "degF"
        case .kelvin:
            return "K"
        }
    }

    /// The description of this temperature unit.
    public var description: String {
        rawValue
    }

}

/// ``UnitsConvertible`` conformance.
extension TemperatureUnits: UnitsConvertible {

    // swiftlint:disable function_body_length

    /// Convert from `self` to a new unit within the same category.
    /// - Parameter unit: The unit to convert to.
    /// - Returns: The operation that will convert `self` to `unit`.
    public func conversion(to unit: TemperatureUnits) -> Operation {
        switch (self, unit) {
        case (.celsius, .celsius), (.fahrenheit, .fahrenheit), (.kelvin, .kelvin):
            return .constant(declaration: AnyUnit(self))
        case (.celsius, .kelvin):
            return .addition(
                lhs: .constant(declaration: AnyUnit(self)),
                rhs: .literal(declaration: .decimal(value: 273.15))
            )
        case (.celsius, .fahrenheit):
            return .addition(
                lhs: .multiplication(
                    lhs: .constant(declaration: AnyUnit(self)),
                    rhs: .literal(declaration: .decimal(value: 1.8))
                ),
                rhs: .literal(declaration: .integer(value: 32))
            )
        case (.kelvin, .celsius):
            return .subtraction(
                lhs: .constant(declaration: AnyUnit(self)),
                rhs: .literal(declaration: .decimal(value: 273.15))
            )
        case (.kelvin, .fahrenheit):
            return .addition(
                lhs: .multiplication(
                    lhs: .precedence(
                        operation: .subtraction(
                            lhs: .constant(declaration: AnyUnit(self)),
                            rhs: .literal(declaration: .decimal(value: 273.15))
                        )
                    ),
                    rhs: .literal(declaration: .decimal(value: 1.8))
                ),
                rhs: .literal(declaration: .integer(value: 32))
            )
        case (.fahrenheit, .celsius):
            return .multiplication(
                lhs: .precedence(
                    operation: .subtraction(
                        lhs: .constant(declaration: AnyUnit(self)),
                        rhs: .literal(declaration: .integer(value: 32))
                    )
                ),
                rhs: .division(
                    lhs: .literal(declaration: .integer(value: 5)),
                    rhs: .literal(declaration: .integer(value: 9))
                )
            )
        case (.fahrenheit, .kelvin):
            return .addition(
                lhs: .multiplication(
                    lhs: .precedence(
                        operation: .subtraction(
                            lhs: .constant(declaration: AnyUnit(self)),
                            rhs: .literal(declaration: .integer(value: 32))
                        )
                    ),
                    rhs: .division(
                        lhs: .literal(declaration: .integer(value: 5)),
                        rhs: .literal(declaration: .integer(value: 9))
                    )
                ),
                rhs: .literal(declaration: .decimal(value: 273.15))
            )
        }
    }

    // swiftlint:enable function_body_length

}
