import Foundation
import GUUnitsGeneratorConversions

// // C++ Variants
// /// The CPP header distance generator.
// let cppHeaderDistanceGenerator = CPPDistanceUnitsGenerator()

// /// The cpp header time generator.
// let cppHeaderTimeGenerator = CPPTimeUnitsGenerator()

// /// The cpp header angle generator.
// let cppHeaderAngleGenerator = CPPAngleUnitsGenerator()

// /// The cpp distance generator.
// let cppDistanceGenerator = CPPDistanceUnitsGenerator(
//     definitionCreator: CPPFunctionDefinitionCreator(namespace: "GU::")
// )

// /// The cpp time generator.
// let cppTimeGenerator = CPPTimeUnitsGenerator(
//     definitionCreator: CPPFunctionDefinitionCreator(namespace: "GU::")
// )

// /// The cpp angle generator.
// let cppAngleGenerator = CPPAngleUnitsGenerator(
//     definitionCreator: CPPFunctionDefinitionCreator(namespace: "GU::")
// )

/*try CPPHeaderCreator().generate(
    distanceGenerator: cppHeaderDistanceGenerator,
    timeGenerator: cppHeaderTimeGenerator,
    angleGenerator: cppHeaderAngleGenerator
).write(
    to: URL(fileURLWithPath: "guunits.hpp", isDirectory: false),
    atomically: false,
    encoding: .utf8
)
try CPPFileCreator().generate(
    distanceGenerator: cppDistanceGenerator,
    timeGenerator: cppTimeGenerator,
    angleGenerator: cppAngleGenerator
).write(
    to: URL(fileURLWithPath: "guunits_cpp.cc", isDirectory: false),
    atomically: false,
    encoding: .utf8
)*/

private func generatePackage() {
    guard var currentDirectory = URL(string: FileManager().currentDirectoryPath) else {
        exit(1)
    }
    let packageURL: URL
    if currentDirectory.lastPathComponent != "guunits_generator" {
        repeat {
            currentDirectory.deleteLastPathComponent()
        } while (currentDirectory.lastPathComponent != "guunits_generator"
            && !currentDirectory.lastPathComponent.isEmpty
        )
    }
    packageURL = currentDirectory.appendingPathComponent("Tests").appendingPathComponent("guunits")
    let guunitsDirectory = packageURL.appendingPathComponent("Sources").appendingPathComponent("guunits")
    let swiftGUUnitsDirectory = packageURL
        .appendingPathComponent("Sources")
        .appendingPathComponent("swift_GUUnits")
    // let guunitsTests = packageURL.appendingPathComponent("Tests/guunitsTests")
    // let swiftTests = packageURL.appendingPathComponent("Tests/swift_GUUnitsTests")
    let generator = GUUnitsGenerator()
    generator.generateCFiles(in: guunitsDirectory)
    generator.generateSwiftFiles(in: swiftGUUnitsDirectory)
}

generatePackage()
