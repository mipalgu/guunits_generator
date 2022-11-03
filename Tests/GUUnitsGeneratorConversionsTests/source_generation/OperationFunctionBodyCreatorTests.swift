// OperationfunctionBodyCreatorTests.swift 
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

/// Test class for ``OperationFunctionBodyCreator``.
final class OperationFunctionBodyCreatorTests: XCTestCase {

    /// Helper velocity unit.
    let v1 = Velocity(
        unit: .division(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: .constant(declaration: AnyUnit(TimeUnits.seconds))
        )
    )
    
    /// Helper velocity unit.
    let v2 = Velocity(
        unit: .division(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.centimetres)),
            rhs: .constant(declaration: AnyUnit(TimeUnits.seconds))
        )
    )

    /// Creator under test.
    let creator = OperationalFunctionBodyCreator<Velocity>()

    /// Test standard signed conversion.
    func testSignedConversion() {
        let result = creator.createFunction(unit: v1, to: v2, sign: .t, otherSign: .d)
        let signType = Signs.t.numericType.rawValue
        let otherSignLimits = Signs.d.numericType.limits
        let code = v1.conversion(to: v2).cCode(sign: .d)
        let expected = """
            const \(signType) unit = ((\(signType)) (metres_per_seconds));
            if (__builtin_expect(overflow_upper_t(unit), 0)) {
                return \(otherSignLimits.1);
            } else if (__builtin_expect(overflow_lower_t(unit), 0)) {
                return \(otherSignLimits.0);
            } else {
                const double result = \(code);
                if (__builtin_expect(overflow_upper_d(result), 0)) {
                    return \(otherSignLimits.1);
                } else if (__builtin_expect(overflow_lower_d(result), 0)) {
                    return \(otherSignLimits.0);
                } else {
                    return ((centimetres_per_seconds_d) (result));
                }
            }
        """
        XCTAssertEqual(result, expected)
    }

    /// Test integer unsigned conversion.
    func testUnsignedConversion() {
        let result = creator.createFunction(unit: v1, to: v2, sign: .u, otherSign: .t)
        let signType = Signs.u.numericType.rawValue
        let otherSignLimits = Signs.t.numericType.limits
        let code = v1.conversion(to: v2).cCode(sign: .u)
        let minString = "MIN(((\(signType)) (\(Signs.t.numericType.limits.1))), result)"
        let expected = """
            const \(signType) unit = ((\(signType)) (metres_per_seconds));
            if (__builtin_expect(overflow_upper_u(unit), 0)) {
                return \(otherSignLimits.1);
            } else {
                const \(signType) result = \(code);
                if (__builtin_expect(overflow_upper_u(result), 0)) {
                    return \(otherSignLimits.1);
                } else {
                    return ((centimetres_per_seconds_t) (\(minString)));
                }
            }
        """
        XCTAssertEqual(result, expected)
    }

}
