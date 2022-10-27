// Operation+Convertibles.swift 
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

extension Operation {

    var cCode: String {
        switch self {
        case .constant(let unit):
            return "((double) (\(unit)))"
        case .division(let lhs, let rhs):
            return "\(lhs.cCode) / \(rhs.cCode)"
        case .exponentiate(let base, let power):
            if power == .literal(declaration: .integer(value: 2)) {
                return Operation.multiplication(lhs: base, rhs: base).cCode
            }
            if power == .literal(declaration: .integer(value: 3)) {
                return Operation.multiplication(
                    lhs: base, rhs: .multiplication(lhs: base, rhs: base)
                ).cCode
            }
            return "pow(\(base.cCode), \(power.cCode))"
        case .literal(let declaration):
            switch declaration {
            case .integer(let value):
                return "((double) (\(value)))"
            case .decimal(let value):
                return "\(value)"
            }
        case .multiplication(let lhs, let rhs):
            return "\(lhs.cCode) * \(rhs.cCode)"
        case .precedence(let operation):
            return "(\(operation.cCode))"
        case .addition(let lhs, let rhs):
            return "\(lhs.cCode) + \(rhs.cCode)"
        case .subtraction(let lhs, let rhs):
            return "\(lhs.cCode) - \(rhs.cCode)"
        }
    }

    func replace(convertibles: [AnyUnit: AnyUnit]) -> String {
        switch self {
        case .constant(let unit):
            guard let newVal = convertibles[unit], newVal != unit else {
                return "((double) (1.0))"
            }
            let u1 = "\(unit)_d"
            let fn = "\(unit.abbreviation)_d_to_\(newVal.abbreviation)_d"
            return "((double) (\(fn)(((\(u1)) (1.0)))))"
        case .division(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            return "(\(lhs)) / (\(rhs))"
        case .exponentiate(let base, let power):
            let base = base.replace(convertibles: convertibles)
            let power = power.replace(convertibles: convertibles)
            return "pow(((double) (\(base))), ((double) (\(power))))"
        case .literal:
            return self.cCode
        case .multiplication(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            return "(\(lhs)) * (\(rhs))"
        case .precedence(let operation):
            let operation = operation.replace(convertibles: convertibles)
            return "(\(operation))"
        case .addition(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            return "(\(lhs)) + (\(rhs))"
        case .subtraction(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            return "(\(lhs)) - (\(rhs))"
        }
    }

    func getUnitConvertibles(comparingTo operation: Operation) -> [AnyUnit: AnyUnit] {
        switch self {
        case .constant(let unit):
            guard case let .constant(otherUnit) = operation else {
                fatalError("Operation mismatch between same units.")
            }
            var acc2: [AnyUnit: AnyUnit] = [:]
            acc2[unit] = otherUnit
            return acc2
        case .division(let lhs, let rhs):
            guard case let .division(lhs2, rhs2) = operation else {
                fatalError("Operation mismatch between same units.")
            }
            return getConvertibles(in: lhs, comparingTo: lhs2, and: rhs, comparingTo: rhs2)
        case .exponentiate(let base, let power):
            guard case let .exponentiate(base2, power2) = operation else {
                fatalError("Operation mismatch between same units.")
            }
            return getConvertibles(in: base, comparingTo: base2, and: power, comparingTo: power2)
        case .literal:
            return [:]
        case .multiplication(let lhs, let rhs):
            guard case let .multiplication(lhs2, rhs2) = operation else {
                fatalError("Operation mismatch between same units.")
            }
            return getConvertibles(in: lhs, comparingTo: lhs2, and: rhs, comparingTo: rhs2)
        case .precedence(let op):
            guard case let .precedence(op2) = operation else {
                fatalError("Operation mismatch between same units.")
            }
            return op.getUnitConvertibles(comparingTo: op2)
        case .addition(let lhs, let rhs):
            guard case let .addition(lhs2, rhs2) = operation else {
                fatalError("Operation mismatch between same units.")
            }
            return getConvertibles(in: lhs, comparingTo: lhs2, and: rhs, comparingTo: rhs2)
        case .subtraction(let lhs, let rhs):
            guard case let .subtraction(lhs2, rhs2) = operation else {
                fatalError("Operation mismatch between same units.")
            }
            return getConvertibles(in: lhs, comparingTo: lhs2, and: rhs, comparingTo: rhs2)
        }
    }

    private func getConvertibles(
        in op1: Operation, comparingTo op11: Operation, and op2: Operation, comparingTo op22: Operation
    ) -> [AnyUnit: AnyUnit] {
        var op1Acc = op1.getUnitConvertibles(comparingTo: op11)
        let op2Acc = op2.getUnitConvertibles(comparingTo: op22)
        guard valid(acc1: op1Acc, acc2: op2Acc) else {
            fatalError("Duplicate conversion in operation")
        }
        op2Acc.keys.forEach {
            op1Acc[$0] = op2Acc[$0]
        }
        return op1Acc
    }

    private func valid(acc1: [AnyUnit: AnyUnit], acc2: [AnyUnit: AnyUnit]) -> Bool {
        for k in acc1.keys {
            guard acc1[k] == acc2[k] || acc2[k] == nil else {
                return false
            }
        }
        return true
    }

}
