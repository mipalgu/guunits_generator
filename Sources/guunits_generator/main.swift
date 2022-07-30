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

private func generate() throws {
    guard let currentDirectory = URL(string: FileManager().currentDirectoryPath) else {
        fatalError("Failed to find current directory.")
    }
    let generator = GUUnitsGenerator()
    try generator.generateCFiles(in: currentDirectory)
    generator.generateSwiftFiles(in: currentDirectory)
}

try generate()
