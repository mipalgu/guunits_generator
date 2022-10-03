# Creating New Units

Provides a guide and example for creating new units.

## Overview

This document provides a step-by-step guide for creating new units in this generator. We will use
the `Mass` `SI` units as an example throughout this document. It is assumed that the reader knowns the
basic layout of this package by reading the [Getting Started](gettingstarted). We have provided an
[additional guide](usingcustomcodegeneration) for units that don't use the `SI` prefixes.

## Defining the Unit

The first step in creating a new unit is to define the category and the units that exist
within the category. This definition is accomplished through an enum that conforms to
``UnitProtocol``. The cases of the enum will represent the different unit types. For
`Mass`, this will be `micrograms`, `milligrams`, `grams`, `kilograms`, and `Megagrams`:

```swift
/// Unit for representing mass.
public enum MassUnits: String, UnitProtocol {

    /// Micrograms.
    case microgram

    /// Milligrams.
    case milligram

    /// Grams.
    case gram

    /// Kilograms.
    case kilogram

    /// Megagrams or Metric Tonnes.
    case megagram

    /// The abbreviation of the unit.
    public var abbreviation: String {
        switch self {
        case .microgram:
            return "ug"
        case .milligram:
            return "mg"
        case .gram:
            return "g"
        case .kilogram:
            return "kg"
        case .megagram:
            return "Mg"
        }
    }

    /// The string equivalent value of the unit.
    public var description: String {
        self.rawValue
    }

}
```

The `abbreviation` computed property represents the unit notation version of the unit. For `Mass`
this will be `ug`, `mg`, `g`, `kg`, and `Mg` for `micrograms`, `milligrams`, `grams`, `kilograms`,
and `Megagrams` respectively.

We have provided protocols for testing units in the test target. The test code for your unit should
be relatively small. The test code for `Mass` is provided below.

```swift
@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for `MassUnits`.
final class MassUnitsTests: XCTestCase, UnitsTestable {

    /// Test microgram case.
    func testMicrogram() {
        assert(
            value: MassUnits.microgram, rawValue: "microgram", abbreviation: "ug", description: "microgram"
        )
    }

    /// Test milligram case.
    func testMilligram() {
        assert(
            value: MassUnits.milligram, rawValue: "milligram", abbreviation: "mg", description: "milligram"
        )
    }

    /// Test gram case.
    func testGram() {
        assert(
            value: MassUnits.gram, rawValue: "gram", abbreviation: "g", description: "gram"
        )
    }

    /// Test kilogram case.
    func testKilogram() {
        assert(
            value: MassUnits.kilogram, rawValue: "kilogram", abbreviation: "kg", description: "kilogram"
        )
    }

    /// Test megagram case.
    func testMegaGram() {
        assert(
            value: MassUnits.megagram, rawValue: "megagram", abbreviation: "Mg", description: "megagram"
        )
    }

}
```

## Defining the Conversion Functions

In order to provide the implementation for conversions between units, you must implement a ``FunctionBodyCreator``.
This protocol requires a simple method for converting between unit types. If you are creating an `SI` based unit
or one that uses a simple multiplication or division operation with a scale factor, then you can use the
``GradualFunctionCreator``. All of the units defined in our `Mass` category are `SI` units, therefore we
can use this function creator.

The top level converter that creates the `C` source and header files is called ``UnitsGenerator``. To use the
``GradualFunctionCreator`` for our function implementations, we can add an extension and
`typealias` onto ``UnitsGenerator`` to make this easy.

```swift
/// MassUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<MassUnits>,
    CFunctionDefinitionCreator<MassUnits>, NumericTypeConverter> {

    /// Initialise using MassUnits and c conversions.
    /// - Parameter unitDifference: The magnitude difference between an ordered array
    ///                             of units.
    public init(unitDifference: [Creator.Unit: Int]) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: GradualFunctionCreator(unitDifference: unitDifference),
            definitionCreator: CFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

/// Mass Units Generator
public typealias MassUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<MassUnits>,
        CFunctionDefinitionCreator<MassUnits>,
        NumericTypeConverter
    >
>
```

