# Getting Started

`GUUnitsGeneratorConversions` is the main target of `guunits_generator`. This target provides the unit and category
definitions for all the code generated in `GUUnits`.

## Overview

The target is broken up into 3 key subdirectories:

* `units`
* `source_generation`
* `test_generation`

We will examine each of these subdirectories in the following sections. For a quick guide explaining how to create a new unit,
see the [Creating New Units](creatingnewunits) document.

## Units

The `units` subdirectory is the simplist of all the other subdirectories. This folder contains the category definitions for each
unit type. A category is simply a group of units that describe/measure the same phenomenon. For example, consider the `Distance`
category which contains the units `metres`, `centimetres`, and `millimetres`. This category is defined in ``DistanceUnits``.
All categories must conform to the ``UnitProtocol`` protocol to allow source and test generation.

In addition to the units definitions, this subdirectory also contains the `C` and `Swift` primitive types that are supported
by `GUUnits`. You may view the supported C types in ``NumericTypes``, and the supported `Swift` types in ``SwiftNumericTypes``.
All units can be converted to/from these supported primitive types.

Lastly, it is worth mentioning that each unit type (e.g. `metres` in the `Distance` category) has 4 different underlying types that support
varying levels of precision. These types are the `C` primitive types `double`, `float`, `uint64_t`, and `int64_t`. Each unit is therefore
represented as a new type depending on it's precision and is suffixed with `_d`, `_f`, `_u`, or `_t` for `double`, `float`, `unit64_t`,
and `int64_t` respectively in the source code. For example, consider the `metres` unit; in the generated `C` source code, the `metres`
unit is represented as 4 `C` types: `metres_d`, `metres_f`, `metres_u`, and `metres_t`. The different versions of the unit type is referred
to in this documentation as a units `Sign`, and is defined in the enum ``Signs``.

## Source Generation

This subdirectory contains the code required to generate the `C` and `Swift` sources for all of the units and their conversions.
In order to generate the correct sources for each unit, an equivalent ``FunctionBodyCreator`` must be used for that unit type.
Simple types using `SI` prefixes can utilise the existing `GradualFunctionCreator` which performs simple multiplication or
division with a pre-defined scale factor (see [Creating New Units](creatingnewunits)). If any unit performs conversions that
cannot be defined as a simple multiplication or divide, then a custom ``FunctionBodyCreator`` must be defined that implements
the `C` code to perform the conversion.

To keep consistency between all unit categories, the definitions of the functions in `C` will follow a naming convention that
is enforced by ``CFunctionDefinitionCreator``. When used in tandem with ``CompositeFunctionCreator`` and ``NumericTypeConverter``,
the `C` implementation is automatically created using the ``FunctionBodyCreator`` of that unit. This process is completely
automated and is not usually altered when adding new units. For convenience, all source generation is performed through
a ``UnitsGenerator`` that combines these types. For brevity, a new unit typically creates an extension on ``UnitsGenerator``
and a `typealias` to allow easy initialisation (see [Creating New Units](creatingnewunits)). This process is demonstrated
for the ``TemperatureUnits`` category below.

```swift
/// TemperatureUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<
        TemperatureFunctionCreator,
        CFunctionDefinitionCreator<TemperatureUnits>,
        NumericTypeConverter
    > {

    /// Initialise using TemperatureUnits and C conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: TemperatureFunctionCreator = TemperatureFunctionCreator(),
        definitionCreator: CFunctionDefinitionCreator<TemperatureUnits> = CFunctionDefinitionCreator(),
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

/// Temperature Units Generator
public typealias TemperatureUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        TemperatureFunctionCreator,
        CFunctionDefinitionCreator<TemperatureUnits>,
        NumericTypeConverter
    >
>
```

The top level code may then create a source generator for `Temperature` by invoking:

```swift
let generator = TemperatureUnitsGenerator()
```

## Test Generation

This package also generates tests for the `C` and `Swift` sources. All of the code that handles the test generation
is contained within the `test_generation` folder. A test in this package is represented as an input to output relationship.
Given some input, the test will perform a function with that input and assert that the output from the function matches the
expected output. This relationship is defined inside a ``TestGenerator`` that creates arrays of input to output relationships
(using ``TestParameters``) for a given conversion function.

Simple types using `SI` prefixes may use the ``GradualTestGenerator`` to generate the tests for them. Custom unit types or
those that cannot use the ``GradualFunctionCreator`` to implement their conversion function must create a custom type
that conforms to ``TestGenerator``. The default implementation of ``TestGenerator`` will provide the test cases
for the numeric conversions, i.e conversions containing the types defined in ``NumericTypes``. The custom
``TestGenerator`` will only need to provide the tests for a unit to unit conversion.

## Public Interface

The entire public interface to this target is encapsulated within ``GUUnitsGenerator``. This struct provides methods
for generating sources and tests for the `C` and `Swift` targets of the `GUUnits` package. The respective methods
in this struct will use the ``UnitsGenerator`` for souce generation, the ``UnitProtocol`` for unit definition,
and the ``TestGenerator`` for test generation following the procedures outlined above. An example of this entire process
is shown in [Creating New Units](creatingnewunits).
