// GradualUnitsConvertible.swift 
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

import Foundation

public protocol Base10UnitsConvertible: UnitsConvertible where Self: Hashable {

    static var exponents: [Self: Int] { get }

}

extension Base10UnitsConvertible where Self: UnitProtocol {

    public func conversion(from unit: Self) -> Operation {
        unit.conversion(to: self)
    }

    public func conversion(to unit: Self) -> Operation {
        guard unit != self else {
            return .constant(declaration: AnyUnit(self))
        }
        guard let value = Self.exponents[self], let otherValue = Self.exponents[unit] else {
            fatalError("Exponents static var is incomplete. Missing \(self) or \(unit).")
        }
        let exponent = (otherValue - value)
        let literal = Array(repeating: 10, count: abs(exponent)).reduce(1, *)
        if exponent < 0 {
            return .multiplication(
                lhs: .constant(declaration: AnyUnit(self)),
                rhs: .literal(declaration: .integer(value: literal))
            )
        } else if exponent == 0 {
            return .constant(declaration: AnyUnit(self))
        } else {
            return .division(
                lhs: .constant(declaration: AnyUnit(self)),
                rhs: .literal(declaration: .integer(value: literal))
            )
        }
    }

    // public func conversion(to unit: Self) -> Operation {
    //     guard unit != self else {
    //         return .constant(declaration: AnyUnit(self))
    //     }
    //     guard Self.unitDifference.count == Self.allCases.count else {
    //         fatalError("Unit Difference is not complete.")
    //     }
    //     let units = unitsBetween(unit: unit)
    //     guard self == units.last || self == units.first else {
    //         fatalError("Failed to get units between \(self) and \(unit).")
    //     }
    //     let isUpwards = self == units.last
    //     let requiresDouble = self.requiresDouble(for: units, isUpwards: isUpwards)
    //     let totalUnits = isUpwards ? units.dropLast() : units.dropFirst()
    //     guard !requiresDouble else {
    //         let total = totalUnits.reduce(1.0) {
    //             guard let conversion = Self.unitDifference[$1] else {
    //                 fatalError("Unit Difference is not complete.")
    //             }
    //             let val = isUpwards ? conversion.upwards : conversion.downwards
    //             return $0 * val.asDouble
    //         }
    //         guard self == units.last else {
    //             return .division(
    //                 lhs: .constant(declaration: AnyUnit(self)),
    //                 rhs: .literal(declaration: .decimal(value: total))
    //             )
    //         }
    //         return .multiplication(
    //             lhs: .constant(declaration: AnyUnit(self)), rhs: .literal(declaration: .decimal(value: total))
    //         )
    //     }
    //     let total = totalUnits.reduce(1) {
    //         guard let conversion = Self.unitDifference[$1] else {
    //             fatalError("Unit Difference is not complete.")
    //         }
    //         let val = isUpwards ? conversion.upwards : conversion.downwards
    //         return $0 * val.asInteger
    //     }
    //     guard self == units.last else {
    //         return .division(
    //             lhs: .constant(declaration: AnyUnit(self)), rhs: .literal(declaration: .integer(value: total))
    //         )
    //     }
    //     return .multiplication(
    //         lhs: .constant(declaration: AnyUnit(self)), rhs: .literal(declaration: .integer(value: total))
    //     )
    // }

    // private func unitsBetween(unit: Self) -> [Self] {
    //     guard
    //         let me = Self.allCases.firstIndex(where: {
    //             $0 == self
    //         }),
    //         let other = Self.allCases.firstIndex(where: {
    //             $0 == unit
    //         })
    //     else {
    //         fatalError("Missing cases in allCases")
    //     }
    //     let max = max(me, other)
    //     let min = min(me, other)
    //     return Array(Self.allCases[min...max])
    // }

    // private func requiresDouble(for units: [Self], isUpwards: Bool) -> Bool {
    //     units.contains {
    //         let val = isUpwards ? Self.unitDifference[$0]?.upwards : Self.unitDifference[$0]?.downwards
    //         return val?.isFloat == true
    //     }
    // }

}
