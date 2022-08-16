// SameUnitTestGenerator.swift 
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

/// Struct for generating tests for unit categories with only 1 unit case.
struct SameUnitTestGenerator<Unit>: TestGenerator where
    Unit: UnitProtocol, Unit: RawRepresentable, Unit.RawValue == String {

    /// Create the default test parameters.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - sign: The sign of the unit.
    ///   - otherUnit: The unit to convert to. This unit must be the same as the other unit.
    ///   - otherSign: The sign of the unit to convert to.
    /// - Returns: The test parameters which test the conversion.
    func testParameters(
        from unit: Unit, with sign: Signs, to otherUnit: Unit, with otherSign: Signs
    ) -> [TestParameters] {
        guard unit == otherUnit else {
            fatalError("Units must be the same!")
        }
        guard sign != otherSign else {
            return []
        }
        return self.defaultParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
    }

    /// Create test parameters for a unit to numeric conversion.
    /// - Parameters:
    ///   - unit: The unit converting from.
    ///   - sign: The sign of the unit.
    ///   - numeric: The numeric type converting to.
    /// - Returns: The test parameters testing the conversion.
    func testParameters(from unit: Unit, with sign: Signs, to numeric: NumericTypes) -> [TestParameters] {
        self.defaultParameters(from: unit, with: sign, to: numeric)
    }

    /// Create test parameters for a numeric to unit conversion.
    /// - Parameters:
    ///   - numeric: The numeric type to convert from.
    ///   - unit: The unit to convert to.
    ///   - sign: The sign of the unit.
    /// - Returns: The test parameters which test the conversion function.
    func testParameters(from numeric: NumericTypes, to unit: Unit, with sign: Signs) -> [TestParameters] {
        self.defaultParameters(from: numeric, to: unit, with: sign)
    }

}
