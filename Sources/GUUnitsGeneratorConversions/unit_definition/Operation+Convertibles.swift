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

import Foundation

/// Adds helper functions and properties for generating C code.
extension Operation {

    /// True if the Operation requires floating-point precision.
    var hasFloatOperation: Bool {
        switch self {
        case .constant:
            return false
        case .division(let lhs, let rhs):
            if case .literal(let declaration) = lhs, case .integer = declaration {
                return true
            }
            return lhs.hasFloatOperation || rhs.hasFloatOperation
        case .exponentiate:
            return true
        case .literal(let declaration):
            return declaration.isFloat
        case .multiplication(let lhs, let rhs):
            return lhs.hasFloatOperation || rhs.hasFloatOperation
        case .precedence(let operation):
            return operation.hasFloatOperation
        case .addition(let lhs, let rhs):
            return lhs.hasFloatOperation || rhs.hasFloatOperation
        case .subtraction(let lhs, let rhs):
            return lhs.hasFloatOperation || rhs.hasFloatOperation
        }
    }

    /// Tries to reduce the Operation into less operations where applicable.
    var simplify: Operation {
        switch self {
        case .constant, .literal:
            return self
        case .division(let lhs, let rhs):
            let newLhs = lhs.simplify
            let newRhs = rhs.simplify
            if newLhs == newRhs {
                return .literal(declaration: .integer(value: 1))
            }
            if case .literal(let value) = newRhs, value.isOne {
                return newLhs.simplify
            }
            return .division(lhs: newLhs, rhs: newRhs)
        case .multiplication(let lhs, let rhs):
            let newLhs = lhs.simplify
            let newRhs = rhs.simplify
            if
                case .literal(let value1) = newLhs,
                case .literal(let value2) = newRhs,
                value1.isOne && value2.isOne
            {
                return .literal(declaration: .integer(value: 1))
            }
            if case .literal(let value) = newLhs, value.isOne {
                return newRhs.simplify
            }
            if case .literal(let value) = newRhs, value.isOne {
                return newLhs.simplify
            }
            if
                case .division(let divLhs, let divRhs) = newRhs,
                case .literal(let value2) = divLhs, value2.isOne
            {
                return .division(lhs: newLhs.simplify, rhs: divRhs.simplify)
            }
            if
                case .division(let divLhs, let divRhs) = newLhs,
                case .literal(let value2) = divLhs, value2.isOne
            {
                return .division(lhs: newRhs.simplify, rhs: divRhs.simplify)
            }
            return .multiplication(lhs: newLhs, rhs: newRhs)
        case .exponentiate(let base, let power):
            let newBase = base.simplify
            let newPower = power.simplify
            if case .literal(let value) = newBase, value.isOne {
                return .literal(declaration: .integer(value: 1))
            }
            if case .literal(let value) = newPower {
                if value.isZero {
                    return .literal(declaration: .integer(value: 1))
                }
                if value.isOne {
                    return newBase.simplify
                }
            }
            return .exponentiate(base: newBase, power: newPower)
        case .addition(let lhs, let rhs):
            let newLhs = lhs.simplify
            let newRhs = rhs.simplify
            if
                case .literal(let value) = newLhs, value.isZero,
                case .literal(let value2) = newRhs, value2.isZero
            {
                return .literal(declaration: .integer(value: 0))
            }
            if case .literal(let value) = newLhs, value.isZero {
                return newRhs.simplify
            }
            if case .literal(let value2) = newRhs, value2.isZero {
                return newLhs.simplify
            }
            return .addition(lhs: lhs.simplify, rhs: rhs.simplify)
        case .precedence(let operation):
            let newOperation = operation.simplify
            if case .literal = operation {
                return newOperation.simplify
            }
            if case .constant = operation {
                return newOperation.simplify
            }
            return .precedence(operation: newOperation)
        case .subtraction(let lhs, let rhs):
            let newLhs = lhs.simplify
            let newRhs = rhs.simplify
            if case .literal(let value) = newRhs, value.isZero {
                return newLhs.simplify
            }
            return .subtraction(lhs: newLhs, rhs: newRhs)
        }
    }

    /// Finds all units within the ``Operation``.
    var units: [AnyUnit] {
        switch self {
        case .constant(let unit):
            return [unit]
        case .division(let lhs, let rhs):
            return lhs.units + rhs.units
        case .exponentiate(let base, let power):
            return base.units + power.units
        case .literal:
            return []
        case .multiplication(let lhs, let rhs):
            return lhs.units + rhs.units
        case .precedence(let value):
            return value.units
        case .addition(let lhs, let rhs):
            return lhs.units + rhs.units
        case .subtraction(let lhs, let rhs):
            return lhs.units + rhs.units
        }
    }

