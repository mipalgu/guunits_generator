print("Hello, world!")

let distanceGenerator = DistanceUnitsGenerator(unitDifference: [
    .millimetres: 10,
    .centimetres: 100
])

let timeGenerator = TimeUnitsGenerator(unitDifference: [
    .microseconds: 1000,
    .milliseconds: 1000
])

let angleGenerator = AngleUnitsGenerator()

print(distanceGenerator.generateDeclarations(forUnits: Array(DistanceUnits.allCases)) ?? "")
print(timeGenerator.generateDeclarations(forUnits: Array(TimeUnits.allCases)) ?? "")
print(angleGenerator.generateDeclarations(forUnits: Array(AngleUnits.allCases)) ?? "")
