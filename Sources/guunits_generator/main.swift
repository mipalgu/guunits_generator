print("Hello, world!")

let distanceGenerator = DistanceUnitsGenerator<DistanceUnits>(unitDifference: [
    .millimetres: 10,
    .centimetres: 100
])

let timeGenerator = DistanceUnitsGenerator<TimeUnits>(unitDifference: [
    .microseconds: 1000,
    .milliseconds: 1000
])

print(distanceGenerator.generate(forUnits: Array(DistanceUnits.allCases)) ?? "")
print(timeGenerator.generate(forUnits: Array(TimeUnits.allCases)) ?? "")