    /// Generate the C code for this operation.
    /// - Parameter sign: The sign of the units in the operation.
    /// - Returns: A String of C code representing this operation.
    func cCode(sign: Signs) -> String {
        let operation = self.simplify
        switch operation {
        case .constant(let unit):
            return "((\(sign.numericType.rawValue)) (\(unit)))"
        case .division(let lhs, let rhs):
            return "divide_\(sign.rawValue)((\(lhs.cCode(sign: sign))), (\(rhs.cCode(sign: sign))))"
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
            return "(pow(\(base.cCode(sign: sign)), \(power.cCode(sign: sign))))"
        case .literal(let declaration):
            switch declaration {
            case .integer(let value):
                return "((\(sign.numericType.rawValue)) (\(value)))"
            case .decimal(let value):
                return "((\(sign.numericType.rawValue)) (\(value)))"
            }
        case .multiplication(let lhs, let rhs):
            return "multiply_\(sign.rawValue)((\(lhs.cCode(sign: sign))), (\(rhs.cCode(sign: sign))))"
        case .precedence(let operation):
            return "(\(operation.cCode(sign: sign)))"
        case .addition(let lhs, let rhs):
            return "addition_\(sign.rawValue)((\(lhs.cCode(sign: sign))), (\(rhs.cCode(sign: sign))))"
        case .subtraction(let lhs, let rhs):
            return "subtraction_\(sign.rawValue)((\(lhs.cCode(sign: sign))), (\(rhs.cCode(sign: sign))))"
        }
    }

    /// Generate the equivalent swift code for this operation.
    /// - Parameter sign: The sign of the units within the operation.
    /// - Returns: A string of swift code performing this operation.
    func swiftCode(sign: Signs) -> String {
        switch self {
        case .constant(let unit):
            return "\(sign.numericType.swiftType.rawValue)(\(unit))"
        case .division(let lhs, let rhs):
            return "(\(lhs.swiftCode(sign: sign))) / (\(rhs.swiftCode(sign: sign)))"
        case .exponentiate(let base, let power):
            if power == .literal(declaration: .integer(value: 2)) {
                return Operation.multiplication(lhs: base, rhs: base).swiftCode(sign: sign)
            }
            if power == .literal(declaration: .integer(value: 3)) {
                return Operation.multiplication(
                    lhs: base, rhs: .multiplication(lhs: base, rhs: base)
                )
                .swiftCode(sign: sign)
            }
            return "(pow(\(base.swiftCode(sign: sign)), \(power.swiftCode(sign: sign))))"
        case .literal(let literal):
            return "\(sign.numericType.swiftType.rawValue)(\(literal))"
        case .multiplication(let lhs, let rhs):
            return "(\(lhs.swiftCode(sign: sign))) * (\(rhs.swiftCode(sign: sign)))"
        case .precedence(let operation):
            return "(\(operation.swiftCode(sign: sign)))"
        case .addition(let lhs, let rhs):
            return "(\(lhs.swiftCode(sign: sign))) + (\(rhs.swiftCode(sign: sign)))"
        case .subtraction(let lhs, let rhs):
            return "(\(lhs.swiftCode(sign: sign))) - (\(rhs.swiftCode(sign: sign)))"
        }
    }

    // swiftlint:disable function_body_length

    /// Replace units within this operation with an equivalent unit. This function will replace
    /// units within the `convertibles` dictionary with an equivalent unit. Units that are not
    /// in the `convertibles` dictionary will be removed from the operation and replaced with
    /// an identity equivalent operation. This function will also optimise the operation to
    /// remove redundent operations such as multiplying by 1, dividing by 1, etc.
    /// - Parameter convertibles: The units to convert in this operation.
    /// - Returns: The new operation with the units converted.
    func replace(convertibles: [AnyUnit: AnyUnit]) -> Operation {
        let newConvertibles = Dictionary(uniqueKeysWithValues: convertibles.map {
            ($0, Operation.constant(declaration: $1))
        })
        return replace(convertibles: newConvertibles)
    }

    /// See replace.
    func replace(convertibles: [AnyUnit: Operation]) -> Operation {
        let newOperation = self.simplify
        switch newOperation {
        case .constant(let unit):
            guard let newVal = convertibles[unit] else {
                return .literal(declaration: .integer(value: 1))
            }
            guard case .constant(let newUnit) = newVal, newUnit == unit else {
                return newVal
            }
            return self
        case .division(let lhs, let rhs):
            let lhs = lhs.replace(convertibles: convertibles)
            let rhs = rhs.replace(convertibles: convertibles)
            if case .literal(let value) = rhs, value.isOne {
                return lhs
            }
            if
                case .literal(let value) = lhs,
                value.isOne,
                case .division(let lhs2, let rhs2) = rhs,
                case .literal(let value2) = lhs2,
                value2.isOne
            {
                return rhs2
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
            if
                case .division(let rhsLhs, let rhsRhs) = rhs,
                case .literal(let value) = rhsLhs,
                value.isOne
            {
                return .division(lhs: lhs, rhs: rhsRhs)
            }
            if case .literal(let value) = lhs, case .literal(let value2) = rhs, value.isOne && value2.isOne {
                return .literal(declaration: .integer(value: 1))
            }
            if case .literal(let value) = lhs, value.isOne {
                return rhs
            }
            if case .literal(let value) = rhs, value.isOne {
                return lhs
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

    // swiftlint:enable function_body_length

}
