// AccelerationFunctionCreatorTests.swift 
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

/// Test class for AccelerationFunctionCreator.
final class AccelerationFunctionCreatorTests: XCTestCase {

    /// The creator under test.
    let creator = AccelerationFunctionCreator()

    /// Test metresPerSecond2_t to g_t.
    func testMps2TogT() {
        let result = creator.createFunction(
            unit: .metresPerSecond2, to: .gs, sign: .t, otherSign: .t
        )
        let expected = """
            const double maxValue = ((double) (INT_MAX)) * 9.807;
            const double minValue = ((double) (INT_MIN)) * 9.807;
            const double value = ((double) (metresPerSecond2));
            if (value > maxValue) {
                return INT_MAX;
            }
            if (value < minValue) {
                return INT_MIN;
            }
            return ((gs_t) (round(value / 9.807)));
        """
        XCTAssertEqual(result, expected)
    }

    /// Test metresPerSecond2_t to g_d.
    func testMps2TogD() {
        let result = creator.createFunction(unit: .metresPerSecond2, to: .gs, sign: .t, otherSign: .d)
        let expected = "    return ((gs_d) (((double) (metresPerSecond2)) / 9.807));"
        XCTAssertEqual(result, expected)
    }

    /// Test metresPerSecond2_d to g_d.
    func testMps2DTogD() {
        let result = creator.createFunction(unit: .metresPerSecond2, to: .gs, sign: .d, otherSign: .d)
        let expected = "    return ((gs_d) (((double) (metresPerSecond2)) / 9.807));"
        XCTAssertEqual(result, expected)
    }

    /// Test g_t to mps2_t.
    func testGToMpsT() {
        let result = creator.createFunction(unit: .gs, to: .metresPerSecond2, sign: .t, otherSign: .t)
        let expected = """
            const double maxValue = ((double) (INT_MAX)) / 9.807;
            const double minValue = ((double) (INT_MIN)) / 9.807;
            const double value = ((double) (gs));
            if (value > maxValue) {
                return INT_MAX;
            }
            if (value < minValue) {
                return INT_MIN;
            }
            return ((metresPerSecond2_t) (round(value * 9.807)));
        """
        XCTAssertEqual(result, expected)
    }

    /// Test g_t to mps_d.
    func testGToMpsD() {
        let result = creator.createFunction(unit: .gs, to: .metresPerSecond2, sign: .t, otherSign: .d)
        let expected = "    return ((metresPerSecond2_d) (((double) (gs)) * 9.807));"
        XCTAssertEqual(result, expected)
    }

    /// Test g_d to mps2_d.
    func testGDToMpsD() {
        let result = creator.createFunction(unit: .gs, to: .metresPerSecond2, sign: .d, otherSign: .d)
        let expected = """
            const double maxValue = ((double) (DBL_MAX)) / 9.807;
            const double minValue = ((double) (-DBL_MAX)) / 9.807;
            const double value = ((double) (gs));
            if (value > maxValue) {
                return DBL_MAX;
            }
            if (value < minValue) {
                return -DBL_MAX;
            }
            return ((metresPerSecond2_d) (value * 9.807));
        """
        XCTAssertEqual(result, expected)
    }

}
