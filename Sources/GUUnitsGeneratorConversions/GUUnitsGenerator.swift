/*
 * GUUnitsGenerator.swift 
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

import Foundation

/// Create the source files the C and swift targets of guunits.
public struct GUUnitsGenerator {

    /// The manager that performs the writing.
    let fileManager = FileManager()

    /// Default init.
    public init() {}

    // swiftlint:disable function_body_length

    /// Create all of the C source files at a specific path.
    /// - Parameter path: The path to create files in.
    public func generateCFiles(in path: URL) throws {
        // guard !path.isFileURL else {
        //     fatalError("Path is not a valid directory.")
        // }
        var hFile = path
        var cFile = path
        hFile.appendPathComponent("include", isDirectory: true)
        if !fileManager.fileExists(atPath: hFile.path) {
            try fileManager.createDirectory(atPath: hFile.path, withIntermediateDirectories: true)
        }
        hFile.appendPathComponent("guunits.h", isDirectory: false)
        cFile.appendPathComponent("guunits.c", isDirectory: false)
        let distanceGenerator = AnyGenerator(
            generating: DistanceUnits.self,
            using: DistanceUnitsGenerator(unitDifference: [
                .millimetres: 10,
                .centimetres: 100
            ])
        )
        let currentGenerator = AnyGenerator(
            generating: CurrentUnits.self,
            using: CurrentUnitsGenerator(unitDifference: [
                .microamperes: 1000,
                .milliamperes: 1000
            ])
        )
        let timeGenerator = AnyGenerator(
            generating: TimeUnits.self,
            using: TimeUnitsGenerator(unitDifference: [
                .microseconds: 1000,
                .milliseconds: 1000
            ])
        )
        let angleGenerator = AnyGenerator(generating: AngleUnits.self, using: AngleUnitsGenerator())
        let imageGenerator = AnyGenerator(
            generating: ImageUnits.self, using: ImageUnitsGenerator(unitDifference: [:])
        )
        let percentGenerator = AnyGenerator(
            generating: PercentUnits.self, using: PercentUnitGenerator(unitDifference: [:])
        )
        let temperatureGenerator = AnyGenerator(
            generating: TemperatureUnits.self, using: TemperatureUnitsGenerator()
        )
        let accelerationGenerator = AnyGenerator(
            generating: AccelerationUnits.self, using: AccelerationUnitsGenerator()
        )
        let fileContents = HeaderCreator().generate(
            generators: [
                distanceGenerator,
                currentGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator,
                accelerationGenerator
            ]
        )
        .data(using: .utf8)
        print("Writing H-file to path \(hFile.absoluteString)...")
        fileManager.createFile(atPath: hFile.path, contents: fileContents)
        print("Done!\nWriting C-File to path \(cFile.absoluteString)...")
        let cContents = CFileCreator().generate(
            generators: [
                distanceGenerator,
                currentGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator,
                accelerationGenerator
            ]
        )
        .data(using: .utf8)
        fileManager.createFile(atPath: cFile.path, contents: cContents)
        print("Done!")
    }

    /// Create the C Test files at a specific location.
    /// - Parameter path: The path to the folder that will contain the test files.
    func generateCTests(in path: URL) {
        // guard !path.isFileURL else {
        //     fatalError("Path is not a valid directory.")
        // }
        let fileCreator = TestFileCreator<TemperatureTestGenerator>()
        let testGenerator = TemperatureTestGenerator()
        writeFile(
            at: path,
            with: "TemperatureTests",
            and: fileCreator.tests(generator: testGenerator, imports: "import CGUUnits")
        )
        let distanceGenerator = GradualTestGenerator<DistanceUnits>(unitDifference: [
            .millimetres: 10,
            .centimetres: 100
        ])
        let distanceFileCreator = TestFileCreator<GradualTestGenerator<DistanceUnits>>()
        writeFile(
            at: path,
            with: "DistanceTests",
            and: distanceFileCreator.tests(generator: distanceGenerator, imports: "import CGUUnits")
        )
        let imageGenerator = SameUnitTestGenerator<ImageUnits>()
        let imageFileCreator = TestFileCreator<SameUnitTestGenerator<ImageUnits>>()
        writeFile(
            at: path,
            with: "ImageTests",
            and: imageFileCreator.tests(generator: imageGenerator, imports: "import CGUUnits")
        )
        let percentGenerator = SameUnitTestGenerator<PercentUnits>()
        let percentFileCreator = TestFileCreator<SameUnitTestGenerator<PercentUnits>>()
        writeFile(
            at: path,
            with: "PercentTests",
            and: percentFileCreator.tests(generator: percentGenerator, imports: "import CGUUnits")
        )
        let timeGenerator = GradualTestGenerator<TimeUnits>(unitDifference: [
            .microseconds: 1000,
            .milliseconds: 1000
        ])
        let timeFileCreator = TestFileCreator<GradualTestGenerator<TimeUnits>>()
        writeFile(
            at: path,
            with: "TimeTests",
            and: timeFileCreator.tests(generator: timeGenerator, imports: "import CGUUnits")
        )
        let angleGenerator = AngleTestGenerator()
        let angleFileCreator = TestFileCreator<AngleTestGenerator>()
        writeFile(
            at: path,
            with: "AngleTests",
            and: angleFileCreator.tests(generator: angleGenerator, imports: "import CGUUnits")
        )
        let accelerationGenerator = AccelerationTestGenerator()
        let accelerationFileCreator = TestFileCreator<AccelerationTestGenerator>()
        writeFile(
            at: path,
            with: "AccelerationTests",
            and: accelerationFileCreator.tests(
                generator: accelerationGenerator, imports: "import CGUUnits"
            )
        )
    }

    // swiftlint:enable function_body_length

    /// Generate the swift source files for guunits.
    /// - Parameter path: The path to the directory containing the new files.
    public func generateSwiftFiles(in path: URL) {
        // guard !path.isFileURL else {
        //     fatalError("Path is not a valid directory.")
        // }
        print("Writing Swift files to \(path.absoluteString)...")
        let swiftFileCreator = SwiftFileCreator()
        writeFile(
            at: path, with: DistanceUnits.category, and: swiftFileCreator.generate(for: DistanceUnits.self)
        )
        writeFile(
            at: path, with: TimeUnits.category, and: swiftFileCreator.generate(for: TimeUnits.self)
        )
        writeFile(
            at: path, with: AngleUnits.category, and: swiftFileCreator.generate(for: AngleUnits.self)
        )
        writeFile(
            at: path, with: ImageUnits.category, and: swiftFileCreator.generate(for: ImageUnits.self)
        )
        writeFile(
            at: path, with: PercentUnits.category, and: swiftFileCreator.generate(for: PercentUnits.self)
        )
        writeFile(
            at: path,
            with: TemperatureUnits.category,
            and: swiftFileCreator.generate(for: TemperatureUnits.self)
        )
        writeFile(
            at: path,
            with: AccelerationUnits.category,
            and: swiftFileCreator.generate(for: AccelerationUnits.self)
        )
        writeFile(at: path, with: "GUUnitsFloat", and: GUUnitsPrimitiveHelpers.float)
        writeFile(at: path, with: "GUUnitsInteger", and: GUUnitsPrimitiveHelpers.integer)
        writeFile(at: path, with: "GUUnitsType", and: GUUnitsPrimitiveHelpers.type)
        print("Done!")
    }

    /// Generate files that test the swift layer of guunits.
    /// - Parameter path: The folder containing the test files.
    public func generateSwiftTests(in path: URL) {
        let swiftFileCreator = SwiftTestFileCreator()
        writeFile(
            at: path, with: "\(DistanceUnits.category)Tests", and: swiftFileCreator.generate(
                with: GradualTestGenerator<DistanceUnits>(
                    unitDifference: [
                        .millimetres: 10,
                        .centimetres: 100
                    ]
                )
            )
        )
        writeFile(
            at: path, with: "\(TimeUnits.category)Tests", and: swiftFileCreator.generate(
                with: GradualTestGenerator<TimeUnits>(
                    unitDifference: [
                        .microseconds: 1000,
                        .milliseconds: 1000
                    ]
                )
            )
        )
        writeFile(
            at: path,
            with: "\(AngleUnits.category)Tests",
            and: swiftFileCreator.generate(with: AngleTestGenerator())
        )
        writeFile(
            at: path,
            with: "\(ImageUnits.category)Tests",
            and: swiftFileCreator.generate(with: SameUnitTestGenerator<ImageUnits>())
        )
        writeFile(
            at: path,
            with: "\(PercentUnits.category)Tests",
            and: swiftFileCreator.generate(with: SameUnitTestGenerator<PercentUnits>())
        )
        writeFile(
            at: path,
            with: "\(TemperatureUnits.category)Tests",
            and: swiftFileCreator.generate(with: TemperatureTestGenerator())
        )
        writeFile(
            at: path,
            with: "\(AccelerationUnits.category)Tests",
            and: swiftFileCreator.generate(with: AccelerationTestGenerator())
        )
    }

    /// Write a Swift source file to a location.
    /// - Parameters:
    ///   - path: The URL of the source file.
    ///   - name: The name of the file.
    ///   - contents: The contents of the file.
    private func writeFile(at path: URL, with name: String, and contents: String) {
        fileManager.createFile(
            atPath: path.appendingPathComponent("\(name).swift", isDirectory: false).path,
            contents: contents.data(using: .utf8)
        )
    }

}
