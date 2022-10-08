// MassUnitsTests.swift 
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

/// Test class for `MassUnits`.
final class MassUnitsTests: XCTestCase, UnitsTestable {

    /// Test microgram case.
    func testMicrogram() {
        assert(
            value: MassUnits.microgram, rawValue: "microgram", abbreviation: "ug", description: "microgram"
        )
    }

    /// Test milligram case.
    func testMilligram() {
        assert(
            value: MassUnits.milligram, rawValue: "milligram", abbreviation: "mg", description: "milligram"
        )
    }

    /// Test gram case.
    func testGram() {
        assert(
            value: MassUnits.gram, rawValue: "gram", abbreviation: "g", description: "gram"
        )
    }

    /// Test kilogram case.
    func testKilogram() {
        assert(
            value: MassUnits.kilogram, rawValue: "kilogram", abbreviation: "kg", description: "kilogram"
        )
    }

    /// Test megagram case.
    func testMegaGram() {
        assert(
            value: MassUnits.megagram, rawValue: "megagram", abbreviation: "Mg", description: "megagram"
        )
    }

    func testUnitDifference() {
        XCTAssertEqual(
            MassUnits.unitDifference,
            [
                .microgram: 1000,
                .milligram: 1000,
                .gram: 1000,
                .kilogram: 1000
            ]
        )
    }

    func testAllCases() {
        XCTAssertEqual(
            MassUnits.allCases,
            [
                .microgram,
                .milligram,
                .gram,
                .kilogram,
                .megagram
            ]
        )
    }

    func testConversionToGreaterUnit() {
        let result = MassUnits.milligram.conversion(to: .kilogram)
        let expected = Operation.division(
            lhs: .constant(declaration: AnyUnit(MassUnits.milligram)), rhs: .literal(declaration: 1000000)
        )
        XCTAssertEqual(result, expected)
    }

    func testConversionToSmallerUnit() {
        let result = MassUnits.kilogram.conversion(to: .milligram)
        let expected = Operation.multiplication(
            lhs: .constant(declaration: AnyUnit(MassUnits.kilogram)), rhs: .literal(declaration: 1000000)
        )
        XCTAssertEqual(result, expected)
    }

    func testConversionFromSmallerUnit() {
        let result = MassUnits.kilogram.conversion(from: .milligram)
        let expected = Operation.division(
            lhs: .constant(declaration: AnyUnit(MassUnits.milligram)), rhs: .literal(declaration: 1000000)
        )
        XCTAssertEqual(result, expected)
    }

    func testConversionFromGreaterUnit() {
        let result = MassUnits.milligram.conversion(from: .kilogram)
        let expected = Operation.multiplication(
            lhs: .constant(declaration: AnyUnit(MassUnits.kilogram)), rhs: .literal(declaration: 1000000)
        )
        XCTAssertEqual(result, expected)
    }

}
