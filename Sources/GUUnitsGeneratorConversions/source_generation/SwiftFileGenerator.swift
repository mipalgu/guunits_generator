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

// swiftlint:disable file_length
// swiftlint:disable type_body_length

/// Struct for generating swift files for a unit type.
public struct SwiftFileCreator {

    /// Default init.
    public init() {}

    /// Creates the swift file contents for a given unit type.
    /// - Parameter type: The type to generate.
    /// - Returns: A string of the file contents.
    public func generate<T: UnitProtocol>(for type: T.Type) -> String {
        let structGeneration = doGenerate(for: type)
        guard let relationshipGeneration = createRelationExtensions(for: type) else {
            return structGeneration + "\n"
        }
        return structGeneration + "\n\n" + relationshipGeneration + "\n"
    }

    private func createRelationExtensions<T: UnitProtocol>(for type: T.Type) -> String? {
        let relations = T.relationships
        guard !relations.isEmpty else {
            return nil
        }
        var targetsCompleted: Set<AnyUnit> = []
        let extensions: [String] = relations.lazy.compactMap { relation -> [String]? in
            let target = relation.target
            guard !targetsCompleted.contains(target) else {
                return nil
            }
            let targetRelations = relations.filter {
                $0.target == target
            }
            targetsCompleted.insert(target)
            return Signs.allCases.compactMap { sign in
                createRelationExtension(relations: targetRelations, targetSign: sign)
            }
        }
        .flatMap { $0 }
        return extensions.joined(separator: "\n\n")
    }

    private func createRelationExtension(relations: [Relation], targetSign: Signs) -> String? {
        guard let target = relations.first?.target else {
            return nil
        }
        let inits: String = relations.flatMap { relation -> [String] in
            Signs.allCases.compactMap { sourceSign -> String? in
                toConversionInit(
                    conversion: UnitConversion(
                        relation: relation, sourceSign: sourceSign, targetSign: targetSign
                    )
                )
            }
        }
        .joined(separator: "\n\n")
        return """
        public extension \(target.description.capitalized)_\(targetSign.rawValue) {

        \(inits)

        }
        """
    }

    private func toConversionInit(conversion: UnitConversion) -> String? {
        let relation = conversion.relation
        let parameters = relation.operation.units
        let conversionName = relation.name(sign: conversion.sourceSign, otherSign: conversion.targetSign)
        guard parameters.count > 1 else {
            guard let value = parameters.first else {
                return nil
            }
            let comment = "/// Create a `\(relation.target.description.capitalized)" +
                "_\(conversion.targetSign.rawValue)` from a `\(value.description.capitalized)" +
                "_\(conversion.sourceSign.rawValue)`."
            return """
                \(comment)
                init(_ value: \(value.description.capitalized)_\(conversion.sourceSign.rawValue)) {
                    self.init(rawValue: \(conversionName)(value.rawValue))
                }
            """
        }
        let sortedParams = parameters.sorted {
            $0.description < $1.description
        }
        let functionParameters: String = sortedParams.map {
            "\($0.description): \($0.description.capitalized)_\(conversion.sourceSign.rawValue)"
        }
        .joined(separator: ", ")
        let functionValues = sortedParams.map {
            "\($0.description).rawValue"
        }
        .joined(separator: ", ")
        let parametersTypes = sortedParams.map {
            "`\($0.description.capitalized)_\(conversion.sourceSign.rawValue)`"
        }
        .joined(separator: ", ")
        let comment = "/// Create a `\(relation.target.description.capitalized)_" +
                "\(conversion.targetSign.rawValue)` from \(parametersTypes)."
        return """
            \(comment)
            init(\(functionParameters)) {
                self.init(rawValue: \(conversionName)(\(functionValues)))
            }
        """
    }

    private func doGenerate<T: UnitProtocol>(for type: T.Type) -> String {
        let prefix = self.prefix(name: type.category)
        let categoryStruct = self.generateCategoryStruct(for: type)
        let categoryExtensions = self.createMultiple(for: SwiftNumericTypes.uniqueTypes) {
            self.generateCategoryExtension(for: $0.rawValue, from: type)
        }
        let unitStruct = self.createMultiple(for: type.allCases) {
            self.generateUnit(for: $0)
        }
        return prefix + "\n\n" + categoryStruct + "\n\n" + categoryExtensions + "\n\n" + unitStruct
    }

