# Creating Composite Units

This guide demonstrates the process for creating *composite units*. A composite unit is a unit category
that is created from other units.

## Overview

A composite unit represents a unit category that contains other unit categories in it's declaration. For example,
consider a *Velocity* unit category. In this category, a velocity unit is represented as a distance divided by some time.
This unit can thus be created by using the unit categories ``DistanceUnits`` and ``TimeUnits`` together, without specifying
new units.

In this document, we will explore how to define the `Velocity` unit correctly using the protocols provided in this generator.

## Prerequisites

Before following this guide, it is preferred that you read the [Getting Started](gettingstarted), [Creating New Units](creatingnewunits)
and [Using Custom Code Generation](usingcustomcodegeneration) guides. These guides will give an overview of the basic package structure
of this generator and how you can modify/add swift files to create new units or language-specific implementations.

## The Velocity Unit

Since we want to create a new Velocty unit, we must understand the existing units within this package. Velocity is made up of 2 units:
Distance and Time. These units already exist in this package, but for simplicity I will place the code for these units below (see sections below).

We will want to combine these units into a Velocity unit performing a cartesian product between all cases between the two types. As such, we will
want to support units such as centimetres per millisecond (cm/ms), millimetres per second (mm/s) and metres per microsecond (m/us) to name a few.
Every combination of Distance and Time must be represented by our new Velocity type.

### Distance

```swift
/// A Unit for representing distances.
public enum DistanceUnits: String, UnitProtocol {

    /// Millimetres
    case millimetres

    /// Centimetres
    case centimetres

    /// Metres
    case metres

    /// The abbreviation of the unit.
    public var abbreviation: String {
        switch self {
        case .millimetres:
            return "mm"
        case .centimetres:
            return "cm"
        case .metres:
            return "m"
        }
    }

    /// The description of the unit.
    public var description: String {
        self.rawValue
    }

}
```

### Time

```swift
/// A type for representing different time units.
public enum TimeUnits: String, UnitProtocol {

    /// Microseconds.
    case microseconds

    /// Milliseconds.
    case milliseconds

    /// Seconds
    case seconds

    /// The abbreviation of the time unit.
    public var abbreviation: String {
        switch self {
        case .microseconds:
            return "us"
        case .milliseconds:
            return "ms"
        case .seconds:
            return "s"
        }
    }

    /// The description of the time unit.
    public var description: String {
        self.rawValue
    }

}
```

## The CompositeUnit Protocol

To start creating our Velocity unit, we must conform to the ``CompositeUnit`` protocol. Every *composite unit*
will conform to this protocol. The ``CompositeUnit`` protocol also conforms to the standard ``UnitProtocol``
meaning that every *composite unit* is also a normal unit. We can start our Velocity unit by using a `struct`
that conforms to this protocol.

```swift
public struct Velocity: CompositeUnit {

    // ToDo

}
```

A ``CompositeUnit`` requires a `baseUnit` static property that represents the minimum-required relationship between
the normal unit types within the composite unit. This relationship is defined through something called an ``Operation``.
An ``Operation`` is simply an abstract notation for defining mathematical relationships. The base unit of our Velocity
will be *metres per second*, or `DistanceUnits.metres` divided by `TimeUnits.seconds`. We will use the following
code to represent this relationship using the ``Operation`` enumeration.

```swift
/// Defines a velocity unit with a base unit of metres per second.
public struct Velocity: CompositeUnit {

    /// The base unit (SI m/s).
    public static let baseUnit: Operation = .division(
        lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
        rhs: .constant(declaration: AnyUnit(TimeUnits.seconds))
    )

}
```

This code will not compile in it's current state until we address a few more requirements in this type definition. For starters,
the Velocity unit has not finished providing all properties for the ``CompositeUnit`` conformance. We must add in a `unit`
property and an initialiser.

