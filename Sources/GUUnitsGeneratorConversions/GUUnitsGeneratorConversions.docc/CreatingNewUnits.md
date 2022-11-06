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

## Generated Code
Our new type will generate the below code in the `GUUnits` package.

### C Layer
The C layer is broken up into 2 files: The header file `guunits.h` and the source file `guunits.c`. The header file contains the
public API for the C layer that can be accessed by external programs including the Swift layer.
Since there is a lot of generated code in the C layer, we will only show the functions for the `gram` types. Similar
functions are also generated for the remaining unit types.

#### Header

```c
// Mass Units.
typedef int64_t microgram_t;
typedef uint64_t microgram_u;
typedef float microgram_f;
typedef double microgram_d;
typedef int64_t milligram_t;
typedef uint64_t milligram_u;
typedef float milligram_f;
typedef double milligram_d;
typedef int64_t gram_t;
typedef uint64_t gram_u;
typedef float gram_f;
typedef double gram_d;
typedef int64_t kilogram_t;
typedef uint64_t kilogram_u;
typedef float kilogram_f;
typedef double kilogram_d;
typedef int64_t megagram_t;
typedef uint64_t megagram_u;
typedef float megagram_f;
typedef double megagram_d;

/**
 * Convert double to gram_d.
 */
gram_d d_to_g_d(double gram);

/**
 * Convert double to gram_f.
 */
gram_f d_to_g_f(double gram);

/**
 * Convert double to gram_t.
 */
gram_t d_to_g_t(double gram);

/**
 * Convert double to gram_u.
 */
gram_u d_to_g_u(double gram);

/**
 * Convert float to gram_d.
 */
gram_d f_to_g_d(float gram);

/**
 * Convert float to gram_f.
 */
gram_f f_to_g_f(float gram);

/**
 * Convert float to gram_t.
 */
gram_t f_to_g_t(float gram);

/**
 * Convert float to gram_u.
 */
gram_u f_to_g_u(float gram);

/**
 * Convert gram_d to double.
 */
double g_d_to_d(gram_d gram);

/**
 * Convert gram_d to float.
 */
float g_d_to_f(gram_d gram);

/**
 * Convert gram_d to gram_f.
 */
gram_f g_d_to_g_f(gram_d gram);

/**
 * Convert gram_d to gram_t.
 */
gram_t g_d_to_g_t(gram_d gram);

/**
 * Convert gram_d to gram_u.
 */
gram_u g_d_to_g_u(gram_d gram);

/**
 * Convert gram_d to int16_t.
 */
int16_t g_d_to_i16(gram_d gram);

/**
 * Convert gram_d to int32_t.
 */
int32_t g_d_to_i32(gram_d gram);

/**
 * Convert gram_d to int64_t.
 */
int64_t g_d_to_i64(gram_d gram);

/**
 * Convert gram_d to int8_t.
 */
int8_t g_d_to_i8(gram_d gram);

/**
 * Convert gram_d to kilogram_d.
 */
kilogram_d g_d_to_kg_d(gram_d gram);

/**
 * Convert gram_d to kilogram_f.
 */
kilogram_f g_d_to_kg_f(gram_d gram);

/**
 * Convert gram_d to kilogram_t.
 */
kilogram_t g_d_to_kg_t(gram_d gram);

/**
 * Convert gram_d to kilogram_u.
 */
kilogram_u g_d_to_kg_u(gram_d gram);

/**
 * Convert gram_d to megagram_d.
 */
megagram_d g_d_to_Mg_d(gram_d gram);

/**
 * Convert gram_d to megagram_f.
 */
megagram_f g_d_to_Mg_f(gram_d gram);

/**
 * Convert gram_d to megagram_t.
 */
megagram_t g_d_to_Mg_t(gram_d gram);

/**
 * Convert gram_d to megagram_u.
 */
megagram_u g_d_to_Mg_u(gram_d gram);

/**
 * Convert gram_d to microgram_d.
 */
microgram_d g_d_to_ug_d(gram_d gram);

/**
 * Convert gram_d to microgram_f.
 */
microgram_f g_d_to_ug_f(gram_d gram);

/**
 * Convert gram_d to microgram_t.
 */
microgram_t g_d_to_ug_t(gram_d gram);

/**
 * Convert gram_d to microgram_u.
 */
microgram_u g_d_to_ug_u(gram_d gram);

/**
 * Convert gram_d to milligram_d.
 */
milligram_d g_d_to_mg_d(gram_d gram);

/**
 * Convert gram_d to milligram_f.
 */
milligram_f g_d_to_mg_f(gram_d gram);

/**
 * Convert gram_d to milligram_t.
 */
milligram_t g_d_to_mg_t(gram_d gram);

/**
 * Convert gram_d to milligram_u.
 */
milligram_u g_d_to_mg_u(gram_d gram);

/**
 * Convert gram_d to uint16_t.
 */
uint16_t g_d_to_u16(gram_d gram);

/**
 * Convert gram_d to uint32_t.
 */
uint32_t g_d_to_u32(gram_d gram);

/**
 * Convert gram_d to uint64_t.
 */
uint64_t g_d_to_u64(gram_d gram);

/**
 * Convert gram_d to uint8_t.
 */
uint8_t g_d_to_u8(gram_d gram);

/**
 * Convert gram_f to double.
 */
double g_f_to_d(gram_f gram);

/**
 * Convert gram_f to float.
 */
float g_f_to_f(gram_f gram);

/**
 * Convert gram_f to gram_d.
 */
gram_d g_f_to_g_d(gram_f gram);

/**
 * Convert gram_f to gram_t.
 */
gram_t g_f_to_g_t(gram_f gram);

/**
 * Convert gram_f to gram_u.
 */
gram_u g_f_to_g_u(gram_f gram);

/**
 * Convert gram_f to int16_t.
 */
int16_t g_f_to_i16(gram_f gram);

/**
 * Convert gram_f to int32_t.
 */
int32_t g_f_to_i32(gram_f gram);

/**
 * Convert gram_f to int64_t.
 */
int64_t g_f_to_i64(gram_f gram);

/**
 * Convert gram_f to int8_t.
 */
int8_t g_f_to_i8(gram_f gram);

/**
 * Convert gram_f to kilogram_d.
 */
kilogram_d g_f_to_kg_d(gram_f gram);

/**
 * Convert gram_f to kilogram_f.
 */
kilogram_f g_f_to_kg_f(gram_f gram);

/**
 * Convert gram_f to kilogram_t.
 */
kilogram_t g_f_to_kg_t(gram_f gram);

/**
 * Convert gram_f to kilogram_u.
 */
kilogram_u g_f_to_kg_u(gram_f gram);

/**
 * Convert gram_f to megagram_d.
 */
megagram_d g_f_to_Mg_d(gram_f gram);

/**
 * Convert gram_f to megagram_f.
 */
megagram_f g_f_to_Mg_f(gram_f gram);

/**
 * Convert gram_f to megagram_t.
 */
megagram_t g_f_to_Mg_t(gram_f gram);

/**
 * Convert gram_f to megagram_u.
 */
megagram_u g_f_to_Mg_u(gram_f gram);

/**
 * Convert gram_f to microgram_d.
 */
microgram_d g_f_to_ug_d(gram_f gram);

/**
 * Convert gram_f to microgram_f.
 */
microgram_f g_f_to_ug_f(gram_f gram);

/**
 * Convert gram_f to microgram_t.
 */
microgram_t g_f_to_ug_t(gram_f gram);

/**
 * Convert gram_f to microgram_u.
 */
microgram_u g_f_to_ug_u(gram_f gram);

/**
 * Convert gram_f to milligram_d.
 */
milligram_d g_f_to_mg_d(gram_f gram);

/**
 * Convert gram_f to milligram_f.
 */
milligram_f g_f_to_mg_f(gram_f gram);

/**
 * Convert gram_f to milligram_t.
 */
milligram_t g_f_to_mg_t(gram_f gram);

/**
 * Convert gram_f to milligram_u.
 */
milligram_u g_f_to_mg_u(gram_f gram);

/**
 * Convert gram_f to uint16_t.
 */
uint16_t g_f_to_u16(gram_f gram);

/**
 * Convert gram_f to uint32_t.
 */
uint32_t g_f_to_u32(gram_f gram);

/**
 * Convert gram_f to uint64_t.
 */
uint64_t g_f_to_u64(gram_f gram);

/**
 * Convert gram_f to uint8_t.
 */
uint8_t g_f_to_u8(gram_f gram);

/**
 * Convert gram_t to double.
 */
double g_t_to_d(gram_t gram);

/**
 * Convert gram_t to float.
 */
float g_t_to_f(gram_t gram);

/**
 * Convert gram_t to gram_d.
 */
gram_d g_t_to_g_d(gram_t gram);

/**
 * Convert gram_t to gram_f.
 */
gram_f g_t_to_g_f(gram_t gram);

/**
 * Convert gram_t to gram_u.
 */
gram_u g_t_to_g_u(gram_t gram);

/**
 * Convert gram_t to int16_t.
 */
int16_t g_t_to_i16(gram_t gram);

/**
 * Convert gram_t to int32_t.
 */
int32_t g_t_to_i32(gram_t gram);

/**
 * Convert gram_t to int64_t.
 */
int64_t g_t_to_i64(gram_t gram);

/**
 * Convert gram_t to int8_t.
 */
int8_t g_t_to_i8(gram_t gram);

/**
 * Convert gram_t to kilogram_d.
 */
kilogram_d g_t_to_kg_d(gram_t gram);

/**
 * Convert gram_t to kilogram_f.
 */
kilogram_f g_t_to_kg_f(gram_t gram);

/**
 * Convert gram_t to kilogram_t.
 */
kilogram_t g_t_to_kg_t(gram_t gram);

/**
 * Convert gram_t to kilogram_u.
 */
kilogram_u g_t_to_kg_u(gram_t gram);

/**
 * Convert gram_t to megagram_d.
 */
megagram_d g_t_to_Mg_d(gram_t gram);

/**
 * Convert gram_t to megagram_f.
 */
megagram_f g_t_to_Mg_f(gram_t gram);

/**
 * Convert gram_t to megagram_t.
 */
megagram_t g_t_to_Mg_t(gram_t gram);

/**
 * Convert gram_t to megagram_u.
 */
megagram_u g_t_to_Mg_u(gram_t gram);

/**
 * Convert gram_t to microgram_d.
 */
microgram_d g_t_to_ug_d(gram_t gram);

/**
 * Convert gram_t to microgram_f.
 */
microgram_f g_t_to_ug_f(gram_t gram);

/**
 * Convert gram_t to microgram_t.
 */
microgram_t g_t_to_ug_t(gram_t gram);

/**
 * Convert gram_t to microgram_u.
 */
microgram_u g_t_to_ug_u(gram_t gram);

/**
 * Convert gram_t to milligram_d.
 */
milligram_d g_t_to_mg_d(gram_t gram);

/**
 * Convert gram_t to milligram_f.
 */
milligram_f g_t_to_mg_f(gram_t gram);

/**
 * Convert gram_t to milligram_t.
 */
milligram_t g_t_to_mg_t(gram_t gram);

/**
 * Convert gram_t to milligram_u.
 */
milligram_u g_t_to_mg_u(gram_t gram);

/**
 * Convert gram_t to uint16_t.
 */
uint16_t g_t_to_u16(gram_t gram);

/**
 * Convert gram_t to uint32_t.
 */
uint32_t g_t_to_u32(gram_t gram);

/**
 * Convert gram_t to uint64_t.
 */
uint64_t g_t_to_u64(gram_t gram);

/**
 * Convert gram_t to uint8_t.
 */
uint8_t g_t_to_u8(gram_t gram);

/**
 * Convert gram_u to double.
 */
double g_u_to_d(gram_u gram);

/**
 * Convert gram_u to float.
 */
float g_u_to_f(gram_u gram);

/**
 * Convert gram_u to gram_d.
 */
gram_d g_u_to_g_d(gram_u gram);

/**
 * Convert gram_u to gram_f.
 */
gram_f g_u_to_g_f(gram_u gram);

/**
 * Convert gram_u to gram_t.
 */
gram_t g_u_to_g_t(gram_u gram);

/**
 * Convert gram_u to int16_t.
 */
int16_t g_u_to_i16(gram_u gram);

/**
 * Convert gram_u to int32_t.
 */
int32_t g_u_to_i32(gram_u gram);

/**
 * Convert gram_u to int64_t.
 */
int64_t g_u_to_i64(gram_u gram);

/**
 * Convert gram_u to int8_t.
 */
int8_t g_u_to_i8(gram_u gram);

/**
 * Convert gram_u to kilogram_d.
 */
kilogram_d g_u_to_kg_d(gram_u gram);

/**
 * Convert gram_u to kilogram_f.
 */
kilogram_f g_u_to_kg_f(gram_u gram);

/**
 * Convert gram_u to kilogram_t.
 */
kilogram_t g_u_to_kg_t(gram_u gram);

/**
 * Convert gram_u to kilogram_u.
 */
kilogram_u g_u_to_kg_u(gram_u gram);

/**
 * Convert gram_u to megagram_d.
 */
megagram_d g_u_to_Mg_d(gram_u gram);

/**
 * Convert gram_u to megagram_f.
 */
megagram_f g_u_to_Mg_f(gram_u gram);

/**
 * Convert gram_u to megagram_t.
 */
megagram_t g_u_to_Mg_t(gram_u gram);

/**
 * Convert gram_u to megagram_u.
 */
megagram_u g_u_to_Mg_u(gram_u gram);

/**
 * Convert gram_u to microgram_d.
 */
microgram_d g_u_to_ug_d(gram_u gram);

/**
 * Convert gram_u to microgram_f.
 */
microgram_f g_u_to_ug_f(gram_u gram);

/**
 * Convert gram_u to microgram_t.
 */
microgram_t g_u_to_ug_t(gram_u gram);

/**
 * Convert gram_u to microgram_u.
 */
microgram_u g_u_to_ug_u(gram_u gram);

/**
 * Convert gram_u to milligram_d.
 */
milligram_d g_u_to_mg_d(gram_u gram);

/**
 * Convert gram_u to milligram_f.
 */
milligram_f g_u_to_mg_f(gram_u gram);

/**
 * Convert gram_u to milligram_t.
 */
milligram_t g_u_to_mg_t(gram_u gram);

/**
 * Convert gram_u to milligram_u.
 */
milligram_u g_u_to_mg_u(gram_u gram);

/**
 * Convert gram_u to uint16_t.
 */
uint16_t g_u_to_u16(gram_u gram);

/**
 * Convert gram_u to uint32_t.
 */
uint32_t g_u_to_u32(gram_u gram);

/**
 * Convert gram_u to uint64_t.
 */
uint64_t g_u_to_u64(gram_u gram);

/**
 * Convert gram_u to uint8_t.
 */
uint8_t g_u_to_u8(gram_u gram);

/**
 * Convert int16_t to gram_d.
 */
gram_d i16_to_g_d(int16_t gram);

/**
 * Convert int16_t to gram_f.
 */
gram_f i16_to_g_f(int16_t gram);

/**
 * Convert int16_t to gram_t.
 */
gram_t i16_to_g_t(int16_t gram);

/**
 * Convert int16_t to gram_u.
 */
gram_u i16_to_g_u(int16_t gram);

/**
 * Convert int32_t to gram_d.
 */
gram_d i32_to_g_d(int32_t gram);

/**
 * Convert int32_t to gram_f.
 */
gram_f i32_to_g_f(int32_t gram);

/**
 * Convert int32_t to gram_t.
 */
gram_t i32_to_g_t(int32_t gram);

/**
 * Convert int32_t to gram_u.
 */
gram_u i32_to_g_u(int32_t gram);

/**
 * Convert int64_t to gram_d.
 */
gram_d i64_to_g_d(int64_t gram);

/**
 * Convert int64_t to gram_f.
 */
gram_f i64_to_g_f(int64_t gram);

/**
 * Convert int64_t to gram_t.
 */
gram_t i64_to_g_t(int64_t gram);

/**
 * Convert int64_t to gram_u.
 */
gram_u i64_to_g_u(int64_t gram);

/**
 * Convert int8_t to gram_d.
 */
gram_d i8_to_g_d(int8_t gram);

/**
 * Convert int8_t to gram_f.
 */
gram_f i8_to_g_f(int8_t gram);

/**
 * Convert int8_t to gram_t.
 */
gram_t i8_to_g_t(int8_t gram);

/**
 * Convert int8_t to gram_u.
 */
gram_u i8_to_g_u(int8_t gram);

/**
 * Convert uint16_t to gram_d.
 */
gram_d u16_to_g_d(uint16_t gram);

/**
 * Convert uint16_t to gram_f.
 */
gram_f u16_to_g_f(uint16_t gram);

/**
 * Convert uint16_t to gram_t.
 */
gram_t u16_to_g_t(uint16_t gram);

/**
 * Convert uint16_t to gram_u.
 */
gram_u u16_to_g_u(uint16_t gram);

/**
 * Convert uint32_t to gram_d.
 */
gram_d u32_to_g_d(uint32_t gram);

/**
 * Convert uint32_t to gram_f.
 */
gram_f u32_to_g_f(uint32_t gram);

/**
 * Convert uint32_t to gram_t.
 */
gram_t u32_to_g_t(uint32_t gram);

/**
 * Convert uint32_t to gram_u.
 */
gram_u u32_to_g_u(uint32_t gram);

/**
 * Convert uint64_t to gram_d.
 */
gram_d u64_to_g_d(uint64_t gram);

/**
 * Convert uint64_t to gram_f.
 */
gram_f u64_to_g_f(uint64_t gram);

/**
 * Convert uint64_t to gram_t.
 */
gram_t u64_to_g_t(uint64_t gram);

/**
 * Convert uint64_t to gram_u.
 */
gram_u u64_to_g_u(uint64_t gram);

/**
 * Convert uint8_t to gram_d.
 */
gram_d u8_to_g_d(uint8_t gram);

/**
 * Convert uint8_t to gram_f.
 */
gram_f u8_to_g_f(uint8_t gram);

/**
 * Convert uint8_t to gram_t.
 */
gram_t u8_to_g_t(uint8_t gram);

/**
 * Convert uint8_t to gram_u.
 */
gram_u u8_to_g_u(uint8_t gram);
```

#### Source File

