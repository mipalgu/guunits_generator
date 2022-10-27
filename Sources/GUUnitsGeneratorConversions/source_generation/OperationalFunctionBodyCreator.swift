// Operation+CConvertible.swift 
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

public struct OperationalFunctionBodyCreator<Unit>: FunctionBodyCreator where
    Unit: UnitProtocol, Unit: UnitsConvertible {

    let converter = NumericTypeConverter()

    public init() {}

    // public func createFunction(unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs) -> String {
    //     guard unit != otherUnit || sign != otherSign else {
    //         return "    return " + unit.description + ";"
    //     }
    //     guard unit != otherUnit else {
    //         let num0 = sign.numericType
    //         return "    return \(num0.abbreviation)_to_\(otherUnit.abbreviation)_\(otherSign)" +
    //             "(((\(num0.rawValue)) (\(unit))));"
    //     }
    //     let convertibles = unit.unit.getUnitConvertibles(comparingTo: otherUnit.unit)
    //     let implementation = "(((\(otherUnit)_d) ((double) (\(unit)))) * " +
    //         "(\(unit.unit.replace(convertibles: convertibles))))"
    //     if otherSign == .d {
    //         return "    return \(implementation);"
    //     } else {
    //         return "    return \(otherUnit.abbreviation)_d_to_\(otherUnit.abbreviation)_\(otherSign)" +
    //             "(\(implementation));"
    //     }
    // }

    public func createFunction(unit: Unit, to otherUnit: Unit, sign: Signs, otherSign: Signs) -> String {
        guard unit != otherUnit || sign != otherSign else {
            return "return \(unit);"
        }
        let conversion = unit.conversion(to: otherUnit)
        print(conversion)
        let needsDouble = sign.isFloatingPoint || otherSign.isFloatingPoint || conversion.hasFloatOperation
        let cSign = needsDouble ? Signs.d : sign
        let code = conversion.cCode(sign: cSign)
        return "    return " +
            converter.convert(code, from: cSign.numericType, to: otherUnit, sign: otherSign) + ";"
    }

}
