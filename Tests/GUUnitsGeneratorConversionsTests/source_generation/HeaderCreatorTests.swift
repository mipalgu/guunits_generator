/*
 * HeaderCreatorTests.swift 
 * guunits_generator 
 *
 * Created by Morgan McColl.
 * Copyright © 2022 Morgan McColl. All rights reserved.
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
 *        This product includes software developed by Morgan McColl.
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

@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for HeaderCreator.
final class HeaderCreatorTests: XCTestCase {

    /// The creator being tested.
    let creator = HeaderCreator()

    /// The distance generator.
    let distanceGenerator = AnyGenerator(
        generating: DistanceUnits.self,
        using: DistanceUnitsGenerator(
            unitDifference: [
                .millimetres: 10,
                .centimetres: 100
            ]
        )
    )

    /// The time generator.
    let timeGenerator = AnyGenerator(
        generating: TimeUnits.self,
        using: TimeUnitsGenerator(unitDifference: [
            .picoseconds: 1000,
            .nanoseconds: 1000,
            .microseconds: 1000,
            .milliseconds: 1000
        ])
    )

    /// The angle generator.
    let angleGenerator = AnyGenerator(generating: AngleUnits.self, using: AngleUnitsGenerator())

    /// The image generator.
    let imageGenerator = AnyGenerator(
        generating: ImageUnits.self, using: ImageUnitsGenerator(unitDifference: [:])
    )

    /// The percent generator.
    let percentGenerator = AnyGenerator(
        generating: PercentUnits.self, using: PercentUnitGenerator(unitDifference: [:])
    )

    /// The temperate generator.
    let temperatureGenerator = AnyGenerator(
        generating: TemperatureUnits.self, using: TemperatureUnitsGenerator()
    )

    /// The acceleration generator.
    let accelerationGenerator = AnyGenerator(
        generating: Acceleration.self, using: OperationalGenerator()
    )

    /// The header of the file.
    var prefix: String {
        """
        /*
        * guunits.h
        * guunits
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
        \("\n")
        #ifndef GUUNITS_H
        #define GUUNITS_H
        \("")
        #include <stdint.h>
        #include <limits.h>
        #include <float.h>
        \("")
        #ifdef __cplusplus
        extern "C" {
        #endif
        """
    }

    /// The footer of the file.
    var suffix: String {
        """
        \(numericConversions)

        #ifdef __cplusplus
        }
        #endif
        \("")
        #endif  /* GUUNITS_H */
        \("")
        """
    }

    /// Add default numeric conversion functions.
    private var numericConversions: String {
        [NumericTypes.double, NumericTypes.float].flatMap { type in
            NumericTypes.allCases.compactMap { otherType in
                guard type.isFloat && !otherType.isFloat || (type == .double && otherType == .float) else {
                    return nil
                }
                return "\(otherType.rawValue) \(type.abbreviation)_to_" +
                    "\(otherType.abbreviation)(\(type.rawValue));"
            }
        }
        .joined(separator: "\n\n")
    }

    /// TypeDefs in header.
    var typeDefs: String {
        let units: [(String, [CustomStringConvertible])] = [
            ("// Distance Units.", Array(DistanceUnits.allCases)),
            ("// Current Units.", Array(CurrentUnits.allCases)),
            ("// Time Units.", Array(TimeUnits.allCases)),
            ("// Angle Units.", Array(AngleUnits.allCases)),
            ("// Image Units.", Array(ImageUnits.allCases)),
            ("// Percent Units.", Array(PercentUnits.allCases)),
            ("// Temperature Units.", Array(TemperatureUnits.allCases)),
            ("// Acceleration Units.", Array(Acceleration.allCases)),
            ("// Reference Acceleration Units", Array(ReferenceAcceleration.allCases)),
            ("// Mass Units.", Array(MassUnits.allCases)),
            ("// Velocity Units.", Array(Velocity.allCases)),
            ("// Angular Velocity Units.", Array(AngularVelocity.allCases))
        ]
        let signs = Signs.allCases
        let typeDefs = units.flatMap { comment, units in
            ["", comment] + units.flatMap { unit in
                signs.map { "typedef \($0.type) \(unit)_\($0.rawValue);" }
            }
        }
        guard let first = typeDefs.first else {
            return ""
        }
        return typeDefs.dropFirst().reduce(first) { $0 + "\n" + $1 }
    }

    /// Test header file is created correctly.
    func testGenerate() {
        let result = creator.generate(
            generators: [
                distanceGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator,
                accelerationGenerator
            ]
        )
        guard
            let distances = distanceGenerator.declarations,
            let times = timeGenerator.declarations,
            let angles = angleGenerator.declarations,
            let images = imageGenerator.declarations,
            let percentages = percentGenerator.declarations,
            let temperatures = temperatureGenerator.declarations,
            let accelerations = accelerationGenerator.declarations
        else {
            XCTFail("Unable to create header.")
            return
        }
        let expected = prefix + "\n" + typeDefs
            + "\n\n" + distances
            + "\n\n" + times
            + "\n\n" + angles
            + "\n\n" + images
            + "\n\n" + percentages
            + "\n\n" + temperatures
            + "\n\n" + accelerations
            + "\n\n" + suffix
        XCTAssertEqual(result, expected)
    }

}
