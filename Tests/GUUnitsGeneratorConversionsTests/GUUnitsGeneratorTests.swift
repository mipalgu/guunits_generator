// 
// GUUnitsGeneratorTests.swift 
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
// 

import Foundation
@testable import GUUnitsGeneratorConversions
import XCTest

final class GUUnitsGeneratorTests: XCTestCase {

    let generator = GUUnitsGenerator()

    var packageURL: URL? {
        URL(fileURLWithPath: #filePath, isDirectory: false)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("guunits", isDirectory: true)
        // guard var currentDirectory = URL(string: FileManager().currentDirectoryPath) else {
        //     return nil
        // }
        // if currentDirectory.lastPathComponent != "guunits_generator" {
        //     repeat {
        //         currentDirectory.deleteLastPathComponent()
        //     } while (currentDirectory.lastPathComponent != "guunits_generator"
        //         && !currentDirectory.lastPathComponent.isEmpty
        //     )
        // }
        // guard !currentDirectory.lastPathComponent.isEmpty else {
        //     return nil
        // }
        // return currentDirectory.appendingPathComponent("Tests").appendingPathComponent("guunits")
    }

    var guunitsDirectory: URL? {
        packageURL?.appendingPathComponent("Sources").appendingPathComponent("CGUUnits")
    }

    var swiftGUUnitsDirectory: URL? {
        packageURL?.appendingPathComponent("Sources").appendingPathComponent("swift_GUUnits")
    }

    var guunitsTests: URL? {
        packageURL?.appendingPathComponent("Tests").appendingPathComponent("CGUUnitsTests")
    }

    var swiftGUUnitsTests: URL? {
        packageURL?.appendingPathComponent("Tests").appendingPathComponent("swift_GUUnitsTests")
    }

    func testguunits() throws {
        guard let packageURL = packageURL else {
            XCTFail("Failed to ascertain package path.")
            return
        }
        print("Using package url: \(packageURL.path)")
        try generatePackage()
        fflush(stdout)
        let process = Process()
        process.currentDirectoryURL = packageURL
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env", isDirectory: false)
        process.arguments = ["swift", "test"]
        try process.run()
        process.waitUntilExit()
        XCTAssertEqual(EXIT_SUCCESS, process.terminationStatus)
    }

    private func generatePackage() throws {
        guard
            let guunitsDirectory = guunitsDirectory,
            let swiftGUUnitsDirectory = swiftGUUnitsDirectory,
            let guunitsTests = guunitsTests,
            let swiftGUUnitsTests = swiftGUUnitsTests
        else {
            XCTFail("Failed to ascertain package path.")
            return
        }
        // let guunitsTests = packageURL.appendingPathComponent("Tests/guunitsTests")
        // let swiftTests = packageURL.appendingPathComponent("Tests/swift_GUUnitsTests")
        try generator.generateCFiles(in: guunitsDirectory)
        generator.generateSwiftFiles(in: swiftGUUnitsDirectory)
        generator.generateCTests(in: guunitsTests)
    }

}
