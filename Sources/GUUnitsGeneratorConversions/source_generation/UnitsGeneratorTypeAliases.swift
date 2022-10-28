/// Generator used for ``CompositeUnit`` types.
public typealias OperationalGenerator<Unit: CompositeUnit> = UnitsGenerator<
    CompositeFunctionCreator<
        OperationalFunctionBodyCreator<Unit>,
        CFunctionDefinitionCreator<Unit>,
        NumericTypeConverter
    >
> where Unit: UnitsConvertible

/// Distance Units Generator
public typealias DistanceUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<DistanceUnits>,
        CFunctionDefinitionCreator<DistanceUnits>,
        NumericTypeConverter
    >
>

/// Mass Units Generator
public typealias MassUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<MassUnits>,
        CFunctionDefinitionCreator<MassUnits>,
        NumericTypeConverter
    >
>

/// Current Units Generator
public typealias CurrentUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        GradualFunctionCreator<CurrentUnits>,
        CFunctionDefinitionCreator<CurrentUnits>,
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

/// Temperature Units Generator
public typealias TemperatureUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        TemperatureFunctionCreator,
        CFunctionDefinitionCreator<TemperatureUnits>,
        NumericTypeConverter
    >
>

/// Acceleration Units Generator.
public typealias AccelerationUnitsGenerator = UnitsGenerator<
    CompositeFunctionCreator<
        AccelerationFunctionCreator,
        CFunctionDefinitionCreator<AccelerationUnits>,
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
