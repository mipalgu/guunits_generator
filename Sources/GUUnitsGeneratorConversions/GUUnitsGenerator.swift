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

public struct GUUnitsGenerator {

    public init() {}

    public func generateCFiles(in path: URL) throws {
        guard !path.isFileURL else {
            fatalError("Path is not a valid directory.")
        }
        var hFile = path
        var cFile = path
        print("Creating urls to source files.")
        hFile.appendPathComponent("guunits.h", isDirectory: false)
        cFile.appendPathComponent("guunits.c", isDirectory: false)
        print("Done")
        print("Resource is reachable.")
        let distanceGenerator = AnyGenerator(
            generating: DistanceUnits.self,
            using: DistanceUnitsGenerator(unitDifference: [
                .millimetres: 10,
                .centimetres: 100
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
        let fileContents = HeaderCreator().generate(
            generators: [
                distanceGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator
            ]
        )
        .data(using: .utf8)
        let fileManager = FileManager()
        print("Writing H-file to path \(hFile.absoluteString)...")
        fileManager.createFile(atPath: hFile.absoluteString, contents: fileContents)
        print("Done!\nWriting C-File to path \(cFile.absoluteString)...")
        let cContents = CFileCreator().generate(
            generators: [
                distanceGenerator,
                timeGenerator,
                angleGenerator,
                imageGenerator,
                percentGenerator,
                temperatureGenerator
            ]
        )
        .data(using: .utf8)
        // if fileManager.fileExists(atPath: cFile.absoluteString) {
        //     try fileManager.removeItem(atPath: cFile.absoluteString)
        // }
        fileManager.createFile(atPath: cFile.absoluteString, contents: cContents)
        print("Done!")
    }

    public func generateSwiftFiles(in path: URL) throws {
        guard !path.isFileURL else {
            fatalError("Path is not a valid directory.")
        }
        let swiftFileCreator = SwiftFileCreator()
        try swiftFileCreator.generate(for: DistanceUnits.self)
            .write(toFile: DistanceUnits.category + ".swift", atomically: true, encoding: .utf8)
        try swiftFileCreator.generate(for: TimeUnits.self)
            .write(toFile: TimeUnits.category + ".swift", atomically: true, encoding: .utf8)
        try swiftFileCreator.generate(for: AngleUnits.self)
            .write(toFile: AngleUnits.category + ".swift", atomically: true, encoding: .utf8)
        try swiftFileCreator.generate(for: ImageUnits.self)
            .write(toFile: ImageUnits.category + ".swift", atomically: true, encoding: .utf8)
        try swiftFileCreator.generate(for: PercentUnits.self)
            .write(toFile: PercentUnits.category + ".swift", atomically: true, encoding: .utf8)
        try swiftFileCreator.generate(for: TemperatureUnits.self)
            .write(toFile: TemperatureUnits.category + ".swift", atomically: true, encoding: .utf8)
    }

}
