/*
 * FunctionHelpers.swift
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

import Foundation

/// Helper struct for generating C function definitions and names.
public struct FunctionHelpers<Unit: UnitProtocol> {

    /// Default init.
    public init() {}

    /// Represents a sign in the format suitable for a function declaration.
    /// - Parameters:
    ///   - sign: The sign to convert.
    ///   - prefix: A string to place immediately before the sign.
    ///   - suffix: A string to place immediately after the sign.
    /// - Returns: The prefix, sign, and suffix concatenated together.
    private func collapse(_ sign: Signs?, prefix: String = "_", suffix: String = "") -> String {
        sign.map { prefix + $0.rawValue + suffix } ?? ""
    }

    /// Generate a function name that represents a unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    ///   - unique: Whether the function name has to be unique.
    /// - Returns: The generated function name.
    func functionName(
        forUnit unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs, unique: Bool = true
    ) -> String {
        let uniqueSign = collapse(unique ? sign : nil)
        return "\(unit.abbreviation)\(uniqueSign)_to_\(otherUnit.abbreviation)\(collapse(otherSign))"
    }

    /// Creates a c-style function definition for a conversion function.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    ///   - unique: Whether the function name has to be unique.
    ///   - namespace: A string that is prepended to the function name.
    /// - Returns: The generated function definition.
    func functionDefinition(
        forUnit unit: Unit,
        to otherUnit: Unit,
        sign: Signs,
        otherSign: Signs,
        unique: Bool = true,
        namespace: String? = nil
    ) -> String {
        let functionName = self.functionName(
            forUnit: unit, to: otherUnit, sign: sign, otherSign: otherSign, unique: unique
        )
        return "\(otherUnit)\(collapse(otherSign)) \(namespace ?? "")" +
            "\(functionName)(\(unit)\(collapse(sign)) \(unit))"
    }

    /// Generate a c-style function name representing a unit conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - type: The type to convert to.
    ///   - unique: Whether the function name has to be unique.
    /// - Returns: The generated function name.
    func functionName(forUnit unit: Unit, sign: Signs, to type: NumericTypes, unique: Bool = true) -> String {
        "\(unit.abbreviation)\(collapse(unique ? sign : nil))_to_\(type.abbreviation)"
    }

    /// Generate a c-style function definition for a unit conversion function.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - type: The c-type to convert to.
    ///   - unique: Whether the function name has to be unique.
    ///   - namespace: A string that is prepended to the function name.
    /// - Returns: The generated function definition.
    func functionDefinition(
        forUnit unit: Unit,
        sign: Signs,
        to type: NumericTypes,
        unique: Bool = true,
        namespace: String? = nil
    ) -> String {
        let functionName = self.functionName(forUnit: unit, sign: sign, to: type, unique: unique)
        return "\(type.rawValue) \(namespace ?? "")\(functionName)(\(unit)\(collapse(sign)) \(unit))"
    }

    /// Generate a function name for a conversion function.
    /// - Parameters:
    ///   - type: The type to convert from.
    ///   - unit: The unit to convert into.
    ///   - sign: The sign of the unit.
    ///   - unique: Whether the function name has to be unique.
    /// - Returns: The generated function name.
    func functionName(from type: NumericTypes, to unit: Unit, sign: Signs, unique: Bool = true) -> String {
        let uniquePrefix = unique || type == .int || type == .uint ? "\(type.abbreviation)_to_" : ""
        return uniquePrefix + "\(unit.abbreviation)\(collapse(sign))"
    }

    /// Generate a c-style function definition for a conversion function.
    /// - Parameters:
    ///   - type: The type to convert from.
    ///   - unit: The unit to convert into.
    ///   - sign: The sign of the unit.
    ///   - unique: Whether the function name has to be unique.
    ///   - namespace: A string that is prepended to the function name.
    /// - Returns: The generated function definition.
    func functionDefinition(
        from type: NumericTypes,
        to unit: Unit,
        sign: Signs,
        unique: Bool = true,
        namespace: String? = nil
    ) -> String {
        let functionName = self.functionName(from: type, to: unit, sign: sign, unique: unique)
        return "\(unit)\(collapse(sign)) \(namespace ?? "")\(functionName)(\(type.rawValue) \(unit))"
    }

    /// Helper function that converts integer literals into floating point and double literals.
    /// - Parameters:
    ///   - value: The literal to convert.
    ///   - sign: The sign to convert into.
    /// - Returns: The generated literal.
    func modify(value: Int, forSign sign: Signs) -> String {
        switch sign.numericType {
        case .float:
            return "\(value).0f"
        case .double:
            return "\(value).0"
        default:
            return "\(value)"
        }
    }

    /// Create the name of a function that test a conversion function.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    ///   - parameters: The test parameters.
    /// - Returns: The name of a suitable test function.
    func testFunctionName<Unit: UnitProtocol>(
        from unit: Unit,
        with sign: Signs,
        to otherUnit: Unit,
        with otherSign: Signs,
        using parameters: TestParameters
    ) -> String where
        Unit: RawRepresentable,
        Unit.RawValue == String {
        doTestFunctionName(
            from: "\(unit.rawValue)_\(sign.rawValue)",
            to: "\(otherUnit.rawValue)_\(otherSign.rawValue)",
            with: "\(parameters.input)",
            expecting: "\(parameters.output)"
        )
    }

    /// Create the name of a function that test a conversion function.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - other: The numeric type to convert to.
    ///   - parameters: The parameters to test in the function.
    /// - Returns: A test function name of this conversion function.
    func testFunctionName<Unit>(
        from unit: Unit,
        with sign: Signs,
        to other: NumericTypes,
        using parameters: TestParameters
    ) -> String where
        Unit: RawRepresentable,
        Unit.RawValue == String {
        doTestFunctionName(
            from: "\(unit.rawValue)_\(sign.rawValue)",
            to: other.rawValue,
            with: parameters.input,
            expecting: parameters.output
        )
    }

    /// Create a test function name for a conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    ///   - parameters: The parameters to use in the test.
    /// - Returns: An appropriate test function name.
    func testFunctionName<Unit>(
        from numeric: NumericTypes,
        to unit: Unit,
        with sign: Signs,
        using parameters: TestParameters
    ) -> String where
        Unit: RawRepresentable,
        Unit.RawValue == String {
        doTestFunctionName(
            from: numeric.rawValue,
            to: "\(unit.rawValue)_\(sign.rawValue)",
            with: parameters.input,
            expecting: parameters.output
        )
    }

    /// Create a test function name for a conversion between 2 numeric types.
    /// - Parameters:
    ///   - from: The numeric type to convert from.
    ///   - to: The numeric type to convert to.
    ///   - parameters: The parameters used in the test function.
    /// - Returns: An appropriate name for the test function.
    func testFunctionName(from: NumericTypes, to: NumericTypes, using parameters: TestParameters) -> String {
        doTestFunctionName(
            from: from.rawValue,
            to: to.rawValue,
            with: parameters.input,
            expecting: parameters.output
        )
    }

    /// Create a test function name.
    /// - Parameters:
    ///   - from: The name of the type to convert from.
    ///   - to: The name of the type to convert to.
    ///   - with: The input parameter.
    ///   - expecting: The expected output parameter.
    /// - Returns: An appropriate test function name.
    private func doTestFunctionName(from: String, to: String, with: String, expecting: String) -> String {
        let firstUnit = sanitise(string: from)
        let secondUnit = sanitise(string: to)
        let input = sanitise(string: with)
        let output = sanitise(string: expecting)
        return "test\(firstUnit)To\(secondUnit)Using\(input)Expecting\(output)"
    }

    /// Remove all characters after an invalid character is found.
    /// - Parameter string: The string to santise.
    /// - Returns: The sanitised string.
    private func sanitise(string: String) -> String {
        guard
            !string.isEmpty,
            let badIndex = string.firstIndex(where: {
                guard let scalar = Unicode.Scalar("\($0)") else {
                    return true
                }
                return !CharacterSet.alphanumerics.contains(scalar) && $0 != "_"
            })
        else {
            return string
        }
        let firstIndex = String.Index(utf16Offset: 0, in: string)
        return String(string[firstIndex..<badIndex])
    }

}
