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
    
    private var internalEnum: String {
        let def = "private enum InternalRepresentation {"
        let cases = SwiftNumericTypes.allCases.reduce("") {
            $0 + "\n\n" + "case \($1.rawValue)(_ value: \($1.rawValue))"
        }
        let enddef = "}"
        return def + self.indent(cases) + "\n\n" + enddef
    }
    
    func generate<T: UnitProtocol>(for type: T) -> String {
        let prefix = self.prefix(name: type.description)
        let strct = self.generateStruct(for: type, allCases: Set(T.allCases).subtracting(Set([type])).sorted { $0.description < $1.description })
        return prefix + "\n\n" + strct
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
            """
    }
    
    private func generateStruct<T: UnitProtocol>(for type: T, allCases: [T]) -> String {
        let def = "public struct \(type.description.capitalized) {"
        let endef = "}"
        let internalRepresentation = self.indent(self.internalEnum)
        let conversionGetters = self.indent(self.createConversionGetters(from: type, allCases: allCases))
        let numericGetters = self.indent(self.createNumericGetters(from: type))
        let numericInits = self.indent(self.createNumericInits(for: type))
        return def
            + "\n\n" + internalRepresentation
            + "\n\n" + conversionGetters
            + "\n\n" + numericGetters
            + "\n\n" + numericInits
            + "\n\n" + endef
    }
    
    private func createSwitch<T>(on condition: String, cases: [T], body: (T) -> String) -> String {
        let def = "switch " + condition + " {"
        let caseList = cases.reduce("") {
            $0 + "case .\($1)(let value):\n    " + body($1) + "\n"
        }.trimmingCharacters(in: .whitespacesAndNewlines)
        let endef = "}"
        return def + "\n" + caseList + "\n" + endef
    }
    
    private func createConversionGetters<T: UnitProtocol>(from value: T, allCases: [T]) -> String {
        return allCases.reduce("") {
            $0 + "\n\n" + self.createConversionGetter(from: value, to: $1)
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createConversionGetter<T: UnitProtocol>(from value: T, to target: T) -> String {
        let targetStruct = target.description.capitalized
        let def = "public var to" + targetStruct + ": " + targetStruct + " {"
        let swtch = self.createSwitch(on: "self.internalRepresentation", cases: SwiftNumericTypes.allCases) {
            let numToValue = $0.sign.rawValue + "_to_" + value.abbreviation + "_" + $0.sign.rawValue
            let valueToTarget = value.abbreviation + "_" + $0.sign.rawValue + "_to_" + target.abbreviation + "_d"
            return "return " + targetStruct + "(" + numToValue + "(" + valueToTarget + "(value)))"
        }
        let endef = "}"
        return def + "\n" + self.indent(swtch) + "\n" + endef
    }
    
    private func createNumericInits<T: UnitProtocol>(for value: T) -> String {
        return SwiftNumericTypes.allCases.reduce("") {
            return $0 + "\n\n" + self.createNumericInit(for: value, from: $1)
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createNumericInit<T: UnitProtocol>(for value: T, from numeric: SwiftNumericTypes) -> String {
        let def = "public init(_ value: " + numeric.rawValue + ") {"
        let body = "self.internalRepresentation = ." + numeric.rawValue + "(value)"
        let endef = "}"
        return def + "\n" + self.indent(body) + "\n" + endef
    }
    
    private func createNumericGetters<T: UnitProtocol>(from value: T) -> String {
        return SwiftNumericTypes.allCases.reduce("") {
            $0 + "\n\n" + self.createNumericGetter(from: value, to: $1)
        }.trimmingCharacters(in: .newlines)
    }
    
    private func createNumericGetter<T: UnitProtocol>(from value: T, to numericType: SwiftNumericTypes) -> String {
        let def = "public var to" + numericType.rawValue + ": " + numericType.rawValue + " {"
        let swtch = self.createSwitch(on: "self.internalRepresentation", cases: SwiftNumericTypes.allCases) {
            return "return " + numericType.rawValue + "(" + value.abbreviation + "_" + $0.numericType.abbreviation + "_to_" + numericType.numericType.abbreviation + "(value))"
        }
        let endef = "}"
        return def + "\n" + self.indent(swtch) + "\n" + endef
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
