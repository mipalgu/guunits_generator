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

/// Protocol that helps units conformance to ``UnitsConvertible`` that use units
/// that are displaced using base10 increments. For example, this protocol can be used
/// with SI units utilising the SI prefixes nano (10^-9), micro (10^-6), milli (10^-3),
/// centi (10^-2), kilo (10^3), mega (10^6), etc. The `exponents` static constant expresses
/// each unit to the exponent used in the base 10 calculation, E.g. millimetres would have
/// an exponent of -3 since it uses the milli prefix.
public protocol Base10UnitsConvertible: UnitsConvertible where Self: Hashable {

    /// The exponents of the base 10 representation of each unit.
    static var exponents: [Self: Int] { get }

}

/// Default implementation of ``Base10UnitsConvertible`` where the conforming type also
/// conformas to ``UnitProtocol``.
extension Base10UnitsConvertible where Self: UnitProtocol {

    /// Convert `self` to another unit withing `Self`.
    /// - Parameter unit: The unit to convert to.
    /// - Returns: The operation that converts `self` to `unit`.
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

}
