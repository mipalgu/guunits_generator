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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Generates all of the C types and conversion functions.
public struct CFileCreator {

    // swiftlint:disable closure_body_length

    /// The prefix which appears at the top of the file.
    private var prefix: String = {
        let includes = """
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
        #include <stdbool.h>
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
        let functionDefs = Signs.allCases.map { sign in
            let type = sign.numericType.rawValue
            guard sign.numericType.isSigned else {
                return """
                \(type) multiply_\(sign.rawValue)(\(type) a, \(type) b);
                \(type) divide_\(sign.rawValue)(\(type) a, \(type) b);
                \(type) addition_\(sign.rawValue)(\(type) a, \(type) b);
                \(type) subtraction_\(sign.rawValue)(\(type) a, \(type) b);
                bool overflow_upper_\(sign.rawValue)(\(type) a);
                bool overflow_\(sign.rawValue)(\(type) a);
                """
            }
            return """
            \(type) multiply_\(sign.rawValue)(\(type) a, \(type) b);
            \(type) divide_\(sign.rawValue)(\(type) a, \(type) b);
            \(type) addition_\(sign.rawValue)(\(type) a, \(type) b);
            \(type) subtraction_\(sign.rawValue)(\(type) a, \(type) b);
            bool overflow_upper_\(sign.rawValue)(\(type) a);
            bool overflow_lower_\(sign.rawValue)(\(type) a);
            bool overflow_\(sign.rawValue)(\(type) a);
            """
        }
        .joined(separator: "\n\n")
        return includes + "\n\n" + functionDefs
    }()

    // swiftlint:enable closure_body_length

    /// The suffix which appears at the end of the file.
    var suffix: String {
        [NumericTypes.double, NumericTypes.float].flatMap { type in
            NumericTypes.allCases.compactMap { otherType in
                defineFloatConversion(type.rawValue, from: type, to: otherType)
            }
        }
        .joined(separator: "\n\n") + "\n\n" + mathFunctions
    }

    /// Mathemtical operations that perform clamping on results.
    var mathFunctions: String {
        Signs.allCases.map {
            createOperations(for: $0)
        }
        .joined(separator: "\n\n")
    }

    /// Default init.
    public init() {}

    /// Standard data initialiser.
    /// - Parameter prefix: The prefix which appears before the function generation.
    init(prefix: String) {
        self.prefix = prefix
    }

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

    // swiftlint:disable line_length
    // swiftlint:disable function_body_length

    /// Create mathematical C operation functions that clamp results. The operations include
    /// multiplication, division, addition, subtraction and overflow checking functions.
    /// - Parameter sign: The sign each operation will act on.
    /// - Returns: The C code that defines these mathematical operations.
    private func createOperations(for sign: Signs) -> String {
        let typeType = sign.numericType
        let type = typeType.rawValue
        let limits = typeType.limits
        let upperLimit = limits.1
        let lowerLimit = limits.0
        let zero = sign.isFloatingPoint ? sanitise(literal: "0.0", to: sign.numericType) : "0"
        let one = sign.isFloatingPoint ? sanitise(literal: "1.0", to: sign.numericType) : "1"
        let multiplication: String
        if !sign.isFloatingPoint && sign.numericType.isSigned {
            multiplication = """
            \(type) multiply_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (__builtin_expect(a == \(zero) || b == \(zero), 0)) {
                    return \(zero);
                }
                const \(type) maxValue = (\(upperLimit)) / a;
                const \(type) minValue = (\(lowerLimit)) / a;
                if (__builtin_expect((b > maxValue && maxValue > 0) || (b < maxValue && maxValue < 0), 0)) {
                    return \(upperLimit);
                } else if (__builtin_expect((b < minValue && minValue < 0) || (b > minValue && minValue > 0), 0)) {
                    return \(lowerLimit);
                } else {
                    return a * b;
                }
            }
            """
        } else if !sign.isFloatingPoint && !sign.numericType.isSigned {
            multiplication = """
            \(type) multiply_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (__builtin_expect(a == \(zero) || b == \(zero), 0)) {
                    return \(zero);
                }
                const \(type) maxValue = (\(upperLimit)) / a;
                if (__builtin_expect(b > maxValue, 0)) {
                    return \(upperLimit);
                } else {
                    return a * b;
                }
            }
            """
        } else {
            multiplication = """
            \(type) multiply_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (__builtin_expect(a == \(zero) || b == \(zero), 0)) {
                    return \(zero);
                }
                if (__builtin_expect((b < \(one) && b > -\(one)) || (a < \(one) && a > -\(one)), 0)) {
                    return a * b;
                }
                if (a < 0 && b > 0) {
                    const \(type) minValue = (\(lowerLimit)) / b;
                    if (__builtin_expect(a < minValue, 0)) {
                        return \(lowerLimit);
                    } else {
                        return a * b;
                    }
                } else if (a > 0 && b < 0) {
                    const \(type) minValue = (\(lowerLimit)) / a;
                    if (__builtin_expect(b < minValue, 0)) {
                        return \(lowerLimit);
                    } else {
                        return a * b;
                    }
                } else {
                    const \(type) maxValue = \(upperLimit) / b;
                    if (__builtin_expect(a > maxValue, 0)) {
                        return \(upperLimit);
                    } else {
                        return a * b;
                    }
                }
            }
            """
        }
        let division: String
        if !sign.isFloatingPoint && sign.numericType.isSigned {
            division = """
            \(type) divide_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (__builtin_expect(b == \(zero), 0)) {
                    return a < 0 ? \(lowerLimit) : \(upperLimit);
                } else {
                    return a / b;
                }
            }
            """
        } else if !sign.isFloatingPoint && !sign.numericType.isSigned {
            division = """
            \(type) divide_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (__builtin_expect(b == \(zero), 0)) {
                    return \(upperLimit);
                } else {
                    return a / b;
                }
            }
            """
        } else {
            division = """
            \(type) divide_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (__builtin_expect(b == \(zero), 0)) {
                    return a < \(zero) ? \(lowerLimit) : \(upperLimit);
                } else if (__builtin_expect(b > \(zero) && b < \(one), 0)) {
                    const \(type) maxValue = (\(upperLimit)) * b;
                    if (__builtin_expect(a > maxValue || a < -maxValue, 0)) {
                        return \(upperLimit);
                    } else {
                        return a / b;
                    }
                } else if (__builtin_expect(b > -\(one) && b < \(zero), 0)) {
                    const \(type) minValue = (\(lowerLimit)) * b;
                    if (__builtin_expect(a > minValue || a < -minValue, 0)) {
                        return \(lowerLimit);
                    } else {
                        return a / b;
                    }
                } else {
                    return a / b;
                }
            }
            """
        }
        let addition: String
        if sign.numericType.isSigned {
            addition = """
            \(type) addition_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (__builtin_expect((a > \(zero) && b < \(zero)) || (a < \(zero) && b > \(zero)), 0)) {
                    return a + b;
                } else if (a > \(zero) && b > \(zero)) {
                    const \(type) maxValue = (\(upperLimit)) - b;
                    if (__builtin_expect(a > maxValue, 0)) {
                        return \(upperLimit);
                    } else {
                        return a + b;
                    }
                } else {
                    const \(type) minValue = (\(lowerLimit)) - b;
                    if (__builtin_expect(a < minValue, 0)) {
                        return \(lowerLimit);
                    } else {
                        return a + b;
                    }
                }
            }
            """
        } else {
            addition = """
            \(type) addition_\(sign.rawValue)(\(type) a, \(type) b)
            {
                const \(type) maxValue = (\(upperLimit)) - b;
                if (__builtin_expect(a > maxValue, 0)) {
                    return \(upperLimit);
                } else {
                    return a + b;
                }
            }
            """
        }
        let subtraction: String
        if !sign.numericType.isSigned {
            subtraction = """
            \(type) subtraction_\(sign.rawValue)(\(type) a, \(type) b)
            {
                return a >= b ? a - b : \(lowerLimit);
            }
            """
        } else if !sign.isFloatingPoint && sign.numericType.isSigned {
            subtraction = """
            \(type) subtraction_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if (a < \(zero) && b > \(zero)) {
                    const \(type) minValue = (\(lowerLimit)) + b;
                    if (__builtin_expect(a < minValue, 0)) {
                        return \(lowerLimit);
                    } else {
                        return a - b;
                    }
                } else if (a > \(zero) && b < \(zero)) {
                    const \(type) maxValue = (\(upperLimit)) + b;
                    if (__builtin_expect(a > maxValue, 0)) {
                        return \(upperLimit);
                    } else {
                        return a - b;
                    }
                } else {
                    return a - b;
                }
            }
            """
        } else {
            subtraction = """
            \(type) subtraction_\(sign.rawValue)(\(type) a, \(type) b)
            {
                if ((a > \(zero) && b > \(zero)) || (a < \(zero) && b < \(zero))) {
                    return a - b;
                } else if (a < \(zero) && b > \(zero)) {
                    const \(type) minValue = (\(lowerLimit)) + b;
                    if (__builtin_expect(a < minValue, 0)) {
                        return \(lowerLimit);
                    } else {
                        return a - b;
                    }
                } else if (a > \(zero) && b < \(zero)) {
                    const \(type) maxValue = (\(upperLimit)) + b;
                    if (__builtin_expect(a > maxValue, 0)) {
                        return \(upperLimit);
                    } else {
                        return a - b;
                    }
                } else {
                    return a - b;
                }
            }
            """
        }
        let overflow: String
        if !sign.numericType.isSigned {
            overflow = """
            bool overflow_upper_\(sign.rawValue)(\(type) a)
            {
                return a == \(upperLimit);
            }

            bool overflow_\(sign.rawValue)(\(type) a)
            {
                return overflow_upper_\(sign.rawValue)(a);
            }
            """
        } else {
            overflow = """
            bool overflow_upper_\(sign.rawValue)(\(type) a)
            {
                return a == \(upperLimit);
            }

            bool overflow_lower_\(sign.rawValue)(\(type) a)
            {
                return a == \(lowerLimit);
            }

            bool overflow_\(sign.rawValue)(\(type) a)
            {
                return overflow_upper_\(sign.rawValue)(a) || overflow_lower_\(sign.rawValue)(a);
            }
            """
        }
        return [multiplication, division, addition, subtraction, overflow].joined(separator: "\n\n")
    }

    // swiftlint:enable line_length
    // swiftlint:enable function_body_length

    /// Create the numeric conversion functions from a floating point type to another numeric type.
    /// - Parameters:
    ///   - str: The value to convert.
    ///   - type: The type of the `str` value. This type must be a double or float.
    ///   - otherType: The type to convert to. This type is usually an integral type, however this type
    ///                may also be a float when `type` is a double.
    /// - Returns: The function definition and implementation that performs the conversion.
    private func defineFloatConversion(
        _ str: String,
        from type: NumericTypes,
        to otherType: NumericTypes
    ) -> String? {
        guard (type.isFloat && !otherType.isFloat) || (type == .double && otherType == .float) else {
            return nil
        }
        let roundLiteral = "\(str)Val"
        var roundedString = ""
        if !otherType.isFloat {
            if type == .float {
                roundedString = "const \(type.rawValue) roundedValue = roundf(\(roundLiteral));"
            } else {
                roundedString = "const \(type.rawValue) roundedValue = round(\(roundLiteral));"
            }
        }
        let nextToward = type == .float ? "nexttowardf" : "nexttoward"
        let upperLimit = self.sanitise(literal: otherType.limits.1, to: type)
        let lowerLimit = self.sanitise(literal: otherType.limits.0, to: type)
        let firstLine = "\(otherType.rawValue) \(type.abbreviation)_to_" +
            "\(otherType.abbreviation)(\(type.rawValue) \(str)Val) {"
        let line2 = "const \(type.rawValue) maxValue = " +
            "\(nextToward)(((\(type.rawValue)) (\(upperLimit))), 0.0);"
        let nextLines = !roundedString.isEmpty ? roundedString + "\n" + line2 : line2
        let trailer = """
            const \(type.rawValue) minValue = \(nextToward)(((\(type.rawValue)) (\(lowerLimit))), 0.0);
            if (\(roundedString.isEmpty ? roundLiteral : "roundedValue") > maxValue) {
                return \(otherType.limits.1);
            } else if (\(roundedString.isEmpty ? roundLiteral : "roundedValue") < minValue) {
                return \(otherType.limits.0);
            } else {
                return ((\(otherType.rawValue)) (\(roundedString.isEmpty ? roundLiteral : "roundedValue")));
            }
        }
        """
        return firstLine +
            nextLines.components(separatedBy: .newlines).reduce(into: "") { $0 = $0 + "\n    " + $1 } +
            "\n" +
            trailer
    }

    /// Convert literals into a value suitable for a specific numeric type. For example converting 0 to 0.0
    /// for a double literal.
    /// - Parameters:
    ///   - literal: The literal to sanitise.
    ///   - type: The type to transform it into.
    /// - Returns: The sanitised literal.
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

}

// swiftlint:enable type_body_length
// swiftlint:enable file_length
