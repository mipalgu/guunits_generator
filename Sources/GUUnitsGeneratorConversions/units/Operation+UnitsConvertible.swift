// Operation+UnitsConvertible.swift 
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

extension Operation: UnitsConvertible {

    func matchedConversion(to unit: Operation) -> Operation {
        switch self {
        case .constant(let me):
            guard case .constant(let other) = unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return me.conversion(to: other)
        case .division(let lhs, let rhs):
            guard case .division(let otherLhs, let otherRhs) = unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return .division(lhs: lhs.conversion(to: otherLhs), rhs: rhs.conversion(to: otherRhs))
        case .exponentiate(let base, let power):
            guard case .exponentiate(let otherBase, let otherPower) = unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return .exponentiate(
                base: base.conversion(to: otherBase), power: power.conversion(to: otherPower)
            )
        case .literal:
            guard self == unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return self
        case .multiplication(let lhs, let rhs):
            guard case .multiplication(let otherLhs, let otherRhs) = unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return .multiplication(lhs: lhs.conversion(to: otherLhs), rhs: rhs.conversion(to: otherRhs))
        case .precedence(let operation):
            guard case .precedence(let otherOperation) = unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return .precedence(operation: operation.conversion(to: otherOperation))
        case .addition(let lhs, let rhs):
            guard case .addition(let otherLhs, let otherRhs) = unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return .addition(lhs: lhs.conversion(to: otherLhs), rhs: rhs.conversion(to: otherRhs))
        case .subtraction(let lhs, let rhs):
            guard case .subtraction(let otherLhs, let otherRhs) = unit else {
                fatalError("Operation mismatch between \(self) and \(unit)")
            }
            return .subtraction(lhs: lhs.conversion(to: otherLhs), rhs: rhs.conversion(to: otherRhs))
        }
    }

    public func conversion(to unit: Operation) -> Operation {
        matchedConversion(to: unit)
    }

}
