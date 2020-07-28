/*
 * SwiftFileGenerator.swift
 * guunits_generator
 *
 * Created by Callum McColl on 28/7/20.
 * Copyright © 2020 Callum McColl. All rights reserved.
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

struct SwiftFileCreator {
    
    func generate<T: UnitProtocol>(for value: T) -> String {
        let prefix = self.prefix(name: value.description.capitalized)
        let structs = Signs.allCases.reduce("") {
            $0 + "\n\n" + self.generate(for: value, $1, allCases: Set(T.allCases).subtracting(Set([value])).sorted { $0.description < $1.description })
        }
        return prefix + structs + "\n"
    }
    
    private func generate<T: UnitProtocol>(for value: T, _ sign: Signs, allCases: [T]) -> String {
        let structDef = self.generateStruct(for: value, sign, allCases: allCases)
        let extensions = SwiftNumericTypes.uniqueTypes.reduce("") {
            $0 + "\n\n" + self.generateNumericExtension(for: $1, from: value, sign)
        }
        return structDef + extensions
    }
    
    private func prefix(name: String) -> String {
        return """
            /*
            * \(name).swift
            * GUUnits
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
            
            import CGUUnits
            """
    }
    
    private func generateStruct<T: UnitProtocol>(for type: T, _ sign: Signs, allCases: [T]) -> String {
        let signComment: String
        switch sign {
        case .d:
            signComment = "A double"
        case .f:
            signComment = "A floating point"
        case .t:
            signComment = "A signed integer"
        case .u:
            signComment = "An unsigned integer"
        }
        let comment = "/// " + signComment + " type for the " + type.description + " unit."
        let def = "public struct " + type.description.capitalized + "_" + sign.rawValue + " {"
        let endef = "}"
        let rawValueProperty = self.indent("public let rawValue: " + type.description + "_" + sign.rawValue)
        let rawInit = self.indent(self.createRawInit(for: type, sign))
        let numericInits = self.indent(self.createNumericInits(for: type, sign))
        let conversionInits: String
        if allCases.isEmpty {
        conversionInits = ""
        } else {
            conversionInits = "\n\n" + self.indent(self.createConversionInits(for: type, sign, allCases: allCases))
        }
        let selfConversions = self.indent(self.createSelfConversionInits(for: type, sign))
        return comment + "\n" + def
            + "\n\n" + rawValueProperty
            + "\n\n" + rawInit
            + "\n\n" + numericInits
            + conversionInits
            + "\n\n" + selfConversions
            + "\n\n" + endef
    }
    
    private func generateNumericExtension<T: UnitProtocol>(for numericType: SwiftNumericTypes, from value: T, _ sign: Signs) -> String {
        let def = "public extension " + numericType.rawValue + " {"
        let body = self.createNumericConversionInit(for: numericType, from: value, sign)
        let endef = "}"
        return def + "\n\n" + self.indent(body) + "\n\n" + endef
    }
    
    private func createNumericConversionInit<T: UnitProtocol>(for numericType: SwiftNumericTypes, from value: T, _ sign: Signs) -> String {
        let sourceStruct = value.description.capitalized + "_" + sign.rawValue
        let comment = """
        /// Create a `\(numericType.rawValue)` by converting a `\(sourceStruct)`.
        ///
        /// - Parameter value: A `\(sourceStruct)` value to convert to a `\(numericType.rawValue)`.
        """
        let def = "init(_ value: " + value.description.capitalized + "_" + sign.rawValue + ") {"
        let valueToNum = value.abbreviation + "_" + sign.rawValue + "_to_" + numericType.numericType.abbreviation
        let conversion: String
        if numericType != numericType.numericType.swiftType {
            conversion = numericType.rawValue + "(" + valueToNum + "(value.rawValue))"
        } else {
            conversion = valueToNum + "(value.rawValue)"
        }
        let body = "self = " + conversion
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createRawInit<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        let comment = "/// Create a `" + value.description.capitalized + "_" + sign.rawValue + "` from the underlying guunits C type `" + value.description + "_" + sign.rawValue + "`."
        let def = "public init(rawValue: " + value.description + "_" + sign.rawValue + ") {"
        let body = "self.rawValue = rawValue"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createConversionInits<T: UnitProtocol>(for value: T, _ sign: Signs, allCases: [T]) -> String {
        return allCases.reduce("") { (previous, source) in
            Signs.allCases.reduce(previous) {
                $0 + "\n\n" + self.createConversionInit(for: value, sign, from: source, $1)
            }
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createSelfConversionInits<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        return Set(Signs.allCases).subtracting([sign]).sorted { $0.rawValue < $1.rawValue }.reduce("") {
            $0 + "\n\n" + self.createConversionInit(for: value, sign, from: value, $1)
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createConversionInit<T: UnitProtocol>(for value: T, _ sign: Signs, from source: T, _ sourceSign: Signs) -> String {
        let valueStruct = value.description.capitalized + "_" + sign.rawValue
        let sourceStruct = source.description.capitalized + "_" + sourceSign.rawValue
        let comment = """
            /// Create a `\(valueStruct)` by converting a `\(sourceStruct)`.
            ///
            /// - Parameter value: A `\(sourceStruct)` value to convert to a `\(valueStruct)`.
            """
        let def = "public init(_ value: " + sourceStruct + ") {"
        let sourceToValue = source.abbreviation + "_" + sourceSign.rawValue + "_to_" + value.abbreviation + "_" + sign.rawValue
        let body = "self.rawValue = " + sourceToValue + "(value.rawValue)"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createNumericInits<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        return SwiftNumericTypes.uniqueTypes.reduce("") {
            return $0 + "\n\n" + self.createNumericInit(for: value, sign, from: $1)
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createNumericInit<T: UnitProtocol>(for value: T, _ sign: Signs, from numeric: SwiftNumericTypes) -> String {
        let sourceStruct = value.description.capitalized + "_" + sign.rawValue
        let comment = """
            /// Create a `\(sourceStruct)` by converting a `\(numeric.rawValue)`.
            ///
            /// - Parameter value: A `\(numeric.rawValue)` value to convert to a `\(sourceStruct)`.
            """
        let def = "public init(_ value: " + numeric.rawValue + ") {"
        let valueStr: String
        if numeric != numeric.numericType.swiftType {
            valueStr = numeric.numericType.swiftType.rawValue + "(value)"
        } else {
            valueStr = "value"
        }
        let body = "self.rawValue = " + numeric.numericType.abbreviation + "_to_" + value.abbreviation + "_" + sign.rawValue + "(" + valueStr + ")"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func indent(_ str: String) -> String {
        return self.prefixNonEmptyLines(str, with: "    ")
    }
    
    private func prefixNonEmptyLines(_ str: String, with prefix: String) -> String {
        let lines = str.components(separatedBy: .newlines)
        guard let first = lines.first else {
            return prefix
        }
        return lines.dropFirst().reduce(prefix + first) {
            if $1.isEmpty {
                return $0 + "\n" + $1
            }
            return $0 + "\n" + prefix + $1
        }
    }
    
}
