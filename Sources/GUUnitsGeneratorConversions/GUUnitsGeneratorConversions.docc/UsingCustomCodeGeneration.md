# Using Custom Code Generation

This document provides a guide for creating custom source and test generation for a unit category that requires
custom conversion functions.

## Overview

Before reading this guide, please read the [Getting Started](gettingstarted) and [Creating New Units](creatingnewunits)
guides.

This guide will focus on creating types that conform to ``FunctionBodyCreator`` for source generation and ``TestGenerator``
for test generation. We will be using the `Angle` category for this example. An `Angle` can be represented as either
degrees or radians. Our unit category needs to be able to convert between the 2 in a type-safe manner.

## Defining the Unit

The first step in creating a new unit is to define the unit category.

```swift
/// A unit that represents angles.
public enum AngleUnits: String {

    /// An angle represented in degrees.
    case degrees

    /// An angle represented in radians.
    case radians

}

/// UnitProtocol conformance.
extension AngleUnits: UnitProtocol {

    /// The abbreviation of the unit.
    public var abbreviation: String {
        switch self {
        case .degrees:
            return "deg"
        case .radians:
            return "rad"
        }
    }

    /// The description of the unit.
    public var description: String {
        self.rawValue
    }

}
```

## Source Generation

The conversion between degrees and radians is `degrees = radians * 180 / π`, and `radians = degrees * π / 180`.
To implement this conversion, we will need to provide a custom ``FunctionBodyCreator``. We will call it
`AngleFunctionCreator` and provide the `createFunction` method from the protocol. This method defines
the `C` code for the function body that performs the conversion. This method needs to provide appropriate
code for all combinations of unit conversions. In our case, this is simply degrees to radians and radians
to degrees. In addition to this conversion, we also need to support conversion from the different unit
``Signs``, i.e. `degrees_t` to `degrees_f` or `degrees_u` to `radians_d` for example. The `C` implementation
must also check for potential overflows and clamp the values at their maximum and minimum when this occurs.

For a sign conversion with the same unit type (eg. `degrees_f` to `degrees_d`), we provide a helper struct
called ``SignConverter`` that will generate the code that correctly performs this conversion. The code that
generates the `C` conversion for the angle conversions is shown below.

```swift
/// Struct that defines conversion functions between angle units.
public struct AngleFunctionCreator: FunctionBodyCreator {

    /// Helper object used to create sign conversion functions.
    private let signConverter = SignConverter()

    /// Default init.
    public init() {}

    // swiftlint:disable function_body_length

    /// Generates C-code that will perform a cast between different angle units.
    /// - Parameters:
    ///   - unit: The unit to convert from.
    ///   - otherUnit: The unit to convert to.
    ///   - sign: The sign of the first unit.
    ///   - otherSign: The sign of the second unit.
    /// - Returns: Generated C-code that performs the conversion.
    public func createFunction(
        unit: AngleUnits, to otherUnit: AngleUnits, sign: Signs, otherSign: Signs
    ) -> String {
        switch (unit, otherUnit) {
        case (.degrees, .radians):
            guard otherSign != .d else {
                return "    return ((radians_d) (((double) (\(unit))) / 180.0 * M_PI));"
            }
            let max = "((double) (\(otherSign.numericType.limits.1)))"
            let min = "((double) (\(otherSign.numericType.limits.0)))"
            let roundString: String
            if otherSign.isFloatingPoint {
                roundString = "((radians_\(otherSign)) (castedValue / 180.0 * M_PI))"
            } else {
                roundString = "((radians_\(otherSign)) (round(castedValue / 180.0 * M_PI)))"
            }
            return """
                const double maxValue = \(max) / M_PI * 180.0;
                const double minValue = \(min) / M_PI * 180.0;
                const double castedValue = ((double) (\(unit)));
                if (castedValue > maxValue) {
                    return \(otherSign.numericType.limits.1);
                }
                if (castedValue < minValue) {
                    return \(otherSign.numericType.limits.0);
                }
                return \(roundString);
            """
        case (.radians, .degrees):
            let max = "((double) (\(otherSign.numericType.limits.1))) / 180.0 * M_PI"
            let min = "((double) (\(otherSign.numericType.limits.0))) / 180.0 * M_PI"
            let roundString: String
            if otherSign.isFloatingPoint {
                roundString = "((degrees_\(otherSign)) (castedValue / M_PI * 180.0))"
            } else {
                roundString = "((degrees_\(otherSign)) (round(castedValue / M_PI * 180.0)))"
            }
            return """
                const double maxValue = \(max);
                const double minValue = \(min);
                const double castedValue = ((double) (\(unit)));
                if (castedValue > maxValue) {
                    return \(otherSign.numericType.limits.1);
                }
                if (castedValue < minValue) {
                    return \(otherSign.numericType.limits.0);
                }
                return \(roundString);
            """
        default:
            return self.castFunc(forUnit: unit, sign: sign, otherSign: otherSign)
        }
    }

    // swiftlint:enable function_body_length

    /// Generates a standard sign conversion for identical unit types.
    /// - Parameters:
    ///   - unit: The unit to change sign.
    ///   - sign: The sign of the unit.
    ///   - otherSign: The sign to change into.
    /// - Returns: The generated C-code that performs the sign conversion.
    func castFunc(forUnit unit: Unit, sign: Signs, otherSign: Signs) -> String {
        "    return \(self.signConverter.convert("\(unit)", otherUnit: unit, from: sign, to: otherSign));"
    }

    /// Function that indicates whether a round operation needs to happen during a conversion.
    /// - Parameters:
    ///   - sign: The sign of the first parameter.
    ///   - otherSign: The sign of the second parameter.
    /// - Returns: Whether a round operation needs to occur.
    private func shouldRound(from sign: Signs, to otherSign: Signs) -> Bool {
        (sign == .d || sign == .f) && (otherSign != .d && otherSign != .f)
    }

}
```

