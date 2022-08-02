// /*
//  * TestFunctionBodyCreator.swift 
//  * guunits_generator 
//  *
//  * Created by Morgan McColl.
//  * Copyright © 2022 Morgan McColl. All rights reserved.
//  *
//  * Redistribution and use in source and binary forms, with or without
//  * modification, are permitted provided that the following conditions
//  * are met:
//  *
//  * 1. Redistributions of source code must retain the above copyright
//  *    notice, this list of conditions and the following disclaimer.
//  *
//  * 2. Redistributions in binary form must reproduce the above
//  *    copyright notice, this list of conditions and the following
//  *    disclaimer in the documentation and/or other materials
//  *    provided with the distribution.
//  *
//  * 3. All advertising materials mentioning features or use of this
//  *    software must display the following acknowledgement:
//  *
//  *        This product includes software developed by Morgan McColl.
//  *
//  * 4. Neither the name of the author nor the names of contributors
//  *    may be used to endorse or promote products derived from this
//  *    software without specific prior written permission.
//  *
//  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
//  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  *
//  * -----------------------------------------------------------------------
//  * This program is free software; you can redistribute it and/or
//  * modify it under the above terms or under the terms of the GNU
//  * General Public License as published by the Free Software Foundation;
//  * either version 2 of the License, or (at your option) any later version.
//  *
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program; if not, see http://www.gnu.org/licenses/
//  * or write to the Free Software Foundation, Inc., 51 Franklin Street,
//  * Fifth Floor, Boston, MA  02110-1301, USA.
//  *
//  */
// 

import Foundation

/// A struct that generates function bodies for test functions that test the
/// guunits conversion functions.
struct TestFunctionBodyCreator<Unit: UnitProtocol> where Unit: RawRepresentable, Unit.RawValue == String {

    /// The helper which provides function names.
    private let helper = FunctionHelpers<Unit>()

    /// Generate the test function body for a unit to unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    ///   - parameters: The test parameters.
    /// - Returns: The function body which performs that test.
    func generateFunction(
        from unit: Unit,
        with sign: Signs,
        to otherUnit: Unit,
        with otherSign: Signs,
        using parameters: TestParameters
    ) -> String {
        let fn = helper.functionName(forUnit: unit, to: otherUnit, sign: sign, otherSign: otherSign)
        guard !otherSign.numericType.isFloat else {
            let conversion = "\(otherUnit.rawValue)_\(otherSign.rawValue)"
            return floatAssert(body: fn, parameters: parameters, conversion: conversion)
        }
        return assert(body: fn, parameters: parameters)
    }

    /// Generate a test function body for a unit to numeric conversion test.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric to convert to.
    ///   - parameters: The test parameters.
    /// - Returns: The function body which implements the test.
    func generateFunction(
        from unit: Unit,
        with sign: Signs,
        to numeric: NumericTypes,
        using parameters: TestParameters
    ) -> String {
        let fn = helper.functionName(forUnit: unit, sign: sign, to: numeric)
        guard !numeric.isFloat else {
            return floatAssert(body: fn, parameters: parameters, conversion: numeric.swiftType.rawValue)
        }
        return assert(body: fn, parameters: parameters)
    }

    /// Generate a test function body for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    ///   - parameters: The test parameters.
    /// - Returns: The test implementation which tests the conversion function.
    func generateFunction(
        from numeric: NumericTypes, to unit: Unit, with sign: Signs, using parameters: TestParameters
    ) -> String {
        let fn = helper.functionName(from: numeric, to: unit, sign: sign)
        guard !sign.numericType.isFloat else {
            let conversion = "\(unit.rawValue)_\(sign.rawValue)"
            return floatAssert(body: fn, parameters: parameters, conversion: conversion)
        }
        return assert(body: fn, parameters: parameters)
    }

