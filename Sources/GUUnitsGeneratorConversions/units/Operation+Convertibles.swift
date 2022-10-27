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

    func cCode(sign: Signs) -> String {
        switch self {
        case .constant(let unit):
            return "((\(sign.numericType.rawValue)) (\(unit)))"
        case .division(let lhs, let rhs):
            return "\(lhs.cCode(sign: sign)) / \(rhs.cCode(sign: sign))"
        case .exponentiate(let base, let power):
            if power == .literal(declaration: .integer(value: 2)) {
                return Operation.multiplication(lhs: base, rhs: base).cCode(sign: sign)
            }
            if power == .literal(declaration: .integer(value: 3)) {
                return Operation.multiplication(
                    lhs: base, rhs: .multiplication(lhs: base, rhs: base)
                )
                .cCode(sign: sign)
            }
            return "pow(\(base.cCode(sign: sign)), \(power.cCode(sign: sign)))"
        case .literal(let declaration):
            switch declaration {
            case .integer(let value):
                return "((\(sign.numericType.rawValue)) (\(value)))"
            case .decimal(let value):
                return "((\(sign.numericType.rawValue)) (\(value)))"
            }
        case .multiplication(let lhs, let rhs):
            return "\(lhs.cCode(sign: sign)) * \(rhs.cCode(sign: sign))"
        case .precedence(let operation):
            return "(\(operation.cCode(sign: sign)))"
        case .addition(let lhs, let rhs):
            return "\(lhs.cCode(sign: sign)) + \(rhs.cCode(sign: sign))"
        case .subtraction(let lhs, let rhs):
            return "\(lhs.cCode(sign: sign)) - \(rhs.cCode(sign: sign))"
        }
    }

    func replace(convertibles: [AnyUnit: AnyUnit]) -> Operation {
        switch self {
        case .constant(let unit):
            guard let newVal = convertibles[unit], newVal == unit else {
                return .literal(declaration: .integer(value: 1))
            }
            return self
        case .division(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            if case .literal(let value) = rhs, value == .integer(value: 1) || value == .decimal(value: 1.0) {
                return lhs
            }
            return .division(lhs: lhs, rhs: rhs)
        case .exponentiate(let base, let power):
            let base = base.replace(convertibles: convertibles)
            let power = power.replace(convertibles: convertibles)
            return .exponentiate(base: base, power: power)
        case .literal:
            return self
        case .multiplication(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            if case .literal(let value) = lhs, value == .integer(value: 1) || value == .decimal(value: 1.0) {
                return rhs
            }
            if case .literal(let value) = rhs, value == .integer(value: 1) || value == .decimal(value: 1.0) {
                return lhs
            }
            if
                case .division(let rhsLhs, let rhsRhs) = rhs,
                case .literal(let value) = rhsLhs,
                value == .integer(value: 1) || value == .decimal(value: 1.0)
            {
                return .division(lhs: lhs, rhs: rhsRhs)
            }
            return .multiplication(lhs: lhs, rhs: rhs)
        case .precedence(let operation):
            let operation = operation.replace(convertibles: convertibles)
            return .precedence(operation: operation)
        case .addition(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            return .addition(lhs: lhs, rhs: rhs)
        case .subtraction(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            return .subtraction(lhs: lhs, rhs: rhs)
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
