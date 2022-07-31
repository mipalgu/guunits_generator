// /*
//  * TestFileCreator.swift 
//  * guunits_generator 
//  *
//  * Created by Morgan McColl.
//  * Copyright © 2022 Morgan McColl. All rights reserved.
//  *
//  * Redistribution and use in source and binary forms, with or without
//  * modification, are permitted provided that the following conditions
//  * are met:
//  *
//  * 1. Redistributions of source code must retain the above copyright
//  *    notice, this list of conditions and the following disclaimer.
//  *
//  * 2. Redistributions in binary form must reproduce the above
//  *    copyright notice, this list of conditions and the following
//  *    disclaimer in the documentation and/or other materials
//  *    provided with the distribution.
//  *
//  * 3. All advertising materials mentioning features or use of this
//  *    software must display the following acknowledgement:
//  *
//  *        This product includes software developed by Morgan McColl.
//  *
//  * 4. Neither the name of the author nor the names of contributors
//  *    may be used to endorse or promote products derived from this
//  *    software without specific prior written permission.
//  *
//  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
//  * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
//  * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
//  * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
//  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
//  * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
//  * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  *
//  * -----------------------------------------------------------------------
//  * This program is free software; you can redistribute it and/or
//  * modify it under the above terms or under the terms of the GNU
//  * General Public License as published by the Free Software Foundation;
//  * either version 2 of the License, or (at your option) any later version.
//  *
//  * This program is distributed in the hope that it will be useful,
//  * but WITHOUT ANY WARRANTY; without even the implied warranty of
//  * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  * GNU General Public License for more details.
//  *
//  * You should have received a copy of the GNU General Public License
//  * along with this program; if not, see http://www.gnu.org/licenses/
//  * or write to the Free Software Foundation, Inc., 51 Franklin Street,
//  * Fifth Floor, Boston, MA  02110-1301, USA.
//  *
//  */
// 

struct TestFileCreator<TestGeneratorType: TestGenerator> {

    typealias Unit = TestGeneratorType.UnitType

    private let helper = FunctionHelpers<Unit>()

    private let bodyCreator = TestFunctionBodyCreator<Unit>()

    func tests(generator: TestGeneratorType, imports: String) -> String {
        let unitTests: [String] = Unit.allCases.flatMap { unit in
            Unit.allCases.flatMap { otherUnit in
                Signs.allCases.flatMap { sign in
                    Signs.allCases.flatMap { otherSign in
                        self.createTests(
                            from: unit, with: sign, to: otherUnit, with: otherSign, using: generator
                        )
                    }
                }
            } +
            Signs.allCases.flatMap { sign in
                NumericTypes.allCases.flatMap { numeric in
                    self.createTests(from: unit, with: sign, to: numeric, using: generator) +
                        self.createTests(from: numeric, to: unit, with: sign, using: generator)
                }
            }
        }
        .sorted()
        print("Created \(unitTests.count) Tests for \(Unit.category)!")
        let allTests = unitTests.joined(separator: "\n\n")
        return "\(imports)\nimport Foundation\nimport XCTest\n\nfinal class \(Unit.category)" +
            "Tests: XCTestCase {\n\n\(allTests)\n\n}\n"
    }

    private func createTests(
        from unit: Unit,
        with sign: Signs,
        to otherUnit: Unit,
        with otherSign: Signs,
        using generator: TestGeneratorType
    ) -> [String] {
        generator.testParameters(from: unit, with: sign, to: otherUnit, with: otherSign).map {
            self.createTestFunction(from: unit, with: sign, to: otherUnit, with: otherSign, with: $0)
        }
    }

    private func createTests(
        from unit: Unit,
        with sign: Signs,
        to numeric: NumericTypes,
        using generator: TestGeneratorType
    ) -> [String] {
        generator.testParameters(from: unit, with: sign, to: numeric).map {
            self.createTestFunction(from: unit, with: sign, to: numeric, with: $0)
        }
    }

    private func createTests(
        from numeric: NumericTypes,
        to unit: Unit,
        with sign: Signs,
        using generator: TestGeneratorType
    ) -> [String] {
        generator.testParameters(from: numeric, to: unit, with: sign).map {
            self.createTestFunction(from: numeric, to: unit, with: sign, with: $0)
        }
    }

    private func createTestFunction(
        from unit: Unit,
        with sign: Signs,
        to otherUnit: Unit,
        with otherSign: Signs,
        with parameters: TestParameters
    ) -> String {
        let name = helper.testFunctionName(
            from: unit, with: sign, to: otherUnit, with: otherSign, using: parameters
        )
        let body = bodyCreator.generateFunction(
            from: unit, with: sign, to: otherUnit, with: otherSign, using: parameters
        )
        return "    func \(name)() {\n        \(body)\n    }"
    }

    private func createTestFunction(
        from unit: Unit,
        with sign: Signs,
        to numeric: NumericTypes,
        with parameters: TestParameters
    ) -> String {
        let name = helper.testFunctionName(from: unit, with: sign, to: numeric, using: parameters)
        let body = bodyCreator.generateFunction(from: unit, with: sign, to: numeric, using: parameters)
        return "    func \(name)() {\n        \(body)\n    }"
    }

    private func createTestFunction(
        from numeric: NumericTypes,
        to unit: Unit,
        with sign: Signs,
        with parameters: TestParameters
    ) -> String {
        let name = helper.testFunctionName(from: numeric, to: unit, with: sign, using: parameters)
        let body = bodyCreator.generateFunction(from: numeric, to: unit, with: sign, using: parameters)
        return "    func \(name)() {\n        \(body)\n    }"
    }

}
