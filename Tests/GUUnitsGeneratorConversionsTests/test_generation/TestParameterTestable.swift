// TestParameterTestable.swift 
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

/// Protocol providing helper functions for Tests that use test parameters.
protocol TestParameterTestable {

    /// Tests that an array of TestParameters contains the same elements as a set of TestParameters.
    /// - Parameters:
    ///   - result: The array to test.
    ///   - expected: The set to compare result against.
    /// - Returns: Whether result contains the same members as expected.
    func testSet(result: [TestParameters], expected: Set<TestParameters>) -> Bool

}

/// Default implementations for TestParameterTestable.
extension TestParameterTestable {

    /// Tests that an array of TestParameters contains the same elements as a set of TestParameters.
    /// - Parameters:
    ///   - result: The array to test.
    ///   - expected: The set to compare result against.
    /// - Returns: Whether result contains the same members as expected.
    func testSet(result: [TestParameters], expected: Set<TestParameters>) -> Bool {
        var success = true
        result.forEach {
            guard expected.contains($0) else {
                XCTFail("Additional test \($0) found!")
                success = false
                return
            }
        }
        let resultSet = Set(result)
        let expectedArray = Array(expected)
        expectedArray.forEach {
            guard resultSet.contains($0) else {
                XCTFail("Missing test \($0)!")
                success = false
                return
            }
        }
        XCTAssertEqual(result.count, expected.count)
        if result.count != expected.count {
            let duplicates = Dictionary(grouping: result.enumerated()) {
                $0.1.input + $0.1.output
            }.filter {
                $1.count > 1
            }
            .map { $0.1 }
            print("result not equal to expected with duplicates \(duplicates)")
        }
        XCTAssertEqual(result.count, resultSet.count)
        guard result.count == expected.count && result.count == resultSet.count else {
            return false
        }
        return success
    }

}
