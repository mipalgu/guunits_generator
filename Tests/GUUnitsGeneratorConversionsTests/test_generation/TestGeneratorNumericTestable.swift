// TestGeneratorNumericTestable.swift 
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

@testable import GUUnitsGeneratorConversions
import XCTest

/// Helper protocol for providing default method for testing unit to numeric conversions.
protocol TestGeneratorNumericTestable {

    /// Require a generator.
    associatedtype Generator: TestGenerator

    /// The generator being tested.
    var generator: Generator { get }

    /// Create test parameters for a sign conversion between a unit.
    /// - Parameters:
    ///   - unit: The unit being tested.
    ///   - sign: The original sign.
    ///   - otherSign: The new sign.
    /// - Returns: The parameters testing this conversion.
    func unitTests(
        from unit: Generator.UnitType, with sign: Signs, to otherSign: Signs
    ) -> Set<TestParameters>

    /// Create test parameters for a unit to numeric type conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    /// - Returns: The test parameters testing the conversion.
    func numericTests(
        from unit: Generator.UnitType, with sign: Signs, to numeric: NumericTypes
    ) -> Set<TestParameters>

}

/// Default implementations for TestGeneratorNumericTestable.
extension TestGeneratorNumericTestable where Self: TestParameterTestable {

    /// Create test parameters for a sign conversion between a unit.
    /// - Parameters:
    ///   - unit: The unit being tested.
    ///   - sign: The original sign.
    ///   - otherSign: The new sign.
    /// - Returns: The parameters testing this conversion.
    func unitTests(
        from unit: Generator.UnitType, with sign: Signs, to otherSign: Signs
    ) -> Set<TestParameters> {
        let creator = TestFunctionBodyCreator<Generator.UnitType>()
        return [
            TestParameters(
                input: "\(unit)_\(sign)(\(sign.numericType.swiftType.limits.1))",
                output: "\(unit)_\(otherSign.rawValue)(\(expectedOtherMax(from: sign, to: otherSign)))"
            ),
            TestParameters(
                input: "\(unit)_\(sign)(\(sign.numericType.swiftType.limits.0))",
                output: "\(unit)_\(otherSign.rawValue)(\(expectedOtherMin(from: sign, to: otherSign)))"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "0.0", sign: sign),
                output: creator.sanitiseLiteral(literal: "0.0", sign: otherSign)
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "5.0", sign: sign),
                output: creator.sanitiseLiteral(literal: "5.0", sign: otherSign)
            )
        ]
    }

    /// Create test parameters for a unit to numeric type conversion.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type to convert to.
    /// - Returns: The test parameters testing the conversion.
    func numericTests(
        from unit: Generator.UnitType, with sign: Signs, to numeric: NumericTypes
    ) -> Set<TestParameters> {
        let creator = TestFunctionBodyCreator<Generator.UnitType>()
        return [
            TestParameters(
                input: "\(unit)_\(sign)(\(sign.numericType.swiftType.limits.1))",
                output: "\(numeric.swiftType.rawValue)(\(expectedOtherMax(from: sign, to: numeric)))"
            ),
            TestParameters(
                input: "\(unit)_\(sign)(\(sign.numericType.swiftType.limits.0))",
                output: "\(numeric.swiftType.rawValue)(\(expectedOtherMin(from: sign, to: numeric)))"
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "0.0", sign: sign),
                output: creator.sanitiseLiteral(literal: "0.0", to: numeric)
            ),
            TestParameters(
                input: creator.sanitiseLiteral(literal: "5.0", sign: sign),
                output: creator.sanitiseLiteral(literal: "5.0", to: numeric)
            )
        ]
    }

    /// Perform a unit test for all sign conversions from a unit type.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    func unitTest(unit: Generator.UnitType, sign: Signs) {
        [Signs.f, Signs.d, Signs.t, Signs.u].forEach {
            guard sign != $0 else {
                return
            }
            let result = generator.testParameters(from: unit, with: sign, to: unit, with: $0)
            let expected = self.unitTests(from: unit, with: sign, to: $0)
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for unit conversion from \(unit)_\(sign) to \(unit)_\($0.rawValue)")
                return
            }
        }
    }

    /// Perform a unit test between a unit type and all numeric types.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    func numericTest(unit: Generator.UnitType, sign: Signs) {
        NumericTypes.allCases.forEach {
            let expected = self.numericTests(from: unit, with: sign, to: $0)
            let result = generator.testParameters(from: unit, with: sign, to: $0)
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for celsius_t to \($0.rawValue) conversion")
                return
            }
        }
    }

    /// Finds the lowest magnitude lower bound between a sign and numeric type.
    /// - Parameters:
    ///   - sign: The sign to compare.
    ///   - numeric: The numeric type to compare.
    /// - Returns: The lowest-magnitude lower bound.
    private func expectedOtherMin(from sign: Signs, to numeric: NumericTypes) -> String {
        switch sign {
        case .t:
            switch numeric {
            case .int16, .int8, .uint, .uint8, .uint16, .uint32, .uint64, .ulong, .int, .int32:
                return numeric.swiftType.limits.0
            default:
                return sign.numericType.swiftType.limits.0
            }
        case .u:
            return sign.numericType.swiftType.limits.0
        case .f:
            switch numeric {
            case .float, .double:
                return sign.numericType.swiftType.limits.0
            default:
                return numeric.swiftType.limits.0
            }
        case .d:
            return numeric.swiftType.limits.0
        }
    }

    /// Finds the lowest magnitude lower bound between a 2 sign types.
    /// - Parameters:
    ///   - sign: The first sign.
    ///   - otherSign: The other sign.
    /// - Returns: The lowest-magnitude lower bound.
    private func expectedOtherMin(from sign: Signs, to otherSign: Signs) -> String {
        switch sign {
        case .t:
            if otherSign == .u {
                return otherSign.numericType.swiftType.limits.0
            }
            return sign.numericType.swiftType.limits.0
        case .u:
            return sign.numericType.swiftType.limits.0
        case .f:
            if otherSign == .d {
                return sign.numericType.swiftType.limits.0
            }
            return otherSign.numericType.swiftType.limits.0
        case .d:
            return otherSign.numericType.swiftType.limits.0
        }
    }

    /// Finds the lowest magnitude upper bound between a sign and numeric type.
    /// - Parameters:
    ///   - sign: The sign to compare.
    ///   - numeric: The numeric type to compare.
    /// - Returns: The lowest-magnitude upper bound.
    private func expectedOtherMax(from sign: Signs, to numeric: NumericTypes) -> String {
        switch sign {
        case .t:
            switch numeric {
            case .int16, .int8, .uint8, .uint16, .int, .int32, .uint, .uint32:
                return numeric.swiftType.limits.1
            default:
                return sign.numericType.swiftType.limits.1
            }
        case .u:
            switch numeric {
            case .uint64, .float, .double, .int64:
                return sign.numericType.swiftType.limits.1
            default:
                return numeric.swiftType.limits.1
            }
        case .f:
            switch numeric {
            case .double:
                return sign.numericType.swiftType.limits.1
            default:
                return numeric.swiftType.limits.1
            }
        case .d:
            return numeric.swiftType.limits.1
        }
    }

    /// Finds the lowest magnitude upper bound between a 2 sign types.
    /// - Parameters:
    ///   - sign: The first sign.
    ///   - otherSign: The other sign.
    /// - Returns: The lowest-magnitude upper bound.
    private func expectedOtherMax(from sign: Signs, to otherSign: Signs) -> String {
        switch sign {
        case .t:
            return sign.numericType.swiftType.limits.1
        case .u:
            if otherSign == .t {
                return otherSign.numericType.swiftType.limits.1
            }
            return sign.numericType.swiftType.limits.1
        case .f:
            if otherSign == .d {
                return sign.numericType.swiftType.limits.1
            }
            return otherSign.numericType.swiftType.limits.1
        case .d:
            return otherSign.numericType.swiftType.limits.1
        }
    }

}