```c
/**
 * Convert double to gram_d.
 */
gram_d d_to_g_d(double gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert double to gram_f.
 */
gram_f d_to_g_f(double gram)
{
    return ((gram_f) (d_to_f(gram)));
}

/**
 * Convert double to gram_t.
 */
gram_t d_to_g_t(double gram)
{
    return ((gram_t) (d_to_i64(gram)));
}

/**
 * Convert double to gram_u.
 */
gram_u d_to_g_u(double gram)
{
    return ((gram_u) (d_to_u64(gram)));
}

/**
 * Convert float to gram_d.
 */
gram_d f_to_g_d(float gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert float to gram_f.
 */
gram_f f_to_g_f(float gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert float to gram_t.
 */
gram_t f_to_g_t(float gram)
{
    return ((gram_t) (f_to_i64(gram)));
}

/**
 * Convert float to gram_u.
 */
gram_u f_to_g_u(float gram)
{
    return ((gram_u) (f_to_u64(gram)));
}

/**
 * Convert gram_d to double.
 */
double g_d_to_d(gram_d gram)
{
    return ((double) (gram));
}

/**
 * Convert gram_d to float.
 */
float g_d_to_f(gram_d gram)
{
    return d_to_f(((double) (gram)));
}

/**
 * Convert gram_d to gram_f.
 */
gram_f g_d_to_g_f(gram_d gram)
{
    return ((gram_f) (gram < ((double) (FLT_MAX)) ? (gram > ((double) (-FLT_MAX)) ? gram : -FLT_MAX) : FLT_MAX));
}

/**
 * Convert gram_d to gram_t.
 */
gram_t g_d_to_g_t(gram_d gram)
{
    return ((gram_t) (round(((double) (gram))) < ((double) (9223372036854775807)) ? (round(((double) (gram))) > ((double) (-9223372036854775807 - 1)) ? ((gram_t) (round(((double) (gram))))) : -9223372036854775807 - 1) : 9223372036854775807));
}

/**
 * Convert gram_d to gram_u.
 */
gram_u g_d_to_g_u(gram_d gram)
{
    return ((gram_u) (round(((double) (gram))) < ((double) (18446744073709551615U)) ? (round(((double) (gram))) > ((double) (0)) ? ((gram_u) (round(((double) (gram))))) : 0) : 18446744073709551615U));
}

/**
 * Convert gram_d to int16_t.
 */
int16_t g_d_to_i16(gram_d gram)
{
    return d_to_i16(((double) (gram)));
}

/**
 * Convert gram_d to int32_t.
 */
int32_t g_d_to_i32(gram_d gram)
{
    return d_to_i32(((double) (gram)));
}

/**
 * Convert gram_d to int64_t.
 */
int64_t g_d_to_i64(gram_d gram)
{
    return d_to_i64(((double) (gram)));
}

/**
 * Convert gram_d to int8_t.
 */
int8_t g_d_to_i8(gram_d gram)
{
    return d_to_i8(((double) (gram)));
}

/**
 * Convert gram_d to kilogram_d.
 */
kilogram_d g_d_to_kg_d(gram_d gram)
{
    return ((kilogram_d) (gram / 1000.0));
}

/**
 * Convert gram_d to kilogram_f.
 */
kilogram_f g_d_to_kg_f(gram_d gram)
{
    const gram_d conversion = gram / 1000.0;
    return ((kilogram_f) (conversion < ((double) (FLT_MAX)) ? (conversion > ((double) (-FLT_MAX)) ? conversion : -FLT_MAX) : FLT_MAX));
}

/**
 * Convert gram_d to kilogram_t.
 */
kilogram_t g_d_to_kg_t(gram_d gram)
{
    const gram_d conversion = gram / 1000.0;
    return ((kilogram_t) (round(((double) (conversion))) < ((double) (9223372036854775807)) ? (round(((double) (conversion))) > ((double) (-9223372036854775807 - 1)) ? ((kilogram_t) (round(((double) (conversion))))) : -9223372036854775807 - 1) : 9223372036854775807));
}

/**
 * Convert gram_d to kilogram_u.
 */
kilogram_u g_d_to_kg_u(gram_d gram)
{
    const gram_d conversion = gram / 1000.0;
    return ((kilogram_u) (round(((double) (conversion))) < ((double) (18446744073709551615U)) ? (round(((double) (conversion))) > ((double) (0)) ? ((kilogram_u) (round(((double) (conversion))))) : 0) : 18446744073709551615U));
}

/**
 * Convert gram_d to megagram_d.
 */
megagram_d g_d_to_Mg_d(gram_d gram)
{
    return ((megagram_d) (gram / 1000000.0));
}

/**
 * Convert gram_d to megagram_f.
 */
megagram_f g_d_to_Mg_f(gram_d gram)
{
    const gram_d conversion = gram / 1000000.0;
    return ((megagram_f) (conversion < ((double) (FLT_MAX)) ? (conversion > ((double) (-FLT_MAX)) ? conversion : -FLT_MAX) : FLT_MAX));
}

/**
 * Convert gram_d to megagram_t.
 */
megagram_t g_d_to_Mg_t(gram_d gram)
{
    const gram_d conversion = gram / 1000000.0;
    return ((megagram_t) (round(((double) (conversion))) < ((double) (9223372036854775807)) ? (round(((double) (conversion))) > ((double) (-9223372036854775807 - 1)) ? ((megagram_t) (round(((double) (conversion))))) : -9223372036854775807 - 1) : 9223372036854775807));
}

/**
 * Convert gram_d to megagram_u.
 */
megagram_u g_d_to_Mg_u(gram_d gram)
{
    const gram_d conversion = gram / 1000000.0;
    return ((megagram_u) (round(((double) (conversion))) < ((double) (18446744073709551615U)) ? (round(((double) (conversion))) > ((double) (0)) ? ((megagram_u) (round(((double) (conversion))))) : 0) : 18446744073709551615U));
}

/**
 * Convert gram_d to microgram_d.
 */
microgram_d g_d_to_ug_d(gram_d gram)
{
    if (gram < ((-DBL_MAX) / 1000000.0)) {
        return -DBL_MAX;
    }
    if (gram > ((DBL_MAX) / 1000000.0)) {
        return DBL_MAX;
    }
    return ((microgram_d) (gram)) * 1000000.0;
}

/**
 * Convert gram_d to microgram_f.
 */
microgram_f g_d_to_ug_f(gram_d gram)
{
    if (gram > (((gram_d) (FLT_MAX)) / 1000000.0)) {
        return FLT_MAX;
    }
    if (gram < (((gram_d) (-FLT_MAX)) / 1000000.0)) {
        return -FLT_MAX;
    }
    return ((microgram_f) (gram * 1000000.0));
}

/**
 * Convert gram_d to microgram_t.
 */
microgram_t g_d_to_ug_t(gram_d gram)
{
    if (gram > (((gram_d) (9223372036854775807)) / 1000000.0)) {
        return 9223372036854775807;
    }
    if (gram < (((gram_d) (-9223372036854775807 - 1)) / 1000000.0)) {
        return -9223372036854775807 - 1;
    }
    return ((microgram_t) (gram * 1000000.0));
}

/**
 * Convert gram_d to microgram_u.
 */
microgram_u g_d_to_ug_u(gram_d gram)
{
    if (gram > (((gram_d) (18446744073709551615U)) / 1000000.0)) {
        return 18446744073709551615U;
    }
    if (gram < (((gram_d) (0)) / 1000000.0)) {
        return 0;
    }
    return ((microgram_u) (gram * 1000000.0));
}

/**
 * Convert gram_d to milligram_d.
 */
milligram_d g_d_to_mg_d(gram_d gram)
{
    if (gram < ((-DBL_MAX) / 1000.0)) {
        return -DBL_MAX;
    }
    if (gram > ((DBL_MAX) / 1000.0)) {
        return DBL_MAX;
    }
    return ((milligram_d) (gram)) * 1000.0;
}

/**
 * Convert gram_d to milligram_f.
 */
milligram_f g_d_to_mg_f(gram_d gram)
{
    if (gram > (((gram_d) (FLT_MAX)) / 1000.0)) {
        return FLT_MAX;
    }
    if (gram < (((gram_d) (-FLT_MAX)) / 1000.0)) {
        return -FLT_MAX;
    }
    return ((milligram_f) (gram * 1000.0));
}

/**
 * Convert gram_d to milligram_t.
 */
milligram_t g_d_to_mg_t(gram_d gram)
{
    if (gram > (((gram_d) (9223372036854775807)) / 1000.0)) {
        return 9223372036854775807;
    }
    if (gram < (((gram_d) (-9223372036854775807 - 1)) / 1000.0)) {
        return -9223372036854775807 - 1;
    }
    return ((milligram_t) (gram * 1000.0));
}

/**
 * Convert gram_d to milligram_u.
 */
milligram_u g_d_to_mg_u(gram_d gram)
{
    if (gram > (((gram_d) (18446744073709551615U)) / 1000.0)) {
        return 18446744073709551615U;
    }
    if (gram < (((gram_d) (0)) / 1000.0)) {
        return 0;
    }
    return ((milligram_u) (gram * 1000.0));
}

/**
 * Convert gram_d to uint16_t.
 */
uint16_t g_d_to_u16(gram_d gram)
{
    return d_to_u16(((double) (gram)));
}

/**
 * Convert gram_d to uint32_t.
 */
uint32_t g_d_to_u32(gram_d gram)
{
    return d_to_u32(((double) (gram)));
}

/**
 * Convert gram_d to uint64_t.
 */
uint64_t g_d_to_u64(gram_d gram)
{
    return d_to_u64(((double) (gram)));
}

/**
 * Convert gram_d to uint8_t.
 */
uint8_t g_d_to_u8(gram_d gram)
{
    return d_to_u8(((double) (gram)));
}

/**
 * Convert gram_f to double.
 */
double g_f_to_d(gram_f gram)
{
    return ((double) (gram));
}

/**
 * Convert gram_f to float.
 */
float g_f_to_f(gram_f gram)
{
    return ((float) (gram));
}

/**
 * Convert gram_f to gram_d.
 */
gram_d g_f_to_g_d(gram_f gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert gram_f to gram_t.
 */
gram_t g_f_to_g_t(gram_f gram)
{
    return ((gram_t) (round(((double) (gram))) < ((double) (9223372036854775807)) ? (round(((double) (gram))) > ((double) (-9223372036854775807 - 1)) ? ((gram_t) (round(((double) (gram))))) : -9223372036854775807 - 1) : 9223372036854775807));
}

/**
 * Convert gram_f to gram_u.
 */
gram_u g_f_to_g_u(gram_f gram)
{
    return ((gram_u) (round(((double) (gram))) < ((double) (18446744073709551615U)) ? (round(((double) (gram))) > ((double) (0)) ? ((gram_u) (round(((double) (gram))))) : 0) : 18446744073709551615U));
}

/**
 * Convert gram_f to int16_t.
 */
int16_t g_f_to_i16(gram_f gram)
{
    return f_to_i16(((float) (gram)));
}

/**
 * Convert gram_f to int32_t.
 */
int32_t g_f_to_i32(gram_f gram)
{
    return f_to_i32(((float) (gram)));
}

/**
 * Convert gram_f to int64_t.
 */
int64_t g_f_to_i64(gram_f gram)
{
    return f_to_i64(((float) (gram)));
}

/**
 * Convert gram_f to int8_t.
 */
int8_t g_f_to_i8(gram_f gram)
{
    return f_to_i8(((float) (gram)));
}

/**
 * Convert gram_f to kilogram_d.
 */
kilogram_d g_f_to_kg_d(gram_f gram)
{
    return (((kilogram_d) (gram)) / 1000.0);
}

/**
 * Convert gram_f to kilogram_f.
 */
kilogram_f g_f_to_kg_f(gram_f gram)
{
    return ((kilogram_f) (gram / 1000.0f));
}

/**
 * Convert gram_f to kilogram_t.
 */
kilogram_t g_f_to_kg_t(gram_f gram)
{
    const gram_f conversion = gram / 1000.0f;
    return ((kilogram_t) (round(((double) (conversion))) < ((double) (9223372036854775807)) ? (round(((double) (conversion))) > ((double) (-9223372036854775807 - 1)) ? ((kilogram_t) (round(((double) (conversion))))) : -9223372036854775807 - 1) : 9223372036854775807));
}

/**
 * Convert gram_f to kilogram_u.
 */
kilogram_u g_f_to_kg_u(gram_f gram)
{
    const gram_f conversion = gram / 1000.0f;
    return ((kilogram_u) (round(((double) (conversion))) < ((double) (18446744073709551615U)) ? (round(((double) (conversion))) > ((double) (0)) ? ((kilogram_u) (round(((double) (conversion))))) : 0) : 18446744073709551615U));
}

/**
 * Convert gram_f to megagram_d.
 */
megagram_d g_f_to_Mg_d(gram_f gram)
{
    return (((megagram_d) (gram)) / 1000000.0);
}

/**
 * Convert gram_f to megagram_f.
 */
megagram_f g_f_to_Mg_f(gram_f gram)
{
    return ((megagram_f) (gram / 1000000.0f));
}

/**
 * Convert gram_f to megagram_t.
 */
megagram_t g_f_to_Mg_t(gram_f gram)
{
    const gram_f conversion = gram / 1000000.0f;
    return ((megagram_t) (round(((double) (conversion))) < ((double) (9223372036854775807)) ? (round(((double) (conversion))) > ((double) (-9223372036854775807 - 1)) ? ((megagram_t) (round(((double) (conversion))))) : -9223372036854775807 - 1) : 9223372036854775807));
}

/**
 * Convert gram_f to megagram_u.
 */
megagram_u g_f_to_Mg_u(gram_f gram)
{
    const gram_f conversion = gram / 1000000.0f;
    return ((megagram_u) (round(((double) (conversion))) < ((double) (18446744073709551615U)) ? (round(((double) (conversion))) > ((double) (0)) ? ((megagram_u) (round(((double) (conversion))))) : 0) : 18446744073709551615U));
}

/**
 * Convert gram_f to microgram_d.
 */
microgram_d g_f_to_ug_d(gram_f gram)
{
    return ((microgram_d) (gram)) * 1000000.0;
}

/**
 * Convert gram_f to microgram_f.
 */
microgram_f g_f_to_ug_f(gram_f gram)
{
    if (gram < ((-FLT_MAX) / 1000000.0f)) {
        return -FLT_MAX;
    }
    if (gram > ((FLT_MAX) / 1000000.0f)) {
        return FLT_MAX;
    }
    return ((microgram_f) (gram)) * 1000000.0f;
}

/**
 * Convert gram_f to microgram_t.
 */
microgram_t g_f_to_ug_t(gram_f gram)
{
    if (gram > (((gram_f) (9223372036854775807)) / 1000000.0f)) {
        return 9223372036854775807;
    }
    if (gram < (((gram_f) (-9223372036854775807 - 1)) / 1000000.0f)) {
        return -9223372036854775807 - 1;
    }
    return ((microgram_t) (gram * 1000000.0f));
}

/**
 * Convert gram_f to microgram_u.
 */
microgram_u g_f_to_ug_u(gram_f gram)
{
    if (gram > (((gram_f) (18446744073709551615U)) / 1000000.0f)) {
        return 18446744073709551615U;
    }
    if (gram < (((gram_f) (0)) / 1000000.0f)) {
        return 0;
    }
    return ((microgram_u) (gram * 1000000.0f));
}

/**
 * Convert gram_f to milligram_d.
 */
milligram_d g_f_to_mg_d(gram_f gram)
{
    return ((milligram_d) (gram)) * 1000.0;
}

/**
 * Convert gram_f to milligram_f.
 */
milligram_f g_f_to_mg_f(gram_f gram)
{
    if (gram < ((-FLT_MAX) / 1000.0f)) {
        return -FLT_MAX;
    }
    if (gram > ((FLT_MAX) / 1000.0f)) {
        return FLT_MAX;
    }
    return ((milligram_f) (gram)) * 1000.0f;
}

/**
 * Convert gram_f to milligram_t.
 */
milligram_t g_f_to_mg_t(gram_f gram)
{
    if (gram > (((gram_f) (9223372036854775807)) / 1000.0f)) {
        return 9223372036854775807;
    }
    if (gram < (((gram_f) (-9223372036854775807 - 1)) / 1000.0f)) {
        return -9223372036854775807 - 1;
    }
    return ((milligram_t) (gram * 1000.0f));
}

/**
 * Convert gram_f to milligram_u.
 */
milligram_u g_f_to_mg_u(gram_f gram)
{
    if (gram > (((gram_f) (18446744073709551615U)) / 1000.0f)) {
        return 18446744073709551615U;
    }
    if (gram < (((gram_f) (0)) / 1000.0f)) {
        return 0;
    }
    return ((milligram_u) (gram * 1000.0f));
}

/**
 * Convert gram_f to uint16_t.
 */
uint16_t g_f_to_u16(gram_f gram)
{
    return f_to_u16(((float) (gram)));
}

/**
 * Convert gram_f to uint32_t.
 */
uint32_t g_f_to_u32(gram_f gram)
{
    return f_to_u32(((float) (gram)));
}

/**
 * Convert gram_f to uint64_t.
 */
uint64_t g_f_to_u64(gram_f gram)
{
    return f_to_u64(((float) (gram)));
}

/**
 * Convert gram_f to uint8_t.
 */
uint8_t g_f_to_u8(gram_f gram)
{
    return f_to_u8(((float) (gram)));
}

/**
 * Convert gram_t to double.
 */
double g_t_to_d(gram_t gram)
{
    return ((double) (gram));
}

/**
 * Convert gram_t to float.
 */
float g_t_to_f(gram_t gram)
{
    return ((float) (gram));
}

/**
 * Convert gram_t to gram_d.
 */
gram_d g_t_to_g_d(gram_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert gram_t to gram_f.
 */
gram_f g_t_to_g_f(gram_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert gram_t to gram_u.
 */
gram_u g_t_to_g_u(gram_t gram)
{
    return ((gram_u) ((gram) < 0 ? 0 : gram));
}

/**
 * Convert gram_t to int16_t.
 */
int16_t g_t_to_i16(gram_t gram)
{
    return ((int16_t) (MIN(((gram_t) (32767)), MAX(((gram_t) (-32768)), gram))));
}

/**
 * Convert gram_t to int32_t.
 */
int32_t g_t_to_i32(gram_t gram)
{
    return ((int32_t) (MIN(((gram_t) (2147483647)), MAX(((gram_t) (-2147483648)), gram))));
}

/**
 * Convert gram_t to int64_t.
 */
int64_t g_t_to_i64(gram_t gram)
{
    return ((int64_t) (gram));
}

/**
 * Convert gram_t to int8_t.
 */
int8_t g_t_to_i8(gram_t gram)
{
    return ((int8_t) (MIN(((gram_t) (127)), MAX(((gram_t) (-128)), gram))));
}

/**
 * Convert gram_t to kilogram_d.
 */
kilogram_d g_t_to_kg_d(gram_t gram)
{
    return ((kilogram_d) (gram / 1000));
}

/**
 * Convert gram_t to kilogram_f.
 */
kilogram_f g_t_to_kg_f(gram_t gram)
{
    return ((kilogram_f) (gram / 1000));
}

/**
 * Convert gram_t to kilogram_t.
 */
kilogram_t g_t_to_kg_t(gram_t gram)
{
    return ((kilogram_t) (gram / 1000));
}

/**
 * Convert gram_t to kilogram_u.
 */
kilogram_u g_t_to_kg_u(gram_t gram)
{
    if (gram < 0) {
        return 0;
    }
    return ((kilogram_u) (gram / 1000));
}

/**
 * Convert gram_t to megagram_d.
 */
megagram_d g_t_to_Mg_d(gram_t gram)
{
    return ((megagram_d) (gram / 1000000));
}

/**
 * Convert gram_t to megagram_f.
 */
megagram_f g_t_to_Mg_f(gram_t gram)
{
    return ((megagram_f) (gram / 1000000));
}

/**
 * Convert gram_t to megagram_t.
 */
megagram_t g_t_to_Mg_t(gram_t gram)
{
    return ((megagram_t) (gram / 1000000));
}

/**
 * Convert gram_t to megagram_u.
 */
megagram_u g_t_to_Mg_u(gram_t gram)
{
    if (gram < 0) {
        return 0;
    }
    return ((megagram_u) (gram / 1000000));
}

/**
 * Convert gram_t to microgram_d.
 */
microgram_d g_t_to_ug_d(gram_t gram)
{
    return ((microgram_d) (gram)) * 1000000.0;
}

/**
 * Convert gram_t to microgram_f.
 */
microgram_f g_t_to_ug_f(gram_t gram)
{
    return ((microgram_f) (gram)) * 1000000.0f;
}

/**
 * Convert gram_t to microgram_t.
 */
microgram_t g_t_to_ug_t(gram_t gram)
{
    if (gram < ((-9223372036854775807 - 1) / 1000000)) {
        return -9223372036854775807 - 1;
    }
    if (gram > ((9223372036854775807) / 1000000)) {
        return 9223372036854775807;
    }
    return ((microgram_t) (gram)) * 1000000;
}

/**
 * Convert gram_t to microgram_u.
 */
microgram_u g_t_to_ug_u(gram_t gram)
{
    if (gram < (0)) {
        return 0;
    }
    const microgram_u otherGram = ((microgram_u) (gram));
    if (otherGram > ((18446744073709551615U) / 1000000)) {
        return 18446744073709551615U;
    }
    return otherGram * 1000000;
}

/**
 * Convert gram_t to milligram_d.
 */
milligram_d g_t_to_mg_d(gram_t gram)
{
    return ((milligram_d) (gram)) * 1000.0;
}

/**
 * Convert gram_t to milligram_f.
 */
milligram_f g_t_to_mg_f(gram_t gram)
{
    return ((milligram_f) (gram)) * 1000.0f;
}

/**
 * Convert gram_t to milligram_t.
 */
milligram_t g_t_to_mg_t(gram_t gram)
{
    if (gram < ((-9223372036854775807 - 1) / 1000)) {
        return -9223372036854775807 - 1;
    }
    if (gram > ((9223372036854775807) / 1000)) {
        return 9223372036854775807;
    }
    return ((milligram_t) (gram)) * 1000;
}

/**
 * Convert gram_t to milligram_u.
 */
milligram_u g_t_to_mg_u(gram_t gram)
{
    if (gram < (0)) {
        return 0;
    }
    const milligram_u otherGram = ((milligram_u) (gram));
    if (otherGram > ((18446744073709551615U) / 1000)) {
        return 18446744073709551615U;
    }
    return otherGram * 1000;
}

/**
 * Convert gram_t to uint16_t.
 */
uint16_t g_t_to_u16(gram_t gram)
{
    return ((uint16_t) (MAX(((gram_t) (0)), gram)));
}

/**
 * Convert gram_t to uint32_t.
 */
uint32_t g_t_to_u32(gram_t gram)
{
    return ((uint32_t) (MAX(((gram_t) (0)), gram)));
}

/**
 * Convert gram_t to uint64_t.
 */
uint64_t g_t_to_u64(gram_t gram)
{
    return ((uint64_t) (MAX(((gram_t) (0)), gram)));
}

/**
 * Convert gram_t to uint8_t.
 */
uint8_t g_t_to_u8(gram_t gram)
{
    return ((uint8_t) (MAX(((gram_t) (0)), gram)));
}

/**
 * Convert gram_u to double.
 */
double g_u_to_d(gram_u gram)
{
    return ((double) (gram));
}

/**
 * Convert gram_u to float.
 */
float g_u_to_f(gram_u gram)
{
    return ((float) (gram));
}

/**
 * Convert gram_u to gram_d.
 */
gram_d g_u_to_g_d(gram_u gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert gram_u to gram_f.
 */
gram_f g_u_to_g_f(gram_u gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert gram_u to gram_t.
 */
gram_t g_u_to_g_t(gram_u gram)
{
    return ((gram_t) ((gram) > ((uint64_t) (9223372036854775807)) ? ((uint64_t) (9223372036854775807)) : gram));
}

/**
 * Convert gram_u to int16_t.
 */
int16_t g_u_to_i16(gram_u gram)
{
    return ((int16_t) (MIN(((gram_u) (32767)), gram)));
}

/**
 * Convert gram_u to int32_t.
 */
int32_t g_u_to_i32(gram_u gram)
{
    return ((int32_t) (MIN(((gram_u) (2147483647)), gram)));
}

/**
 * Convert gram_u to int64_t.
 */
int64_t g_u_to_i64(gram_u gram)
{
    return ((int64_t) (MIN(((gram_u) (9223372036854775807)), gram)));
}

/**
 * Convert gram_u to int8_t.
 */
int8_t g_u_to_i8(gram_u gram)
{
    return ((int8_t) (MIN(((gram_u) (127)), gram)));
}

/**
 * Convert gram_u to kilogram_d.
 */
kilogram_d g_u_to_kg_d(gram_u gram)
{
    return ((kilogram_d) (gram / 1000));
}

/**
 * Convert gram_u to kilogram_f.
 */
kilogram_f g_u_to_kg_f(gram_u gram)
{
    return ((kilogram_f) (gram / 1000));
}

/**
 * Convert gram_u to kilogram_t.
 */
kilogram_t g_u_to_kg_t(gram_u gram)
{
    const gram_u conversion = gram / 1000;
    return ((kilogram_t) ((conversion) > ((uint64_t) (9223372036854775807)) ? ((uint64_t) (9223372036854775807)) : conversion));
}

/**
 * Convert gram_u to kilogram_u.
 */
kilogram_u g_u_to_kg_u(gram_u gram)
{
    return ((kilogram_u) (gram / 1000));
}

/**
 * Convert gram_u to megagram_d.
 */
megagram_d g_u_to_Mg_d(gram_u gram)
{
    return ((megagram_d) (gram / 1000000));
}

/**
 * Convert gram_u to megagram_f.
 */
megagram_f g_u_to_Mg_f(gram_u gram)
{
    return ((megagram_f) (gram / 1000000));
}

/**
 * Convert gram_u to megagram_t.
 */
megagram_t g_u_to_Mg_t(gram_u gram)
{
    const gram_u conversion = gram / 1000000;
    return ((megagram_t) ((conversion) > ((uint64_t) (9223372036854775807)) ? ((uint64_t) (9223372036854775807)) : conversion));
}

/**
 * Convert gram_u to megagram_u.
 */
megagram_u g_u_to_Mg_u(gram_u gram)
{
    return ((megagram_u) (gram / 1000000));
}

/**
 * Convert gram_u to microgram_d.
 */
microgram_d g_u_to_ug_d(gram_u gram)
{
    return ((microgram_d) (gram)) * 1000000.0;
}

/**
 * Convert gram_u to microgram_f.
 */
microgram_f g_u_to_ug_f(gram_u gram)
{
    return ((microgram_f) (gram)) * 1000000.0f;
}

/**
 * Convert gram_u to microgram_t.
 */
microgram_t g_u_to_ug_t(gram_u gram)
{
    if (gram > ((gram_u) ((9223372036854775807) / 1000000))) {
        return 9223372036854775807;
    }
    return ((microgram_t) (gram * 1000000));
}

/**
 * Convert gram_u to microgram_u.
 */
microgram_u g_u_to_ug_u(gram_u gram)
{
    if (gram > ((18446744073709551615U) / 1000000)) {
        return 18446744073709551615U;
    }
    return ((microgram_u) (gram)) * 1000000;
}

/**
 * Convert gram_u to milligram_d.
 */
milligram_d g_u_to_mg_d(gram_u gram)
{
    return ((milligram_d) (gram)) * 1000.0;
}

/**
 * Convert gram_u to milligram_f.
 */
milligram_f g_u_to_mg_f(gram_u gram)
{
    return ((milligram_f) (gram)) * 1000.0f;
}

/**
 * Convert gram_u to milligram_t.
 */
milligram_t g_u_to_mg_t(gram_u gram)
{
    if (gram > ((gram_u) ((9223372036854775807) / 1000))) {
        return 9223372036854775807;
    }
    return ((milligram_t) (gram * 1000));
}

/**
 * Convert gram_u to milligram_u.
 */
milligram_u g_u_to_mg_u(gram_u gram)
{
    if (gram > ((18446744073709551615U) / 1000)) {
        return 18446744073709551615U;
    }
    return ((milligram_u) (gram)) * 1000;
}

/**
 * Convert gram_u to uint16_t.
 */
uint16_t g_u_to_u16(gram_u gram)
{
    return ((uint16_t) (MIN(((gram_u) (65535)), MAX(((gram_u) (0)), gram))));
}

/**
 * Convert gram_u to uint32_t.
 */
uint32_t g_u_to_u32(gram_u gram)
{
    return ((uint32_t) (MIN(((gram_u) (4294967295U)), MAX(((gram_u) (0)), gram))));
}

/**
 * Convert gram_u to uint64_t.
 */
uint64_t g_u_to_u64(gram_u gram)
{
    return ((uint64_t) (gram));
}

/**
 * Convert gram_u to uint8_t.
 */
uint8_t g_u_to_u8(gram_u gram)
{
    return ((uint8_t) (MIN(((gram_u) (255)), MAX(((gram_u) (0)), gram))));
}

/**
 * Convert int16_t to gram_d.
 */
gram_d i16_to_g_d(int16_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert int16_t to gram_f.
 */
gram_f i16_to_g_f(int16_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert int16_t to gram_t.
 */
gram_t i16_to_g_t(int16_t gram)
{
    return ((gram_t) (gram));
}

/**
 * Convert int16_t to gram_u.
 */
gram_u i16_to_g_u(int16_t gram)
{
    return ((gram_u) (MAX(((int16_t) (0)), gram)));
}

/**
 * Convert int32_t to gram_d.
 */
gram_d i32_to_g_d(int32_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert int32_t to gram_f.
 */
gram_f i32_to_g_f(int32_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert int32_t to gram_t.
 */
gram_t i32_to_g_t(int32_t gram)
{
    return ((gram_t) (gram));
}

/**
 * Convert int32_t to gram_u.
 */
gram_u i32_to_g_u(int32_t gram)
{
    return ((gram_u) (MAX(((int32_t) (0)), gram)));
}

/**
 * Convert int64_t to gram_d.
 */
gram_d i64_to_g_d(int64_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert int64_t to gram_f.
 */
gram_f i64_to_g_f(int64_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert int64_t to gram_t.
 */
gram_t i64_to_g_t(int64_t gram)
{
    return ((gram_t) (gram));
}

/**
 * Convert int64_t to gram_u.
 */
gram_u i64_to_g_u(int64_t gram)
{
    return ((gram_u) (MAX(((int64_t) (0)), gram)));
}

/**
 * Convert int8_t to gram_d.
 */
gram_d i8_to_g_d(int8_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert int8_t to gram_f.
 */
gram_f i8_to_g_f(int8_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert int8_t to gram_t.
 */
gram_t i8_to_g_t(int8_t gram)
{
    return ((gram_t) (gram));
}

/**
 * Convert int8_t to gram_u.
 */
gram_u i8_to_g_u(int8_t gram)
{
    return ((gram_u) (MAX(((int8_t) (0)), gram)));
}

/**
 * Convert uint16_t to gram_d.
 */
gram_d u16_to_g_d(uint16_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert uint16_t to gram_f.
 */
gram_f u16_to_g_f(uint16_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert uint16_t to gram_t.
 */
gram_t u16_to_g_t(uint16_t gram)
{
    return ((gram_t) (gram));
}

/**
 * Convert uint16_t to gram_u.
 */
gram_u u16_to_g_u(uint16_t gram)
{
    return ((gram_u) (gram));
}

/**
 * Convert uint32_t to gram_d.
 */
gram_d u32_to_g_d(uint32_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert uint32_t to gram_f.
 */
gram_f u32_to_g_f(uint32_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert uint32_t to gram_t.
 */
gram_t u32_to_g_t(uint32_t gram)
{
    return ((gram_t) (gram));
}

/**
 * Convert uint32_t to gram_u.
 */
gram_u u32_to_g_u(uint32_t gram)
{
    return ((gram_u) (gram));
}

/**
 * Convert uint64_t to gram_d.
 */
gram_d u64_to_g_d(uint64_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert uint64_t to gram_f.
 */
gram_f u64_to_g_f(uint64_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert uint64_t to gram_t.
 */
gram_t u64_to_g_t(uint64_t gram)
{
    return ((gram_t) (MIN(((uint64_t) (9223372036854775807)), gram)));
}

/**
 * Convert uint64_t to gram_u.
 */
gram_u u64_to_g_u(uint64_t gram)
{
    return ((gram_u) (gram));
}

/**
 * Convert uint8_t to gram_d.
 */
gram_d u8_to_g_d(uint8_t gram)
{
    return ((gram_d) (gram));
}

/**
 * Convert uint8_t to gram_f.
 */
gram_f u8_to_g_f(uint8_t gram)
{
    return ((gram_f) (gram));
}

/**
 * Convert uint8_t to gram_t.
 */
gram_t u8_to_g_t(uint8_t gram)
{
    return ((gram_t) (gram));
}

/**
 * Convert uint8_t to gram_u.
 */
gram_u u8_to_g_u(uint8_t gram)
{
    return ((gram_u) (gram));
}
```

