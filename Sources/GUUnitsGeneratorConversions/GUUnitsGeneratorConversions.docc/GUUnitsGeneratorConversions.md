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

### C Source Generation
- ``AccelerationFunctionCreator``
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

### Swift Test Generation
- ``SwiftTestFileCreator``

### Unit Definitions
- ``AccelerationUnits``
- ``AngleUnits``
- ``CurrentUnits``
- ``DistanceUnits``
- ``ImageUnits``
- ``MassUnits``
- ``NumericTypes``
- ``PercentUnits``
- ``Signs``
- ``SwiftNumericTypes``
- ``TemperatureUnits``
- ``TimeUnits``
- ``UnitProtocol``

### Top Module
- ``GUUnitsGenerator``
