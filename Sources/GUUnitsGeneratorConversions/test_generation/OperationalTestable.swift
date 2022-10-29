// OperationalTestable.swift 
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

/// A type that specifies it's own ``TestParameters`` for conversions within the
/// category.
public protocol OperationalTestable where Self: UnitProtocol {

    /// The ``TestParameters`` for each conversion.
    static var testParameters: [ConversionMetaData<Self>: [TestParameters]] { get }

}

extension OperationalTestable where Self: UnitsConvertible {

    public static var testParameters: [ConversionMetaData<Self>: [TestParameters]] {
        let inputs = [-50000, -5000, -500, -50, -5, 0, 5, 50, 500, 5000, 50000]
        return Self.allCases.reduce(into: [:]) { parameters, unit in
            Signs.allCases.forEach { sign in
                Self.allCases.forEach { otherUnit in
                    Signs.allCases.forEach { otherSign in
                        guard unit != otherUnit || sign != otherSign else {
                            return
                        }
                        let data = ConversionMetaData(
                            unit: unit, sign: sign, otherUnit: otherUnit, otherSign: otherSign
                        )
                        let testParams: [TestParameters] = inputs.lazy.filter {
                            ($0 < 0 && sign != .u) || $0 >= 0
                        }
                        .map {
                            let input = "\($0)"
                            let conversion = unit.conversion(to: otherUnit).replace(
                                convertibles: [
                                    AnyUnit(unit): Operation.literal(declaration: .integer(value: $0))
                                ]
                            )
                            let needsDouble = sign.isFloatingPoint || otherSign.isFloatingPoint ||
                                conversion.hasFloatOperation
                            let swiftSign = needsDouble ? Signs.d : sign
                            let code = "\(otherUnit.description.capitalized)_\(otherSign)" +
                                "(\(conversion.swiftCode(sign: swiftSign)))"
                            return TestParameters(input: input, output: code)
                        }
                        parameters[data] = testParams
                    }
                }
            }
        }
    }

}
