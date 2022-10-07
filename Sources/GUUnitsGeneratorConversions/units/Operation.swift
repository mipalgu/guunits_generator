// Operation.swift 
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

/// Enum for defining common operations in a composite unit.
indirect enum Operation: Hashable {

    /// The unit itself as a constant.
    case constant(declaration: AnyUnit, sign: Signs? = nil)

    /// A literal value, should not be used by itself as a stand-alone unit.
    case literal(declaration: Int)

    /// Two operations multiplied together.
    case multiplication(lhs: Operation, rhs: Operation)

    /// One operation divided by another operation.
    case division(lhs: Operation, rhs: Operation)

    /// Gives this operation precedence over other operations. Equivalent to placing
    /// brackets around an operation.
    case precedence(operation: Operation)

    /// Raise some operation to a power.
    case exponentiate(base: Operation, power: Operation)

    /// The abbreviation of the operation.
    var abbreviation: String {
        switch self {
        case .constant(let unit, let sign):
            guard let sign = sign else {
                return unit.abbreviation
            }
            return AnySignedUnit(unit: unit, sign: sign).abbreviation
        case .multiplication(let lhs, let rhs):
            let rhsAbbreviation = rhs.abbreviation
            let lhsAbbreviation = lhs.abbreviation
            if lhsAbbreviation == "1" && rhsAbbreviation == "1" {
                return "1"
            }
            if lhsAbbreviation == "1" {
                return rhsAbbreviation
            }
            if rhsAbbreviation == "1" {
                return lhsAbbreviation
            }
            return lhsAbbreviation + "_" + rhsAbbreviation
        case .division(let lhs, let rhs):
            let rhsAbbreviation = rhs.abbreviation
            let lhsAbbreviation = lhs.abbreviation
            if lhsAbbreviation == "1" && rhsAbbreviation == "1" {
                return "1"
            }
            if rhsAbbreviation == "1" {
                return lhsAbbreviation
            }
            if lhsAbbreviation == "1" {
                return Operation.exponentiate(base: rhs, power: .literal(declaration: -1)).abbreviation
            }
            return lhsAbbreviation + "_per_" + rhsAbbreviation
        case .precedence(let operation):
            return "_" + operation.abbreviation + "_"
        case .exponentiate(let base, let power):
            if case let .literal(num) = power, num == 0 {
                return "1"
            }
            if power.abbreviation == "1" {
                return base.abbreviation
            }
            if case let .literal(num) = power, num == 2 {
                return base.abbreviation + "_sq"
            }
            if case let .literal(num) = power, num == 3 {
                return base.abbreviation + "_cub"
            }
            return base.abbreviation + "_pwr_\(power.abbreviation)"
        case .literal(let literal):
            return literal.abbreviation
        }
    }

    /// The description of the operation.
    var description: String {
        switch self {
        case .constant(let unit, let sign):
            guard let sign = sign else {
                return unit.description
            }
            return AnySignedUnit(unit: unit, sign: sign).description
        case .multiplication(let lhs, let rhs):
            let rhsDescription = rhs.description
            let lhsDescription = lhs.description
            if lhsDescription == "1" && rhsDescription == "1" {
                return "1"
            }
            if lhsDescription == "1" {
                return rhsDescription
            }
            if rhsDescription == "1" {
                return lhsDescription
            }
            return lhsDescription + "_" + rhsDescription
        case .division(let lhs, let rhs):
            let rhsDescription = rhs.description
            let lhsDescription = lhs.description
            if lhsDescription == "1" && rhsDescription == "1" {
                return "1"
            }
            if rhsDescription == "1" {
                return lhsDescription
            }
            if lhsDescription == "1" {
                return Operation.exponentiate(base: rhs, power: .literal(declaration: -1)).abbreviation
            }
            return lhsDescription + "_per_" + rhsDescription
        case .precedence(let operation):
            return "_" + operation.description + "_"
        case .exponentiate(let base, let power):
            if case let .literal(num) = power, num == 0 {
                return "1"
            }
            if power.description == "1" {
                return base.description
            }
            if case let .literal(num) = power, num == 2 {
                return base.description + "_sq"
            }
            if case let .literal(num) = power, num == 3 {
                return base.description + "_cub"
            }
            return base.description + "_pwr_\(power.description)"
        case .literal(let literal):
            return literal.description
        }
    }

    /// Provides all possible combinations of unit category cases for the operation.
    var allCases: [Operation] {
        switch self {
        case .constant(let unit, let sign):
            guard let sign = sign else {
                return unit.allCases.map {
                    Operation.constant(declaration: $0)
                }
            }
            return AnySignedUnit(unit: unit, sign: sign).allCases.map {
                Operation.constant(declaration: $0.unit, sign: $0.sign)
            }
        case .multiplication(let lhs, let rhs):
            return lhs.allCases.flatMap { lhsUnit in
                rhs.allCases.map { rhsUnit in
                    Operation.multiplication(lhs: lhsUnit, rhs: rhsUnit)
                }
            }
        case .division(let lhs, let rhs):
            return lhs.allCases.flatMap { lhsUnit in
                rhs.allCases.map { rhsUnit in
                    Operation.division(lhs: lhsUnit, rhs: rhsUnit)
                }
            }
        case .precedence(let operation):
            return operation.allCases.map {
                Operation.precedence(operation: $0)
            }
        case .exponentiate(let base, let power):
            return base.allCases.flatMap { baseUnit in
                power.allCases.map { powerUnit in
                    Operation.exponentiate(base: baseUnit, power: powerUnit)
                }
            }
        case .literal:
            return [self]
        }
    }

}

/// Add abbreviation to Int.
private extension Int {

    /// The abbreviation of the Int.
    var abbreviation: String {
        guard self > 0 else {
            return "neg" + abs(self).abbreviation
        }
        return "\(self)"
    }

}
