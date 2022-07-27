// /*
//  * TemperatureTestGenerator.swift 
//  * guunits_generator 
//  *
//  * Created by Morgan McColl.
//  * Copyright © 2022 Morgan McColl. All rights reserved.
//  *
//  * Redistribution and use in source and binary forms, with or without
//  * modification, are permitted provided that the following conditions
//  * are met:
//  *
//  * 1. Redistributions of source code must retain the above copyright
//  *    notice, this list of conditions and the following disclaimer.
//  *
//  * 2. Redistributions in binary form must reproduce the above
//  *    copyright notice, this list of conditions and the following
//  *    disclaimer in the documentation and/or other materials
//  *    provided with the distribution.
//  *
//  * 3. All advertising materials mentioning features or use of this
//  *    software must display the following acknowledgement:
//  *
//  *        This product includes software developed by Morgan McColl.
//  *
//  * 4. Neither the name of the author nor the names of contributors
//  *    may be used to endorse or promote products derived from this
//  *    software without specific prior written permission.
//  *
//  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
//  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  *
//  * -----------------------------------------------------------------------
//  * This program is free software; you can redistribute it and/or
//  * modify it under the above terms or under the terms of the GNU
//  * General Public License as published by the Free Software Foundation;
//  * either version 2 of the License, or (at your option) any later version.
//  *
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program; if not, see http://www.gnu.org/licenses/
//  * or write to the Free Software Foundation, Inc., 51 Franklin Street,
//  * Fifth Floor, Boston, MA  02110-1301, USA.
//  *
//  */
// 

struct TemperatureTestGenerator: TestGenerator {

    typealias UnitType = TemperatureUnits

    let creator = TestFunctionBodyCreator<TemperatureUnits>()

    func testParameters(
        from unit: UnitType, with sign: Signs, to otherUnit: UnitType, with otherSign: Signs
    ) -> [TestParameters] {
        let defaultTests = self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
        var newTests: [TestParameters] = []
        switch unit {
        case .celsius:
            switch otherUnit {
            case .fahrenheit:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "25", sign: sign),
                        output: creator.sanitiseLiteral(literal: "77", sign: otherSign)
                    )
                )
                if (sign == .d || sign == .f || sign == .t) && otherSign == .u {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "-20", sign: sign),
                            output: "0"
                        )
                    )
                }
                if (sign == .d || sign == .f || sign == .u) && otherSign == .t {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "1193046455", sign: sign),
                            output: "((fahrenheit_\(otherSign.rawValue)) (INT_MAX))"
                        )
                    )
                }
            case .kelvin:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "5", sign: sign),
                        output: creator.sanitiseLiteral(literal: "278", sign: otherSign)
                    )
                )
                if (sign == .t || sign == .f || sign == .d) && otherSign == .u {
                    newTests.append(
                        TestParameters(input: "-300", output: "0")
                    )
                }
                if (sign == .u || sign == .f || sign == .d) && otherSign == .t {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "2147483375", sign: sign),
                            output: "((kelvin_\(otherSign.rawValue)) (INT_MAX))"
                        )
                    )
                }
            default:
                break
            }
        case .fahrenheit:
            switch otherUnit {
            case .celsius:
                newTests.append(
                    TestParameters(
                        input: creator.sanitiseLiteral(literal: "77", sign: sign),
                        output: creator.sanitiseLiteral(literal: "25", sign: otherSign)
                    )
                )
                if (sign == .u || sign == .d || sign == .f) && otherSign == .t {
                    newTests.append(
                        TestParameters(
                            input: creator.sanitiseLiteral(literal: "3865470600", sign: sign),
                            output: "((celsius_\(otherSign.rawValue)) (INT_MAX))"
                        )
                    )
                }
            case .kelvin:

            default:
                break
            }
        case .kelvin:
            switch otherUnit {
            case .celsius:

            case .kelvin:

            default:
                break
            }
        }
        return defaultTests + newTests
    }

    func testParameters(from unit: UnitType, with sign: Signs, to numeric: NumericTypes) -> [TestParameters] {
        self.defaultParameters(from: unit, with: sign, to: numeric)
    }

    func testParameters(from numeric: NumericTypes, to unit: UnitType, with sign: Signs) -> [TestParameters] {
        self.defaultParameters(from: numeric, to: unit, with: sign)
    }

}
