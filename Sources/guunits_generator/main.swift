import Foundation
import GUUnitsGeneratorConversions

/// The distance generator.
let distanceGenerator = DistanceUnitsGenerator(unitDifference: [
    .millimetres: 10,
    .centimetres: 100
])

/// The time generator.
let timeGenerator = TimeUnitsGenerator(unitDifference: [
    .microseconds: 1000,
    .milliseconds: 1000
])

/// The angle generator.
let angleGenerator = AngleUnitsGenerator()

/// The image generator.
let imageGenerator = ImageUnitsGenerator(unitDifference: [:])

/// The percent Generator.
let percentGenerator = PercentUnitGenerator(unitDifference: [:])

// C++ Variants
/// The CPP header distance generator.
let cppHeaderDistanceGenerator = CPPDistanceUnitsGenerator()

/// The cpp header time generator.
let cppHeaderTimeGenerator = CPPTimeUnitsGenerator()

/// The cpp header angle generator.
let cppHeaderAngleGenerator = CPPAngleUnitsGenerator()

/// The cpp distance generator.
let cppDistanceGenerator = CPPDistanceUnitsGenerator(
    definitionCreator: CPPFunctionDefinitionCreator(namespace: "GU::")
)

/// The cpp time generator.
let cppTimeGenerator = CPPTimeUnitsGenerator(
    definitionCreator: CPPFunctionDefinitionCreator(namespace: "GU::")
)

/// The cpp angle generator.
let cppAngleGenerator = CPPAngleUnitsGenerator(
    definitionCreator: CPPFunctionDefinitionCreator(namespace: "GU::")
)

/// The file creator for swift types.
let swiftFileCreator = SwiftFileCreator()

do {
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
} catch let e {
    fatalError("Unable to write swift file: \(e)")
}

do {
    try HeaderCreator().generate(
            distanceGenerator: distanceGenerator,
            timeGenerator: timeGenerator,
            angleGenerator: angleGenerator,
            imageGenerator: imageGenerator,
            percentGenerator: percentGenerator
        )
        .write(
            to: URL(fileURLWithPath: "guunits.h", isDirectory: false),
            atomically: false,
            encoding: .utf8
        )
    try CFileCreator().generate(
            distanceGenerator: distanceGenerator,
            timeGenerator: timeGenerator,
            angleGenerator: angleGenerator,
            imageGenerator: imageGenerator,
            percentGenerator: percentGenerator
        )
        .write(
            to: URL(fileURLWithPath: "guunits.c", isDirectory: false),
            atomically: false,
            encoding: .utf8
        )
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
} catch let e {
    fatalError("\(e)")
}