The new extension in ``UnitsGenerator`` provides an initialiser that takes a *unit difference*. This parameter
is a dictionary that represents the multiplicative difference between the unit types. We will demonstrate how
this is used in the coming sections.

You will not need to write any additional tests since this unit uses existing structs.

## Defining the Test Functions

The last key component to generate the new unit is to define the tests for the unit. Since we are using
an `SI` unit, you will not need to write any custom test generation and simply use the provided
``GradualTestGenerator``.

## Putting it all Together

We will now use our new unit to create `C` and `Swift` code in `GUUnits`. We will do this by editing
the ``GUUnitsGenerator`` top-level struct. Currently, ``GUUnitsGenerator`` takes the following form:

```swift

import Foundation

/// Create the source files the C and swift targets of guunits.
public struct GUUnitsGenerator {

    /// The manager that performs the writing.
    let fileManager = FileManager()

    /// The Package.swift file contents.
    private var package: String {
        // Package.swift code.
    }

    /// Default init.
    public init() {}

    /// Creates the Package.swift file in the folder pointed to by path.
    /// - Parameter path: A URL to the folder containing the Package.swift file.
    public func generatePackageSwift(in path: URL) {
        writeFile(at: path, with: "Package", and: package)
    }

    // swiftlint:disable function_body_length

    /// Create all of the C source files at a specific path.
    /// - Parameter path: The path to create files in.
    public func generateCFiles(in path: URL) throws {
        var hFile = path
        var cFile = path
        hFile.appendPathComponent("include", isDirectory: true)
        if !fileManager.fileExists(atPath: hFile.path) {
            try fileManager.createDirectory(atPath: hFile.path, withIntermediateDirectories: true)
        }
        hFile.appendPathComponent("guunits.h", isDirectory: false)
        cFile.appendPathComponent("guunits.c", isDirectory: false)
        // create source generator here.
        let fileContents = HeaderCreator().generate(
            generators: [
                // generators
            ]
        )
        .data(using: .utf8)
        fileManager.createFile(atPath: hFile.path, contents: fileContents)
        let cContents = CFileCreator().generate(
            generators: [
                // generators
            ]
        )
        .data(using: .utf8)
        fileManager.createFile(atPath: cFile.path, contents: cContents)
    }

    /// Create the C Test files at a specific location.
    /// - Parameter path: The path to the folder that will contain the test files.
    public func generateCTests(in path: URL) {
        // create test generator here.
        createTestFiles(
            at: path, with: // generator invokation
        )
    }

    // swiftlint:enable function_body_length

    /// Generate the swift source files for guunits.
    /// - Parameter path: The path to the directory containing the new files.
    public func generateSwiftFiles(in path: URL) {
        let swiftFileCreator = SwiftFileCreator()
        writeFile(
            at: path,
            with: // category,
            and: swiftFileCreator.generate(
                for: // category type
            )
        )
    }

    /// Generate files that test the swift layer of guunits.
    /// - Parameter path: The folder containing the test files.
    public func generateSwiftTests(in path: URL) {
        let swiftFileCreator = SwiftTestFileCreator()
        // create test generator here.
        createTestFiles(at: path, with: swiftFileCreator.generate(
            with: // generator
        ))
    }

    /// Writes the test files to the correct path.
    /// - Parameters:
    ///   - path: The path containing the files.
    ///   - tests: The tests as an array of tuples containing the file name and the test code.
    private func createTestFiles(at path: URL, with tests: [(String, String)]) {
        tests.forEach {
            writeFile(at: path, with: $0, and: $1)
        }
    }

    /// Write a Swift source file to a location.
    /// - Parameters:
    ///   - path: The URL of the source file.
    ///   - name: The name of the file.
    ///   - contents: The contents of the file.
    private func writeFile(at path: URL, with name: String, and contents: String) {
        fileManager.createFile(
            atPath: path.appendingPathComponent("\(name).swift", isDirectory: false).path,
            contents: contents.data(using: .utf8)
        )
    }

}

```

### Source Generation

To generate the `C` source and header file, we will add our generator to the `generateCFiles` function.

