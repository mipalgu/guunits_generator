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
            $0 + "\n\n" + self.generateStruct(for: value, $1, allCases: Set(T.allCases).subtracting(Set([value])).sorted { $0.description < $1.description })
        }
        return prefix + structs + "\n"
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
        let def = "public struct " + type.description.capitalized + "_" + sign.rawValue + " {"
        let endef = "}"
        let rawValueProperty = self.indent("public let rawValue: " + type.description + "_" + sign.rawValue)
        let rawInit = self.indent(self.createRawInit(for: type, sign))
        let conversionGetters = self.indent(self.createConversionGetters(from: type, sign, allCases: allCases))
        let numericGetters = self.indent(self.createNumericGetters(from: type, sign))
        let numericInits = self.indent(self.createNumericInits(for: type, sign))
        let conversionInits = self.indent(self.createConversionInits(for: type, sign, allCases: allCases))
        let selfConversions = self.indent(self.createSelfConversionInits(for: type, sign))
        return def
            + "\n\n" + rawValueProperty
            + "\n\n" + rawInit
            + "\n\n" + conversionGetters
            + "\n\n" + numericGetters
            + "\n\n" + numericInits
            + "\n\n" + conversionInits
            + "\n\n" + selfConversions
            + "\n\n" + endef
    }
    
    private func createRawInit<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        let def = "public init(rawValue: " + value.description + "_" + sign.rawValue + ") {"
        let body = "self.rawValue = rawValue"
        let endef = "}"
        return def + "\n" + self.indent(body) + "\n" + endef
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
        let def = "public init(_ value: " + source.description.capitalized + "_" + sourceSign.rawValue + ") {"
        let sourceToValue = source.abbreviation + "_" + sourceSign.rawValue + "_to_" + value.abbreviation + "_" + sign.rawValue
        let body = "self.rawValue = " + sourceToValue + "(value.rawValue)"
        let endef = "}"
        return def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createConversionGetters<T: UnitProtocol>(from value: T, _ sign: Signs, allCases: [T]) -> String {
        return allCases.reduce("") { (previous, target) in
            Signs.allCases.reduce(previous) {
                $0 + "\n\n" + self.createConversionGetter(from: value, sign, to: target, $1)
            }
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createConversionGetter<T: UnitProtocol>(from value: T, _ sign: Signs, to target: T, _ targetSign: Signs) -> String {
        let targetStruct = target.description.capitalized + "_" + targetSign.rawValue
        let def = "public var to" + targetStruct + ": " + targetStruct + " {"
        let valueToTarget = value.abbreviation + "_" + sign.rawValue + "_to_" + target.abbreviation + "_" + targetSign.rawValue
        let body =  "return " + targetStruct + "(" + valueToTarget + "(self.rawValue))"
        let endef = "}"
        return def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createNumericInits<T: UnitProtocol>(for value: T, _ sign: Signs) -> String {
        return SwiftNumericTypes.allCases.reduce("") {
            return $0 + "\n\n" + self.createNumericInit(for: value, sign, from: $1)
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createNumericInit<T: UnitProtocol>(for value: T, _ sign: Signs, from numeric: SwiftNumericTypes) -> String {
        let def = "public init(_ value: " + numeric.rawValue + ") {"
        let valueStr: String
        if numeric == .Int {
            valueStr = "CInt(value)"
        } else if numeric == .UInt {
            valueStr = "CUnsignedInt(value)"
        } else {
            valueStr = "value"
        }
        let body = "self.rawValue = " + numeric.numericType.abbreviation + "_to_" + value.abbreviation + "_" + sign.rawValue + "(" + valueStr + ")"
        let endef = "}"
        return def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createNumericGetters<T: UnitProtocol>(from value: T, _ sign: Signs) -> String {
        return SwiftNumericTypes.allCases.reduce("") {
            $0 + "\n\n" + self.createNumericGetter(from: value, sign, to: $1)
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createNumericGetter<T: UnitProtocol>(from value: T, _ sign: Signs, to numericType: SwiftNumericTypes) -> String {
        let def = "public var to" + numericType.rawValue + ": " + numericType.rawValue + " {"
        let body =  numericType.rawValue + "(" + value.abbreviation + "_" + sign.rawValue + "_to_" + numericType.numericType.abbreviation + "(self.rawValue))"
        let endef = "}"
        return def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func indent(_ str: String) -> String {
        return self.prefixLines(str, with: "    ")
    }
    
    private func prefixLines(_ str: String, with prefix: String) -> String {
        let lines = str.components(separatedBy: .newlines)
        guard let first = lines.first else {
            return prefix
        }
        return lines.dropFirst().reduce(prefix + first) { $0 + "\n" + prefix + $1 }
    }
    
}
