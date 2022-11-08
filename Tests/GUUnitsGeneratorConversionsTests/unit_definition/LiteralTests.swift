// LiteralTests.swift 
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

/// Test class for ``Literal``.
final class LiteralTests: XCTestCase {

    /// Int literal under test.
    let intLiteral = Literal.integer(value: 5)

    /// Double Literal under test.
    let doubleLiteral = Literal.decimal(value: 12.3456)

    /// Test abbreviation is correct.
    func testAbbreviation() {
        XCTAssertEqual(intLiteral.abbreviation, "5")
        XCTAssertEqual(doubleLiteral.abbreviation, "12_35")
    }

    /// Test double conversion is correct.
    func testAsDouble() {
        XCTAssertEqual(5.0, intLiteral.asDouble)
        XCTAssertEqual(12.3456, doubleLiteral.asDouble)
    }

    /// Test integer conversion is correct.
    func testAsInteger() {
        XCTAssertEqual(5, intLiteral.asInteger)
        XCTAssertEqual(12, doubleLiteral.asInteger)
        let literal3 = Literal.decimal(value: 7.6)
        XCTAssertEqual(8, literal3.asInteger)
    }

    /// Test string representation maintains the underlying values.
    func testAsString() {
        XCTAssertEqual("5", intLiteral.asString)
        XCTAssertEqual("12.3456", doubleLiteral.asString)
    }

    /// Test isFloat is correct.
    func testIsFloat() {
        XCTAssertFalse(intLiteral.isFloat)
        XCTAssertTrue(doubleLiteral.isFloat)
    }

    /// Test isZero property.
    func testIsZero() {
        let literal = Literal.integer(value: 0)
        let literal2 = Literal.decimal(value: 0.0)
        let literal3 = Literal.integer(value: 1)
        let literal4 = Literal.decimal(value: 1.0)
        XCTAssertTrue(literal.isZero)
        XCTAssertTrue(literal2.isZero)
        XCTAssertFalse(literal3.isZero)
        XCTAssertFalse(literal4.isZero)
    }

    /// Test isOne property.
    func testIsOne() {
        let literal = Literal.integer(value: 0)
        let literal2 = Literal.decimal(value: 0.0)
        let literal3 = Literal.integer(value: 1)
        let literal4 = Literal.decimal(value: 1.0)
        XCTAssertFalse(literal.isOne)
        XCTAssertFalse(literal2.isOne)
        XCTAssertTrue(literal3.isOne)
        XCTAssertTrue(literal4.isOne)
    }

}