    /// Creates the swift file contents for a given case of a unit type.
    /// - Parameter type: The case to generate.
    /// - Returns: A string of the file contents.
    private func generateUnit<T: UnitProtocol>(for value: T) -> String {
        let unitStruct = Signs.allCases.reduce(into: "") {
            $0 = $0 + "\n\n" + self.generateUnitStruct(for: value, $1, allCases: Set(T.allCases)
                .subtracting(Set([value]))
                .sorted { $0.description < $1.description })
        }
        let extensionDef = SwiftNumericTypes.uniqueTypes.reduce(into: "") {
            $0 = $0 + "\n\n" + self.generateNumericExtension(for: $1, from: value)
        }
        return unitStruct + extensionDef + "\n"
    }

    // swiftlint:disable function_body_length

    /// The header that appears at the top of the swift file.
    /// - Parameter name: The name of the file.
    /// - Returns: The `String` contents of the header.
    private func prefix(name: String) -> String {
        """
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

    /// Generates a cetgory struct for abstracting all of the unit cases.
    /// - Parameter type: The type of the unit.
    /// - Returns: A `String` containing the definition of the struct.
    private func generateCategoryStruct<T: UnitProtocol>(for type: T.Type) -> String {
        _ = Signs.d
        let comment = """
            /// Provides a generic way of working with \(T.category.lowercased()) units.
            ///
            /// This type is useful as it allows you to specify that you are
            /// working with a particular type of unit, without having to
            /// specify in which units you are working. This type allows you
            /// to convert to any of the related underlying unit types.
            ///
            /// It is recommended that if you are creating a library or public
            /// api of some sort, then this type should be used in your function
            /// declaration over the more specific underlying unit types that
            /// this type can convert to. If you are performing some
            /// sort of calculations then you obviously need to use one of the
            /// underlying unit types that this type can convert to; however,
            /// the public api should take this type which you should then
            /// convert to the underlying unit type you need.
            ///
            /// - Attention: Because this type is numeric, and therefore allows
            /// you to perform arithmetic, this type must behave like a double
            /// as a double has the highest precision. If this is not
            /// necessary, then you may opt to use one of the integer
            /// variants of the underlying unit types that this type can convert
            /// to.
            """
        let def = "public struct " + type.category + ": Sendable, Hashable, Codable {"
        let enumDefinition = generateCategoryEnum(for: type)
        let rawProperty = self.indent(self.generateCategoryRawValueProperty(for: type))
        let getters = self.indent(self.generateCategoryGetters(for: type))
        let zeroGetter: String
        if type.sameZeroPoint {
            zeroGetter = "\n\n" + self.indent(self.createCategoryZeroStaticGetter(for: type))
        } else {
            zeroGetter = ""
        }
        let staticInits = self.indent(self.createCategoryStaticInits(for: type))
        let rawPropertyInit = self.indent(self.generateCategoryRawValueInit(for: type))
        let numericInits = self.indent(self.createCategoryNumericInits(for: type))
        let conversionInits = self.indent(self.createCategoryConversionInits(for: type))
        let endef = "}"
        return comment + "\n" + def
            + "\n\n" + enumDefinition
            + "\n\n" + "// MARK: - Converting Between The Internal Representation"
            + "\n\n" + rawProperty
            + "\n\n" + rawPropertyInit
            + "\n\n" + "// MARK: - Converting To The Underlying Unit Types"
            + "\n\n" + getters
            + "\n\n" + "// MARK: - Converting From The Underlying Unit Types"
            + "\n\n" + conversionInits
            + "\n\n" + "// MARK: - Converting From Swift Numeric Types"
            + zeroGetter
            + "\n\n" + staticInits
            + "\n\n" + numericInits
            + "\n\n" + endef
    }

    // swiftlint:enable function_body_length

    /// Create the private unit enum types for the category struct.
    /// - Parameter type: The type of the category.
    /// - Returns: A string containing the declaration for the private enum containing
    ///            the raw values for the category.
    private func generateCategoryEnum<T: UnitProtocol>( for type: T.Type) -> String {
        let cases = type.allCases.flatMap { unit in
            Signs.allCases.map { sign in
                let unitType = "\(unit)_\(sign)".lowercased()
                return "        case \(unitType)(_ \(unitType.lowercased()): " +
                    "\(unit.description.capitalized)_\(sign))"
            }
        }
        .joined(separator: "\n\n")
        return """
            enum \(type.category)Types: Sendable, Hashable, Codable {

        \(cases)

            }
        """
    }

    /// Generates the rawValue property within a category struct.
    /// - Parameter type: The unit type.
    /// - Returns: The rawValue definition.
    private func generateCategoryRawValueProperty<T: UnitProtocol>(for type: T.Type) -> String {
        let comment = "/// Always store internally as a `\(type.category)Types`"
        let def = "let rawValue: \(type.category)Types"
        return comment + "\n" + def
    }

    /// Generates the init that takes a rawValue.
    /// - Parameter type: The type of the unit.
    /// - Returns: The definition of the init.
    private func generateCategoryRawValueInit<T: UnitProtocol>(for type: T.Type) -> String {
        let comment = "/// Initialise `" + type.category + "` from its internally representation."
        let def = "init(rawValue: \(T.category)Types) {"
        let body = "self.rawValue = rawValue"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Generates the getters for the unit cases within a category struct.
    /// - Parameter type: The unit type.
    /// - Returns: All getters as a `String`.
    private func generateCategoryGetters<T: UnitProtocol>(for type: T.Type) -> String {
        self.createMultiple(for: type.allCases) { value in
            self.createMultiple(for: Signs.allCases) { sign in
                self.generateCategoryGetter(to: value, sign)
            }
        }
    }

    /// Generate a switch statement over a CategoryTypes enum.
    /// - Parameters:
    ///   - type: The type of the unit.
    ///   - name: The name of the variable containing an instance of the enum type.
    ///   - perform: A conversion function which generates code containing the objects
    ///              contained within the enum cases.
    /// - Returns: A generated switch stated using the perform function.
    private func switchValues<T: UnitProtocol>(
        for type: T.Type, with name: String = "rawValue", to perform: (String) -> String
    ) -> String {
        let cases = type.allCases.flatMap { unit in
            Signs.allCases.map { sign in
                let unitType = "\(unit)_\(sign)".lowercased()
                return "case .\(unitType)(let value):\n\(self.indent(perform("value")))"
            }
        }
        .joined(separator: "\n")
        return """
        switch \(name) {
        \(cases)
        }
        """
    }

    /// Generates a getter for converting the category struct to a case struct.
    /// - Parameters:
    ///   - value: The target unit case type.
    ///   - sign: The target sign of the unit.
    /// - Returns: The getter definition and implementation.
    private func generateCategoryGetter<T: UnitProtocol>(to value: T, _ sign: Signs) -> String {
        let targetStruct = value.description.capitalized + "_" + sign.rawValue
        let getterName = value.description + "_" + sign.rawValue
        let comment = "/// Create a `" + targetStruct + "`."
        let def = "public var " + getterName + ": " + targetStruct + " {"
        let body = switchValues(for: T.self) { "return " + targetStruct + "(\($0))" }
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Generates a static property for the zero-point of the category.
    /// - Parameter type: The unit type.
    /// - Returns: The definition and implementation of this static property.
    private func createCategoryZeroStaticGetter<T: UnitProtocol>(for type: T.Type) -> String {
        let sourceStruct = type.category
        let comment = """
            /// Create a `\(sourceStruct)` equal to zero.
            """
        let def = "public static var zero: " + sourceStruct + " {"
        let body = "return " + sourceStruct + "(" + type.highestPrecision.description + ": 0)"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Generates swift code that allows static initialisation of all unit types in a category.
    /// For example, using `.centimetres(_:)` in a Distance category.
    /// - Parameter type: The unit type.
    /// - Returns: The definition and implementation of all static functions.
    private func createCategoryStaticInits<T: UnitProtocol>(for type: T.Type) -> String {
        self.createMultiple(for: SwiftNumericTypes.uniqueTypes) { numeric in
            self.createMultiple(for: type.allCases) {
                self.createCategoryStaticInit(for: type, from: numeric, as: $0)
            }
        }
    }

    /// Generates swift code that allows static initialisation of unit types in a category.
    /// For example, using `.centimetres(_:)` in a Distance category.
    /// - Parameter type: The unit case.
    /// - Returns: The definition and implementation of this static functions.
    private func createCategoryStaticInit<T: UnitProtocol>(
        for type: T.Type, from numeric: SwiftNumericTypes, as value: T
    ) -> String {
        let sourceStruct = type.category
        // swiftlint:disable line_length
        let comment = """
            /// Create a `\(sourceStruct)` by converting a `\(numeric.rawValue)` \(value.description) value.
            ///
            /// - Parameter value: A `\(numeric.rawValue)` \(value.description) value to convert to a `\(sourceStruct)`.
            """
        // swiftlint:enable line_length
        let def = "public static func " + value.description + "(_ value: "
            + numeric.rawValue + ") -> " + sourceStruct + " {"
        let body = "return " + sourceStruct + "(" + value.description + ": value)"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Create inits that convert between unit cases.
    ///
    /// - Parameter type: The type of the unit.
    ///
    /// - Returns: The definitions of all inits separated by two newlines.
    private func createCategoryConversionInits<T: UnitProtocol>(for type: T.Type) -> String {
        self.createMultiple(for: T.allCases) { source in
            self.createMultiple(for: Signs.allCases) {
                self.createCategoryConversionInit(for: type, from: source, $0)
            }
        }
    }

    /// Create an initialiser that creates a category struct from a unit case.
    ///
    /// - Parameter type: The type of the unit.
    ///
    /// - Parameter source: The specific case that the init converts from.
    ///
    /// - Parameter sign: The sign of the unit case that the init converts from.
    ///
    /// - Returns: The init definition and implementation.
    private func createCategoryConversionInit<T: UnitProtocol>(
        for type: T.Type, from source: T, _ sign: Signs
    ) -> String {
        let valueStruct = T.category
        let sourceStruct = source.description.capitalized + "_" + sign.rawValue
        let comment = """
            /// Create a `\(valueStruct)` by converting a `\(sourceStruct)`.
            ///
            /// - Parameter value: A `\(sourceStruct)` value to convert to a `\(valueStruct)`.
            """
        let def = "public init(_ value: " + source.description.capitalized + "_" + sign.rawValue + ") {"
        let endef = "}"
        let body = "self.rawValue = \(type.category)Types." +
            "\(source.description.lowercased())_\(sign)(value)"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Create initialisers that can create a category struct from support
    /// swift numeric type found in `SwiftNumericTypes.uniqueTypes`.
    ///
    /// - Parameter type: The type of the unit that the initialiser creates.
    ///
    /// - Returns: The definitions and implementations of all inits separated by
    /// two new line characters.
    private func createCategoryNumericInits<T: UnitProtocol>(for type: T.Type) -> String {
        self.createMultiple(for: SwiftNumericTypes.uniqueTypes) { numeric in
            self.createMultiple(for: type.allCases) {
                self.createCategoryNumericInit(for: type, from: numeric, as: $0)
            }
        }
    }

    /// Create a single initialiser that create a category struct from a swift
    /// numeric type.
    ///
    /// - Parameter type: The type of the unit being created.
    ///
    /// - Parameter numeric: The swift numeric type that is being converted.
    ///
    /// - Parameter value: A specific unit case the dictates what unit the
    /// numeric value is in. The external parameter name of the value that this
    /// init takes will be the description of this case.
    private func createCategoryNumericInit<T: UnitProtocol>(
        for type: T.Type, from numeric: SwiftNumericTypes, as value: T
    ) -> String {
        let sourceStruct = type.category
        // swiftlint:disable line_length
        let comment = """
            /// Create a `\(sourceStruct)` by converting a `\(numeric.rawValue)` \(value.description) value.
            ///
            /// - Parameter value: A `\(numeric.rawValue)` \(value.description) value to convert to a `\(sourceStruct)`.
            """
        // swiftlint:enable line_length
        let def = "public init(" + value.description + " value: " + numeric.rawValue + ") {"
        let body: String
        switch numeric {
        case .Double, .Int64, .UInt64:
            body = "self.rawValue = \(type.category)Types.\(value.description.lowercased())_d" +
                "(\(value.description.capitalized)_d(value))"
        case .Float:
            body = "self.rawValue = \(type.category)Types.\(value.description.lowercased())_f" +
                "(\(value.description.capitalized)_f(value))"
        case .Int, .CInt, .Int16, .Int8, .Int32:
            body = "self.rawValue = \(type.category)Types.\(value.description.lowercased())_t" +
                "(\(value.description.capitalized)_t(value))"
        case .UInt, .CUnsignedInt, .UInt8, .UInt16, .UInt32:
            body = "self.rawValue = \(type.category)Types.\(value.description.lowercased())_u" +
                "(\(value.description.capitalized)_u(value))"
        }
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Create extensions on `extensionType` that provide initialisers
    /// that convert from a category type to a `type` type.
    ///
    /// - Parameter extensionType: The name of the type being extended.
    ///
    /// - Parameter type: The unit type that the initialiser creates.
    ///
    /// - Returns: The definition and implementation of the extension including
    /// the initialiser.
    private func generateCategoryExtension<T: UnitProtocol>(
        for extensionType: String, from type: T.Type
    ) -> String {
        let category: String = type.category
        let def = "public extension " + extensionType + " {"
        let mark = "// MARK: - Creating a " + extensionType + " From The " + category + " Units"
        let initDef = "init(_ value: " + category + ") {"
        let initBody = self.switchValues(for: type, with: "value.rawValue") { "self.init(\($0))" }
        let endef = "}"
        let body = initDef + "\n" + self.indent(initBody) + "\n" + endef
        return def
            + "\n\n" + mark
            + "\n\n" + self.indent(body)
            + "\n\n" + endef
    }

    /// Creates a struct for a particular case of a unit.
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
        let conformingType = "GUUnits" + sign.rawValue.uppercased() + "Type, Hashable, Codable"
        let def = "public struct " + type.description.capitalized + "_" + sign.rawValue
            + ": " + conformingType + " {"
        let endef = "}"
        let rawValueProperty = self.indent(self.generateRawProperty(for: type, sign))
        let rawInit = self.indent(self.createRawInit(for: type, sign))
        let numericInits = self.indent(self.createNumericInits(for: type, sign))
        let conversionInits: String
        if allCases.isEmpty {
            conversionInits = ""
        } else {
            let conversionInitMark = "// MARK: - Converting From Other Units"
            conversionInits = "\n\n" + conversionInitMark + "\n\n"
                + self.indent(self.createConversionInits(for: type, sign, allCases: allCases))
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
            + "\n\n" + selfConversions + "\n\n" + endef
    }

    /// Generate a property that creates the underlying C-type.
    private func generateRawProperty<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        let comment = "/// Convert to the guunits underlying C type `"
            + value.description + "_" + sign.rawValue + "`"
        let def = "public let rawValue: " + value.description + "_" + sign.rawValue
        return comment + "\n" + def
    }

    /// Create an extension that contains an init from the numeric type.
    private func generateNumericExtension<T: UnitProtocol>(
        for numericType: SwiftNumericTypes, from value: T
    ) -> String {
        let def = "public extension " + numericType.rawValue + " {"
        let mark = "// MARK: Creating a " + numericType.rawValue + " From The "
            + value.description.capitalized + " Units"
        let body = Signs.allCases.reduce(into: "") {
            $0 = $0 + "\n\n" + self.createNumericConversionInit(for: numericType, from: value, $1)
        }
            .trimmingCharacters(in: .newlines)
        let endef = "}"
        return def
            + "\n\n" + mark
            + "\n\n" + self.indent(body)
            + "\n\n" + endef
    }

    /// Generate an initialiser that creates a numeric type from a unit type.
    private func createNumericConversionInit<T: UnitProtocol>(
        for numericType: SwiftNumericTypes, from value: T, _ sign: Signs
    ) -> String {
        let sourceStruct = value.description.capitalized + "_" + sign.rawValue
        let comment = """
        /// Create a `\(numericType.rawValue)` by converting a `\(sourceStruct)`.
        ///
        /// - Parameter value: A `\(sourceStruct)` value to convert to a `\(numericType.rawValue)`.
        """
        let def = "init(_ value: " + value.description.capitalized + "_" + sign.rawValue + ") {"
        let valueToNum = value.abbreviation + "_" + sign.rawValue + "_to_"
            + numericType.numericType.abbreviation
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

    /// Generate an init that takes the underlying unit C-type.
    private func createRawInit<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        let comment = "/// Create a `" + value.description.capitalized + "_"
            + sign.rawValue + "` from the underlying guunits C type `" + value.description
            + "_" + sign.rawValue + "`."
        let def = "public init(rawValue: " + value.description + "_" + sign.rawValue + ") {"
        let body = "self.rawValue = rawValue"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Create all conversion inits that work within the same category.
    private func createConversionInits<T: UnitProtocol>(
        for value: T, _ sign: Signs, allCases: [T]
    ) -> String {
        let categoryInit = self.createConversionInitFromCategory(for: value, sign)
        let conversionInits = self.createMultiple(for: allCases) { source in
            self.createMultiple(for: Signs.allCases) {
                self.createConversionInit(for: value, sign, from: source, $0)
            }
        }
        return categoryInit + "\n\n" + conversionInits
    }

    /// Generate an init that converts from a unit in the same category to Self.
    private func createConversionInitFromCategory<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        let valueStruct = value.description.capitalized + "_" + sign.rawValue
        let sourceStruct = T.category
        let comment = """
        /// Create a `\(valueStruct)` by converting a `\(sourceStruct)`.
        ///
        /// - Parameter value: A `\(sourceStruct)` value to convert to a `\(valueStruct)`.
        """
        let def = "public init(_ value: " + sourceStruct + ") {"
        let body = self.switchValues(for: T.self, with: "value.rawValue") { "self.init(\($0))" }
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Create all conversion inits.
    private func createSelfConversionInits<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        self.createMultiple(for: Set(Signs.allCases)
            .subtracting([sign]).sorted { $0.rawValue < $1.rawValue }) {
            self.createConversionInit(for: value, sign, from: value, $0)
        }
    }

    /// Generate a conversion init.
    private func createConversionInit<T: UnitProtocol>(
        for value: T, _ sign: Signs, from source: T, _ sourceSign: Signs
    ) -> String {
        let valueStruct = value.description.capitalized + "_" + sign.rawValue
        let sourceStruct = source.description.capitalized + "_" + sourceSign.rawValue
        let comment = """
            /// Create a `\(valueStruct)` by converting a `\(sourceStruct)`.
            ///
            /// - Parameter value: A `\(sourceStruct)` value to convert to a `\(valueStruct)`.
            """
        let def = "public init(_ value: " + sourceStruct + ") {"
        let sourceToValue = source.abbreviation + "_" + sourceSign.rawValue + "_to_"
            + value.abbreviation + "_" + sign.rawValue
        let body = "self.rawValue = " + sourceToValue + "(value.rawValue)"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Create all inits that take numeric swift types.
    private func createNumericInits<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        self.createMultiple(for: SwiftNumericTypes.uniqueTypes) {
            self.createNumericInit(for: value, sign, from: $0)
        }
    }

    /// Create an init that takes a numeric swift type.
    private func createNumericInit<T: UnitProtocol>(
        for value: T, _ sign: Signs, from numeric: SwiftNumericTypes
    ) -> String {
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
        let body = "self.rawValue = " + numeric.numericType.abbreviation + "_to_"
            + value.abbreviation + "_" + sign.rawValue + "(" + valueStr + ")"
        let endef = "}"
        return comment + "\n" + def + "\n" + self.indent(body) + "\n" + endef
    }

    /// Converts all elements in a sequence to strings by using a callback. After this conversion,
    /// all elements are joined into a string separated by `"\n\n"` strings.
    private func createMultiple<S: Sequence, T>(
        for data: S, _ body: (T) -> String
    ) -> String where S.Element == T {
        data.reduce(into: "") { $0 = $0 + "\n\n" + body($1) }.trimmingCharacters(in: .newlines)
    }

    /// An indent is 4 spaces.
    private func indent(_ str: String) -> String {
        self.prefixNonEmptyLines(str, with: "    ")
    }

    /// Adds a prefix to all lines that aren't empty.
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

// swiftlint:enable type_body_length
// swiftlint:enable file_length
