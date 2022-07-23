@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for CFileCreator.
final class CFileCreatorTests: XCTestCase {

    /// The creator being tested.
    let creator = CFileCreator()

    /// The header of the file.
    var prefix: String {
        """
        /*
        * guunits.c
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
        #include "guunits.h"
        \("")
        #include <math.h>
        \("")
        #ifndef MAX
        #define MAX(a, b) ((a) > (b) ? (a) : (b))
        #endif
        \("")
        #ifndef MIN
        #define MIN(a, b) ((a) < (b) ? (a) : (b))
        #endif
        \("")
        #ifndef M_PI
        #define M_PI 3.14159265358979323846
        #endif
        """
    }

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

    /// Test computed properties have right values.
    func testComputedProperties() {
        XCTAssertEqual(creator.suffix, "")
    }

    /// Test generate function creates all c functions.
    func testGenerate() {
        let result = creator.generate(
            generators: [
                distanceGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator
            ]
        )
        guard
            let distances = distanceGenerator.implementations,
            let times = timeGenerator.implementations,
            let angles = angleGenerator.implementations,
            let images = imageGenerator.implementations,
            let percentages = percentGenerator.implementations,
            let temperatures = temperatureGenerator.implementations
        else {
            XCTFail("Unable to create C file.")
            return
        }
        let expected = prefix + "\n\n" + distances
            + "\n\n" + times
            + "\n\n" + angles
            + "\n\n" + images
            + "\n\n" + percentages
            + "\n\n" + temperatures
            + "\n\n"
        XCTAssertEqual(result, expected)
    }

}
