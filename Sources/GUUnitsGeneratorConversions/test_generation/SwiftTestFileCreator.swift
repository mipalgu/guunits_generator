// SwiftTestFileCreator.swift 
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

public struct SwiftTestFileCreator {

    public init() {}

    func generate<T: TestGenerator>(with generator: T) -> String {
        prefix(name: "\(T.UnitType.category)Tests") + "\n\n" +
            T.UnitType.allCases.flatMap { unit in
                Signs.allCases.map { sign in
                    createTestStruct(from: unit, with: sign, using: generator)
                }
            }
            .joined(separator: "\n\n") + "\n"
    }

    private func createTestStruct<T: TestGenerator>(
        from unit: T.UnitType, with sign: Signs, using generator: T
    ) -> String {
        let testCases: String = Signs.allCases.map { otherSign in
            T.UnitType.allCases.compactMap { otherUnit in
                guard (sign != otherSign) || (unit != otherUnit) else {
                    return nil
                }
                let tests = generator.testParameters(from: unit, with: sign, to: otherUnit, with: otherSign)
                return tests.map { test in
                    createTest(from: unit, with: sign, to: otherUnit, with: otherSign, and: test)
                }
                .joined(separator: "\n\n")
            }
            .joined(separator: "\n\n")
        }
        .joined(separator: "\n\n")
        let numericTests = NumericTypes.allCases.map { numeric in
            generator.testParameters(from: unit, with: sign, to: numeric).map { toTest in
                createTest(from: unit, with: sign, to: numeric, and: toTest)
            }
            .joined(separator: "\n\n") + "\n\n" +
            generator.testParameters(from: numeric, to: unit, with: sign).map { fromTest in
                createTest(from: numeric, to: unit, with: sign, and: fromTest)
            }
            .joined(separator: "\n\n")
        }
        .joined(separator: "\n\n")
        let name = "\(unit.rawValue.capitalized)_\(sign)Tests"
        return """
        /// Provides \(unit.rawValue.lowercased())_\(sign) unit tests.
        final class \(name): XCTestCase {

        \(testCases)

        \(numericTests)

        }
        """
    }

    private func createTest<T: UnitProtocol>(
        from unit: T, with sign: Signs, to otherUnit: T, with otherSign: Signs, and parameters: TestParameters
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let creator = TestFunctionBodyCreator<T>()
        let helper = FunctionHelpers<T>()
        let fnTestName = helper.testFunctionName(
            from: unit, with: sign, to: otherUnit, with: otherSign, using: parameters
        )
        let fnName = helper.functionName(
            forUnit: unit, to: otherUnit, sign: sign, otherSign: otherSign, unique: true
        )
        let unit = "\(unit.rawValue.capitalized)_\(sign)(\(parameters.input))"
        let conversion = "\(otherUnit.rawValue.capitalized)_\(otherSign)(unit)"
        if parameters.input == "Double.greatestFiniteMagnitude" ||
            parameters.input == "-Double.greatestFiniteMagnitude" {
            return """
                func \(fnTestName)() {
                    let unit = \(unit)
                    let expected = \(fnName)(\(parameters.input))
                    let result = \(conversion).rawValue
                    XCTAssertEqual(expected, result)
                }
            """
        }
        let tolerance = creator.sanitiseLiteral(literal: "1", sign: otherSign)
        let categoryConversion = "\(T.category.capitalized)(unit).\(otherUnit.rawValue)_\(otherSign)"
        return """
            func \(fnTestName)() {
                let unit = \(unit)
                let expected = \(fnName)(\(parameters.input))
                let result = \(conversion).rawValue
                XCTAssertEqual(expected, result)
                let tolerance: \(otherUnit.rawValue)_\(otherSign) = \(tolerance)
                let categoryResult = \(categoryConversion).rawValue
                if categoryResult > expected {
                    XCTAssertLessThanOrEqual(categoryResult - expected, tolerance)
                } else {
                    XCTAssertLessThanOrEqual(expected - categoryResult, tolerance)
                }
            }
        """
    }

    private func createTest<T: UnitProtocol>(
        from unit: T, with sign: Signs, to numeric: NumericTypes, and parameters: TestParameters
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let helper = FunctionHelpers<T>()
        let fnTestName = helper.testFunctionName(from: unit, with: sign, to: numeric, using: parameters)
        let fnName = helper.functionName(forUnit: unit, sign: sign, to: numeric, unique: true)
        let initialiser = "\(unit.rawValue.capitalized)_\(sign.rawValue)(\(parameters.input))"
        return """
            func \(fnTestName)() {
                let expected = \(fnName)(\(parameters.input))
                let result = \(numeric.swiftType)(\(initialiser))
                XCTAssertEqual(expected, result)
            }
        """
    }

    private func createTest<T: UnitProtocol>(
        from numeric: NumericTypes, to unit: T, with sign: Signs, and parameters: TestParameters
    ) -> String where T: RawRepresentable, T.RawValue == String {
        let helper = FunctionHelpers<T>()
        let fnTestName = helper.testFunctionName(from: numeric, to: unit, with: sign, using: parameters)
        let fnName = helper.functionName(from: numeric, to: unit, sign: sign, unique: true)
        let unitType = "\(unit.rawValue.capitalized)_\(sign.rawValue)"
        let initialiser = "\(unitType)(\(numeric.swiftType)(\(parameters.input)))"
        return """
            func \(fnTestName)() {
                let expected = \(fnName)(\(parameters.input))
                let result = \(initialiser).rawValue
                XCTAssertEqual(expected, result)
            }
        """
    }

    // swiftlint:disable function_body_length

    /// The header that appears at the top of the swift file.
    /// - Parameter name: The name of the file.
    /// - Returns: The `String` contents of the header.
    private func prefix(name: String) -> String {
        """
        /*
        * \(name).swift
        * GUUnitsTests
        *
        * Created by Callum McColl on 05/06/2019.
        * Copyright © 2019 Callum McColl. All rights reserved.
        *
        * Redistribution and use in source and binary forms, with or without
        * modification, are permitted provided that the following conditions
        * are met:
        *
        * 1. Redistributions of source code must retain the above copyright
        *    notice, this list of conditions and the following disclaimer.
        *
        * 2. Redistributions in binary form must reproduce the above
        *    copyright notice, this list of conditions and the following
        *    disclaimer in the documentation and/or other materials
        *    provided with the distribution.
        *
        * 3. All advertising materials mentioning features or use of this
        *    software must display the following acknowledgement:
        *
        *        This product includes software developed by Callum McColl.
        *
        * 4. Neither the name of the author nor the names of contributors
        *    may be used to endorse or promote products derived from this
        *    software without specific prior written permission.
        *
        * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
        * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
        * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
        * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
        * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
        * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
        * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
        * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
        * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
        * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
        *
        * -----------------------------------------------------------------------
        * This program is free software; you can redistribute it and/or
        * modify it under the above terms or under the terms of the GNU
        * General Public License as published by the Free Software Foundation;
        * either version 2 of the License, or (at your option) any later version.
        *
        * This program is distributed in the hope that it will be useful,
        * but WITHOUT ANY WARRANTY; without even the implied warranty of
        * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        * GNU General Public License for more details.
        *
        * You should have received a copy of the GNU General Public License
        * along with this program; if not, see http://www.gnu.org/licenses/
        * or write to the Free Software Foundation, Inc., 51 Franklin Street,
        * Fifth Floor, Boston, MA  02110-1301, USA.
        *
        */

        import CGUUnits
        import swift_GUUnits
        import XCTest
        """
    }

}