We still need to add the extension and `typealias` to ``UnitsGenerator`` for this new type.

```swift
/// AngleUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<
        AngleFunctionCreator,
        CFunctionDefinitionCreator<AngleUnits>,
        NumericTypeConverter
    > {

    /// Initialise using AngleUnits and C conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: AngleFunctionCreator = AngleFunctionCreator(),
        definitionCreator: CFunctionDefinitionCreator<AngleUnits> = CFunctionDefinitionCreator(),
        numericConverter: NumericTypeConverter = NumericTypeConverter(),
        helpers: FunctionHelpers<Creator.Unit> = FunctionHelpers<Creator.Unit>()
    ) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: bodyCreator,
            definitionCreator: definitionCreator,
            numericConverter: numericConverter
        ))
    }

}

/// Angle Units Generator.
public typealias AngleUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        AngleFunctionCreator,
        CFunctionDefinitionCreator<AngleUnits>,
        NumericTypeConverter
    >
>
```

## Test Generation

Now we move on to generating the code that will test our generated source code.

Testing this code is incredibly cumbersome, so we have provided protocols with default
implementations in the test target to make this easier. To create tests for your new type,
you will have to conform to ``TestGenerator`` and implement the three functions defined
in that protocol. Each function represents a type of test (unit to unit conversion, unit
to numeric conversion or numeric to unit conversion). The purpose of these functions is to
generate an array of input to output relations using ``TestParameters`` for each conversion.
The generator code may then take these relations and generate `XCTest` test cases. The
extensions of ``TestGenerator`` provide functions called `defaultParameters` that provide
the default implemntation for the numeric conversions. You will need to delegate to these
functions in your conformance if you wish to use the default parameters. Using the default
parameters should be sufficient for the numeric conversions. Our new test generator
will look like the code below to begin with.

```swift
struct AngleTestGenerator: TestGenerator {

    typealias UnitType = AngleUnits

    func testParameters(
        from unit: AngleUnits, with sign: Signs, to otherUnit: AngleUnits, with otherSign: Signs
    ) -> [TestParameters] {
        // Need to implement...
    }

    func testParameters(
        from unit: AngleUnits, with sign: Signs, to numeric: NumericTypes
    ) -> [TestParameters] {
        self.defaultParameters(from: unit, with: sign, to: numeric)
    }

    func testParameters(
        from numeric: NumericTypes, to unit: AngleUnits, with sign: Signs
    ) -> [TestParameters] {
        self.defaultParameters(from: numeric, to: unit, with: sign)
    }

}
```

Now, if we wanted to test a conversion from a `degrees_t` value of *180 degrees* to `radians_t`,
we would introduce a test parameter in our new test generator.

