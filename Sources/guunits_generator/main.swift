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

let headerCreator = HeaderCreator()
print(headerCreator.generateHeader(distanceGenerator: distanceGenerator, timeGenerator: timeGenerator, angleGenerator: angleGenerator))