### Swift Layer
The swift layer generates a category type that contains conversions to all units within the category,
structs for each unit type, and extensions on Swift primitive types. All of this code is placed within
a swift file called `Mass.swift`. For brevity, we will only show the code related to the `gram` unit, but please
be aware that similar code is generated for the remaining units.

#### The Gram Structs

```swift
/// A signed integer type for the gram unit.
public struct Gram_t: GUUnitsTType, Hashable, Codable {

// MARK: - Converting Between The Underlying guunits C Type

    /// Convert to the guunits underlying C type `gram_t`
    public let rawValue: gram_t

    /// Create a `Gram_t` from the underlying guunits C type `gram_t`.
    public init(rawValue: gram_t) {
        self.rawValue = rawValue
    }

// MARK: - Converting From Swift Numeric Types

    /// Create a `Gram_t` by converting a `Double`.
    ///
    /// - Parameter value: A `Double` value to convert to a `Gram_t`.
    public init(_ value: Double) {
        self.rawValue = d_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `Float`.
    ///
    /// - Parameter value: A `Float` value to convert to a `Gram_t`.
    public init(_ value: Float) {
        self.rawValue = f_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `Int`.
    ///
    /// - Parameter value: A `Int` value to convert to a `Gram_t`.
    public init(_ value: Int) {
        self.rawValue = i64_to_g_t(Int64(value))
    }

    /// Create a `Gram_t` by converting a `Int16`.
    ///
    /// - Parameter value: A `Int16` value to convert to a `Gram_t`.
    public init(_ value: Int16) {
        self.rawValue = i16_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `Int32`.
    ///
    /// - Parameter value: A `Int32` value to convert to a `Gram_t`.
    public init(_ value: Int32) {
        self.rawValue = i32_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `Int64`.
    ///
    /// - Parameter value: A `Int64` value to convert to a `Gram_t`.
    public init(_ value: Int64) {
        self.rawValue = i64_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `Int8`.
    ///
    /// - Parameter value: A `Int8` value to convert to a `Gram_t`.
    public init(_ value: Int8) {
        self.rawValue = i8_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `UInt`.
    ///
    /// - Parameter value: A `UInt` value to convert to a `Gram_t`.
    public init(_ value: UInt) {
        self.rawValue = u64_to_g_t(UInt64(value))
    }

    /// Create a `Gram_t` by converting a `UInt16`.
    ///
    /// - Parameter value: A `UInt16` value to convert to a `Gram_t`.
    public init(_ value: UInt16) {
        self.rawValue = u16_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `UInt32`.
    ///
    /// - Parameter value: A `UInt32` value to convert to a `Gram_t`.
    public init(_ value: UInt32) {
        self.rawValue = u32_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `UInt64`.
    ///
    /// - Parameter value: A `UInt64` value to convert to a `Gram_t`.
    public init(_ value: UInt64) {
        self.rawValue = u64_to_g_t(value)
    }

    /// Create a `Gram_t` by converting a `UInt8`.
    ///
    /// - Parameter value: A `UInt8` value to convert to a `Gram_t`.
    public init(_ value: UInt8) {
        self.rawValue = u8_to_g_t(value)
    }

// MARK: - Converting From Other Units

    /// Create a `Gram_t` by converting a `Mass`.
    ///
    /// - Parameter value: A `Mass` value to convert to a `Gram_t`.
    public init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

    /// Create a `Gram_t` by converting a `Kilogram_t`.
    ///
    /// - Parameter value: A `Kilogram_t` value to convert to a `Gram_t`.
    public init(_ value: Kilogram_t) {
        self.rawValue = kg_t_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Kilogram_u`.
    ///
    /// - Parameter value: A `Kilogram_u` value to convert to a `Gram_t`.
    public init(_ value: Kilogram_u) {
        self.rawValue = kg_u_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Kilogram_f`.
    ///
    /// - Parameter value: A `Kilogram_f` value to convert to a `Gram_t`.
    public init(_ value: Kilogram_f) {
        self.rawValue = kg_f_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Kilogram_d`.
    ///
    /// - Parameter value: A `Kilogram_d` value to convert to a `Gram_t`.
    public init(_ value: Kilogram_d) {
        self.rawValue = kg_d_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Megagram_t`.
    ///
    /// - Parameter value: A `Megagram_t` value to convert to a `Gram_t`.
    public init(_ value: Megagram_t) {
        self.rawValue = Mg_t_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Megagram_u`.
    ///
    /// - Parameter value: A `Megagram_u` value to convert to a `Gram_t`.
    public init(_ value: Megagram_u) {
        self.rawValue = Mg_u_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Megagram_f`.
    ///
    /// - Parameter value: A `Megagram_f` value to convert to a `Gram_t`.
    public init(_ value: Megagram_f) {
        self.rawValue = Mg_f_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Megagram_d`.
    ///
    /// - Parameter value: A `Megagram_d` value to convert to a `Gram_t`.
    public init(_ value: Megagram_d) {
        self.rawValue = Mg_d_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Microgram_t`.
    ///
    /// - Parameter value: A `Microgram_t` value to convert to a `Gram_t`.
    public init(_ value: Microgram_t) {
        self.rawValue = ug_t_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Microgram_u`.
    ///
    /// - Parameter value: A `Microgram_u` value to convert to a `Gram_t`.
    public init(_ value: Microgram_u) {
        self.rawValue = ug_u_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Microgram_f`.
    ///
    /// - Parameter value: A `Microgram_f` value to convert to a `Gram_t`.
    public init(_ value: Microgram_f) {
        self.rawValue = ug_f_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Microgram_d`.
    ///
    /// - Parameter value: A `Microgram_d` value to convert to a `Gram_t`.
    public init(_ value: Microgram_d) {
        self.rawValue = ug_d_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Milligram_t`.
    ///
    /// - Parameter value: A `Milligram_t` value to convert to a `Gram_t`.
    public init(_ value: Milligram_t) {
        self.rawValue = mg_t_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Milligram_u`.
    ///
    /// - Parameter value: A `Milligram_u` value to convert to a `Gram_t`.
    public init(_ value: Milligram_u) {
        self.rawValue = mg_u_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Milligram_f`.
    ///
    /// - Parameter value: A `Milligram_f` value to convert to a `Gram_t`.
    public init(_ value: Milligram_f) {
        self.rawValue = mg_f_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Milligram_d`.
    ///
    /// - Parameter value: A `Milligram_d` value to convert to a `Gram_t`.
    public init(_ value: Milligram_d) {
        self.rawValue = mg_d_to_g_t(value.rawValue)
    }

// MARK: - Converting From Other Precisions

    /// Create a `Gram_t` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Gram_t`.
    public init(_ value: Gram_d) {
        self.rawValue = g_d_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Gram_t`.
    public init(_ value: Gram_f) {
        self.rawValue = g_f_to_g_t(value.rawValue)
    }

    /// Create a `Gram_t` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Gram_t`.
    public init(_ value: Gram_u) {
        self.rawValue = g_u_to_g_t(value.rawValue)
    }

}

/// An unsigned integer type for the gram unit.
public struct Gram_u: GUUnitsUType, Hashable, Codable {

// MARK: - Converting Between The Underlying guunits C Type

    /// Convert to the guunits underlying C type `gram_u`
    public let rawValue: gram_u

    /// Create a `Gram_u` from the underlying guunits C type `gram_u`.
    public init(rawValue: gram_u) {
        self.rawValue = rawValue
    }

// MARK: - Converting From Swift Numeric Types

    /// Create a `Gram_u` by converting a `Double`.
    ///
    /// - Parameter value: A `Double` value to convert to a `Gram_u`.
    public init(_ value: Double) {
        self.rawValue = d_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `Float`.
    ///
    /// - Parameter value: A `Float` value to convert to a `Gram_u`.
    public init(_ value: Float) {
        self.rawValue = f_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `Int`.
    ///
    /// - Parameter value: A `Int` value to convert to a `Gram_u`.
    public init(_ value: Int) {
        self.rawValue = i64_to_g_u(Int64(value))
    }

    /// Create a `Gram_u` by converting a `Int16`.
    ///
    /// - Parameter value: A `Int16` value to convert to a `Gram_u`.
    public init(_ value: Int16) {
        self.rawValue = i16_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `Int32`.
    ///
    /// - Parameter value: A `Int32` value to convert to a `Gram_u`.
    public init(_ value: Int32) {
        self.rawValue = i32_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `Int64`.
    ///
    /// - Parameter value: A `Int64` value to convert to a `Gram_u`.
    public init(_ value: Int64) {
        self.rawValue = i64_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `Int8`.
    ///
    /// - Parameter value: A `Int8` value to convert to a `Gram_u`.
    public init(_ value: Int8) {
        self.rawValue = i8_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `UInt`.
    ///
    /// - Parameter value: A `UInt` value to convert to a `Gram_u`.
    public init(_ value: UInt) {
        self.rawValue = u64_to_g_u(UInt64(value))
    }

    /// Create a `Gram_u` by converting a `UInt16`.
    ///
    /// - Parameter value: A `UInt16` value to convert to a `Gram_u`.
    public init(_ value: UInt16) {
        self.rawValue = u16_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `UInt32`.
    ///
    /// - Parameter value: A `UInt32` value to convert to a `Gram_u`.
    public init(_ value: UInt32) {
        self.rawValue = u32_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `UInt64`.
    ///
    /// - Parameter value: A `UInt64` value to convert to a `Gram_u`.
    public init(_ value: UInt64) {
        self.rawValue = u64_to_g_u(value)
    }

    /// Create a `Gram_u` by converting a `UInt8`.
    ///
    /// - Parameter value: A `UInt8` value to convert to a `Gram_u`.
    public init(_ value: UInt8) {
        self.rawValue = u8_to_g_u(value)
    }

// MARK: - Converting From Other Units

    /// Create a `Gram_u` by converting a `Mass`.
    ///
    /// - Parameter value: A `Mass` value to convert to a `Gram_u`.
    public init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

    /// Create a `Gram_u` by converting a `Kilogram_t`.
    ///
    /// - Parameter value: A `Kilogram_t` value to convert to a `Gram_u`.
    public init(_ value: Kilogram_t) {
        self.rawValue = kg_t_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Kilogram_u`.
    ///
    /// - Parameter value: A `Kilogram_u` value to convert to a `Gram_u`.
    public init(_ value: Kilogram_u) {
        self.rawValue = kg_u_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Kilogram_f`.
    ///
    /// - Parameter value: A `Kilogram_f` value to convert to a `Gram_u`.
    public init(_ value: Kilogram_f) {
        self.rawValue = kg_f_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Kilogram_d`.
    ///
    /// - Parameter value: A `Kilogram_d` value to convert to a `Gram_u`.
    public init(_ value: Kilogram_d) {
        self.rawValue = kg_d_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Megagram_t`.
    ///
    /// - Parameter value: A `Megagram_t` value to convert to a `Gram_u`.
    public init(_ value: Megagram_t) {
        self.rawValue = Mg_t_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Megagram_u`.
    ///
    /// - Parameter value: A `Megagram_u` value to convert to a `Gram_u`.
    public init(_ value: Megagram_u) {
        self.rawValue = Mg_u_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Megagram_f`.
    ///
    /// - Parameter value: A `Megagram_f` value to convert to a `Gram_u`.
    public init(_ value: Megagram_f) {
        self.rawValue = Mg_f_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Megagram_d`.
    ///
    /// - Parameter value: A `Megagram_d` value to convert to a `Gram_u`.
    public init(_ value: Megagram_d) {
        self.rawValue = Mg_d_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Microgram_t`.
    ///
    /// - Parameter value: A `Microgram_t` value to convert to a `Gram_u`.
    public init(_ value: Microgram_t) {
        self.rawValue = ug_t_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Microgram_u`.
    ///
    /// - Parameter value: A `Microgram_u` value to convert to a `Gram_u`.
    public init(_ value: Microgram_u) {
        self.rawValue = ug_u_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Microgram_f`.
    ///
    /// - Parameter value: A `Microgram_f` value to convert to a `Gram_u`.
    public init(_ value: Microgram_f) {
        self.rawValue = ug_f_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Microgram_d`.
    ///
    /// - Parameter value: A `Microgram_d` value to convert to a `Gram_u`.
    public init(_ value: Microgram_d) {
        self.rawValue = ug_d_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Milligram_t`.
    ///
    /// - Parameter value: A `Milligram_t` value to convert to a `Gram_u`.
    public init(_ value: Milligram_t) {
        self.rawValue = mg_t_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Milligram_u`.
    ///
    /// - Parameter value: A `Milligram_u` value to convert to a `Gram_u`.
    public init(_ value: Milligram_u) {
        self.rawValue = mg_u_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Milligram_f`.
    ///
    /// - Parameter value: A `Milligram_f` value to convert to a `Gram_u`.
    public init(_ value: Milligram_f) {
        self.rawValue = mg_f_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Milligram_d`.
    ///
    /// - Parameter value: A `Milligram_d` value to convert to a `Gram_u`.
    public init(_ value: Milligram_d) {
        self.rawValue = mg_d_to_g_u(value.rawValue)
    }

// MARK: - Converting From Other Precisions

    /// Create a `Gram_u` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Gram_u`.
    public init(_ value: Gram_d) {
        self.rawValue = g_d_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Gram_u`.
    public init(_ value: Gram_f) {
        self.rawValue = g_f_to_g_u(value.rawValue)
    }

    /// Create a `Gram_u` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Gram_u`.
    public init(_ value: Gram_t) {
        self.rawValue = g_t_to_g_u(value.rawValue)
    }

}

/// A floating point type for the gram unit.
public struct Gram_f: GUUnitsFType, Hashable, Codable {

// MARK: - Converting Between The Underlying guunits C Type

    /// Convert to the guunits underlying C type `gram_f`
    public let rawValue: gram_f

    /// Create a `Gram_f` from the underlying guunits C type `gram_f`.
    public init(rawValue: gram_f) {
        self.rawValue = rawValue
    }

// MARK: - Converting From Swift Numeric Types

    /// Create a `Gram_f` by converting a `Double`.
    ///
    /// - Parameter value: A `Double` value to convert to a `Gram_f`.
    public init(_ value: Double) {
        self.rawValue = d_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `Float`.
    ///
    /// - Parameter value: A `Float` value to convert to a `Gram_f`.
    public init(_ value: Float) {
        self.rawValue = f_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `Int`.
    ///
    /// - Parameter value: A `Int` value to convert to a `Gram_f`.
    public init(_ value: Int) {
        self.rawValue = i64_to_g_f(Int64(value))
    }

    /// Create a `Gram_f` by converting a `Int16`.
    ///
    /// - Parameter value: A `Int16` value to convert to a `Gram_f`.
    public init(_ value: Int16) {
        self.rawValue = i16_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `Int32`.
    ///
    /// - Parameter value: A `Int32` value to convert to a `Gram_f`.
    public init(_ value: Int32) {
        self.rawValue = i32_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `Int64`.
    ///
    /// - Parameter value: A `Int64` value to convert to a `Gram_f`.
    public init(_ value: Int64) {
        self.rawValue = i64_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `Int8`.
    ///
    /// - Parameter value: A `Int8` value to convert to a `Gram_f`.
    public init(_ value: Int8) {
        self.rawValue = i8_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `UInt`.
    ///
    /// - Parameter value: A `UInt` value to convert to a `Gram_f`.
    public init(_ value: UInt) {
        self.rawValue = u64_to_g_f(UInt64(value))
    }

    /// Create a `Gram_f` by converting a `UInt16`.
    ///
    /// - Parameter value: A `UInt16` value to convert to a `Gram_f`.
    public init(_ value: UInt16) {
        self.rawValue = u16_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `UInt32`.
    ///
    /// - Parameter value: A `UInt32` value to convert to a `Gram_f`.
    public init(_ value: UInt32) {
        self.rawValue = u32_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `UInt64`.
    ///
    /// - Parameter value: A `UInt64` value to convert to a `Gram_f`.
    public init(_ value: UInt64) {
        self.rawValue = u64_to_g_f(value)
    }

    /// Create a `Gram_f` by converting a `UInt8`.
    ///
    /// - Parameter value: A `UInt8` value to convert to a `Gram_f`.
    public init(_ value: UInt8) {
        self.rawValue = u8_to_g_f(value)
    }

// MARK: - Converting From Other Units

    /// Create a `Gram_f` by converting a `Mass`.
    ///
    /// - Parameter value: A `Mass` value to convert to a `Gram_f`.
    public init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

    /// Create a `Gram_f` by converting a `Kilogram_t`.
    ///
    /// - Parameter value: A `Kilogram_t` value to convert to a `Gram_f`.
    public init(_ value: Kilogram_t) {
        self.rawValue = kg_t_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Kilogram_u`.
    ///
    /// - Parameter value: A `Kilogram_u` value to convert to a `Gram_f`.
    public init(_ value: Kilogram_u) {
        self.rawValue = kg_u_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Kilogram_f`.
    ///
    /// - Parameter value: A `Kilogram_f` value to convert to a `Gram_f`.
    public init(_ value: Kilogram_f) {
        self.rawValue = kg_f_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Kilogram_d`.
    ///
    /// - Parameter value: A `Kilogram_d` value to convert to a `Gram_f`.
    public init(_ value: Kilogram_d) {
        self.rawValue = kg_d_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Megagram_t`.
    ///
    /// - Parameter value: A `Megagram_t` value to convert to a `Gram_f`.
    public init(_ value: Megagram_t) {
        self.rawValue = Mg_t_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Megagram_u`.
    ///
    /// - Parameter value: A `Megagram_u` value to convert to a `Gram_f`.
    public init(_ value: Megagram_u) {
        self.rawValue = Mg_u_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Megagram_f`.
    ///
    /// - Parameter value: A `Megagram_f` value to convert to a `Gram_f`.
    public init(_ value: Megagram_f) {
        self.rawValue = Mg_f_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Megagram_d`.
    ///
    /// - Parameter value: A `Megagram_d` value to convert to a `Gram_f`.
    public init(_ value: Megagram_d) {
        self.rawValue = Mg_d_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Microgram_t`.
    ///
    /// - Parameter value: A `Microgram_t` value to convert to a `Gram_f`.
    public init(_ value: Microgram_t) {
        self.rawValue = ug_t_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Microgram_u`.
    ///
    /// - Parameter value: A `Microgram_u` value to convert to a `Gram_f`.
    public init(_ value: Microgram_u) {
        self.rawValue = ug_u_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Microgram_f`.
    ///
    /// - Parameter value: A `Microgram_f` value to convert to a `Gram_f`.
    public init(_ value: Microgram_f) {
        self.rawValue = ug_f_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Microgram_d`.
    ///
    /// - Parameter value: A `Microgram_d` value to convert to a `Gram_f`.
    public init(_ value: Microgram_d) {
        self.rawValue = ug_d_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Milligram_t`.
    ///
    /// - Parameter value: A `Milligram_t` value to convert to a `Gram_f`.
    public init(_ value: Milligram_t) {
        self.rawValue = mg_t_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Milligram_u`.
    ///
    /// - Parameter value: A `Milligram_u` value to convert to a `Gram_f`.
    public init(_ value: Milligram_u) {
        self.rawValue = mg_u_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Milligram_f`.
    ///
    /// - Parameter value: A `Milligram_f` value to convert to a `Gram_f`.
    public init(_ value: Milligram_f) {
        self.rawValue = mg_f_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Milligram_d`.
    ///
    /// - Parameter value: A `Milligram_d` value to convert to a `Gram_f`.
    public init(_ value: Milligram_d) {
        self.rawValue = mg_d_to_g_f(value.rawValue)
    }

// MARK: - Converting From Other Precisions

    /// Create a `Gram_f` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Gram_f`.
    public init(_ value: Gram_d) {
        self.rawValue = g_d_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Gram_f`.
    public init(_ value: Gram_t) {
        self.rawValue = g_t_to_g_f(value.rawValue)
    }

    /// Create a `Gram_f` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Gram_f`.
    public init(_ value: Gram_u) {
        self.rawValue = g_u_to_g_f(value.rawValue)
    }

}

/// A double type for the gram unit.
public struct Gram_d: GUUnitsDType, Hashable, Codable {

// MARK: - Converting Between The Underlying guunits C Type

    /// Convert to the guunits underlying C type `gram_d`
    public let rawValue: gram_d

    /// Create a `Gram_d` from the underlying guunits C type `gram_d`.
    public init(rawValue: gram_d) {
        self.rawValue = rawValue
    }

// MARK: - Converting From Swift Numeric Types

    /// Create a `Gram_d` by converting a `Double`.
    ///
    /// - Parameter value: A `Double` value to convert to a `Gram_d`.
    public init(_ value: Double) {
        self.rawValue = d_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `Float`.
    ///
    /// - Parameter value: A `Float` value to convert to a `Gram_d`.
    public init(_ value: Float) {
        self.rawValue = f_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `Int`.
    ///
    /// - Parameter value: A `Int` value to convert to a `Gram_d`.
    public init(_ value: Int) {
        self.rawValue = i64_to_g_d(Int64(value))
    }

    /// Create a `Gram_d` by converting a `Int16`.
    ///
    /// - Parameter value: A `Int16` value to convert to a `Gram_d`.
    public init(_ value: Int16) {
        self.rawValue = i16_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `Int32`.
    ///
    /// - Parameter value: A `Int32` value to convert to a `Gram_d`.
    public init(_ value: Int32) {
        self.rawValue = i32_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `Int64`.
    ///
    /// - Parameter value: A `Int64` value to convert to a `Gram_d`.
    public init(_ value: Int64) {
        self.rawValue = i64_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `Int8`.
    ///
    /// - Parameter value: A `Int8` value to convert to a `Gram_d`.
    public init(_ value: Int8) {
        self.rawValue = i8_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `UInt`.
    ///
    /// - Parameter value: A `UInt` value to convert to a `Gram_d`.
    public init(_ value: UInt) {
        self.rawValue = u64_to_g_d(UInt64(value))
    }

    /// Create a `Gram_d` by converting a `UInt16`.
    ///
    /// - Parameter value: A `UInt16` value to convert to a `Gram_d`.
    public init(_ value: UInt16) {
        self.rawValue = u16_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `UInt32`.
    ///
    /// - Parameter value: A `UInt32` value to convert to a `Gram_d`.
    public init(_ value: UInt32) {
        self.rawValue = u32_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `UInt64`.
    ///
    /// - Parameter value: A `UInt64` value to convert to a `Gram_d`.
    public init(_ value: UInt64) {
        self.rawValue = u64_to_g_d(value)
    }

    /// Create a `Gram_d` by converting a `UInt8`.
    ///
    /// - Parameter value: A `UInt8` value to convert to a `Gram_d`.
    public init(_ value: UInt8) {
        self.rawValue = u8_to_g_d(value)
    }

// MARK: - Converting From Other Units

    /// Create a `Gram_d` by converting a `Mass`.
    ///
    /// - Parameter value: A `Mass` value to convert to a `Gram_d`.
    public init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

    /// Create a `Gram_d` by converting a `Kilogram_t`.
    ///
    /// - Parameter value: A `Kilogram_t` value to convert to a `Gram_d`.
    public init(_ value: Kilogram_t) {
        self.rawValue = kg_t_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Kilogram_u`.
    ///
    /// - Parameter value: A `Kilogram_u` value to convert to a `Gram_d`.
    public init(_ value: Kilogram_u) {
        self.rawValue = kg_u_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Kilogram_f`.
    ///
    /// - Parameter value: A `Kilogram_f` value to convert to a `Gram_d`.
    public init(_ value: Kilogram_f) {
        self.rawValue = kg_f_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Kilogram_d`.
    ///
    /// - Parameter value: A `Kilogram_d` value to convert to a `Gram_d`.
    public init(_ value: Kilogram_d) {
        self.rawValue = kg_d_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Megagram_t`.
    ///
    /// - Parameter value: A `Megagram_t` value to convert to a `Gram_d`.
    public init(_ value: Megagram_t) {
        self.rawValue = Mg_t_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Megagram_u`.
    ///
    /// - Parameter value: A `Megagram_u` value to convert to a `Gram_d`.
    public init(_ value: Megagram_u) {
        self.rawValue = Mg_u_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Megagram_f`.
    ///
    /// - Parameter value: A `Megagram_f` value to convert to a `Gram_d`.
    public init(_ value: Megagram_f) {
        self.rawValue = Mg_f_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Megagram_d`.
    ///
    /// - Parameter value: A `Megagram_d` value to convert to a `Gram_d`.
    public init(_ value: Megagram_d) {
        self.rawValue = Mg_d_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Microgram_t`.
    ///
    /// - Parameter value: A `Microgram_t` value to convert to a `Gram_d`.
    public init(_ value: Microgram_t) {
        self.rawValue = ug_t_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Microgram_u`.
    ///
    /// - Parameter value: A `Microgram_u` value to convert to a `Gram_d`.
    public init(_ value: Microgram_u) {
        self.rawValue = ug_u_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Microgram_f`.
    ///
    /// - Parameter value: A `Microgram_f` value to convert to a `Gram_d`.
    public init(_ value: Microgram_f) {
        self.rawValue = ug_f_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Microgram_d`.
    ///
    /// - Parameter value: A `Microgram_d` value to convert to a `Gram_d`.
    public init(_ value: Microgram_d) {
        self.rawValue = ug_d_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Milligram_t`.
    ///
    /// - Parameter value: A `Milligram_t` value to convert to a `Gram_d`.
    public init(_ value: Milligram_t) {
        self.rawValue = mg_t_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Milligram_u`.
    ///
    /// - Parameter value: A `Milligram_u` value to convert to a `Gram_d`.
    public init(_ value: Milligram_u) {
        self.rawValue = mg_u_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Milligram_f`.
    ///
    /// - Parameter value: A `Milligram_f` value to convert to a `Gram_d`.
    public init(_ value: Milligram_f) {
        self.rawValue = mg_f_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Milligram_d`.
    ///
    /// - Parameter value: A `Milligram_d` value to convert to a `Gram_d`.
    public init(_ value: Milligram_d) {
        self.rawValue = mg_d_to_g_d(value.rawValue)
    }

// MARK: - Converting From Other Precisions

    /// Create a `Gram_d` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Gram_d`.
    public init(_ value: Gram_f) {
        self.rawValue = g_f_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Gram_d`.
    public init(_ value: Gram_t) {
        self.rawValue = g_t_to_g_d(value.rawValue)
    }

    /// Create a `Gram_d` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Gram_d`.
    public init(_ value: Gram_u) {
        self.rawValue = g_u_to_g_d(value.rawValue)
    }

}
```

#### The Extensions for the Gram Structs

```swift
public extension Double {

// MARK: Creating a Double From The Gram Units

    /// Create a `Double` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Double`.
    init(_ value: Gram_t) {
        self = g_t_to_d(value.rawValue)
    }

    /// Create a `Double` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Double`.
    init(_ value: Gram_u) {
        self = g_u_to_d(value.rawValue)
    }

    /// Create a `Double` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Double`.
    init(_ value: Gram_f) {
        self = g_f_to_d(value.rawValue)
    }

    /// Create a `Double` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Double`.
    init(_ value: Gram_d) {
        self = g_d_to_d(value.rawValue)
    }

}

public extension Float {

// MARK: Creating a Float From The Gram Units

    /// Create a `Float` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Float`.
    init(_ value: Gram_t) {
        self = g_t_to_f(value.rawValue)
    }

    /// Create a `Float` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Float`.
    init(_ value: Gram_u) {
        self = g_u_to_f(value.rawValue)
    }

    /// Create a `Float` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Float`.
    init(_ value: Gram_f) {
        self = g_f_to_f(value.rawValue)
    }

    /// Create a `Float` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Float`.
    init(_ value: Gram_d) {
        self = g_d_to_f(value.rawValue)
    }

}

public extension Int {

// MARK: Creating a Int From The Gram Units

    /// Create a `Int` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Int`.
    init(_ value: Gram_t) {
        self = Int(g_t_to_i64(value.rawValue))
    }

    /// Create a `Int` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Int`.
    init(_ value: Gram_u) {
        self = Int(g_u_to_i64(value.rawValue))
    }

    /// Create a `Int` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Int`.
    init(_ value: Gram_f) {
        self = Int(g_f_to_i64(value.rawValue))
    }

    /// Create a `Int` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Int`.
    init(_ value: Gram_d) {
        self = Int(g_d_to_i64(value.rawValue))
    }

}

public extension Int16 {

// MARK: Creating a Int16 From The Gram Units

    /// Create a `Int16` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Int16`.
    init(_ value: Gram_t) {
        self = g_t_to_i16(value.rawValue)
    }

    /// Create a `Int16` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Int16`.
    init(_ value: Gram_u) {
        self = g_u_to_i16(value.rawValue)
    }

    /// Create a `Int16` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Int16`.
    init(_ value: Gram_f) {
        self = g_f_to_i16(value.rawValue)
    }

    /// Create a `Int16` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Int16`.
    init(_ value: Gram_d) {
        self = g_d_to_i16(value.rawValue)
    }

}

public extension Int32 {

// MARK: Creating a Int32 From The Gram Units

    /// Create a `Int32` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Int32`.
    init(_ value: Gram_t) {
        self = g_t_to_i32(value.rawValue)
    }

    /// Create a `Int32` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Int32`.
    init(_ value: Gram_u) {
        self = g_u_to_i32(value.rawValue)
    }

    /// Create a `Int32` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Int32`.
    init(_ value: Gram_f) {
        self = g_f_to_i32(value.rawValue)
    }

    /// Create a `Int32` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Int32`.
    init(_ value: Gram_d) {
        self = g_d_to_i32(value.rawValue)
    }

}

public extension Int64 {

// MARK: Creating a Int64 From The Gram Units

    /// Create a `Int64` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Int64`.
    init(_ value: Gram_t) {
        self = g_t_to_i64(value.rawValue)
    }

    /// Create a `Int64` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Int64`.
    init(_ value: Gram_u) {
        self = g_u_to_i64(value.rawValue)
    }

    /// Create a `Int64` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Int64`.
    init(_ value: Gram_f) {
        self = g_f_to_i64(value.rawValue)
    }

    /// Create a `Int64` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Int64`.
    init(_ value: Gram_d) {
        self = g_d_to_i64(value.rawValue)
    }

}

public extension Int8 {

// MARK: Creating a Int8 From The Gram Units

    /// Create a `Int8` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Int8`.
    init(_ value: Gram_t) {
        self = g_t_to_i8(value.rawValue)
    }

    /// Create a `Int8` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Int8`.
    init(_ value: Gram_u) {
        self = g_u_to_i8(value.rawValue)
    }

    /// Create a `Int8` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Int8`.
    init(_ value: Gram_f) {
        self = g_f_to_i8(value.rawValue)
    }

    /// Create a `Int8` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Int8`.
    init(_ value: Gram_d) {
        self = g_d_to_i8(value.rawValue)
    }

}

public extension UInt {

// MARK: Creating a UInt From The Gram Units

    /// Create a `UInt` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `UInt`.
    init(_ value: Gram_t) {
        self = UInt(g_t_to_u64(value.rawValue))
    }

    /// Create a `UInt` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `UInt`.
    init(_ value: Gram_u) {
        self = UInt(g_u_to_u64(value.rawValue))
    }

    /// Create a `UInt` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `UInt`.
    init(_ value: Gram_f) {
        self = UInt(g_f_to_u64(value.rawValue))
    }

    /// Create a `UInt` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `UInt`.
    init(_ value: Gram_d) {
        self = UInt(g_d_to_u64(value.rawValue))
    }

}

public extension UInt16 {

// MARK: Creating a UInt16 From The Gram Units

    /// Create a `UInt16` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `UInt16`.
    init(_ value: Gram_t) {
        self = g_t_to_u16(value.rawValue)
    }

    /// Create a `UInt16` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `UInt16`.
    init(_ value: Gram_u) {
        self = g_u_to_u16(value.rawValue)
    }

    /// Create a `UInt16` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `UInt16`.
    init(_ value: Gram_f) {
        self = g_f_to_u16(value.rawValue)
    }

    /// Create a `UInt16` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `UInt16`.
    init(_ value: Gram_d) {
        self = g_d_to_u16(value.rawValue)
    }

}

public extension UInt32 {

// MARK: Creating a UInt32 From The Gram Units

    /// Create a `UInt32` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `UInt32`.
    init(_ value: Gram_t) {
        self = g_t_to_u32(value.rawValue)
    }

    /// Create a `UInt32` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `UInt32`.
    init(_ value: Gram_u) {
        self = g_u_to_u32(value.rawValue)
    }

    /// Create a `UInt32` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `UInt32`.
    init(_ value: Gram_f) {
        self = g_f_to_u32(value.rawValue)
    }

    /// Create a `UInt32` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `UInt32`.
    init(_ value: Gram_d) {
        self = g_d_to_u32(value.rawValue)
    }

}

public extension UInt64 {

// MARK: Creating a UInt64 From The Gram Units

    /// Create a `UInt64` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `UInt64`.
    init(_ value: Gram_t) {
        self = g_t_to_u64(value.rawValue)
    }

    /// Create a `UInt64` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `UInt64`.
    init(_ value: Gram_u) {
        self = g_u_to_u64(value.rawValue)
    }

    /// Create a `UInt64` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `UInt64`.
    init(_ value: Gram_f) {
        self = g_f_to_u64(value.rawValue)
    }

    /// Create a `UInt64` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `UInt64`.
    init(_ value: Gram_d) {
        self = g_d_to_u64(value.rawValue)
    }

}

public extension UInt8 {

// MARK: Creating a UInt8 From The Gram Units

    /// Create a `UInt8` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `UInt8`.
    init(_ value: Gram_t) {
        self = g_t_to_u8(value.rawValue)
    }

    /// Create a `UInt8` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `UInt8`.
    init(_ value: Gram_u) {
        self = g_u_to_u8(value.rawValue)
    }

    /// Create a `UInt8` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `UInt8`.
    init(_ value: Gram_f) {
        self = g_f_to_u8(value.rawValue)
    }

    /// Create a `UInt8` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `UInt8`.
    init(_ value: Gram_d) {
        self = g_d_to_u8(value.rawValue)
    }

}
```

#### The Category Type

```swift
/// Provides a generic way of working with mass units.
///
/// This type is useful as it allows you to specify that you are
/// working with a particular type of unit, without having to
/// specify in which units you are working. This type allows you
/// to convert to any of the related underlying unit types.
///
/// It is recommended that if you are creating a library or public
/// api of some sort, then this type should be used in your function
/// declaration over the more specific underlying unit types that
/// this type can convert to. If you are performing some
/// sort of calculations then you obviously need to use one of the
/// underlying unit types that this type can convert to; however,
/// the public api should take this type which you should then
/// convert to the underlying unit type you need.
///
/// - Attention: Because this type is numeric, and therefore allows
/// you to perform arithmetic, this type must behave like a double
/// as a double has the highest precision. If this is not
/// necessary, then you may opt to use one of the integer
/// variants of the underlying unit types that this type can convert
/// to.
public struct Mass: Sendable, Hashable, Codable {

    enum MassTypes: Sendable, Hashable, Codable {

        case microgram_t(_ microgram_t: Microgram_t)

        case microgram_u(_ microgram_u: Microgram_u)

        case microgram_f(_ microgram_f: Microgram_f)

        case microgram_d(_ microgram_d: Microgram_d)

        case milligram_t(_ milligram_t: Milligram_t)

        case milligram_u(_ milligram_u: Milligram_u)

        case milligram_f(_ milligram_f: Milligram_f)

        case milligram_d(_ milligram_d: Milligram_d)

        case gram_t(_ gram_t: Gram_t)

        case gram_u(_ gram_u: Gram_u)

        case gram_f(_ gram_f: Gram_f)

        case gram_d(_ gram_d: Gram_d)

        case kilogram_t(_ kilogram_t: Kilogram_t)

        case kilogram_u(_ kilogram_u: Kilogram_u)

        case kilogram_f(_ kilogram_f: Kilogram_f)

        case kilogram_d(_ kilogram_d: Kilogram_d)

        case megagram_t(_ megagram_t: Megagram_t)

        case megagram_u(_ megagram_u: Megagram_u)

        case megagram_f(_ megagram_f: Megagram_f)

        case megagram_d(_ megagram_d: Megagram_d)

    }

// MARK: - Converting Between The Internal Representation

    /// Always store internally as a `MassTypes`
    let rawValue: MassTypes

    /// Initialise `Mass` from its internally representation.
    init(rawValue: MassTypes) {
        self.rawValue = rawValue
    }

// MARK: - Converting To The Underlying Unit Types

    /// Create a `Microgram_t`.
    public var microgram_t: Microgram_t {
        switch rawValue {
        case .microgram_t(let value):
            return Microgram_t(value)
        case .microgram_u(let value):
            return Microgram_t(value)
        case .microgram_f(let value):
            return Microgram_t(value)
        case .microgram_d(let value):
            return Microgram_t(value)
        case .milligram_t(let value):
            return Microgram_t(value)
        case .milligram_u(let value):
            return Microgram_t(value)
        case .milligram_f(let value):
            return Microgram_t(value)
        case .milligram_d(let value):
            return Microgram_t(value)
        case .gram_t(let value):
            return Microgram_t(value)
        case .gram_u(let value):
            return Microgram_t(value)
        case .gram_f(let value):
            return Microgram_t(value)
        case .gram_d(let value):
            return Microgram_t(value)
        case .kilogram_t(let value):
            return Microgram_t(value)
        case .kilogram_u(let value):
            return Microgram_t(value)
        case .kilogram_f(let value):
            return Microgram_t(value)
        case .kilogram_d(let value):
            return Microgram_t(value)
        case .megagram_t(let value):
            return Microgram_t(value)
        case .megagram_u(let value):
            return Microgram_t(value)
        case .megagram_f(let value):
            return Microgram_t(value)
        case .megagram_d(let value):
            return Microgram_t(value)
        }
    }

    /// Create a `Microgram_u`.
    public var microgram_u: Microgram_u {
        switch rawValue {
        case .microgram_t(let value):
            return Microgram_u(value)
        case .microgram_u(let value):
            return Microgram_u(value)
        case .microgram_f(let value):
            return Microgram_u(value)
        case .microgram_d(let value):
            return Microgram_u(value)
        case .milligram_t(let value):
            return Microgram_u(value)
        case .milligram_u(let value):
            return Microgram_u(value)
        case .milligram_f(let value):
            return Microgram_u(value)
        case .milligram_d(let value):
            return Microgram_u(value)
        case .gram_t(let value):
            return Microgram_u(value)
        case .gram_u(let value):
            return Microgram_u(value)
        case .gram_f(let value):
            return Microgram_u(value)
        case .gram_d(let value):
            return Microgram_u(value)
        case .kilogram_t(let value):
            return Microgram_u(value)
        case .kilogram_u(let value):
            return Microgram_u(value)
        case .kilogram_f(let value):
            return Microgram_u(value)
        case .kilogram_d(let value):
            return Microgram_u(value)
        case .megagram_t(let value):
            return Microgram_u(value)
        case .megagram_u(let value):
            return Microgram_u(value)
        case .megagram_f(let value):
            return Microgram_u(value)
        case .megagram_d(let value):
            return Microgram_u(value)
        }
    }

    /// Create a `Microgram_f`.
    public var microgram_f: Microgram_f {
        switch rawValue {
        case .microgram_t(let value):
            return Microgram_f(value)
        case .microgram_u(let value):
            return Microgram_f(value)
        case .microgram_f(let value):
            return Microgram_f(value)
        case .microgram_d(let value):
            return Microgram_f(value)
        case .milligram_t(let value):
            return Microgram_f(value)
        case .milligram_u(let value):
            return Microgram_f(value)
        case .milligram_f(let value):
            return Microgram_f(value)
        case .milligram_d(let value):
            return Microgram_f(value)
        case .gram_t(let value):
            return Microgram_f(value)
        case .gram_u(let value):
            return Microgram_f(value)
        case .gram_f(let value):
            return Microgram_f(value)
        case .gram_d(let value):
            return Microgram_f(value)
        case .kilogram_t(let value):
            return Microgram_f(value)
        case .kilogram_u(let value):
            return Microgram_f(value)
        case .kilogram_f(let value):
            return Microgram_f(value)
        case .kilogram_d(let value):
            return Microgram_f(value)
        case .megagram_t(let value):
            return Microgram_f(value)
        case .megagram_u(let value):
            return Microgram_f(value)
        case .megagram_f(let value):
            return Microgram_f(value)
        case .megagram_d(let value):
            return Microgram_f(value)
        }
    }

    /// Create a `Microgram_d`.
    public var microgram_d: Microgram_d {
        switch rawValue {
        case .microgram_t(let value):
            return Microgram_d(value)
        case .microgram_u(let value):
            return Microgram_d(value)
        case .microgram_f(let value):
            return Microgram_d(value)
        case .microgram_d(let value):
            return Microgram_d(value)
        case .milligram_t(let value):
            return Microgram_d(value)
        case .milligram_u(let value):
            return Microgram_d(value)
        case .milligram_f(let value):
            return Microgram_d(value)
        case .milligram_d(let value):
            return Microgram_d(value)
        case .gram_t(let value):
            return Microgram_d(value)
        case .gram_u(let value):
            return Microgram_d(value)
        case .gram_f(let value):
            return Microgram_d(value)
        case .gram_d(let value):
            return Microgram_d(value)
        case .kilogram_t(let value):
            return Microgram_d(value)
        case .kilogram_u(let value):
            return Microgram_d(value)
        case .kilogram_f(let value):
            return Microgram_d(value)
        case .kilogram_d(let value):
            return Microgram_d(value)
        case .megagram_t(let value):
            return Microgram_d(value)
        case .megagram_u(let value):
            return Microgram_d(value)
        case .megagram_f(let value):
            return Microgram_d(value)
        case .megagram_d(let value):
            return Microgram_d(value)
        }
    }

    /// Create a `Milligram_t`.
    public var milligram_t: Milligram_t {
        switch rawValue {
        case .microgram_t(let value):
            return Milligram_t(value)
        case .microgram_u(let value):
            return Milligram_t(value)
        case .microgram_f(let value):
            return Milligram_t(value)
        case .microgram_d(let value):
            return Milligram_t(value)
        case .milligram_t(let value):
            return Milligram_t(value)
        case .milligram_u(let value):
            return Milligram_t(value)
        case .milligram_f(let value):
            return Milligram_t(value)
        case .milligram_d(let value):
            return Milligram_t(value)
        case .gram_t(let value):
            return Milligram_t(value)
        case .gram_u(let value):
            return Milligram_t(value)
        case .gram_f(let value):
            return Milligram_t(value)
        case .gram_d(let value):
            return Milligram_t(value)
        case .kilogram_t(let value):
            return Milligram_t(value)
        case .kilogram_u(let value):
            return Milligram_t(value)
        case .kilogram_f(let value):
            return Milligram_t(value)
        case .kilogram_d(let value):
            return Milligram_t(value)
        case .megagram_t(let value):
            return Milligram_t(value)
        case .megagram_u(let value):
            return Milligram_t(value)
        case .megagram_f(let value):
            return Milligram_t(value)
        case .megagram_d(let value):
            return Milligram_t(value)
        }
    }

    /// Create a `Milligram_u`.
    public var milligram_u: Milligram_u {
        switch rawValue {
        case .microgram_t(let value):
            return Milligram_u(value)
        case .microgram_u(let value):
            return Milligram_u(value)
        case .microgram_f(let value):
            return Milligram_u(value)
        case .microgram_d(let value):
            return Milligram_u(value)
        case .milligram_t(let value):
            return Milligram_u(value)
        case .milligram_u(let value):
            return Milligram_u(value)
        case .milligram_f(let value):
            return Milligram_u(value)
        case .milligram_d(let value):
            return Milligram_u(value)
        case .gram_t(let value):
            return Milligram_u(value)
        case .gram_u(let value):
            return Milligram_u(value)
        case .gram_f(let value):
            return Milligram_u(value)
        case .gram_d(let value):
            return Milligram_u(value)
        case .kilogram_t(let value):
            return Milligram_u(value)
        case .kilogram_u(let value):
            return Milligram_u(value)
        case .kilogram_f(let value):
            return Milligram_u(value)
        case .kilogram_d(let value):
            return Milligram_u(value)
        case .megagram_t(let value):
            return Milligram_u(value)
        case .megagram_u(let value):
            return Milligram_u(value)
        case .megagram_f(let value):
            return Milligram_u(value)
        case .megagram_d(let value):
            return Milligram_u(value)
        }
    }

    /// Create a `Milligram_f`.
    public var milligram_f: Milligram_f {
        switch rawValue {
        case .microgram_t(let value):
            return Milligram_f(value)
        case .microgram_u(let value):
            return Milligram_f(value)
        case .microgram_f(let value):
            return Milligram_f(value)
        case .microgram_d(let value):
            return Milligram_f(value)
        case .milligram_t(let value):
            return Milligram_f(value)
        case .milligram_u(let value):
            return Milligram_f(value)
        case .milligram_f(let value):
            return Milligram_f(value)
        case .milligram_d(let value):
            return Milligram_f(value)
        case .gram_t(let value):
            return Milligram_f(value)
        case .gram_u(let value):
            return Milligram_f(value)
        case .gram_f(let value):
            return Milligram_f(value)
        case .gram_d(let value):
            return Milligram_f(value)
        case .kilogram_t(let value):
            return Milligram_f(value)
        case .kilogram_u(let value):
            return Milligram_f(value)
        case .kilogram_f(let value):
            return Milligram_f(value)
        case .kilogram_d(let value):
            return Milligram_f(value)
        case .megagram_t(let value):
            return Milligram_f(value)
        case .megagram_u(let value):
            return Milligram_f(value)
        case .megagram_f(let value):
            return Milligram_f(value)
        case .megagram_d(let value):
            return Milligram_f(value)
        }
    }

    /// Create a `Milligram_d`.
    public var milligram_d: Milligram_d {
        switch rawValue {
        case .microgram_t(let value):
            return Milligram_d(value)
        case .microgram_u(let value):
            return Milligram_d(value)
        case .microgram_f(let value):
            return Milligram_d(value)
        case .microgram_d(let value):
            return Milligram_d(value)
        case .milligram_t(let value):
            return Milligram_d(value)
        case .milligram_u(let value):
            return Milligram_d(value)
        case .milligram_f(let value):
            return Milligram_d(value)
        case .milligram_d(let value):
            return Milligram_d(value)
        case .gram_t(let value):
            return Milligram_d(value)
        case .gram_u(let value):
            return Milligram_d(value)
        case .gram_f(let value):
            return Milligram_d(value)
        case .gram_d(let value):
            return Milligram_d(value)
        case .kilogram_t(let value):
            return Milligram_d(value)
        case .kilogram_u(let value):
            return Milligram_d(value)
        case .kilogram_f(let value):
            return Milligram_d(value)
        case .kilogram_d(let value):
            return Milligram_d(value)
        case .megagram_t(let value):
            return Milligram_d(value)
        case .megagram_u(let value):
            return Milligram_d(value)
        case .megagram_f(let value):
            return Milligram_d(value)
        case .megagram_d(let value):
            return Milligram_d(value)
        }
    }

    /// Create a `Gram_t`.
    public var gram_t: Gram_t {
        switch rawValue {
        case .microgram_t(let value):
            return Gram_t(value)
        case .microgram_u(let value):
            return Gram_t(value)
        case .microgram_f(let value):
            return Gram_t(value)
        case .microgram_d(let value):
            return Gram_t(value)
        case .milligram_t(let value):
            return Gram_t(value)
        case .milligram_u(let value):
            return Gram_t(value)
        case .milligram_f(let value):
            return Gram_t(value)
        case .milligram_d(let value):
            return Gram_t(value)
        case .gram_t(let value):
            return Gram_t(value)
        case .gram_u(let value):
            return Gram_t(value)
        case .gram_f(let value):
            return Gram_t(value)
        case .gram_d(let value):
            return Gram_t(value)
        case .kilogram_t(let value):
            return Gram_t(value)
        case .kilogram_u(let value):
            return Gram_t(value)
        case .kilogram_f(let value):
            return Gram_t(value)
        case .kilogram_d(let value):
            return Gram_t(value)
        case .megagram_t(let value):
            return Gram_t(value)
        case .megagram_u(let value):
            return Gram_t(value)
        case .megagram_f(let value):
            return Gram_t(value)
        case .megagram_d(let value):
            return Gram_t(value)
        }
    }

    /// Create a `Gram_u`.
    public var gram_u: Gram_u {
        switch rawValue {
        case .microgram_t(let value):
            return Gram_u(value)
        case .microgram_u(let value):
            return Gram_u(value)
        case .microgram_f(let value):
            return Gram_u(value)
        case .microgram_d(let value):
            return Gram_u(value)
        case .milligram_t(let value):
            return Gram_u(value)
        case .milligram_u(let value):
            return Gram_u(value)
        case .milligram_f(let value):
            return Gram_u(value)
        case .milligram_d(let value):
            return Gram_u(value)
        case .gram_t(let value):
            return Gram_u(value)
        case .gram_u(let value):
            return Gram_u(value)
        case .gram_f(let value):
            return Gram_u(value)
        case .gram_d(let value):
            return Gram_u(value)
        case .kilogram_t(let value):
            return Gram_u(value)
        case .kilogram_u(let value):
            return Gram_u(value)
        case .kilogram_f(let value):
            return Gram_u(value)
        case .kilogram_d(let value):
            return Gram_u(value)
        case .megagram_t(let value):
            return Gram_u(value)
        case .megagram_u(let value):
            return Gram_u(value)
        case .megagram_f(let value):
            return Gram_u(value)
        case .megagram_d(let value):
            return Gram_u(value)
        }
    }

    /// Create a `Gram_f`.
    public var gram_f: Gram_f {
        switch rawValue {
        case .microgram_t(let value):
            return Gram_f(value)
        case .microgram_u(let value):
            return Gram_f(value)
        case .microgram_f(let value):
            return Gram_f(value)
        case .microgram_d(let value):
            return Gram_f(value)
        case .milligram_t(let value):
            return Gram_f(value)
        case .milligram_u(let value):
            return Gram_f(value)
        case .milligram_f(let value):
            return Gram_f(value)
        case .milligram_d(let value):
            return Gram_f(value)
        case .gram_t(let value):
            return Gram_f(value)
        case .gram_u(let value):
            return Gram_f(value)
        case .gram_f(let value):
            return Gram_f(value)
        case .gram_d(let value):
            return Gram_f(value)
        case .kilogram_t(let value):
            return Gram_f(value)
        case .kilogram_u(let value):
            return Gram_f(value)
        case .kilogram_f(let value):
            return Gram_f(value)
        case .kilogram_d(let value):
            return Gram_f(value)
        case .megagram_t(let value):
            return Gram_f(value)
        case .megagram_u(let value):
            return Gram_f(value)
        case .megagram_f(let value):
            return Gram_f(value)
        case .megagram_d(let value):
            return Gram_f(value)
        }
    }

    /// Create a `Gram_d`.
    public var gram_d: Gram_d {
        switch rawValue {
        case .microgram_t(let value):
            return Gram_d(value)
        case .microgram_u(let value):
            return Gram_d(value)
        case .microgram_f(let value):
            return Gram_d(value)
        case .microgram_d(let value):
            return Gram_d(value)
        case .milligram_t(let value):
            return Gram_d(value)
        case .milligram_u(let value):
            return Gram_d(value)
        case .milligram_f(let value):
            return Gram_d(value)
        case .milligram_d(let value):
            return Gram_d(value)
        case .gram_t(let value):
            return Gram_d(value)
        case .gram_u(let value):
            return Gram_d(value)
        case .gram_f(let value):
            return Gram_d(value)
        case .gram_d(let value):
            return Gram_d(value)
        case .kilogram_t(let value):
            return Gram_d(value)
        case .kilogram_u(let value):
            return Gram_d(value)
        case .kilogram_f(let value):
            return Gram_d(value)
        case .kilogram_d(let value):
            return Gram_d(value)
        case .megagram_t(let value):
            return Gram_d(value)
        case .megagram_u(let value):
            return Gram_d(value)
        case .megagram_f(let value):
            return Gram_d(value)
        case .megagram_d(let value):
            return Gram_d(value)
        }
    }

    /// Create a `Kilogram_t`.
    public var kilogram_t: Kilogram_t {
        switch rawValue {
        case .microgram_t(let value):
            return Kilogram_t(value)
        case .microgram_u(let value):
            return Kilogram_t(value)
        case .microgram_f(let value):
            return Kilogram_t(value)
        case .microgram_d(let value):
            return Kilogram_t(value)
        case .milligram_t(let value):
            return Kilogram_t(value)
        case .milligram_u(let value):
            return Kilogram_t(value)
        case .milligram_f(let value):
            return Kilogram_t(value)
        case .milligram_d(let value):
            return Kilogram_t(value)
        case .gram_t(let value):
            return Kilogram_t(value)
        case .gram_u(let value):
            return Kilogram_t(value)
        case .gram_f(let value):
            return Kilogram_t(value)
        case .gram_d(let value):
            return Kilogram_t(value)
        case .kilogram_t(let value):
            return Kilogram_t(value)
        case .kilogram_u(let value):
            return Kilogram_t(value)
        case .kilogram_f(let value):
            return Kilogram_t(value)
        case .kilogram_d(let value):
            return Kilogram_t(value)
        case .megagram_t(let value):
            return Kilogram_t(value)
        case .megagram_u(let value):
            return Kilogram_t(value)
        case .megagram_f(let value):
            return Kilogram_t(value)
        case .megagram_d(let value):
            return Kilogram_t(value)
        }
    }

    /// Create a `Kilogram_u`.
    public var kilogram_u: Kilogram_u {
        switch rawValue {
        case .microgram_t(let value):
            return Kilogram_u(value)
        case .microgram_u(let value):
            return Kilogram_u(value)
        case .microgram_f(let value):
            return Kilogram_u(value)
        case .microgram_d(let value):
            return Kilogram_u(value)
        case .milligram_t(let value):
            return Kilogram_u(value)
        case .milligram_u(let value):
            return Kilogram_u(value)
        case .milligram_f(let value):
            return Kilogram_u(value)
        case .milligram_d(let value):
            return Kilogram_u(value)
        case .gram_t(let value):
            return Kilogram_u(value)
        case .gram_u(let value):
            return Kilogram_u(value)
        case .gram_f(let value):
            return Kilogram_u(value)
        case .gram_d(let value):
            return Kilogram_u(value)
        case .kilogram_t(let value):
            return Kilogram_u(value)
        case .kilogram_u(let value):
            return Kilogram_u(value)
        case .kilogram_f(let value):
            return Kilogram_u(value)
        case .kilogram_d(let value):
            return Kilogram_u(value)
        case .megagram_t(let value):
            return Kilogram_u(value)
        case .megagram_u(let value):
            return Kilogram_u(value)
        case .megagram_f(let value):
            return Kilogram_u(value)
        case .megagram_d(let value):
            return Kilogram_u(value)
        }
    }

    /// Create a `Kilogram_f`.
    public var kilogram_f: Kilogram_f {
        switch rawValue {
        case .microgram_t(let value):
            return Kilogram_f(value)
        case .microgram_u(let value):
            return Kilogram_f(value)
        case .microgram_f(let value):
            return Kilogram_f(value)
        case .microgram_d(let value):
            return Kilogram_f(value)
        case .milligram_t(let value):
            return Kilogram_f(value)
        case .milligram_u(let value):
            return Kilogram_f(value)
        case .milligram_f(let value):
            return Kilogram_f(value)
        case .milligram_d(let value):
            return Kilogram_f(value)
        case .gram_t(let value):
            return Kilogram_f(value)
        case .gram_u(let value):
            return Kilogram_f(value)
        case .gram_f(let value):
            return Kilogram_f(value)
        case .gram_d(let value):
            return Kilogram_f(value)
        case .kilogram_t(let value):
            return Kilogram_f(value)
        case .kilogram_u(let value):
            return Kilogram_f(value)
        case .kilogram_f(let value):
            return Kilogram_f(value)
        case .kilogram_d(let value):
            return Kilogram_f(value)
        case .megagram_t(let value):
            return Kilogram_f(value)
        case .megagram_u(let value):
            return Kilogram_f(value)
        case .megagram_f(let value):
            return Kilogram_f(value)
        case .megagram_d(let value):
            return Kilogram_f(value)
        }
    }

    /// Create a `Kilogram_d`.
    public var kilogram_d: Kilogram_d {
        switch rawValue {
        case .microgram_t(let value):
            return Kilogram_d(value)
        case .microgram_u(let value):
            return Kilogram_d(value)
        case .microgram_f(let value):
            return Kilogram_d(value)
        case .microgram_d(let value):
            return Kilogram_d(value)
        case .milligram_t(let value):
            return Kilogram_d(value)
        case .milligram_u(let value):
            return Kilogram_d(value)
        case .milligram_f(let value):
            return Kilogram_d(value)
        case .milligram_d(let value):
            return Kilogram_d(value)
        case .gram_t(let value):
            return Kilogram_d(value)
        case .gram_u(let value):
            return Kilogram_d(value)
        case .gram_f(let value):
            return Kilogram_d(value)
        case .gram_d(let value):
            return Kilogram_d(value)
        case .kilogram_t(let value):
            return Kilogram_d(value)
        case .kilogram_u(let value):
            return Kilogram_d(value)
        case .kilogram_f(let value):
            return Kilogram_d(value)
        case .kilogram_d(let value):
            return Kilogram_d(value)
        case .megagram_t(let value):
            return Kilogram_d(value)
        case .megagram_u(let value):
            return Kilogram_d(value)
        case .megagram_f(let value):
            return Kilogram_d(value)
        case .megagram_d(let value):
            return Kilogram_d(value)
        }
    }

    /// Create a `Megagram_t`.
    public var megagram_t: Megagram_t {
        switch rawValue {
        case .microgram_t(let value):
            return Megagram_t(value)
        case .microgram_u(let value):
            return Megagram_t(value)
        case .microgram_f(let value):
            return Megagram_t(value)
        case .microgram_d(let value):
            return Megagram_t(value)
        case .milligram_t(let value):
            return Megagram_t(value)
        case .milligram_u(let value):
            return Megagram_t(value)
        case .milligram_f(let value):
            return Megagram_t(value)
        case .milligram_d(let value):
            return Megagram_t(value)
        case .gram_t(let value):
            return Megagram_t(value)
        case .gram_u(let value):
            return Megagram_t(value)
        case .gram_f(let value):
            return Megagram_t(value)
        case .gram_d(let value):
            return Megagram_t(value)
        case .kilogram_t(let value):
            return Megagram_t(value)
        case .kilogram_u(let value):
            return Megagram_t(value)
        case .kilogram_f(let value):
            return Megagram_t(value)
        case .kilogram_d(let value):
            return Megagram_t(value)
        case .megagram_t(let value):
            return Megagram_t(value)
        case .megagram_u(let value):
            return Megagram_t(value)
        case .megagram_f(let value):
            return Megagram_t(value)
        case .megagram_d(let value):
            return Megagram_t(value)
        }
    }

    /// Create a `Megagram_u`.
    public var megagram_u: Megagram_u {
        switch rawValue {
        case .microgram_t(let value):
            return Megagram_u(value)
        case .microgram_u(let value):
            return Megagram_u(value)
        case .microgram_f(let value):
            return Megagram_u(value)
        case .microgram_d(let value):
            return Megagram_u(value)
        case .milligram_t(let value):
            return Megagram_u(value)
        case .milligram_u(let value):
            return Megagram_u(value)
        case .milligram_f(let value):
            return Megagram_u(value)
        case .milligram_d(let value):
            return Megagram_u(value)
        case .gram_t(let value):
            return Megagram_u(value)
        case .gram_u(let value):
            return Megagram_u(value)
        case .gram_f(let value):
            return Megagram_u(value)
        case .gram_d(let value):
            return Megagram_u(value)
        case .kilogram_t(let value):
            return Megagram_u(value)
        case .kilogram_u(let value):
            return Megagram_u(value)
        case .kilogram_f(let value):
            return Megagram_u(value)
        case .kilogram_d(let value):
            return Megagram_u(value)
        case .megagram_t(let value):
            return Megagram_u(value)
        case .megagram_u(let value):
            return Megagram_u(value)
        case .megagram_f(let value):
            return Megagram_u(value)
        case .megagram_d(let value):
            return Megagram_u(value)
        }
    }

    /// Create a `Megagram_f`.
    public var megagram_f: Megagram_f {
        switch rawValue {
        case .microgram_t(let value):
            return Megagram_f(value)
        case .microgram_u(let value):
            return Megagram_f(value)
        case .microgram_f(let value):
            return Megagram_f(value)
        case .microgram_d(let value):
            return Megagram_f(value)
        case .milligram_t(let value):
            return Megagram_f(value)
        case .milligram_u(let value):
            return Megagram_f(value)
        case .milligram_f(let value):
            return Megagram_f(value)
        case .milligram_d(let value):
            return Megagram_f(value)
        case .gram_t(let value):
            return Megagram_f(value)
        case .gram_u(let value):
            return Megagram_f(value)
        case .gram_f(let value):
            return Megagram_f(value)
        case .gram_d(let value):
            return Megagram_f(value)
        case .kilogram_t(let value):
            return Megagram_f(value)
        case .kilogram_u(let value):
            return Megagram_f(value)
        case .kilogram_f(let value):
            return Megagram_f(value)
        case .kilogram_d(let value):
            return Megagram_f(value)
        case .megagram_t(let value):
            return Megagram_f(value)
        case .megagram_u(let value):
            return Megagram_f(value)
        case .megagram_f(let value):
            return Megagram_f(value)
        case .megagram_d(let value):
            return Megagram_f(value)
        }
    }

    /// Create a `Megagram_d`.
    public var megagram_d: Megagram_d {
        switch rawValue {
        case .microgram_t(let value):
            return Megagram_d(value)
        case .microgram_u(let value):
            return Megagram_d(value)
        case .microgram_f(let value):
            return Megagram_d(value)
        case .microgram_d(let value):
            return Megagram_d(value)
        case .milligram_t(let value):
            return Megagram_d(value)
        case .milligram_u(let value):
            return Megagram_d(value)
        case .milligram_f(let value):
            return Megagram_d(value)
        case .milligram_d(let value):
            return Megagram_d(value)
        case .gram_t(let value):
            return Megagram_d(value)
        case .gram_u(let value):
            return Megagram_d(value)
        case .gram_f(let value):
            return Megagram_d(value)
        case .gram_d(let value):
            return Megagram_d(value)
        case .kilogram_t(let value):
            return Megagram_d(value)
        case .kilogram_u(let value):
            return Megagram_d(value)
        case .kilogram_f(let value):
            return Megagram_d(value)
        case .kilogram_d(let value):
            return Megagram_d(value)
        case .megagram_t(let value):
            return Megagram_d(value)
        case .megagram_u(let value):
            return Megagram_d(value)
        case .megagram_f(let value):
            return Megagram_d(value)
        case .megagram_d(let value):
            return Megagram_d(value)
        }
    }

// MARK: - Converting From The Underlying Unit Types

    /// Create a `Mass` by converting a `Microgram_t`.
    ///
    /// - Parameter value: A `Microgram_t` value to convert to a `Mass`.
    public init(_ value: Microgram_t) {
        self.rawValue = MassTypes.microgram_t(value)
    }

    /// Create a `Mass` by converting a `Microgram_u`.
    ///
    /// - Parameter value: A `Microgram_u` value to convert to a `Mass`.
    public init(_ value: Microgram_u) {
        self.rawValue = MassTypes.microgram_u(value)
    }

    /// Create a `Mass` by converting a `Microgram_f`.
    ///
    /// - Parameter value: A `Microgram_f` value to convert to a `Mass`.
    public init(_ value: Microgram_f) {
        self.rawValue = MassTypes.microgram_f(value)
    }

    /// Create a `Mass` by converting a `Microgram_d`.
    ///
    /// - Parameter value: A `Microgram_d` value to convert to a `Mass`.
    public init(_ value: Microgram_d) {
        self.rawValue = MassTypes.microgram_d(value)
    }

    /// Create a `Mass` by converting a `Milligram_t`.
    ///
    /// - Parameter value: A `Milligram_t` value to convert to a `Mass`.
    public init(_ value: Milligram_t) {
        self.rawValue = MassTypes.milligram_t(value)
    }

    /// Create a `Mass` by converting a `Milligram_u`.
    ///
    /// - Parameter value: A `Milligram_u` value to convert to a `Mass`.
    public init(_ value: Milligram_u) {
        self.rawValue = MassTypes.milligram_u(value)
    }

    /// Create a `Mass` by converting a `Milligram_f`.
    ///
    /// - Parameter value: A `Milligram_f` value to convert to a `Mass`.
    public init(_ value: Milligram_f) {
        self.rawValue = MassTypes.milligram_f(value)
    }

    /// Create a `Mass` by converting a `Milligram_d`.
    ///
    /// - Parameter value: A `Milligram_d` value to convert to a `Mass`.
    public init(_ value: Milligram_d) {
        self.rawValue = MassTypes.milligram_d(value)
    }

    /// Create a `Mass` by converting a `Gram_t`.
    ///
    /// - Parameter value: A `Gram_t` value to convert to a `Mass`.
    public init(_ value: Gram_t) {
        self.rawValue = MassTypes.gram_t(value)
    }

    /// Create a `Mass` by converting a `Gram_u`.
    ///
    /// - Parameter value: A `Gram_u` value to convert to a `Mass`.
    public init(_ value: Gram_u) {
        self.rawValue = MassTypes.gram_u(value)
    }

    /// Create a `Mass` by converting a `Gram_f`.
    ///
    /// - Parameter value: A `Gram_f` value to convert to a `Mass`.
    public init(_ value: Gram_f) {
        self.rawValue = MassTypes.gram_f(value)
    }

    /// Create a `Mass` by converting a `Gram_d`.
    ///
    /// - Parameter value: A `Gram_d` value to convert to a `Mass`.
    public init(_ value: Gram_d) {
        self.rawValue = MassTypes.gram_d(value)
    }

    /// Create a `Mass` by converting a `Kilogram_t`.
    ///
    /// - Parameter value: A `Kilogram_t` value to convert to a `Mass`.
    public init(_ value: Kilogram_t) {
        self.rawValue = MassTypes.kilogram_t(value)
    }

    /// Create a `Mass` by converting a `Kilogram_u`.
    ///
    /// - Parameter value: A `Kilogram_u` value to convert to a `Mass`.
    public init(_ value: Kilogram_u) {
        self.rawValue = MassTypes.kilogram_u(value)
    }

    /// Create a `Mass` by converting a `Kilogram_f`.
    ///
    /// - Parameter value: A `Kilogram_f` value to convert to a `Mass`.
    public init(_ value: Kilogram_f) {
        self.rawValue = MassTypes.kilogram_f(value)
    }

    /// Create a `Mass` by converting a `Kilogram_d`.
    ///
    /// - Parameter value: A `Kilogram_d` value to convert to a `Mass`.
    public init(_ value: Kilogram_d) {
        self.rawValue = MassTypes.kilogram_d(value)
    }

    /// Create a `Mass` by converting a `Megagram_t`.
    ///
    /// - Parameter value: A `Megagram_t` value to convert to a `Mass`.
    public init(_ value: Megagram_t) {
        self.rawValue = MassTypes.megagram_t(value)
    }

    /// Create a `Mass` by converting a `Megagram_u`.
    ///
    /// - Parameter value: A `Megagram_u` value to convert to a `Mass`.
    public init(_ value: Megagram_u) {
        self.rawValue = MassTypes.megagram_u(value)
    }

    /// Create a `Mass` by converting a `Megagram_f`.
    ///
    /// - Parameter value: A `Megagram_f` value to convert to a `Mass`.
    public init(_ value: Megagram_f) {
        self.rawValue = MassTypes.megagram_f(value)
    }

    /// Create a `Mass` by converting a `Megagram_d`.
    ///
    /// - Parameter value: A `Megagram_d` value to convert to a `Mass`.
    public init(_ value: Megagram_d) {
        self.rawValue = MassTypes.megagram_d(value)
    }

// MARK: - Converting From Swift Numeric Types

    /// Create a `Mass` equal to zero.
    public static var zero: Mass {
        return Mass(microgram: 0)
    }

    /// Create a `Mass` by converting a `Double` microgram value.
    ///
    /// - Parameter value: A `Double` microgram value to convert to a `Mass`.
    public static func microgram(_ value: Double) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `Double` milligram value.
    ///
    /// - Parameter value: A `Double` milligram value to convert to a `Mass`.
    public static func milligram(_ value: Double) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `Double` gram value.
    ///
    /// - Parameter value: A `Double` gram value to convert to a `Mass`.
    public static func gram(_ value: Double) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `Double` kilogram value.
    ///
    /// - Parameter value: A `Double` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: Double) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `Double` megagram value.
    ///
    /// - Parameter value: A `Double` megagram value to convert to a `Mass`.
    public static func megagram(_ value: Double) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `Float` microgram value.
    ///
    /// - Parameter value: A `Float` microgram value to convert to a `Mass`.
    public static func microgram(_ value: Float) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `Float` milligram value.
    ///
    /// - Parameter value: A `Float` milligram value to convert to a `Mass`.
    public static func milligram(_ value: Float) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `Float` gram value.
    ///
    /// - Parameter value: A `Float` gram value to convert to a `Mass`.
    public static func gram(_ value: Float) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `Float` kilogram value.
    ///
    /// - Parameter value: A `Float` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: Float) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `Float` megagram value.
    ///
    /// - Parameter value: A `Float` megagram value to convert to a `Mass`.
    public static func megagram(_ value: Float) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `Int` microgram value.
    ///
    /// - Parameter value: A `Int` microgram value to convert to a `Mass`.
    public static func microgram(_ value: Int) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `Int` milligram value.
    ///
    /// - Parameter value: A `Int` milligram value to convert to a `Mass`.
    public static func milligram(_ value: Int) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `Int` gram value.
    ///
    /// - Parameter value: A `Int` gram value to convert to a `Mass`.
    public static func gram(_ value: Int) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `Int` kilogram value.
    ///
    /// - Parameter value: A `Int` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: Int) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `Int` megagram value.
    ///
    /// - Parameter value: A `Int` megagram value to convert to a `Mass`.
    public static func megagram(_ value: Int) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `Int16` microgram value.
    ///
    /// - Parameter value: A `Int16` microgram value to convert to a `Mass`.
    public static func microgram(_ value: Int16) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `Int16` milligram value.
    ///
    /// - Parameter value: A `Int16` milligram value to convert to a `Mass`.
    public static func milligram(_ value: Int16) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `Int16` gram value.
    ///
    /// - Parameter value: A `Int16` gram value to convert to a `Mass`.
    public static func gram(_ value: Int16) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `Int16` kilogram value.
    ///
    /// - Parameter value: A `Int16` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: Int16) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `Int16` megagram value.
    ///
    /// - Parameter value: A `Int16` megagram value to convert to a `Mass`.
    public static func megagram(_ value: Int16) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `Int32` microgram value.
    ///
    /// - Parameter value: A `Int32` microgram value to convert to a `Mass`.
    public static func microgram(_ value: Int32) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `Int32` milligram value.
    ///
    /// - Parameter value: A `Int32` milligram value to convert to a `Mass`.
    public static func milligram(_ value: Int32) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `Int32` gram value.
    ///
    /// - Parameter value: A `Int32` gram value to convert to a `Mass`.
    public static func gram(_ value: Int32) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `Int32` kilogram value.
    ///
    /// - Parameter value: A `Int32` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: Int32) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `Int32` megagram value.
    ///
    /// - Parameter value: A `Int32` megagram value to convert to a `Mass`.
    public static func megagram(_ value: Int32) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `Int64` microgram value.
    ///
    /// - Parameter value: A `Int64` microgram value to convert to a `Mass`.
    public static func microgram(_ value: Int64) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `Int64` milligram value.
    ///
    /// - Parameter value: A `Int64` milligram value to convert to a `Mass`.
    public static func milligram(_ value: Int64) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `Int64` gram value.
    ///
    /// - Parameter value: A `Int64` gram value to convert to a `Mass`.
    public static func gram(_ value: Int64) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `Int64` kilogram value.
    ///
    /// - Parameter value: A `Int64` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: Int64) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `Int64` megagram value.
    ///
    /// - Parameter value: A `Int64` megagram value to convert to a `Mass`.
    public static func megagram(_ value: Int64) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `Int8` microgram value.
    ///
    /// - Parameter value: A `Int8` microgram value to convert to a `Mass`.
    public static func microgram(_ value: Int8) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `Int8` milligram value.
    ///
    /// - Parameter value: A `Int8` milligram value to convert to a `Mass`.
    public static func milligram(_ value: Int8) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `Int8` gram value.
    ///
    /// - Parameter value: A `Int8` gram value to convert to a `Mass`.
    public static func gram(_ value: Int8) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `Int8` kilogram value.
    ///
    /// - Parameter value: A `Int8` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: Int8) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `Int8` megagram value.
    ///
    /// - Parameter value: A `Int8` megagram value to convert to a `Mass`.
    public static func megagram(_ value: Int8) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `UInt` microgram value.
    ///
    /// - Parameter value: A `UInt` microgram value to convert to a `Mass`.
    public static func microgram(_ value: UInt) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `UInt` milligram value.
    ///
    /// - Parameter value: A `UInt` milligram value to convert to a `Mass`.
    public static func milligram(_ value: UInt) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `UInt` gram value.
    ///
    /// - Parameter value: A `UInt` gram value to convert to a `Mass`.
    public static func gram(_ value: UInt) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `UInt` kilogram value.
    ///
    /// - Parameter value: A `UInt` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: UInt) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `UInt` megagram value.
    ///
    /// - Parameter value: A `UInt` megagram value to convert to a `Mass`.
    public static func megagram(_ value: UInt) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `UInt16` microgram value.
    ///
    /// - Parameter value: A `UInt16` microgram value to convert to a `Mass`.
    public static func microgram(_ value: UInt16) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `UInt16` milligram value.
    ///
    /// - Parameter value: A `UInt16` milligram value to convert to a `Mass`.
    public static func milligram(_ value: UInt16) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `UInt16` gram value.
    ///
    /// - Parameter value: A `UInt16` gram value to convert to a `Mass`.
    public static func gram(_ value: UInt16) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `UInt16` kilogram value.
    ///
    /// - Parameter value: A `UInt16` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: UInt16) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `UInt16` megagram value.
    ///
    /// - Parameter value: A `UInt16` megagram value to convert to a `Mass`.
    public static func megagram(_ value: UInt16) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `UInt32` microgram value.
    ///
    /// - Parameter value: A `UInt32` microgram value to convert to a `Mass`.
    public static func microgram(_ value: UInt32) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `UInt32` milligram value.
    ///
    /// - Parameter value: A `UInt32` milligram value to convert to a `Mass`.
    public static func milligram(_ value: UInt32) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `UInt32` gram value.
    ///
    /// - Parameter value: A `UInt32` gram value to convert to a `Mass`.
    public static func gram(_ value: UInt32) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `UInt32` kilogram value.
    ///
    /// - Parameter value: A `UInt32` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: UInt32) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `UInt32` megagram value.
    ///
    /// - Parameter value: A `UInt32` megagram value to convert to a `Mass`.
    public static func megagram(_ value: UInt32) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `UInt64` microgram value.
    ///
    /// - Parameter value: A `UInt64` microgram value to convert to a `Mass`.
    public static func microgram(_ value: UInt64) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `UInt64` milligram value.
    ///
    /// - Parameter value: A `UInt64` milligram value to convert to a `Mass`.
    public static func milligram(_ value: UInt64) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `UInt64` gram value.
    ///
    /// - Parameter value: A `UInt64` gram value to convert to a `Mass`.
    public static func gram(_ value: UInt64) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `UInt64` kilogram value.
    ///
    /// - Parameter value: A `UInt64` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: UInt64) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `UInt64` megagram value.
    ///
    /// - Parameter value: A `UInt64` megagram value to convert to a `Mass`.
    public static func megagram(_ value: UInt64) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `UInt8` microgram value.
    ///
    /// - Parameter value: A `UInt8` microgram value to convert to a `Mass`.
    public static func microgram(_ value: UInt8) -> Mass {
        return Mass(microgram: value)
    }

    /// Create a `Mass` by converting a `UInt8` milligram value.
    ///
    /// - Parameter value: A `UInt8` milligram value to convert to a `Mass`.
    public static func milligram(_ value: UInt8) -> Mass {
        return Mass(milligram: value)
    }

    /// Create a `Mass` by converting a `UInt8` gram value.
    ///
    /// - Parameter value: A `UInt8` gram value to convert to a `Mass`.
    public static func gram(_ value: UInt8) -> Mass {
        return Mass(gram: value)
    }

    /// Create a `Mass` by converting a `UInt8` kilogram value.
    ///
    /// - Parameter value: A `UInt8` kilogram value to convert to a `Mass`.
    public static func kilogram(_ value: UInt8) -> Mass {
        return Mass(kilogram: value)
    }

    /// Create a `Mass` by converting a `UInt8` megagram value.
    ///
    /// - Parameter value: A `UInt8` megagram value to convert to a `Mass`.
    public static func megagram(_ value: UInt8) -> Mass {
        return Mass(megagram: value)
    }

    /// Create a `Mass` by converting a `Double` microgram value.
    ///
    /// - Parameter value: A `Double` microgram value to convert to a `Mass`.
    public init(microgram value: Double) {
        self.rawValue = MassTypes.microgram_d(Microgram_d(value))
    }

    /// Create a `Mass` by converting a `Double` milligram value.
    ///
    /// - Parameter value: A `Double` milligram value to convert to a `Mass`.
    public init(milligram value: Double) {
        self.rawValue = MassTypes.milligram_d(Milligram_d(value))
    }

    /// Create a `Mass` by converting a `Double` gram value.
    ///
    /// - Parameter value: A `Double` gram value to convert to a `Mass`.
    public init(gram value: Double) {
        self.rawValue = MassTypes.gram_d(Gram_d(value))
    }

    /// Create a `Mass` by converting a `Double` kilogram value.
    ///
    /// - Parameter value: A `Double` kilogram value to convert to a `Mass`.
    public init(kilogram value: Double) {
        self.rawValue = MassTypes.kilogram_d(Kilogram_d(value))
    }

    /// Create a `Mass` by converting a `Double` megagram value.
    ///
    /// - Parameter value: A `Double` megagram value to convert to a `Mass`.
    public init(megagram value: Double) {
        self.rawValue = MassTypes.megagram_d(Megagram_d(value))
    }

    /// Create a `Mass` by converting a `Float` microgram value.
    ///
    /// - Parameter value: A `Float` microgram value to convert to a `Mass`.
    public init(microgram value: Float) {
        self.rawValue = MassTypes.microgram_f(Microgram_f(value))
    }

    /// Create a `Mass` by converting a `Float` milligram value.
    ///
    /// - Parameter value: A `Float` milligram value to convert to a `Mass`.
    public init(milligram value: Float) {
        self.rawValue = MassTypes.milligram_f(Milligram_f(value))
    }

    /// Create a `Mass` by converting a `Float` gram value.
    ///
    /// - Parameter value: A `Float` gram value to convert to a `Mass`.
    public init(gram value: Float) {
        self.rawValue = MassTypes.gram_f(Gram_f(value))
    }

    /// Create a `Mass` by converting a `Float` kilogram value.
    ///
    /// - Parameter value: A `Float` kilogram value to convert to a `Mass`.
    public init(kilogram value: Float) {
        self.rawValue = MassTypes.kilogram_f(Kilogram_f(value))
    }

    /// Create a `Mass` by converting a `Float` megagram value.
    ///
    /// - Parameter value: A `Float` megagram value to convert to a `Mass`.
    public init(megagram value: Float) {
        self.rawValue = MassTypes.megagram_f(Megagram_f(value))
    }

    /// Create a `Mass` by converting a `Int` microgram value.
    ///
    /// - Parameter value: A `Int` microgram value to convert to a `Mass`.
    public init(microgram value: Int) {
        self.rawValue = MassTypes.microgram_t(Microgram_t(value))
    }

    /// Create a `Mass` by converting a `Int` milligram value.
    ///
    /// - Parameter value: A `Int` milligram value to convert to a `Mass`.
    public init(milligram value: Int) {
        self.rawValue = MassTypes.milligram_t(Milligram_t(value))
    }

    /// Create a `Mass` by converting a `Int` gram value.
    ///
    /// - Parameter value: A `Int` gram value to convert to a `Mass`.
    public init(gram value: Int) {
        self.rawValue = MassTypes.gram_t(Gram_t(value))
    }

    /// Create a `Mass` by converting a `Int` kilogram value.
    ///
    /// - Parameter value: A `Int` kilogram value to convert to a `Mass`.
    public init(kilogram value: Int) {
        self.rawValue = MassTypes.kilogram_t(Kilogram_t(value))
    }

    /// Create a `Mass` by converting a `Int` megagram value.
    ///
    /// - Parameter value: A `Int` megagram value to convert to a `Mass`.
    public init(megagram value: Int) {
        self.rawValue = MassTypes.megagram_t(Megagram_t(value))
    }

    /// Create a `Mass` by converting a `Int16` microgram value.
    ///
    /// - Parameter value: A `Int16` microgram value to convert to a `Mass`.
    public init(microgram value: Int16) {
        self.rawValue = MassTypes.microgram_t(Microgram_t(value))
    }

    /// Create a `Mass` by converting a `Int16` milligram value.
    ///
    /// - Parameter value: A `Int16` milligram value to convert to a `Mass`.
    public init(milligram value: Int16) {
        self.rawValue = MassTypes.milligram_t(Milligram_t(value))
    }

    /// Create a `Mass` by converting a `Int16` gram value.
    ///
    /// - Parameter value: A `Int16` gram value to convert to a `Mass`.
    public init(gram value: Int16) {
        self.rawValue = MassTypes.gram_t(Gram_t(value))
    }

    /// Create a `Mass` by converting a `Int16` kilogram value.
    ///
    /// - Parameter value: A `Int16` kilogram value to convert to a `Mass`.
    public init(kilogram value: Int16) {
        self.rawValue = MassTypes.kilogram_t(Kilogram_t(value))
    }

    /// Create a `Mass` by converting a `Int16` megagram value.
    ///
    /// - Parameter value: A `Int16` megagram value to convert to a `Mass`.
    public init(megagram value: Int16) {
        self.rawValue = MassTypes.megagram_t(Megagram_t(value))
    }

    /// Create a `Mass` by converting a `Int32` microgram value.
    ///
    /// - Parameter value: A `Int32` microgram value to convert to a `Mass`.
    public init(microgram value: Int32) {
        self.rawValue = MassTypes.microgram_t(Microgram_t(value))
    }

    /// Create a `Mass` by converting a `Int32` milligram value.
    ///
    /// - Parameter value: A `Int32` milligram value to convert to a `Mass`.
    public init(milligram value: Int32) {
        self.rawValue = MassTypes.milligram_t(Milligram_t(value))
    }

    /// Create a `Mass` by converting a `Int32` gram value.
    ///
    /// - Parameter value: A `Int32` gram value to convert to a `Mass`.
    public init(gram value: Int32) {
        self.rawValue = MassTypes.gram_t(Gram_t(value))
    }

    /// Create a `Mass` by converting a `Int32` kilogram value.
    ///
    /// - Parameter value: A `Int32` kilogram value to convert to a `Mass`.
    public init(kilogram value: Int32) {
        self.rawValue = MassTypes.kilogram_t(Kilogram_t(value))
    }

    /// Create a `Mass` by converting a `Int32` megagram value.
    ///
    /// - Parameter value: A `Int32` megagram value to convert to a `Mass`.
    public init(megagram value: Int32) {
        self.rawValue = MassTypes.megagram_t(Megagram_t(value))
    }

    /// Create a `Mass` by converting a `Int64` microgram value.
    ///
    /// - Parameter value: A `Int64` microgram value to convert to a `Mass`.
    public init(microgram value: Int64) {
        self.rawValue = MassTypes.microgram_d(Microgram_d(value))
    }

    /// Create a `Mass` by converting a `Int64` milligram value.
    ///
    /// - Parameter value: A `Int64` milligram value to convert to a `Mass`.
    public init(milligram value: Int64) {
        self.rawValue = MassTypes.milligram_d(Milligram_d(value))
    }

    /// Create a `Mass` by converting a `Int64` gram value.
    ///
    /// - Parameter value: A `Int64` gram value to convert to a `Mass`.
    public init(gram value: Int64) {
        self.rawValue = MassTypes.gram_d(Gram_d(value))
    }

    /// Create a `Mass` by converting a `Int64` kilogram value.
    ///
    /// - Parameter value: A `Int64` kilogram value to convert to a `Mass`.
    public init(kilogram value: Int64) {
        self.rawValue = MassTypes.kilogram_d(Kilogram_d(value))
    }

    /// Create a `Mass` by converting a `Int64` megagram value.
    ///
    /// - Parameter value: A `Int64` megagram value to convert to a `Mass`.
    public init(megagram value: Int64) {
        self.rawValue = MassTypes.megagram_d(Megagram_d(value))
    }

    /// Create a `Mass` by converting a `Int8` microgram value.
    ///
    /// - Parameter value: A `Int8` microgram value to convert to a `Mass`.
    public init(microgram value: Int8) {
        self.rawValue = MassTypes.microgram_t(Microgram_t(value))
    }

    /// Create a `Mass` by converting a `Int8` milligram value.
    ///
    /// - Parameter value: A `Int8` milligram value to convert to a `Mass`.
    public init(milligram value: Int8) {
        self.rawValue = MassTypes.milligram_t(Milligram_t(value))
    }

    /// Create a `Mass` by converting a `Int8` gram value.
    ///
    /// - Parameter value: A `Int8` gram value to convert to a `Mass`.
    public init(gram value: Int8) {
        self.rawValue = MassTypes.gram_t(Gram_t(value))
    }

    /// Create a `Mass` by converting a `Int8` kilogram value.
    ///
    /// - Parameter value: A `Int8` kilogram value to convert to a `Mass`.
    public init(kilogram value: Int8) {
        self.rawValue = MassTypes.kilogram_t(Kilogram_t(value))
    }

    /// Create a `Mass` by converting a `Int8` megagram value.
    ///
    /// - Parameter value: A `Int8` megagram value to convert to a `Mass`.
    public init(megagram value: Int8) {
        self.rawValue = MassTypes.megagram_t(Megagram_t(value))
    }

    /// Create a `Mass` by converting a `UInt` microgram value.
    ///
    /// - Parameter value: A `UInt` microgram value to convert to a `Mass`.
    public init(microgram value: UInt) {
        self.rawValue = MassTypes.microgram_u(Microgram_u(value))
    }

    /// Create a `Mass` by converting a `UInt` milligram value.
    ///
    /// - Parameter value: A `UInt` milligram value to convert to a `Mass`.
    public init(milligram value: UInt) {
        self.rawValue = MassTypes.milligram_u(Milligram_u(value))
    }

    /// Create a `Mass` by converting a `UInt` gram value.
    ///
    /// - Parameter value: A `UInt` gram value to convert to a `Mass`.
    public init(gram value: UInt) {
        self.rawValue = MassTypes.gram_u(Gram_u(value))
    }

    /// Create a `Mass` by converting a `UInt` kilogram value.
    ///
    /// - Parameter value: A `UInt` kilogram value to convert to a `Mass`.
    public init(kilogram value: UInt) {
        self.rawValue = MassTypes.kilogram_u(Kilogram_u(value))
    }

    /// Create a `Mass` by converting a `UInt` megagram value.
    ///
    /// - Parameter value: A `UInt` megagram value to convert to a `Mass`.
    public init(megagram value: UInt) {
        self.rawValue = MassTypes.megagram_u(Megagram_u(value))
    }

    /// Create a `Mass` by converting a `UInt16` microgram value.
    ///
    /// - Parameter value: A `UInt16` microgram value to convert to a `Mass`.
    public init(microgram value: UInt16) {
        self.rawValue = MassTypes.microgram_u(Microgram_u(value))
    }

    /// Create a `Mass` by converting a `UInt16` milligram value.
    ///
    /// - Parameter value: A `UInt16` milligram value to convert to a `Mass`.
    public init(milligram value: UInt16) {
        self.rawValue = MassTypes.milligram_u(Milligram_u(value))
    }

    /// Create a `Mass` by converting a `UInt16` gram value.
    ///
    /// - Parameter value: A `UInt16` gram value to convert to a `Mass`.
    public init(gram value: UInt16) {
        self.rawValue = MassTypes.gram_u(Gram_u(value))
    }

    /// Create a `Mass` by converting a `UInt16` kilogram value.
    ///
    /// - Parameter value: A `UInt16` kilogram value to convert to a `Mass`.
    public init(kilogram value: UInt16) {
        self.rawValue = MassTypes.kilogram_u(Kilogram_u(value))
    }

    /// Create a `Mass` by converting a `UInt16` megagram value.
    ///
    /// - Parameter value: A `UInt16` megagram value to convert to a `Mass`.
    public init(megagram value: UInt16) {
        self.rawValue = MassTypes.megagram_u(Megagram_u(value))
    }

    /// Create a `Mass` by converting a `UInt32` microgram value.
    ///
    /// - Parameter value: A `UInt32` microgram value to convert to a `Mass`.
    public init(microgram value: UInt32) {
        self.rawValue = MassTypes.microgram_u(Microgram_u(value))
    }

    /// Create a `Mass` by converting a `UInt32` milligram value.
    ///
    /// - Parameter value: A `UInt32` milligram value to convert to a `Mass`.
    public init(milligram value: UInt32) {
        self.rawValue = MassTypes.milligram_u(Milligram_u(value))
    }

    /// Create a `Mass` by converting a `UInt32` gram value.
    ///
    /// - Parameter value: A `UInt32` gram value to convert to a `Mass`.
    public init(gram value: UInt32) {
        self.rawValue = MassTypes.gram_u(Gram_u(value))
    }

    /// Create a `Mass` by converting a `UInt32` kilogram value.
    ///
    /// - Parameter value: A `UInt32` kilogram value to convert to a `Mass`.
    public init(kilogram value: UInt32) {
        self.rawValue = MassTypes.kilogram_u(Kilogram_u(value))
    }

    /// Create a `Mass` by converting a `UInt32` megagram value.
    ///
    /// - Parameter value: A `UInt32` megagram value to convert to a `Mass`.
    public init(megagram value: UInt32) {
        self.rawValue = MassTypes.megagram_u(Megagram_u(value))
    }

    /// Create a `Mass` by converting a `UInt64` microgram value.
    ///
    /// - Parameter value: A `UInt64` microgram value to convert to a `Mass`.
    public init(microgram value: UInt64) {
        self.rawValue = MassTypes.microgram_d(Microgram_d(value))
    }

    /// Create a `Mass` by converting a `UInt64` milligram value.
    ///
    /// - Parameter value: A `UInt64` milligram value to convert to a `Mass`.
    public init(milligram value: UInt64) {
        self.rawValue = MassTypes.milligram_d(Milligram_d(value))
    }

    /// Create a `Mass` by converting a `UInt64` gram value.
    ///
    /// - Parameter value: A `UInt64` gram value to convert to a `Mass`.
    public init(gram value: UInt64) {
        self.rawValue = MassTypes.gram_d(Gram_d(value))
    }

    /// Create a `Mass` by converting a `UInt64` kilogram value.
    ///
    /// - Parameter value: A `UInt64` kilogram value to convert to a `Mass`.
    public init(kilogram value: UInt64) {
        self.rawValue = MassTypes.kilogram_d(Kilogram_d(value))
    }

    /// Create a `Mass` by converting a `UInt64` megagram value.
    ///
    /// - Parameter value: A `UInt64` megagram value to convert to a `Mass`.
    public init(megagram value: UInt64) {
        self.rawValue = MassTypes.megagram_d(Megagram_d(value))
    }

    /// Create a `Mass` by converting a `UInt8` microgram value.
    ///
    /// - Parameter value: A `UInt8` microgram value to convert to a `Mass`.
    public init(microgram value: UInt8) {
        self.rawValue = MassTypes.microgram_u(Microgram_u(value))
    }

    /// Create a `Mass` by converting a `UInt8` milligram value.
    ///
    /// - Parameter value: A `UInt8` milligram value to convert to a `Mass`.
    public init(milligram value: UInt8) {
        self.rawValue = MassTypes.milligram_u(Milligram_u(value))
    }

    /// Create a `Mass` by converting a `UInt8` gram value.
    ///
    /// - Parameter value: A `UInt8` gram value to convert to a `Mass`.
    public init(gram value: UInt8) {
        self.rawValue = MassTypes.gram_u(Gram_u(value))
    }

    /// Create a `Mass` by converting a `UInt8` kilogram value.
    ///
    /// - Parameter value: A `UInt8` kilogram value to convert to a `Mass`.
    public init(kilogram value: UInt8) {
        self.rawValue = MassTypes.kilogram_u(Kilogram_u(value))
    }

    /// Create a `Mass` by converting a `UInt8` megagram value.
    ///
    /// - Parameter value: A `UInt8` megagram value to convert to a `Mass`.
    public init(megagram value: UInt8) {
        self.rawValue = MassTypes.megagram_u(Megagram_u(value))
    }

}
```

#### The Extensions for the Category Type

```swift
public extension Double {

// MARK: - Creating a Double From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension Float {

// MARK: - Creating a Float From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension Int {

// MARK: - Creating a Int From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension Int16 {

// MARK: - Creating a Int16 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension Int32 {

// MARK: - Creating a Int32 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension Int64 {

// MARK: - Creating a Int64 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension Int8 {

// MARK: - Creating a Int8 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension UInt {

// MARK: - Creating a UInt From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension UInt16 {

// MARK: - Creating a UInt16 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension UInt32 {

// MARK: - Creating a UInt32 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension UInt64 {

// MARK: - Creating a UInt64 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}

public extension UInt8 {

// MARK: - Creating a UInt8 From The Mass Units

    init(_ value: Mass) {
        switch value.rawValue {
        case .microgram_t(let value):
            self.init(value)
        case .microgram_u(let value):
            self.init(value)
        case .microgram_f(let value):
            self.init(value)
        case .microgram_d(let value):
            self.init(value)
        case .milligram_t(let value):
            self.init(value)
        case .milligram_u(let value):
            self.init(value)
        case .milligram_f(let value):
            self.init(value)
        case .milligram_d(let value):
            self.init(value)
        case .gram_t(let value):
            self.init(value)
        case .gram_u(let value):
            self.init(value)
        case .gram_f(let value):
            self.init(value)
        case .gram_d(let value):
            self.init(value)
        case .kilogram_t(let value):
            self.init(value)
        case .kilogram_u(let value):
            self.init(value)
        case .kilogram_f(let value):
            self.init(value)
        case .kilogram_d(let value):
            self.init(value)
        case .megagram_t(let value):
            self.init(value)
        case .megagram_u(let value):
            self.init(value)
        case .megagram_f(let value):
            self.init(value)
        case .megagram_d(let value):
            self.init(value)
        }
    }

}
```
