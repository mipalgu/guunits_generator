print("Hello, world!")

let distanceGenerator = DistanceUnitsGenerator(unitDifference: [
    .millimetres: 10,
    .centimetres: 100
])

let timeGenerator = TimeUnitsGenerator(unitDifference: [
    .microseconds: 1000,
    .milliseconds: 1000
])

print(distanceGenerator.generate(forUnits: Array(DistanceUnits.allCases)) ?? "")
print(timeGenerator.generate(forUnits: Array(TimeUnits.allCases)) ?? "")
