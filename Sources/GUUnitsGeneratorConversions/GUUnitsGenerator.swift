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

    /// The Package.swift file contents.
    private var package: String {
        """
        // swift-tools-version: 5.6
        // The swift-tools-version declares the minimum version of Swift required to build this package.

        import PackageDescription

        /// Package description.
        let package = Package(
            name: "GUUnits",
            products: [
                // Products define the executables and libraries a package produces, and make them visible
                // to other packages.
                .library(
                    name: "guunits",
                    type: .dynamic,
                    targets: ["CGUUnits"]
                ),
                .library(name: "GUUnits", targets: ["CGUUnits", "GUUnits"])
            ],
            dependencies: [
                // Dependencies declare other packages that this package depends on.
                // .package(url: /* package url */, from: "1.0.0"),
                .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
            ],
            targets: [
                // Targets are the basic building blocks of a package.
                // A target can define a module or a test suite.
                // Targets can depend on other targets in this package, and on products in packages
                // this package depends on.
                .target(
                    name: "CGUUnits",
                    dependencies: []
                ),
                .target(
                    name: "GUUnits",
                    dependencies: ["CGUUnits"]
                ),
                .testTarget(
                    name: "CGUUnitsTests",
                    dependencies: ["CGUUnits"]
                ),
                .testTarget(
                    name: "GUUnitsTests",
                    dependencies: ["GUUnits"]
                )
            ]
        )

        """
    }

    /// Default init.
    public init() {}

    /// Creates the Package.swift file in the folder pointed to by path.
    /// - Parameter path: A URL to the folder containing the Package.swift file.
    public func generatePackageSwift(in path: URL) {
        writeFile(at: path, with: "Package", and: package)
    }

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
        let massGenerator = AnyGenerator(
            generating: MassUnits.self, using: MassUnitsGenerator(unitDifference: [
                .microgram: 1000,
                .milligram: 1000,
                .gram: 1000,
                .kilogram: 1000
            ])
        )
        let velocityGenerator = AnyGenerator(generating: Velocity.self, using: OperationalGenerator())
        let fileContents = HeaderCreator().generate(
            generators: [
                distanceGenerator,
                currentGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator,
                accelerationGenerator,
                massGenerator,
                velocityGenerator
            ]
        )
        .data(using: .utf8)
        print("Writing H-file to path \(hFile.absoluteString)...")
        fflush(stdout)
        fileManager.createFile(atPath: hFile.path, contents: fileContents)
        print("Done!\nWriting C-File to path \(cFile.absoluteString)...")
        fflush(stdout)
        let cContents = CFileCreator().generate(
            generators: [
                distanceGenerator,
                currentGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator,
                accelerationGenerator,
                massGenerator,
                velocityGenerator
            ]
        )
        .data(using: .utf8)
        fileManager.createFile(atPath: cFile.path, contents: cContents)
        print("Done!")
    }

    /// Create the C Test files at a specific location.
    /// - Parameter path: The path to the folder that will contain the test files.
    public func generateCTests(in path: URL) {
        // guard !path.isFileURL else {
        //     fatalError("Path is not a valid directory.")
        // }
        print("Creating C Test code in path \(path.absoluteString)...")
        fflush(stdout)
        let fileCreator = TestFileCreator<TemperatureTestGenerator>()
        let testGenerator = TemperatureTestGenerator()
        createTestFiles(
            at: path, with: fileCreator.tests(generator: testGenerator, imports: "import CGUUnits")
        )
        let distanceGenerator = GradualTestGenerator<DistanceUnits>(unitDifference: [
            .millimetres: 10,
            .centimetres: 100
        ])
        let distanceFileCreator = TestFileCreator<GradualTestGenerator<DistanceUnits>>()
        createTestFiles(
            at: path,
            with: distanceFileCreator.tests(generator: distanceGenerator, imports: "import CGUUnits")
        )
        let massGenerator = GradualTestGenerator<MassUnits>(unitDifference: [
            .microgram: 1000,
            .milligram: 1000,
            .gram: 1000,
            .kilogram: 1000
        ])
        let massFileCreator = TestFileCreator<GradualTestGenerator<MassUnits>>()
        createTestFiles(
            at: path, with: massFileCreator.tests(generator: massGenerator, imports: "import CGUUnits")
        )
        let currentGenerator = GradualTestGenerator<CurrentUnits>(unitDifference: [
            .microamperes: 1000,
            .milliamperes: 1000
        ])
        let currentFileCreator = TestFileCreator<GradualTestGenerator<CurrentUnits>>()
        createTestFiles(
            at: path,
            with: currentFileCreator.tests(generator: currentGenerator, imports: "import CGUUnits")
        )
        let imageGenerator = SameUnitTestGenerator<ImageUnits>()
        let imageFileCreator = TestFileCreator<SameUnitTestGenerator<ImageUnits>>()
        createTestFiles(
            at: path, with: imageFileCreator.tests(generator: imageGenerator, imports: "import CGUUnits")
        )
        let percentGenerator = SameUnitTestGenerator<PercentUnits>()
        let percentFileCreator = TestFileCreator<SameUnitTestGenerator<PercentUnits>>()
        createTestFiles(
            at: path, with: percentFileCreator.tests(generator: percentGenerator, imports: "import CGUUnits")
        )
        let timeGenerator = GradualTestGenerator<TimeUnits>(unitDifference: [
            .microseconds: 1000,
            .milliseconds: 1000
        ])
        let timeFileCreator = TestFileCreator<GradualTestGenerator<TimeUnits>>()
        createTestFiles(
            at: path, with: timeFileCreator.tests(generator: timeGenerator, imports: "import CGUUnits")
        )
        let angleGenerator = AngleTestGenerator()
        let angleFileCreator = TestFileCreator<AngleTestGenerator>()
        createTestFiles(
            at: path, with: angleFileCreator.tests(generator: angleGenerator, imports: "import CGUUnits")
        )
        let accelerationGenerator = AccelerationTestGenerator()
        let accelerationFileCreator = TestFileCreator<AccelerationTestGenerator>()
        createTestFiles(
            at: path,
            with: accelerationFileCreator.tests(generator: accelerationGenerator, imports: "import CGUUnits")
        )
        print("Done!")
        fflush(stdout)
    }

    // swiftlint:enable function_body_length

    /// Generate the swift source files for guunits.
    /// - Parameter path: The path to the directory containing the new files.
    public func generateSwiftFiles(in path: URL) {
        // guard !path.isFileURL else {
        //     fatalError("Path is not a valid directory.")
        // }
        print("Writing Swift files in path \(path.absoluteString)...")
        fflush(stdout)
        let swiftFileCreator = SwiftFileCreator()
        writeFile(
            at: path, with: DistanceUnits.category, and: swiftFileCreator.generate(for: DistanceUnits.self)
        )
        writeFile(
            at: path, with: CurrentUnits.category, and: swiftFileCreator.generate(for: CurrentUnits.self)
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
        writeFile(at: path, with: MassUnits.category, and: swiftFileCreator.generate(for: MassUnits.self))
        writeFile(at: path, with: Velocity.category, and: swiftFileCreator.generate(for: Velocity.self))
        writeFile(at: path, with: "GUUnitsFloat", and: GUUnitsPrimitiveHelpers.float)
        writeFile(at: path, with: "GUUnitsInteger", and: GUUnitsPrimitiveHelpers.integer)
        writeFile(at: path, with: "GUUnitsType", and: GUUnitsPrimitiveHelpers.type)
        print("Done!")
        fflush(stdout)
    }

    // swiftlint:disable function_body_length

    /// Generate files that test the swift layer of guunits.
    /// - Parameter path: The folder containing the test files.
    public func generateSwiftTests(in path: URL) {
        print("Creating Swift test code in path \(path.absoluteString)...")
        fflush(stdout)
        let swiftFileCreator = SwiftTestFileCreator()
        createTestFiles(at: path, with: swiftFileCreator.generate(
            with: GradualTestGenerator<DistanceUnits>(
                unitDifference: [
                    .millimetres: 10,
                    .centimetres: 100
                ]
            )
        ))
        createTestFiles(at: path, with: swiftFileCreator.generate(
            with: GradualTestGenerator<CurrentUnits>(
                unitDifference: [
                    .microamperes: 1000,
                    .milliamperes: 1000
                ]
            )
        ))
        createTestFiles(at: path, with: swiftFileCreator.generate(
            with: GradualTestGenerator<TimeUnits>(
                unitDifference: [
                    .microseconds: 1000,
                    .milliseconds: 1000
                ]
            )
        ))
        createTestFiles(at: path, with: swiftFileCreator.generate(with: AngleTestGenerator()))
        createTestFiles(at: path, with: swiftFileCreator.generate(with: SameUnitTestGenerator<ImageUnits>()))
        createTestFiles(
            at: path, with: swiftFileCreator.generate(with: SameUnitTestGenerator<PercentUnits>())
        )
        createTestFiles(at: path, with: swiftFileCreator.generate(with: TemperatureTestGenerator()))
        createTestFiles(at: path, with: swiftFileCreator.generate(with: AccelerationTestGenerator()))
        createTestFiles(
            at: path,
            with: swiftFileCreator.generate(
                with: GradualTestGenerator<MassUnits>(
                    unitDifference: [
                        .microgram: 1000,
                        .milligram: 1000,
                        .gram: 1000,
                        .kilogram: 1000
                    ]
                )
            )
        )
        print("Done!")
        fflush(stdout)
    }

    /// Writes the test files to the correct path.
    /// - Parameters:
    ///   - path: The path containing the files.
    ///   - tests: The tests as an array of tuples containing the file name and the test code.
    private func createTestFiles(at path: URL, with tests: [(String, String)]) {
        tests.forEach {
            writeFile(at: path, with: $0, and: $1)
        }
    }

    // swiftlint:enable function_body_length

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
