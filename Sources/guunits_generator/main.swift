print("Hello, world!")

let generator = DistanceUnitsGenerator()

print(generator.generate(forUnits: Array(DistanceUnits.allCases)) ?? "")
