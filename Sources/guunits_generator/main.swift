import Foundation

let distanceGenerator = DistanceUnitsGenerator(unitDifference: [
    .millimetres: 10,
    .centimetres: 100
])

let timeGenerator = TimeUnitsGenerator(unitDifference: [
    .microseconds: 1000,
    .milliseconds: 1000
])

let angleGenerator = AngleUnitsGenerator()

do {
    try HeaderCreator().generate(
            distanceGenerator: distanceGenerator,
            timeGenerator: timeGenerator,
            angleGenerator: angleGenerator
        ).write(
            to: URL(fileURLWithPath: "guunits.h", isDirectory: false),
            atomically: false,
            encoding: .utf8
        )
    try CFileCreator().generate(
            distanceGenerator: distanceGenerator,
            timeGenerator: timeGenerator,
            angleGenerator: angleGenerator
        ).write(
            to: URL(fileURLWithPath: "guunits.c", isDirectory: false),
            atomically: false,
            encoding: .utf8
        )
} catch (let e) {
    fatalError("\(e)")
}
