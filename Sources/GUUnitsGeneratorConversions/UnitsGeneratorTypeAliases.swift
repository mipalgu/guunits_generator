/// Distance Units Generator
public typealias DistanceUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<DistanceUnits>,
        CFunctionDefinitionCreator<DistanceUnits>,
        NumericTypeConverter
    >
>

/// Time Units Generator
public typealias TimeUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<TimeUnits>,
        CFunctionDefinitionCreator<TimeUnits>,
        NumericTypeConverter
    >
>

/// Angle Units Generator.
public typealias AngleUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        AngleFunctionCreator,
        CFunctionDefinitionCreator<AngleUnits>,
        NumericTypeConverter
    >
>

/// Image Units Generator
public typealias ImageUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<ImageUnits>,
        CFunctionDefinitionCreator<ImageUnits>,
        NumericTypeConverter
    >
>

/// Percent Units Generator
public typealias PercentUnitGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<PercentUnits>,
        CFunctionDefinitionCreator<PercentUnits>,
        NumericTypeConverter
    >
>

/// CPP Distance Units Generator
public typealias CPPDistanceUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        DelegatingFunctionCreator<DistanceUnits>,
        CPPFunctionDefinitionCreator<DistanceUnits>,
        DelegatingNumericConverter
    >
>

/// CPP Time Units Generator.
public typealias CPPTimeUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        DelegatingFunctionCreator<TimeUnits>,
        CPPFunctionDefinitionCreator<TimeUnits>,
        DelegatingNumericConverter
    >
>

/// CPP Angle Units Generator.
public typealias CPPAngleUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        DelegatingFunctionCreator<AngleUnits>,
        CPPFunctionDefinitionCreator<AngleUnits>,
        DelegatingNumericConverter
    >
>
