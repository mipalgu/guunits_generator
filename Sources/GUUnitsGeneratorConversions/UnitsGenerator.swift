/*
 * UnitsGenerator.swift
 * guunits_generator 
 *
 * Created by Callum McColl on 15/06/2019.
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

/// Struct that generates the code for all the possible conversion functions.
public struct UnitsGenerator<Creator: FunctionCreator>: UnitsGeneratable {

    /// The creator which generators language-specific code for a conversion function.
    let creator: Creator

    /// Helper that creates function names and definitions.
    private let helpers: FunctionHelpers<Creator.Unit>

    /// Initialise the UnitsGenerator with a creator and helpers.
    /// - Parameters:
    ///   - creator: The creator which will generate function definitions for unit conversions.
    ///   - helpers: The helper which will generate function definitions for unit and numeric conversions.
    public init(creator: Creator, helpers: FunctionHelpers<Creator.Unit> = FunctionHelpers<Creator.Unit>()) {
        self.creator = creator
        self.helpers = helpers
    }

    // swiftlint:disable force_cast

    /// Generates the function declarations for an array of units.
    /// - Parameter units: The units to generate conversion functions for.
    /// - Returns: A String representing valid C-code for conversion functions which can be
    ///            applied to the units.
    public func generateDeclarations<Unit>(forUnits units: [Unit]) -> String? where Unit == Creator.Unit {
        self.generate(forUnits: units as! [Creator.Unit], includeImplementation: false)
    }

    /// Generates the function implementations for an array of units.
    /// - Parameter units: The units to generate conversion functions for.
    /// - Returns: A string representing valid C-code for conversion functions with
    ///            function bodies.
    public func generateImplementations<Unit>(forUnits units: [Unit]) -> String? where Unit == Creator.Unit {
        self.generate(forUnits: units as! [Creator.Unit], includeImplementation: true)
    }

    // swiftlint:enable force_cast

    /// Generates the conversion function definitions for the given units.
    /// - Parameters:
    ///   - units: The units to generate functions for.
    ///   - includeImplementation: Whether these functions should include a function body.
    /// - Returns: The generated C-code with the conversion function definitions.
    private func generate(forUnits units: [Creator.Unit], includeImplementation: Bool) -> String? {
        var hashSet = Set<Creator.Unit>()
        var unique: [Creator.Unit] = []
        unique.reserveCapacity(units.count)
        units.forEach {
            if hashSet.contains($0) {
                return
            }
            hashSet.insert($0)
            unique.append($0)
        }
        let functions = Set<String>(
            unique.flatMap {
                self.generate(unit: $0, against: unique, includeImplementation: includeImplementation)
            }
        )
        let sorted = functions.sorted { (lhs: String, rhs: String) -> Bool in
            let first = lhs
                .components(separatedBy: .whitespaces)
                .dropFirst()
                .reduce(into: "") { $0 = $0 + $1 }
            let second = rhs
                .components(separatedBy: .whitespaces)
                .dropFirst()
                .reduce(into: "") { $0 = $0 + $1 }
            return first < second
        }
        guard let firstFunction = sorted.first else {
            return nil
        }
        return sorted.dropFirst().reduce(firstFunction) { $0 + "\n\n" + $1 }
    }

    /// Generate the conversion functions for a given unit.
    /// - Parameters:
    ///   - unit: The unit to generate conversion functions for.
    ///   - allUnits: The units to convert into.
    ///   - includeImplementation: Whether the function definition includes the function
    ///                            body.
    /// - Returns: An array of conversion functions.
    private func generate(
        unit: Creator.Unit, against allUnits: [Creator.Unit], includeImplementation: Bool
    ) -> [String] {
        let signFunc = self.createSignFunction(includeImplementation: includeImplementation)
        let toNumFunc = self.createToNumericFunction(includeImplementation: includeImplementation)
        let fromNumFunc = self.createFromNumericFunction(includeImplementation: includeImplementation)
        return NumericTypes.allCases.flatMap { type in
            Signs.allCases.flatMap { sign in
                Signs.allCases.flatMap { otherSign in
                    allUnits.flatMap { unit -> [String] in
                        let increasing = allUnits.compactMap { signFunc(unit, $0, sign, otherSign) }
                        let decreasing = allUnits.compactMap { signFunc($0, unit, sign, otherSign) }
                        var arr: [String] = []
                        arr.append(toNumFunc(unit, sign, type))
                        arr.append(fromNumFunc(type, unit, sign))
                        return Array(increasing) + Array(decreasing) + arr
                    }
                }
            }
        }
    }

    /// Creates a function that generates a conversion function using a unit to unit conversion.
    /// - Parameter includeImplementation: Whether to include the implementation.
    /// - Returns: A function containing the code to generate a unit to unit conversion.
    private func createSignFunction(includeImplementation: Bool)
        -> (Creator.Unit, Creator.Unit, Signs, Signs)
        -> String? {
        { unit, otherUnit, sign, otherSign in
            if unit == otherUnit && sign == otherSign {
                return nil
            }
            let comment = """
                /**
                 * Convert \(unit)_\(sign.rawValue) to \(otherUnit)_\(otherSign.rawValue).
                 */
                """
            let definition = self.creator
                .functionDefinition(forUnit: unit, to: otherUnit, sign: sign, otherSign: otherSign)
            if false == includeImplementation {
                return comment + "\n" + definition + ";"
            }
            let body = self.creator
                .createFunction(unit: unit, to: otherUnit, sign: sign, otherSign: otherSign)
            return comment + "\n" + definition + "\n{\n" + body + "\n" + "}"
        }
    }

    /// Creates function that generates a conversion function for unit to numeric conversions.
    /// - Parameter includeImplementation: Whether the function definition should include the
    ///                                    function body.
    /// - Returns: A function the can be called to generate C-code that performs a unit to numeric
    ///            conversion.
    private func createToNumericFunction(includeImplementation: Bool)
        -> (Creator.Unit, Signs, NumericTypes)
        -> String {
        { unit, sign, type in
            let comment = """
                /**
                 * Convert \(unit)_\(sign.rawValue) to \(type.rawValue).
                 */
                """
            let definition = self.creator.functionDefinition(forUnit: unit, sign: sign, to: type)
            if false == includeImplementation {
                return comment + "\n" + definition + ";"
            }
            let body = self.creator.convert("\(unit)", from: unit, sign: sign, to: type)
            return comment + "\n" + definition + "\n{\n" + "    return " + body + ";\n}"
        }
    }

    /// Creates a function that generates a C function that will perform a numeric to unit
    /// conversion.
    /// - Parameter includeImplementation: Whether the generated function will include the function
    ///                                    body.
    /// - Returns: A function which can be used to generate a numeric to unit conversion.
    private func createFromNumericFunction(includeImplementation: Bool)
        -> (NumericTypes, Creator.Unit, Signs)
        -> String {
        { type, unit, sign in
            let comment = """
            /**
             * Convert \(type.rawValue) to \(unit)_\(sign.rawValue).
             */
            """
            let definition = self.creator.functionDefinition(from: type, to: unit, sign: sign)
            if false == includeImplementation {
                return comment + "\n" + definition + ";"
            }
            let body = self.creator.convert("\(unit)", from: type, to: unit, sign: sign)
            return comment + "\n" + definition + "\n{\n" + "    return " + body + ";\n}"
        }
    }

}
