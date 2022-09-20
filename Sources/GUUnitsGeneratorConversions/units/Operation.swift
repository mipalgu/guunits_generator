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
indirect enum Operation {

    /// The unit itself as a constant.
    case constant(declaration: AnyUnit)

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
        case .constant(let unit):
            return unit.abbreviation
        case .multiplication(let lhs, let rhs):
            return lhs.abbreviation + "_" + rhs.abbreviation
        case .division(let lhs, let rhs):
            return lhs.abbreviation + "_per_" + rhs.abbreviation
        case .precedence(let operation):
            return "_" + operation.abbreviation + "_"
        case .exponentiate(let base, let power):
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

}

/// Add abbreviation to Int.
private extension Int {

    /// The abbreviation of the Int.
    var abbreviation: String {
        guard self > 0 else {
            return "neg" + abs(self).abbreviation
        }
        guard self != 0 else {
            return ""
        }
        return "\(self)"
    }

}
