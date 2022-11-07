/*
 * HeaderCreator.swift
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

/// Struct for creating the C header file.
public struct HeaderCreator {

    /// The prefix which appears at the top of the header file.
    private var prefix: String {
        """
        /*
        * guunits.h
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
        #ifndef GUUNITS_H
        #define GUUNITS_H
        \("")
        #include <stdint.h>
        #include <limits.h>
        #include <float.h>
        \("")
        #ifdef __cplusplus
        extern "C" {
        #endif
        """
    }

    /// The suffix which appears at the bottom of the header file.
    private var suffix: String {
        """
        \(numericConversions)

        #ifdef __cplusplus
        }
        #endif
        \("")
        #endif  /* GUUNITS_H */
        \("")
        """
    }

    /// The function definitions for the numeric conversion functions.
    private var numericConversions: String {
        [NumericTypes.double, NumericTypes.float].flatMap { type in
            NumericTypes.allCases.compactMap { otherType in
                guard (type.isFloat && !otherType.isFloat) || (type == .double && otherType == .float) else {
                    return nil
                }
                return "\(otherType.rawValue) \(type.abbreviation)_to_" +
                    "\(otherType.abbreviation)(\(type.rawValue));"
            }
        }
        .joined(separator: "\n\n")
    }

    /// Type definitions for all the unit types.
    private var typeDefs: String {
        let units: [(String, [CustomStringConvertible])] = [
            ("// Distance Units.", Array(DistanceUnits.allCases)),
            ("// Current Units.", Array(CurrentUnits.allCases)),
            ("// Time Units.", Array(TimeUnits.allCases)),
            ("// Angle Units.", Array(AngleUnits.allCases)),
            ("// Image Units.", Array(ImageUnits.allCases)),
            ("// Percent Units.", Array(PercentUnits.allCases)),
            ("// Temperature Units.", Array(TemperatureUnits.allCases)),
            ("// Acceleration Units.", Array(Acceleration.allCases)),
            ("// Reference Acceleration Units", Array(ReferenceAcceleration.allCases)),
            ("// Mass Units.", Array(MassUnits.allCases)),
            ("// Velocity Units.", Array(Velocity.allCases)),
            ("// Angular Velocity Units.", Array(AngularVelocity.allCases))
        ]
        let signs = Signs.allCases
        let typeDefs = units.flatMap { comment, units in
            ["", comment] + units.flatMap { unit in
                signs.map { "typedef \($0.type) \(unit)_\($0.rawValue);" }
            }
        }
        guard let first = typeDefs.first else {
            return ""
        }
        return typeDefs.dropFirst().reduce(first) { $0 + "\n" + $1 }
    }

    /// Default init.
    public init() {}

    /// Generate a string containing all of the type and function definitions.
    /// - Parameters:
    ///   - generators: The generators that creates the function definitions for their
    ///                 respective units.
    /// - Returns: All of the type and function definitions for a C header file.
    public func generate(generators: [AnyGenerator]) -> String {
        let content = self.createContent(generators: generators)
        return self.prefix + "\n" + self.typeDefs + "\n\n" + content + "\n\n" + self.suffix
    }

    /// Creates the function definitions for every unit type.
    /// - Parameters:
    ///   - generators: The generators that creates the function definitions for their
    ///                 respective units.
    /// - Returns: A string of all the function definitions.
    private func createContent(generators: [AnyGenerator]) -> String {
        let functions: [String] = generators.map {
            guard let definitions = $0.declarations else {
                fatalError("Failed to convert functions")
            }
            return definitions
        }
        return functions.joined(separator: "\n\n")
    }

}
