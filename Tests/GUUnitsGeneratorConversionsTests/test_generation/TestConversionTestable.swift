// TestConversionTestable.swift 
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

/// Common interface for implementing helper functions for conversion method testing.
protocol TestConversionTestable {

    /// Require a generator.
    associatedtype Generator: TestGenerator

    /// The generator stored property.
    var generator: Generator { get }

    /// Perform all the tests.
    /// - Parameter conversion: The conversion functions to test and their parameters. 
    func doTest(conversion: ConversionTest<Generator.UnitType>)

    /// Create default test parameters for a unit conversion.
    /// - Parameters:
    ///   - sign: The sign of the first parameter.
    ///   - otherSign: The sign of the second parameter.
    ///   - additional: Additional tests.
    /// - Returns: A set of all test cases to be tested against the conversion function.
    func expected(
        from sign: Signs, to otherSign: Signs, additional: Set<TestParameters>
    ) -> Set<TestParameters>

}

/// Default implementation for TestConversionTestable.
extension TestConversionTestable where Self: TestParameterTestable {

    /// Test a conversion function by delegating to underlying implementation.
    /// - Parameter conversion: The conversion functions to test.
    func doTest(conversion: ConversionTest<Generator.UnitType>) {
        self.doTest(
            from: conversion.unit,
            with: conversion.sign,
            to: conversion.otherUnit,
            with: conversion.otherSign,
            and: conversion.parameters
        )
    }

    /// Test a conversion function.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to.
    ///   - otherSign: The sign of the unit to convert to.
    ///   - parameters: Any additional test cases for the conversion function.
    private func doTest(
        from unit: Generator.UnitType,
        with sign: Signs,
        to otherUnit: Generator.UnitType,
        with otherSign: Signs,
        and parameters: Set<TestParameters>
    ) {
        let result = generator.testParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
        let expected = self.expected(from: sign, to: otherSign, additional: parameters)
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

}
