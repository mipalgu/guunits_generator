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

private func generate(directory: URL? = URL(string: FileManager().currentDirectoryPath)) throws {
    guard let directory = directory else {
        fatalError("Failed to find current directory.")
    }
    let generator = GUUnitsGenerator()
    try generator.generateCFiles(in: directory)
    generator.generateSwiftFiles(in: directory)
}

private func main() throws {
    var path: String?
    let argc = CommandLine.argc
    let arguments = CommandLine.arguments
    if argc == 2 && arguments.count > 1 && arguments[1] == "-h" || arguments[1] == "--help" {
        print("guunits_generator\n\nUsage: guunits_generator [-h] [-d <directory>]")
        return
    }
    guard argc > 1 else {
        try generate()
        return
    }
    arguments.indices.forEach {
        let argument = arguments[$0]
        guard $0 < argc - 1 else {
            return
        }
        if argument == "-d" || argument == "--directory" {
            path = arguments[$0 + 1]
        }
    }
    guard let unwrappedPath = path, let url = URL(string: unwrappedPath) else {
        try generate()
        return
    }
    try generate(directory: url)
}

try main()