```swift
/// Defines a velocity unit with a base unit of metres per second.
public struct Velocity: CompositeUnit {

    /// The base unit (SI m/s).
    public static let baseUnit: Operation = .division(
        lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
        rhs: .constant(declaration: AnyUnit(TimeUnits.seconds))
    )

    /// A instance of this unit category.
    public let unit: Operation

    /// Initialise the Velocity from a derivation of the `baseUnit`.
    /// - Parameter unit: The operation representing this unit. This parameter
    /// must be a derivation of `baseUnit`. It cannot have a different structure.
    public init(unit: Operation) {
        self.unit = unit
    }

}
```

The Velocity code is now finished and ready to be compiled. For most composite units, this implementation is enough
to define a new composite unit. In some cases, the normal units within the composite unit may not conform to the
protocols required to allow type-erasure using ``AnyUnit``. This is the case for this example, so we will now
examine how to change ``DistanceUnits`` and ``TimeUnits`` to meet this conformance.

## Making Existing Units Convertible

To allow type-erase through the ``AnyUnit`` struct, we must conform ``DistanceUnits`` and ``TimeUnits`` to the
``UnitsConvertible`` protocol. This protocol defines functions that generate an ``Operation`` for a conversion
between unit types within the same category. Both our ``DistanceUnits`` and ``TimeUnits`` use SI units in their
definition, therefore we can use an additional protocol to make this easy.

Since SI units use a prefixed base-10 notation in their unit derivations, we may use the protocol ``Base10UnitsConvertible``
instead of ``UnitsConvertible`` to achieve the conformance for type-erasure. This protocol will create the conversion
functions automatically for units that conform to it. The only thing we need to specify is the power of 10 each unit
is represented as. For example, millimetres is 10^-3 metres, and centimetres is 10^-2 metres. These powers of 10
will be represented inside a static dictionary property called exponents. Our distance and time types will thus
change to include the code below. Once we have provided this conformance, our code should now compile.

### Distance

```swift
/// A Unit for representing distances.
public enum DistanceUnits: String, UnitProtocol, Base10UnitsConvertible {

    /// Millimetres
    case millimetres

    /// Centimetres
    case centimetres

    /// Metres
    case metres

    /// The exponents of the units expressed as base 10.
    public static let exponents: [DistanceUnits: Int] = [
        .millimetres: -3,
        .centimetres: -2,
        .metres: 0
    ]

    /// The abbreviation of the unit.
    public var abbreviation: String {
        switch self {
        case .millimetres:
            return "mm"
        case .centimetres:
            return "cm"
        case .metres:
            return "m"
        }
    }

    /// The description of the unit.
    public var description: String {
        self.rawValue
    }

}
```

### Time

```swift
/// A type for representing different time units.
public enum TimeUnits: String, UnitProtocol, Base10UnitsConvertible {

    /// Microseconds.
    case microseconds

    /// Milliseconds.
    case milliseconds

    /// Seconds
    case seconds

    /// The exponents of the units expressed as base 10.
    public static let exponents: [TimeUnits: Int] = [
        .microseconds: -6,
        .milliseconds: -3,
        .seconds: 0
    ]

    /// The abbreviation of the time unit.
    public var abbreviation: String {
        switch self {
        case .microseconds:
            return "us"
        case .milliseconds:
            return "ms"
        case .seconds:
            return "s"
        }
    }

    /// The description of the time unit.
    public var description: String {
        self.rawValue
    }

}
```

## Creating the C Code

At this point, we have correctly defined the Velocity unit category. We now have a choice on the best approach for
implementing the C code. The first option is to follow the previous guide for [Creating Custom Code Generation](usingcustomcodegeneration),
the second is to conform Velocity to ``UnitsConvertible`` and use an existing ``FunctionBodyCreator`` for this purpose.
We will demonstrate the ``UnitsConvertible`` approach.

This approach is far simpler than all previous approaches thus far. You simply have to conform Velocty to ``UnitsConvertible``.

```swift
public extension Velocity: UnitsConvertible {}
```

The default implementations of ``UnitsConvertible`` will create the conversion functions automatically since Velocity is a
``CompositeUnit``. You may also provide your own implementation by providing your own `conversion(to: ) -> Operation` function:

```swift
public extension Velocity: UnitsConvertible {

    func conversion(to unit: Velocity) -> Operation {
        // ToDo
    }

}
```

This is in no way required, but the option is open for types that may require it.

