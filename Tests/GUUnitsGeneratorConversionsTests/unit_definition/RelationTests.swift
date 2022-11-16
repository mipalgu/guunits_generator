// RelationTests.swift 
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

/// Test class for ``Relation``.
final class RelationTests: XCTestCase {

    /// A metres type-erased unit.
    let metres = AnyUnit(DistanceUnits.metres)

    /// A seconds type-erased unit.
    let seconds = AnyUnit(TimeUnits.seconds)

    /// A test relation from metres to seconds.
    let singleRelation = Relation(
        source: AnyUnit(DistanceUnits.metres),
        target: AnyUnit(TimeUnits.seconds),
        operation: .constant(declaration: AnyUnit(DistanceUnits.metres))
    )

    /// Test init sets properties correctly.
    func testInit() {
        let source = Acceleration.metresPerSecond2
        let target = AnyUnit(ReferenceAcceleration.earthG)
        let operation: GUUnitsGeneratorConversions.Operation = .division(
            lhs: .constant(declaration: source),
            rhs: .literal(declaration: .decimal(value: .earthAcceleration))
        )
        let relation = Relation(source: source, target: target, operation: operation)
        XCTAssertEqual(relation.source, source)
        XCTAssertEqual(relation.target, target)
        XCTAssertEqual(relation.operation, operation)
    }

    /// Test single parameter relations conversion function name.
    func testSingleParameterFunctionName() {
        let sign = Signs.t
        let otherSign = Signs.u
        let name = singleRelation.name(sign: sign, otherSign: otherSign)
        let fnName = "\(metres.abbreviation)_\(sign.rawValue)_to_" +
            "\(seconds.abbreviation)_\(otherSign.rawValue)"
        XCTAssertEqual(name, fnName)
    }

    /// Test function definition for single-parameter relation.
    func testSingleParameterDefinition() {
        let sign = Signs.t
        let otherSign = Signs.u
        let definition = singleRelation.definition(sign: sign, otherSign: otherSign)
        let comment = """
        /**
        * Convert \(metres)_\(sign.rawValue) to \(seconds)_\(otherSign.rawValue).
        */
        """
        let fnName = singleRelation.name(sign: sign, otherSign: otherSign)
        let parameters = "\(metres)_\(sign.rawValue) \(metres)"
        let expected = comment + "\n" + "\(seconds)_\(otherSign.rawValue) \(fnName)(\(parameters));"
        XCTAssertEqual(definition, expected)
    }

    func testSingleParameterImplementationSignedToUnsigned() {
        let converter = NumericTypeConverter()
        let sign = Signs.t
        let otherSign = Signs.u
        let implementation = singleRelation.implementation(sign: sign, otherSign: otherSign)
        let comment = """
        /**
        * Convert \(metres)_\(sign.rawValue) to \(seconds)_\(otherSign.rawValue).
        */
        """
        let fnName = singleRelation.name(sign: sign, otherSign: otherSign)
        let parameters = "\(metres)_\(sign.rawValue) \(metres)"
        let functionDef = comment + "\n" + "\(seconds)_\(otherSign.rawValue) \(fnName)(\(parameters))"
        let cast = converter.convert(
            "result", from: sign.numericType, to: singleRelation.target, sign: otherSign
        )
        let body = """
            const \(sign.numericType.rawValue) unit0 = ((\(sign.numericType.rawValue)) (metres));
            if (__builtin_expect(overflow_upper_\(sign.rawValue)(unit0), 0)) {
                return \(otherSign.numericType.limits.1);
            } else if (__builtin_expect(overflow_lower_\(sign.rawValue)(unit0), 0)) {
                return \(otherSign.numericType.limits.0);
            } else {
                const \(sign.numericType.rawValue) result = \(singleRelation.operation.cCode(sign: sign));
                if (__builtin_expect(overflow_upper_\(sign.rawValue)(result), 0)) {
                    return \(otherSign.numericType.limits.1);
                } else if (__builtin_expect(overflow_lower_\(sign.rawValue)(result), 0)) {
                    return \(otherSign.numericType.limits.0);
                } else {
                    return \(cast);
                }
            }
        """
        let expected = """
        \(functionDef)
        {
        \(body)
        }
        """
        XCTAssertEqual(implementation, expected)
    }

}