```swift
/// Create all of the C source files at a specific path.
/// - Parameter path: The path to create files in.
public func generateCFiles(in path: URL) throws {
    var hFile = path
    var cFile = path
    hFile.appendPathComponent("include", isDirectory: true)
    if !fileManager.fileExists(atPath: hFile.path) {
        try fileManager.createDirectory(atPath: hFile.path, withIntermediateDirectories: true)
    }
    hFile.appendPathComponent("guunits.h", isDirectory: false)
    cFile.appendPathComponent("guunits.c", isDirectory: false)
    // create source generator here.
    let massGenerator = AnyGenerator(
        generating: MassUnits.self,
        using: MassUnitsGenerator(
            unitDifference: [
                .microgram: 1000,
                .milligram: 1000,
                .gram: 1000,
                .kilogram: 1000
            ]
        )
    )
    let fileContents = HeaderCreator().generate(
        generators: [
            massGenerator
        ]
    )
    .data(using: .utf8)
    fileManager.createFile(atPath: hFile.path, contents: fileContents)
    let cContents = CFileCreator().generate(
        generators: [
            massGenerator
        ]
    )
    .data(using: .utf8)
    fileManager.createFile(atPath: cFile.path, contents: cContents)
}
```

You will notice that the generator needs to be type-erased by using the ``AnyGenerator`` struct. Also, we
have added in our unit differences when we created the ``MassUnitsGenerator``. Each of these numbers
represent the difference between 2 types. For example, there is 1000 micrograms in a milligram, 1000
milligrams in a gram, 1000 grams in a kilogram, and 1000 kilograms in a Megagram. The ``GradualFunctionCreator``
will generate all the source code from this unit difference for us.

Now we will add `Swift` source generation by changing the `generateSwiftFiles` function.

```swift
/// Generate the swift source files for guunits.
/// - Parameter path: The path to the directory containing the new files.
public func generateSwiftFiles(in path: URL) {
    let swiftFileCreator = SwiftFileCreator()
    writeFile(
        at: path,
        with: MassUnits.category,
        and: swiftFileCreator.generate(
            for: MassUnits.self
        )
    )
}
```

You will now have `C` and `Swift` source code generation.

### Test Generation

Now we will do the last step which is generating the test code for our new generated source code. To do this,
we will modify the `generateCTests` and `generateSwiftTests` functions to include the existing ``TestGenerator``
and ``TestFileCreator``.

```swift
/// Create the C Test files at a specific location.
/// - Parameter path: The path to the folder that will contain the test files.
public func generateCTests(in path: URL) {
    let massFileCreator = TestFileCreator<GradualTestGenerator<MassUnits>>()
    let massGenerator = GradualTestGenerator<MassUnits>(unitDifference: [
        .microgram: 1000,
        .milligram: 1000,
        .gram: 1000,
        .kilogram: 1000
    ])
    createTestFiles(
        at: path,
        with: massFileCreator.tests(generator: massGenerator, imports: "import CGUUnits")
    )
}

/// Generate files that test the swift layer of guunits.
/// - Parameter path: The folder containing the test files.
public func generateSwiftTests(in path: URL) {
    let swiftFileCreator = SwiftTestFileCreator()
    createTestFiles(
        at: path,
        with: swiftFileCreator.generate(
            with: GradualTestGenerator<MassUnits>(
                unitDifference: [
                    .microgram: 1000,
                    .milligram: 1000,
                    .gram: 1000,
                    .kilogram: 1000
                ]
            )
        )
    )
}
```

## Summary

The entire process for adding additional units can be summarised into 4 easy steps.

1. Define the new unit category with a conformance to ``UnitProtocol``.
2. Create the source code for the conversion functions by conforming to ``FunctionBodyCreator``.
3. Create the test parameters for the test code by conforming to ``TestGenerator``.
4. Modify ``GUUnitsGenerator`` to include the new unit category.

Note well, that steps 2 and 3 are rudimentary when implementing `SI` units by using the existing ``GradualFunctionCreator``
and ``GradualTestGenerator`` structs. For a more in-depth guide on conforming to ``FunctionBodyCreator``
and ``TestGenerator``, see [Using Custom Code Generation](usingcustomcodegeneration).
