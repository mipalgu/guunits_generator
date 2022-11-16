// Relation.swift 
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

/// A relation between 2 units within different categories. This struct defines an operation
/// to convert a source unit into a target unit through an ``Operation``.
public struct Relation {

    /// The source unit.
    public let source: AnyUnit

    /// The target unit.
    public let target: AnyUnit

    /// The operation converting `source` into `target`.
    public let operation: Operation

    /// Initialise this type from the source, target, and operation.
    /// - Parameters:
    ///   - source: The source unit.
    ///   - target: The target unit.
    ///   - operation: The operation converting `source` into `target`.
    /// - Warning: `source` and `target` must not exist in the same unit category.
    /// This will cause a runtime crash when this occurs.
    public init(source: AnyUnit, target: AnyUnit, operation: Operation) {
        guard source.category != target.category else {
            fatalError("You cannot have a relation to the same category.")
        }
        self.source = source
        self.target = target
        self.operation = operation
    }

}

/// Equatable conformance.
extension Relation: Hashable {}

extension Relation {

    /// Defines the C function definition for the Relation.
    /// - Parameters:
    ///   - sign: The sign of the source unit.
    ///   - otherSign: The sign of the target unit.
    /// - Returns: The C function definition.
    func definition(sign: Signs, otherSign: Signs) -> String {
        let parameters = self.operation.units.map {
            "\($0)_\(sign.rawValue) \($0)"
        }
        .joined(separator: ", ")
        let source = self.source.description
        let sourceType = "\(source)_\(sign.rawValue)"
        let returnType = self.target.description + "_\(otherSign.rawValue)"
        let name = name(sign: sign, otherSign: otherSign)
        let comment = """
        /**
        * Convert \(sourceType) to \(returnType).
        */
        """
        let definition = "\(returnType) \(name)(\(parameters))"
        return comment + "\n" + definition + ";"
    }

    // swiftlint:disable function_body_length

    /// Generate the function body for a conversion to a unit outside of a units category.
    /// - Parameters:
    ///   - relationship: The conversion to generate.
    ///   - sign: The sign of the source unit.
    ///   - otherSign: The sign of the target unit.
    /// - Returns: A string containing the C code to perform the conversion.
    func implementation(sign: Signs, otherSign: Signs) -> String {
        let converter = NumericTypeConverter()
        let inputs = self.operation.units
        let parameters = inputs.map {
            "\($0)_\(sign.rawValue) \($0)"
        }
        .joined(separator: ", ")
        let source = self.source.description
        let sourceType = "\(source)_\(sign.rawValue)"
        let returnType = self.target.description + "_\(otherSign.rawValue)"
        let name = name(sign: sign, otherSign: otherSign)
        let comment = """
        /**
        * Convert \(sourceType) to \(returnType).
        */
        """
        let definition = "\(returnType) \(name)(\(parameters))"
        let numericType = sign.numericType.rawValue
        let unitDefs = inputs.enumerated()
        .map {
            "    const \(numericType) unit\($0) = ((\(numericType)) (\($1)));"
        }
        .joined(separator: "\n")
        let upperOverflow = inputs.indices.map {
            "overflow_upper_\(sign.rawValue)(unit\($0))"
        }
        .joined(separator: " || ")
        let lowerOverflow = inputs.indices.map {
            "overflow_lower_\(sign.rawValue)(unit\($0))"
        }
        .joined(separator: " || ")
        let conversion = self.operation
        let needsDouble = sign.isFloatingPoint || otherSign.isFloatingPoint || conversion.hasFloatOperation
        let cSign = needsDouble ? Signs.d : sign
        let code = conversion.cCode(sign: cSign)
        let upperLimit = otherSign.numericType.limits.1
        let lowerLimit = otherSign.numericType.limits.0
        let call = converter.convert(
            "result", from: cSign.numericType, to: self.target, sign: otherSign
        )
        let implementation: String
        if !sign.numericType.isSigned {
            implementation = """
            \(unitDefs)
                if (__builtin_expect(\(upperOverflow), 0)) {
                    return \(upperLimit);
                } else {
                    const \(cSign.numericType.rawValue) result = \(code);
                    if (__builtin_expect(overflow_upper_\(cSign.rawValue)(result), 0)) {
                        return \(upperLimit);
                    } else {
                        return \(call);
                    }
                }
            """
        } else {
            implementation = """
            \(unitDefs)
                if (__builtin_expect(\(upperOverflow), 0)) {
                    return \(upperLimit);
                } else if (__builtin_expect(\(lowerOverflow), 0)) {
                    return \(lowerLimit);
                } else {
                    const \(cSign.numericType.rawValue) result = \(code);
                    if (__builtin_expect(overflow_upper_\(cSign.rawValue)(result), 0)) {
                        return \(upperLimit);
                    } else if (__builtin_expect(overflow_lower_\(cSign.rawValue)(result), 0)) {
                        return \(lowerLimit);
                    } else {
                        return \(call);
                    }
                }
            """
        }
        return """
        \(comment)
        \(definition)
        {
        \(implementation)
        }
        """
    }

    // swiftlint:enable function_body_length

    /// The C function name for this conversion.
    /// - Parameters:
    ///   - sign: The sign of the source type.
    ///   - otherSign: The sign of the target type.
    /// - Returns: The C function name of this conversion.
    func name(sign: Signs, otherSign: Signs) -> String {
        self.source.abbreviation + "_\(sign.rawValue)_to_" +
            self.target.abbreviation + "_\(otherSign.rawValue)"
    }

}