    /// Converts a literal into a suitable C-literal for type conversion. The typical use-case of
    /// this function is to turn a double literal into a float literal when doing float conversions.
    /// For example turning 0.0 into 0.0f.
    /// - Parameters:
    ///   - literal: The string to sanitise.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    /// - Returns: The sanitised literal.
    func sanitiseLiteral(literal: String, sign: Signs) -> String {
        sanitiseLiteral(literal: literal, to: sign.numericType)
    }

    /// Converts a literal into a suitable C-literal for type conversion. The typical use-case of
    /// this function is to turn a double literal into a float literal when doing float conversions.
    /// For example turning 0.0 into 0.0f.
    /// - Parameters:
    ///   - literal: The string to sanitise.
    ///   - type: The numeric type to convert to.
    /// - Returns: The sanitised literal.
    func sanitiseLiteral(literal: String, to type: NumericTypes) -> String {
        let trimmedLiteral = literal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = trimmedLiteral.first else {
            return trimmedLiteral
        }
        let isNegative = first == "-"
        let literal = isNegative ? String(trimmedLiteral.dropFirst()) : trimmedLiteral
        guard !literal.isEmpty, isNumeric(literal: literal) else {
            return isNegative ? "-" + literal : literal
        }
        let components = literal.components(separatedBy: ".")
        guard components.count == 2 else {
            switch type {
            case .double, .float:
                return addNegative(literal: "\(literal).0", isNegative: isNegative)
            case .uint, .uint8, .uint16, .uint32, .uint64:
                return isNegative ? "0" : literal
            default:
                return addNegative(literal: literal, isNegative: isNegative)
            }
        }
        switch type {
        case .double, .float:
            return isNegative ? "-" + literal : literal
        case .uint8, .uint16, .uint32, .uint64, .uint:
            return isNegative ? "0" : "\(components[0])"
        default:
            return isNegative ? "-" + "\(components[0])" : "\(components[0])"
        }
    }

    /// Adds a negative symbol to the front of a string if that string requires it.
    /// - Parameters:
    ///   - literal: The string to modify.
    ///   - isNegative: Whether to add the negative sign.
    /// - Returns: A new string with a negative symbol out the front if required.
    private func addNegative(literal: String, isNegative: Bool = false) -> String {
        isNegative ? "-" + literal : literal
    }

    /// Checks that a given string only contains the decimal digits (0-9) and at most
    /// 1 decimal point (.). This check will only work for positive literals.
    /// - Parameter literal: The string to check.
    /// - Returns: Whether it is a numeric literal.
    private func isNumeric(literal: String) -> Bool {
        literal.allSatisfy {
            guard let scalar = Unicode.Scalar(String($0)) else {
                return false
            }
            return CharacterSet.decimalDigits.contains(scalar) || $0 == "." || $0 == "U" || $0 == "L"
        }
         && literal.components(separatedBy: ".").count < 3
         && literal.components(separatedBy: "U").count < 2
         && literal.components(separatedBy: "L").filter { !$0.isEmpty }.count == 1
    }

    /// Use XCTest to test.
    /// - Parameters:
    ///   - body: The conversion function.
    ///   - parameters: The parameters to test.
    /// - Returns: The implementation of the conversion test.
    private func assert(body: String, parameters: TestParameters) -> String {
        "XCTAssertEqual(\(body)(\(parameters.input)), \(parameters.output))"
    }

    /// Template code for performing an assertion using floating point numbers. This code performs a floating
    /// point operating and assumes the result is within some margin of error.
    /// - Parameters:
    ///   - body: The conversion function to test.
    ///   - parameters: The parameters to use in the test.
    ///   - conversion: The type of the converted output.
    /// - Returns: The test code for asserting that the operation was successful.
    private func floatAssert(body: String, parameters: TestParameters, conversion: String) -> String {
        """
        let result = \(body)(\(parameters.input))
        let expected: \(conversion) = \(parameters.output)
        let tolerance: \(conversion) = 0.5
        if result > expected {
            XCTAssertLessThanOrEqual(result - expected, tolerance)
        } else {
            XCTAssertLessThanOrEqual(expected - result, tolerance)
        }
        """
    }

}