```swift
struct AngleTestGenerator: TestGenerator {

    typealias UnitType = AngleUnits

    func testParameters(
        from unit: AngleUnits, with sign: Signs, to otherUnit: AngleUnits, with otherSign: Signs
    ) -> [TestParameters] {
        var testParameters: [TestParameters] = []
        if unit == .degrees && sign == .t && otherUnit == .radians && otherSign == .t {
            testParameters += [TestParameters(input: "180", output: "3")]
        }
        return testParameters
    }

    func testParameters(
        from unit: AngleUnits, with sign: Signs, to numeric: NumericTypes
    ) -> [TestParameters] {
        self.defaultParameters(from: unit, with: sign, to: numeric)
    }

    func testParameters(
        from numeric: NumericTypes, to unit: AngleUnits, with sign: Signs
    ) -> [TestParameters] {
        self.defaultParameters(from: numeric, to: unit, with: sign)
    }

}
```

You can see how this process can be incredibly cumbersome. You should try and test the edge cases by using the
limits of the underlying numeric types (eg. `Signs.t.numericType.swiftType.limits`).

Please look at the `AngleTestGenerator` tests in the test target for the code that tests this struct.

## Performing Code Generation with the New Type

Now we will alter the top-level generator to include our new custom type. The top-level module that performs the
code generation is ``GUUnitsGenerator`` and provides functions for generating the C and Swift code for `GUUnits`.
Seen below is the code that you will need to add to ``GUUnitsGenerator`` to perform the code generation of the
new unit. You will need to modify the `generateCFiles`, `generateCTests`, `generateSwiftFiles` and
`generateSwiftTests` functions. You will need to use the existing structs for generating the different source and
test files, namely ``HeaderCreator``, ``CFileCreator``, ``TestFileCreator``, ``SwiftFileCreator``,
``SwiftTestFileCreator`` and ``AnyGenerator``.

```swift
import Foundation

public struct GUUnitsGenerator {

    let fileManager = FileManager()

    public func generateCFiles(in path: URL) throws {
        var hFile = path
        var cFile = path
        hFile.appendPathComponent("include", isDirectory: true)
        if !fileManager.fileExists(atPath: hFile.path) {
            try fileManager.createDirectory(atPath: hFile.path, withIntermediateDirectories: true)
        }
        hFile.appendPathComponent("guunits.h", isDirectory: false)
        cFile.appendPathComponent("guunits.c", isDirectory: false)
        
        // New Code:
        
        let angleGenerator = AnyGenerator(generating: AngleUnits.self, using: AngleUnitsGenerator())
        let fileContents = HeaderCreator().generate(
            generators: [
                angleGenerator,
                // other generators...
            ]
        )
        .data(using: .utf8)
        fileManager.createFile(atPath: hFile.path, contents: fileContents)
        let cContents = CFileCreator().generate(
            generators: [
                angleGenerator,
                // other generators...
            ]
        )
        .data(using: .utf8)
        fileManager.createFile(atPath: cFile.path, contents: cContents)
    }

    public func generateCTests(in path: URL) {
        let angleGenerator = AngleTestGenerator()
        let angleFileCreator = TestFileCreator<AngleTestGenerator>()
        createTestFiles(
            at: path, with: angleFileCreator.tests(generator: angleGenerator, imports: "import CGUUnits")
        )
        // other test generators...
    }

    public func generateSwiftFiles(in path: URL) {
        let swiftFileCreator = SwiftFileCreator()
        writeFile(
            at: path, with: AngleUnits.category, and: swiftFileCreator.generate(for: AngleUnits.self)
        )
        // other units...
    }

    public func generateSwiftTests(in path: URL) {
        let swiftFileCreator = SwiftTestFileCreator()
        createTestFiles(at: path, with: swiftFileCreator.generate(with: AngleTestGenerator()))
        // other units...
    }

    // End new code.

    private func createTestFiles(at path: URL, with tests: [(String, String)]) {
        tests.forEach {
            writeFile(at: path, with: $0, and: $1)
        }
    }

    private func writeFile(at path: URL, with name: String, and contents: String) {
        fileManager.createFile(
            atPath: path.appendingPathComponent("\(name).swift", isDirectory: false).path,
            contents: contents.data(using: .utf8)
        )
    }

}

```
