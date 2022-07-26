/*
 * UnitProtocol.swift
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

/// A protocol for representing unit types that exist within a unit category.
/// A unit category represents a type of data that can be expressed with different
/// units. Examples include Distance, Time, Angles, etc. Conforming types might
/// contain many units for a category, e.g. Distance can have metres, centimetres,
/// millimetres, etc.
public protocol UnitProtocol: Hashable, CaseIterable, CustomStringConvertible, UnitRelatable {

    /// The category the unit belong to. Eg. radians belongs to the Angle category.
    static var category: String { get }

    /// The unit in the category with the highest precision.
    static var highestPrecision: Self { get }

    /// Whether the units in the category all share the same zero point. An example of this
    /// would be distance where 0m, 0cm, and 0mm all represent the same point. Whereas a
    /// contrary example would be Temperature values 0C and 0F which represent different points.
    static var sameZeroPoint: Bool { get }

    /// The abbreviation of the unit. Eg. seconds is abbreviated as s.
    var abbreviation: String { get }

}

/// Default Implementation of UnitProtocol
extension UnitProtocol {

    /// By default, the unit category is equal to the conforming type name.
    /// without a Units suffix.
    public static var category: String {
        let name = "\(Self.self)"
        if name.hasSuffix("Units") {
            return String(name.dropLast(5))
        }
        return name
    }

    // swiftlint:disable force_unwrapping

    /// By default, the highest precision is the first unit defined.
    /// by conforming types.
    /// - Warning: This default implementation assumes that atleast one unit is defined in the conforming
    ///            type. If this is not the case, then you will encounter runtime errors.
    public static var highestPrecision: Self {
        allCases.first!
    }

    // swiftlint:enable force_unwrapping

    /// By default, it is assumed that all units in this category share
    /// the same zero point.
    public static var sameZeroPoint: Bool {
        true
    }

    /// Initialise the unit from a string description.
    /// - Parameter desciption: The description of the unit.
    init?(description: String) {
        guard let unit = Self.allCases.first(where: {
            $0.description == description
        }) else {
            return nil
        }
        self = unit
    }

}
