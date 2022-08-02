/*
 * CFileCreator.swift
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

/// Generates all of the C types and conversion functions.
public struct CFileCreator {

    /// The prefix which appears at the top of the file.
    private var prefix: String {
        """
        /*
        * guunits.c
        * guunits
        *
        * Created by Callum McColl on 05/06/2019.
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
        \("\n")
        #include "guunits.h"
        \("")
        #include <math.h>
        \("")
        #ifndef MAX
        #define MAX(a, b) ((a) > (b) ? (a) : (b))
        #endif
        \("")
        #ifndef MIN
        #define MIN(a, b) ((a) < (b) ? (a) : (b))
        #endif
        \("")
        #ifndef M_PI
        #define M_PI 3.14159265358979323846
        #endif
        """
    }

    /// The suffix which appears at the end of the file.
    var suffix: String {
        [NumericTypes.double, NumericTypes.float].flatMap { type in
            NumericTypes.allCases.compactMap { otherType in
                defineFloatToIntegralConversion(type.rawValue, from: type, to: otherType)
            }
        }
        .joined(separator: "\n\n")
    }

    private func defineFloatToIntegralConversion(
        _ str: String,
        from type: NumericTypes,
        to otherType: NumericTypes
    ) -> String? {
        guard type.isFloat && !otherType.isFloat else {
            return nil
        }
        let roundLiteral = "\(str)Val"
        let roundedString: String
        if type == .float {
            roundedString = "const \(type.rawValue) roundedValue = roundf(\(roundLiteral));"
        } else {
            roundedString = "const \(type.rawValue) roundedValue = round(\(roundLiteral));"
        }
        let nextToward = type == .float ? "nexttowardf" : "nexttoward"
        let upperLimit = self.sanitise(literal: otherType.limits.1, to: type)
        let lowerLimit = self.sanitise(literal: otherType.limits.0, to: type)
        return """
        \(otherType.rawValue) \(type.abbreviation)_to_\(otherType.abbreviation)(\(type.rawValue) \(str)Val) {
            \(roundedString)
            const \(type.rawValue) maxValue = \(nextToward)(((\(type.rawValue)) (\(upperLimit))), 0.0);
            const \(type.rawValue) minValue = \(nextToward)(((\(type.rawValue)) (\(lowerLimit))), 0.0);
            if (roundedValue > maxValue) {
                return \(otherType.limits.1);
            } else if (roundedValue < minValue) {
                return \(otherType.limits.0);
            } else {
                return ((\(otherType.rawValue)) (roundedValue));
            }
        }
        """
    }

    private func sanitise(literal: String, to type: NumericTypes) -> String {
        guard
            nil == literal.first(where: {
                guard let scalar = Unicode.Scalar(String($0)) else {
                    return true
                }
                return !(CharacterSet.decimalDigits.contains(scalar) || $0 == "." || $0 == "-")
            }),
            literal.filter({ $0 == "." }).count <= 1,
            literal.filter({ $0 == "-" }).count <= 1,
            let firstChar = literal.first,
            literal.contains("-") ? firstChar == "-" : true
        else {
            return literal
        }
        let hasDecimal = literal.contains(".")
        switch type {
        case .float:
            guard hasDecimal else {
                return "\(literal).0f"
            }
            return "\(literal)f"
        case .double:
            guard hasDecimal else {
                return "\(literal).0"
            }
            return literal
        default:
            guard hasDecimal else {
                return literal
            }
            return "round((double) (\(literal)))"
        }
    }

    /// Default init.
    public init() {}

    /// Generate all of the guunits source code.
    /// - Parameters:
    ///   - generators: The generators that creates the function definitions for their
    ///                 respective units.
    /// - Returns: A string of all C functions for the supported guunits types.
    public func generate(generators: [AnyGenerator]) -> String {
        let content = self.createContent(generators: generators)
        return self.prefix + "\n\n" + content + "\n\n" + self.suffix + "\n"
    }

    /// Create the conversion functions for each unit type.
    /// - Parameters:
    ///   - generators: The generators that creates the function definitions for their
    ///                 respective units.
    /// - Returns: A string containing all of the conversion functions.
    private func createContent(generators: [AnyGenerator]) -> String {
        let implementations: [String] = generators.map {
            guard let imp = $0.implementations else {
                fatalError("Failed to get implementations")
            }
            return imp
        }
        return implementations.joined(separator: "\n\n")
    }

}
