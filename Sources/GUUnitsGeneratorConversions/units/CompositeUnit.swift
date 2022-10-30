// CompositeUnit.swift 
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

/// Defines a category that is created from relationships of other units. This protocol
/// defines a class of unit that uses different `UnitProtocol` types
/// in it's definition.
public protocol CompositeUnit: UnitProtocol, RawRepresentable where RawValue == String {

    /// The base operation of this unit.
    static var baseUnit: Operation { get }

    /// Any units in Self that have a name.
    static var namedUnit: [Operation: NamedUnit] { get }

    /// A unit type of this category.
    var unit: Operation { get }

    /// Create a unit that exists within this category.
    /// - Parameter unit: A specific unit belonging to this category.
    init(unit: Operation)

}

/// Default Implementation.
public extension CompositeUnit {

    /// The different permutations of the subunits.
    static var allCases: [Self] {
        Self.baseUnit.allCases.map {
            Self(unit: $0)
        }
    }

    /// The default `namedUnit` is an empty dictionary.
    static var namedUnit: [Operation: NamedUnit] {
        [:]
    }

    /// The abbreviation of the unit.
    var abbreviation: String {
        guard let name = Self.namedUnit[unit] else {
            return unit.abbreviation
        }
        return name.abbreviation
    }

    /// The string representation of the unit.
    var description: String {
        guard let name = Self.namedUnit[unit] else {
            return unit.description
        }
        return name.description
    }

    var rawValue: RawValue {
        guard let name = Self.namedUnit[unit] else {
            return unit.description
        }
        return name.description
    }

    init?(rawValue: RawValue) {
        nil
    }

}
