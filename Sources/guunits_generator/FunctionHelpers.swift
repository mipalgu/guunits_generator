/*
 * FunctionHelpers.swift
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

struct FunctionHelpers<Unit: UnitProtocol> {
    
    fileprivate func collapse(_ sign: Signs?, prefix: String = "_", suffix: String = "") -> String {
        return sign.map { prefix + $0.rawValue + suffix} ?? ""
    }
    
    func functionName(forUnit unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs, unique: Bool = true) -> String {
        let uniqueSign = collapse(unique ? sign : nil)
        let uniquePrefix = unique ? "\(unit.abbreviation)\(uniqueSign)_" : ""
        return uniquePrefix + "to_\(otherUnit.abbreviation)\(collapse(otherSign))"
    }
    
    func functionDefinition(forUnit unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs, unique: Bool = true) -> String {
        let functionName = self.functionName(forUnit: unit, to: otherUnit, sign: sign, otherSign: otherSign, unique: unique)
        return "\(otherUnit)\(collapse(otherSign)) \(functionName)(\(unit)\(collapse(sign)) \(unit))"
    }
    
    func functionName(forUnit unit: Unit, sign: Signs? = nil, to type: NumericTypes, unique: Bool = true) -> String {
        let uniquePrefix = unique ? "\(unit.abbreviation)\(collapse(sign))_" : ""
        return uniquePrefix + "to_\(type.abbreviation)"
    }
    
    func functionDefinition(forUnit unit: Unit, sign: Signs? = nil, to type: NumericTypes, unique: Bool = true) -> String {
        let functionName = self.functionName(forUnit: unit, sign: sign, to: type, unique: unique)
        return "\(type.rawValue) \(functionName)(\(unit)\(collapse(sign)) \(unit))"
    }
    
    func functionName(from type: NumericTypes, to unit: Unit, sign: Signs? = nil, unique: Bool = true) -> String {
        let uniquePrefix = unique ? "\(type.abbreviation)_" : ""
        return uniquePrefix + "to_\(unit.abbreviation)\(collapse(unique ? sign : nil))"
    }
    
    func functionDefinition(from type: NumericTypes, to unit: Unit, sign: Signs? = nil, unique: Bool = true) -> String {
        let functionName = self.functionName(from: type, to: unit, sign: sign, unique: unique)
        return "\(unit)\(collapse(sign)) \(functionName)(\(type.rawValue) \(unit))"
    }
    
    func modify(value: Int, forSign sign: Signs) -> String {
        switch sign.numericType {
        case .float:
            return "\(value).0f"
        case .double:
            return "\(value).0"
        default:
            return "\(value)"
        }
    }
    
}
