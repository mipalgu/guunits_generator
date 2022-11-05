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

    static var relationTests: [UnitConversion: [TestParameters]] { get }

}

private extension Relation {

    init<Unit>(metaData: ConversionMetaData<Unit>) where Unit: UnitsConvertible {
        self.source = AnyUnit(metaData.unit)
        self.target = AnyUnit(metaData.otherUnit)
        self.operation = metaData.unit.conversion(to: metaData.otherUnit)
    }

}

extension OperationalTestable {

    public static var relationTests: [UnitConversion: [TestParameters]] {
        Dictionary(uniqueKeysWithValues: Self.relationships.flatMap { relationship in
            Signs.allCases.flatMap { sign in
                Signs.allCases.map { otherSign in
                    (
                        UnitConversion(relation: relationship, sourceSign: sign, targetSign: otherSign),
                        [-5_000_000, 0, 5_000_000].compactMap { value in
                            guard
                                sign.numericType.isSigned || (!sign.numericType.isSigned && value >= 0)
                            else {
                                return nil
                            }
                            return self.toTestParameter(
                                relationship: relationship, sign: sign, otherSign: otherSign, value: value
                            )
                        }
                    )
                }
            }
        })
    }

    fileprivate static func toTestParameter(
        relationship: Relation, sign: Signs, otherSign: Signs, value: Int
    ) -> TestParameters {
        let input = "\(value)"
        let conversion = relationship.operation
        let unit = relationship.source
        let otherUnit = relationship.target
        let needsDouble = sign.isFloatingPoint || otherSign.isFloatingPoint ||
            conversion.hasFloatOperation
        let simplifiedConversion = conversion.replace(
            convertibles: [
                unit: Operation.literal(declaration: .integer(value: value))
            ]
        )
        let swiftSign = needsDouble ? Signs.d : sign
        let code: String
        if swiftSign != .d && swiftSign != .f && !sign.isFloatingPoint &&
            !otherSign.isFloatingPoint {
            code = "\(otherSign.numericType.swiftType.rawValue)" +
                "(clamping: \(simplifiedConversion.swiftCode(sign: swiftSign)))"
        } else if !otherSign.isFloatingPoint {
            let conversion = "\(simplifiedConversion.swiftCode(sign: swiftSign))"
            let max = "\(swiftSign.numericType.swiftType)" +
                "(\(otherSign.numericType.swiftType.limits.1))"
            let min = "\(swiftSign.numericType.swiftType)" +
                "(\(otherSign.numericType.swiftType.limits.0))"
            if swiftSign.isFloatingPoint {
                let maxLimit = otherSign.numericType.swiftType.limits.1
                let minLimit = otherSign.numericType.swiftType.limits.0
                code = "((\(conversion)).rounded()) > (\(max)).nextDown ? (\(maxLimit))" +
                    " : ((((\(conversion)).rounded()) < (\(min)).nextUp) ? (\(minLimit)" +
                    ") : \(otherSign.numericType.swiftType)((\(conversion)).rounded()))"
            } else {
                code = "max(\(min), min(\(max), \(conversion)))"
            }
        } else {
            code = "\(simplifiedConversion.swiftCode(sign: swiftSign))"
        }
        return TestParameters(
            input: input, output: "\(otherUnit)_\(otherSign)(\(code))"
        )
    }

}

/// Helper static variables providing default test parameters for convertible units.
extension OperationalTestable where Self: UnitsConvertible {

    // swiftlint:disable closure_body_length

    /// This property provides the default parameters that should accompany any unit category.
    /// These parameters include some calculations using some predefined values and the edge
    /// cases of the underlying C types (e.g. UINT64_MAX and UINT64_MIN). These parameters
    /// assume that a conversion will clamp all operations protecting from overflows and
    /// underflows. If an overflow occurs, then these tests will make sure that it is detected
    /// and corrected.
    static var defaultParameters: [ConversionMetaData<Self>: [TestParameters]] {
        let inputs = [-5_000_000, 0, 5_000_000]
        var params: [ConversionMetaData<Self>: [TestParameters]] = Self.allCases.reduce(
            into: [:]
        ) { parameters, unit in
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
                            self.toTestParameter(
                                relationship: Relation(metaData: data),
                                sign: sign,
                                otherSign: otherSign,
                                value: $0
                            )
                        }
                        parameters[data] = testParams
                    }
                }
            }
        }
        params.merge(edgeParameters, uniquingKeysWith: +)
        return params
    }

    /// The parameters for the underlying C type edge cases.
    private static var edgeParameters: [ConversionMetaData<Self>: [TestParameters]] {
        var params: [ConversionMetaData<Self>: [TestParameters]] = [:]
        Self.allCases.forEach { v0 in
            Self.allCases.forEach { v1 in
                let operation = v0.conversion(to: v1)
                Signs.allCases.forEach { s0 in
                    let s0Limits = s0.numericType.swiftType.limits
                    Signs.allCases.forEach { s1 in
                        guard v0 != v1 || s0 != s1 else {
                            return
                        }
                        let metaData = ConversionMetaData(unit: v0, sign: s0, otherUnit: v1, otherSign: s1)
                        let operationSign = operation.hasFloatOperation || s1.isFloatingPoint ? Signs.d : s0
                        let s1Limits = s1.numericType.swiftType.limits
                        let otherType = "\(v1)_\(s1)"
                        let lowerCode = operation.swiftCode(sign: operationSign)
                            .replacingOccurrences(of: "\(v0)", with: s0Limits.0)
                        let lowerOutput: String
                        if !s0.numericType.isSigned {
                            lowerOutput = operationSign.isFloatingPoint ? "(\(lowerCode)).rounded()" :
                                lowerCode
                        } else {
                            lowerOutput = s1Limits.0
                        }
                        let upperOutput = s1Limits.1
                        params[metaData] = [
                            TestParameters(input: s0Limits.0, output: "\(otherType)(\(lowerOutput))"),
                            TestParameters(input: s0Limits.1, output: "\(otherType)(\(upperOutput))")
                        ]
                    }
                }
            }
        }
        return params
    }

    // swiftlint:enable closure_body_length

}
