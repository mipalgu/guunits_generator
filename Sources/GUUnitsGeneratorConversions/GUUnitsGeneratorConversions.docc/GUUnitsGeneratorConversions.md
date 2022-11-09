# ``GUUnitsGeneratorConversions``

A target for generating the GUUnits package.

## Usage

You may use this package as a stand-alone swift project. You may perform the standard package manager commands to build
and test the code.

```shell
swift build
swift test
```

To generate the binary for this package, it is preferred that you perform a release build.

```swift
swift build -c release
```

You may then invoke the binary via:

```
$ .build/release/guunits_generator -h
guunits_generator

Usage: guunits_generator [-h] [-d <directory>]
```

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:CreatingNewUnits>
- <doc:UsingCustomCodeGeneration>
- <doc:CreatingCompositeUnits>
- <doc:ConvertingBetweenCategories>

### C Source Generation
- ``AngleFunctionCreator``
- ``AnyGenerator``
- ``CFileCreator``
- ``CFunctionDefinitionCreator``
- ``CompositeFunctionCreator``
- ``DelegatingFunctionCreator``
- ``DelegatingNumericConverter``
- ``FunctionBodyCreator``
- ``FunctionCreator``
- ``FunctionDefinitionCreator``
- ``FunctionHelpers``
- ``GradualFunctionCreator``
- ``HeaderCreator``
- ``NumericConverterProtocol``
- ``NumericTypeConverter``
- ``OperationalFunctionBodyCreator``
- ``SignConverter``
- ``TemperatureFunctionCreator``
- ``UnitsGeneratable``
- ``UnitsGenerator``

### Swift Source Generation
- ``SwiftFileCreator``

### C Test Generation
- ``GradualTestGenerator``
- ``TestFileCreator``
- ``TestGenerator``
- ``TestParameters``
- ``OperationalTestable``
- ``OperationalTestGenerator``
- ``ConversionMetaData``
- ``UnitConversion``

### Swift Test Generation
- ``SwiftTestFileCreator``

### Unit Definitions
- ``Base10UnitsConvertible``
- ``CompositeUnit``
- ``Literal``
- ``NamedUnit``
- ``NumericTypes``
- ``Operation``
- ``Relation``
- ``Signs``
- ``SwiftNumericTypes``
- ``UnitProtocol``
- ``UnitRelatable``
- ``UnitsConvertible``

### Supported Units
- ``Acceleration``
- ``AngleUnits``
- ``AngularVelocity``
- ``CurrentUnits``
- ``DistanceUnits``
- ``ImageUnits``
- ``MassUnits``
- ``PercentUnits``
- ``ReferenceAcceleration``
- ``TemperatureUnits``
- ``TimeUnits``
- ``Velocity``

### Top Module
- ``GUUnitsGenerator``
