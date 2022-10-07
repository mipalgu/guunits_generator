// AnyUnit.swift 
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

/// A struct for type-erased units conforming to `UnitProtocol`.
/// - SeeAlso: `UnitProtocol`.
public struct AnyUnit: CustomStringConvertible {

    /// A function to retrieve the category.
    private var categoryFn: () -> String

    /// A function to retrieve the same zero point.
    private var sameZeroPointFn: () -> Bool

    /// A function to retrieve the abbreviation.
    private var abbreviationFn: () -> String

    /// A function to retrieve the description.
    private var descriptionFn: () -> String

    /// A function that retrieves all of the units for the category.
    private var allCasesFn: () -> [AnyUnit]

    /// A function that retrieves the unit in the category with the highest precision.
    private var highestPrecisionFn: () -> AnyUnit

    /// The category of the unit.
    public var category: String {
        categoryFn()
    }

    /// Whether the category has the same zero point accross all units.
    public var sameZeroPoint: Bool {
        sameZeroPointFn()
    }

    /// The abbreviation of the unit.
    public var abbreviation: String {
        abbreviationFn()
    }

    /// The string representation of the unit.
    public var description: String {
        descriptionFn()
    }

    /// All of the unit cases in the category type.
    public var allCases: [AnyUnit] {
        allCasesFn()
    }

    /// The unit in the category with the highest precision.
    public var highestPrecision: AnyUnit {
        highestPrecisionFn()
    }

    /// Type-Erase a type unit conforming to `UnitProtocol`.
    /// - Parameter unit: The unit to type erase.
    public init<T>(_ unit: T) where T: UnitProtocol {
        self.categoryFn = { T.category }
        self.sameZeroPointFn = { T.sameZeroPoint }
        self.abbreviationFn = { unit.abbreviation }
        self.descriptionFn = { unit.description }
        self.allCasesFn = {
            T.allCases.map { u in
                AnyUnit(u)
            }
        }
        self.highestPrecisionFn = {
            AnyUnit(T.highestPrecision)
        }
    }

}

/// Hashable conformance.
extension AnyUnit: Hashable {

    /// Equality operation.
    public static func == (lhs: AnyUnit, rhs: AnyUnit) -> Bool {
        lhs.abbreviation == rhs.abbreviation && lhs.category == rhs.category
            && lhs.description == rhs.description && lhs.sameZeroPoint == rhs.sameZeroPoint
    }

    /// Hash operation.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(abbreviation)
        hasher.combine(description)
        hasher.combine(category)
        hasher.combine(sameZeroPoint)
    }

}
