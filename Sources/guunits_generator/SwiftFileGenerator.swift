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
    
    func generate<T: UnitProtocol>(for type: T.Type) -> String {
        let prefix = self.prefix(name: type.category)
        let categoryStruct = self.generateCategoryStruct(for: type)
        let allUnits = type.allCases.flatMap { unit in
            Signs.allCases.map {
                unit.description.capitalized + "_" + $0.rawValue
            }
        }
        let extensionTypes = SwiftNumericTypes.uniqueTypes.map { $0.rawValue } + allUnits
        let categoryExtensions = self.createMultiple(for: extensionTypes) {
            return self.generateCategoryExtension(for: $0, from: type)
        }
        let unitStruct = self.createMultiple(for: type.allCases) {
            self.generateUnit(for: $0)
        }
        return prefix + "\n\n" + categoryStruct + "\n\n" + categoryExtensions + "\n\n" + unitStruct
    }
    
    private func generateUnit<T: UnitProtocol>(for value: T) -> String {
        let unitStruct = Signs.allCases.reduce("") {
            $0 + "\n\n" + self.generateUnitStruct(for: value, $1, allCases: Set(T.allCases).subtracting(Set([value])).sorted { $0.description < $1.description })
        }
        let extensionDef = SwiftNumericTypes.uniqueTypes.reduce("") {
            $0 + "\n\n" + self.generateNumericExtension(for: $1, from: value)
        }
        return unitStruct + extensionDef + "\n"
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
    
    private func generateCategoryStruct<T: UnitProtocol>(for type: T.Type) -> String {
        let _ = Signs.d
        let def = "public struct " + type.category + ": GUUnitsDType {"
        let rawProperty = self.indent(self.generateCategoryRawValueProperty(for: type))
        let rawPropertyInit = self.indent(self.generateCategoryRawValueInit(for: type))
        let numericInits = self.indent(self.createCategoryNumericInits(for: type))
        let conversionInits = self.indent(self.createCategoryConversionInits(for: type))
        let endef = "}"
        return def
            + "\n\n" + rawProperty
            + "\n\n" + rawPropertyInit
            + "\n\n" + numericInits
            + "\n\n" + conversionInits
            + "\n\n" + endef
    }
    
    private func generateCategoryRawValueProperty<T: UnitProtocol>(for type: T.Type) -> String {
        let comment = "/// Always store internally as a `" + type.highestPrecision.description.capitalized + "_" + Signs.d.rawValue + "`"
        let def = "public let rawValue: " + type.highestPrecision.description.capitalized + "_" + Signs.d.rawValue
        return comment + "\n" + def
    }
    
    private func generateCategoryRawValueInit<T: UnitProtocol>(for type: T.Type) -> String {
        let def = "public init(rawValue: " + type.highestPrecision.description.capitalized + "_" + Signs.d.rawValue + ") {"
        let body = "self.rawValue = rawValue"
        let endef = "}"
        return def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createCategoryConversionInits<T: UnitProtocol>(for type: T.Type) -> String {
        return self.createMultiple(for: T.allCases) { source in
            return self.createMultiple(for: Signs.allCases) {
                return self.createCategoryConversionInit(for: type, from: source, $0)
            }
        }
    }
    
    private func createCategoryConversionInit<T: UnitProtocol>(for type: T.Type, from source: T, _ sign: Signs) -> String {
        let def = "public init(_ value: " + source.description.capitalized + "_" + sign.rawValue  + ") {"
        let endef = "}"
        let body: String
        if source == T.highestPrecision && sign == .d {
            body = "self.rawValue = value"
        } else {
            body = "self.rawValue = " + T.highestPrecision.description.capitalized + "_" + Signs.d.rawValue + "(value)"
        }
        return def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createCategoryNumericInits<T: UnitProtocol>(for type: T.Type) -> String {
        return self.createMultiple(for: SwiftNumericTypes.uniqueTypes) {
            return self.createCategoryNumericInit(for: type, from: $0)
        }
    }
    
    private func createCategoryNumericInit<T: UnitProtocol>(for type: T.Type, from numeric: SwiftNumericTypes) -> String {
        let sourceStruct = type.category
        let comment = """
            /// Create a `\(sourceStruct)` by converting a `\(numeric.rawValue)`.
            ///
            /// - Parameter value: A `\(numeric.rawValue)` value to convert to a `\(sourceStruct)`.
            """
        let def = "public init(_ value: " + numeric.rawValue + ") {"
        let body = "self.rawValue = " + type.highestPrecision.description.capitalized + "_" + Signs.d.rawValue + "(value)"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func generateCategoryExtension<T: UnitProtocol>(for extensionType: String, from type: T.Type) -> String {
        let category: String = type.category
        let def = "public extension " + extensionType + " {"
        let mark = "// MARK: - Creating a " + extensionType + " From `" + category + "`"
        let initDef = "init(_ value: " + category + ") {"
        let initBody = "self.init(value.rawValue)"
        let endef = "}"
        let body = initDef + "\n" + self.indent(initBody) + "\n" + endef
        return def
            + "\n\n" + mark
            + "\n\n" + self.indent(body)
            + "\n\n" + endef
    }
    
    private func generateUnitStruct<T: UnitProtocol>(for type: T, _ sign: Signs, allCases: [T]) -> String {
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
        let conformingType = "GUUnits" + sign.rawValue.uppercased() + "Type"
        let def = "public struct " + type.description.capitalized + "_" + sign.rawValue + ": " + conformingType + " {"
        let endef = "}"
        let rawValueProperty = self.indent(self.generateRawProperty(for: type, sign))
        let rawInit = self.indent(self.createRawInit(for: type, sign))
        let numericInits = self.indent(self.createNumericInits(for: type, sign))
        let conversionInits: String
        if allCases.isEmpty {
            conversionInits = ""
        } else {
            let conversionInitMark = "// MARK: - Converting From Other Units"
            conversionInits = "\n\n" + conversionInitMark + "\n\n" + self.indent(self.createConversionInits(for: type, sign, allCases: allCases))
        }
        let selfConversions = self.indent(self.createSelfConversionInits(for: type, sign))
        return comment + "\n" + def
            + "\n\n" + "// MARK: - Converting Between The Underlying guunits C Type"
            + "\n\n" + rawValueProperty
            + "\n\n" + rawInit
            + "\n\n" + "// MARK: - Converting From Swift Numeric Types"
            + "\n\n" + numericInits
            + conversionInits
            + "\n\n" + "// MARK: - Converting From Other Precisions"
            + "\n\n" + selfConversions
            + "\n\n" + endef
    }
    
    private func generateRawProperty<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        let comment = "/// Convert to the guunits underlying C type `" + value.description + "_" + sign.rawValue + "`"
        let def = "public let rawValue: " + value.description + "_" + sign.rawValue
        return comment + "\n" + def
    }
    
    private func generateNumericExtension<T: UnitProtocol>(for numericType: SwiftNumericTypes, from value: T) -> String {
        let def = "public extension " + numericType.rawValue + " {"
        let mark = "// MARK: - Creating a " + numericType.rawValue + " From The " + value.description.capitalized + " Units"
        let body = Signs.allCases.reduce("") {
            $0 + "\n\n" + self.createNumericConversionInit(for: numericType, from: value, $1)
        }.trimmingCharacters(in: .newlines)
        let endef = "}"
        return def
            + "\n\n" + mark
            + "\n\n" + self.indent(body)
            + "\n\n" + endef
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
        return self.createMultiple(for: allCases) { source in
            self.createMultiple(for: Signs.allCases) {
                self.createConversionInit(for: value, sign, from: source, $0)
            }
        }
    }
    
    private func createSelfConversionInits<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        return self.createMultiple(for: Set(Signs.allCases).subtracting([sign]).sorted { $0.rawValue < $1.rawValue }) {
            return self.createConversionInit(for: value, sign, from: value, $0)
        }
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
        return self.createMultiple(for: SwiftNumericTypes.uniqueTypes) {
            self.createNumericInit(for: value, sign, from: $0)
        }
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
    
    private func createMultiple<S: Sequence, T>(for data: S, _ body: (T) -> String) -> String where S.Element == T {
        return data.reduce("") { $0 + "\n\n" + body($1) }.trimmingCharacters(in: .newlines)
    }
    
    private func indent(_ str: String) -> String {
        return self.prefixNonEmptyLines(str, with: "    ")
    }
    
    private func prefixNonEmptyLines(_ str: String, with prefix: String) -> String {
        let lines = str.components(separatedBy: .newlines)
        guard let first = lines.first?.trimmingCharacters(in: .whitespaces) else {
            return ""
        }
        return lines.dropFirst().reduce(first.isEmpty ? "" : prefix + first) {
            if $1.trimmingCharacters(in: .whitespaces).isEmpty {
                return $0 + "\n"
            }
            return $0 + "\n" + prefix + $1
        }
    }
    
}
