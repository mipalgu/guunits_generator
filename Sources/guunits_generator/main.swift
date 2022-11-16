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

/// Generate the source code for the guunits package.
/// - Parameter directory: The folder to create the package in.
private func generate(directory: URL? = nil) throws {
    let fileManager = FileManager()
    let directory = directory ?? URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
    guard directory.hasDirectoryPath else {
        fatalError("Path is an invalid directory.")
    }
    let generator = GUUnitsGenerator()
    let sources = directory.appendingPathComponent("Sources", isDirectory: true)
    let tests = directory.appendingPathComponent("Tests", isDirectory: true)
    try fileManager.removeItem(at: tests)
    try fileManager.removeItem(at: sources)
    try fileManager.createDirectory(atPath: tests.path, withIntermediateDirectories: true)
    try fileManager.createDirectory(atPath: sources.path, withIntermediateDirectories: true)
    try generator.generateCFiles(in: sources.appendingPathComponent("CGUUnits", isDirectory: true))
    try generator.generateSwiftFiles(in: sources.appendingPathComponent("GUUnits", isDirectory: true))
    try generator.generateCTests(in: tests.appendingPathComponent("CGUUnitsTests", isDirectory: true))
    try generator.generateSwiftTests(in: tests.appendingPathComponent("GUUnitsTests", isDirectory: true))
    try generator.generatePackageSwift(in: directory)
}

/// Main method for generating the guunits sources.
private func main() throws {
    let argc = CommandLine.argc
    let arguments = CommandLine.arguments
    guard argc == 2, arguments.count > 1, arguments[1] == "-h" || arguments[1] == "--help" else {
        try generate()
        return
    }
    let helpText = """
    guunits_generator

    Usage:
    guunits_generator [-h]

    Generate the GUUnits package inside the current directory.
    """
    print(helpText)
}

/// Run main.
try main()