A ``FunctionBodyCreator`` called ``OperationalFunctionBodyCreator`` is already provided for types that conform to ``UnitsConvertible``.
You may use this type in the top module to generate the C code.

## Putting it all Together

We will now add all of the code into the top module for source code generation. The steps in this section are identical to the last steps
in [Creating New Units](creatingnewunits).

### Adding the Extension to UnitsGenerator

You must still add the extensions onto the ``UnitsGenerator``.

```swift
/// Velocity initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<OperationalFunctionBodyCreator<Velocity>,
    CFunctionDefinitionCreator<Velocity>, NumericTypeConverter> {

    /// Initialise using Velocity and c conversions.
    public init() {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: OperationalFunctionBodyCreator(),
            definitionCreator: CFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}
```

### Adding the C Source Generation Code

You must change the `generateCFiles` function in ``GUUnitsGenerator`` to include the new C code. A type alias already exists to create
an ``OperationalGenerator``.

```swift
public struct GUUnitsGenerator {

    // ...

    public func generateCFiles(in path: URL) throws {
        // ...
        let velocityGenerator = AnyGenerator(generating: Velocity.self, using: OperationalGenerator())
        let fileContents = HeaderCreator().generate(
            generators: [
                // ...
                velocityGenerator
            ]
        )
        .data(using: .utf8)
        // ...
        let cContents = CFileCreator().generate(
            generators: [
                // ...
                velocityGenerator
            ]
        )
        .data(using: .utf8)
        // ...
    }

    // ...

}

```

You must not forget to change `typeDefs` in ``HeaderCreator`` to include your new unit.

```swift
public struct HeaderCreator {

    // ...

    private var typeDefs: String {
        let units: [(String, [CustomStringConvertible])] = [
            // ...
            ("// Velocity Units.", Array(Velocity.allCases))
        ]
        // ...
    }

    // ...

}
```

### C Test Generation

As our units work off a ``Operation``, we may automatically generate the test code by inspecting the
structure of the categories `baseUnit` property. This process is automatically handled by conforming to
a protocol called ``OperationalTestable`` and using the ``OperationalTestGenerator``.

```swift
extension Velocity: OperationalTestable {

    public static let testParameters: [ConversionMetaData<Velocity>: [TestParameters]] = defaultParameters

}
```

You can see in the code above, that we have conformed to ``OperationalTestable`` by creating a static stored
property called `testParameters`. This property uses an underlying computed property called `defaultParameters`
that is provided by ``OperationalTestable`` as part of it's default implementation. Using this property
will create tests for a number of pre-defined values and edge cases. If you would like to add more custom
tests, then you may add then to `testParameters` yourself. The ``ConversionMetaData`` type simply stores
the conversion information, i.e. the type converting from and the type converting to.

We may now follow the same process for adding tests as normal units, but instead we may use the ``OperationalTestGenerator``.
Our test generation code in `GUUnitsGenerator.swift` will now contain the following lines for velocity:

```swift
public struct GUUnitsGenerator {

    // ...

    public func generateCTests(in path: URL) {
        // ...
        let velocityGenerator = OperationalTestGenerator<Velocity>()
        let velocityFileCreator = TestFileCreator<OperationalTestGenerator<Velocity>>()
        createTestFiles(
            at: path,
            with: velocityFileCreator.tests(generator: velocityGenerator, imports: "import CGUUnits")
        )
        // ...
    }

    // ...

}

```

### Swift Source and Test Generation

Finally, we must follow a similar procedure to add the swift sources and tests.

```swift
public struct GUUnitsGenerator {

    // ...

    public func generateSwiftFiles(in path: URL) {
        // ...
        writeFile(at: path, with: Velocity.category, and: swiftFileCreator.generate(for: Velocity.self))
        // ...
    }

    /// Generate files that test the swift layer of guunits.
    /// - Parameter path: The folder containing the test files.
    public func generateSwiftTests(in path: URL) {
        // ...
        createTestFiles(at: path, with: swiftFileCreator.generate(with: OperationalTestGenerator<Velocity>()))
        // ...
    }

    // ...

}
```
