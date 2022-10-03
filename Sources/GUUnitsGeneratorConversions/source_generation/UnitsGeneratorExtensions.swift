/// DistanceUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<DistanceUnits>,
    CFunctionDefinitionCreator<DistanceUnits>, NumericTypeConverter> {

    /// Initialise using DistanceUnits and c conversions.
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

/// DistanceUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<DistanceUnits>,
    CPPFunctionDefinitionCreator<DistanceUnits>, NumericTypeConverter> {

    /// Initialise using DistanceUnits and cpp conversions.
    /// - Parameter unitDifference: The magnitude difference between an ordered array
    ///                             of units.
    public init(unitDifference: [Creator.Unit: Int]) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: GradualFunctionCreator(unitDifference: unitDifference),
            definitionCreator: CPPFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

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

/// MassUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<MassUnits>,
    CPPFunctionDefinitionCreator<MassUnits>, NumericTypeConverter> {

    /// Initialise using MassUnits and cpp conversions.
    /// - Parameter unitDifference: The magnitude difference between an ordered array
    ///                             of units.
    public init(unitDifference: [Creator.Unit: Int]) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: GradualFunctionCreator(unitDifference: unitDifference),
            definitionCreator: CPPFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

/// CurrentUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<CurrentUnits>,
    CFunctionDefinitionCreator<CurrentUnits>, NumericTypeConverter> {

    /// Initialise using CurrentUnits and c conversions.
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

/// CurrentUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<CurrentUnits>,
    CPPFunctionDefinitionCreator<CurrentUnits>, NumericTypeConverter> {

    /// Initialise using CurrentUnits and cpp conversions.
    /// - Parameter unitDifference: The magnitude difference between an ordered array
    ///                             of units.
    public init(unitDifference: [Creator.Unit: Int]) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: GradualFunctionCreator(unitDifference: unitDifference),
            definitionCreator: CPPFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

/// ImageUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<ImageUnits>,
    CFunctionDefinitionCreator<ImageUnits>, NumericTypeConverter> {

    /// Initialise using ImageUnits and c conversions.
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

/// ImageUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<ImageUnits>,
    CPPFunctionDefinitionCreator<ImageUnits>, NumericTypeConverter> {

    /// Initialise using ImageUnits and cpp conversions.
    /// - Parameter unitDifference: The magnitude difference between an ordered array
    ///                             of units.
    public init(unitDifference: [Creator.Unit: Int]) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: GradualFunctionCreator(unitDifference: unitDifference),
            definitionCreator: CPPFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

/// PercentUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<PercentUnits>,
    CFunctionDefinitionCreator<PercentUnits>, NumericTypeConverter> {

    /// Initialise using PercentUnits and c conversions.
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

/// PercentUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<PercentUnits>,
    CPPFunctionDefinitionCreator<PercentUnits>, NumericTypeConverter> {

    /// Initialise using PercentUnits and cpp conversions.
    /// - Parameter unitDifference: The magnitude difference between an ordered array
    ///                             of units.
    public init(unitDifference: [Creator.Unit: Int]) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: GradualFunctionCreator(unitDifference: unitDifference),
            definitionCreator: CPPFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

/// TimeUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<TimeUnits>,
    CFunctionDefinitionCreator<TimeUnits>, NumericTypeConverter> {

    /// Initialise using TimeUnits and c conversions.
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

/// TimeUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<GradualFunctionCreator<TimeUnits>,
    CPPFunctionDefinitionCreator<TimeUnits>, NumericTypeConverter> {

    /// Initialise using TimeUnits and cpp conversions.
    /// - Parameter unitDifference: The magnitude difference between an ordered array
    ///                             of units.
    public init(unitDifference: [Creator.Unit: Int]) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: GradualFunctionCreator(unitDifference: unitDifference),
            definitionCreator: CPPFunctionDefinitionCreator(),
            numericConverter: NumericTypeConverter()
        ))
    }

}

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

/// AngleUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<
        AngleFunctionCreator,
        CPPFunctionDefinitionCreator<AngleUnits>,
        NumericTypeConverter
    > {

    /// Initialise using AngleUnits and CPP conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: AngleFunctionCreator = AngleFunctionCreator(),
        definitionCreator: CPPFunctionDefinitionCreator<AngleUnits> = CPPFunctionDefinitionCreator(),
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

/// TemperatureUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<
        TemperatureFunctionCreator,
        CPPFunctionDefinitionCreator<TemperatureUnits>,
        NumericTypeConverter
    > {

    /// Initialise using TemperatureUnits and CPP conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: TemperatureFunctionCreator = TemperatureFunctionCreator(),
        definitionCreator: CPPFunctionDefinitionCreator<TemperatureUnits> = CPPFunctionDefinitionCreator(),
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

/// AccelerationUnits initialiser for C conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<
        AccelerationFunctionCreator,
        CFunctionDefinitionCreator<AccelerationUnits>,
        NumericTypeConverter
    > {

    /// Initialise using AngleUnits and C conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: AccelerationFunctionCreator = AccelerationFunctionCreator(),
        definitionCreator: CFunctionDefinitionCreator<AccelerationUnits> = CFunctionDefinitionCreator(),
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

/// AccelerationUnits initialiser for CPP conversions.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<
        AccelerationFunctionCreator,
        CPPFunctionDefinitionCreator<AccelerationUnits>,
        NumericTypeConverter
    > {

    /// Initialise using AngleUnits and CPP conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: AccelerationFunctionCreator = AccelerationFunctionCreator(),
        definitionCreator: CPPFunctionDefinitionCreator<AccelerationUnits> = CPPFunctionDefinitionCreator(),
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

/// DistanceUnits initialiser for cpp conversions using Delegating function creators.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<DelegatingFunctionCreator<DistanceUnits>,
    CPPFunctionDefinitionCreator<DistanceUnits>, DelegatingNumericConverter> {

    /// Initialise using DistanceUnits and CPP conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: DelegatingFunctionCreator<DistanceUnits> = DelegatingFunctionCreator(),
        definitionCreator: CPPFunctionDefinitionCreator<DistanceUnits> = CPPFunctionDefinitionCreator(),
        numericConverter: DelegatingNumericConverter = DelegatingNumericConverter(),
        helpers: FunctionHelpers<Creator.Unit> = FunctionHelpers<Creator.Unit>()
    ) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: bodyCreator,
            definitionCreator: definitionCreator,
            numericConverter: numericConverter
        ))
    }

}

/// MassUnits initialiser for cpp conversions using Delegating function creators.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<DelegatingFunctionCreator<MassUnits>,
    CPPFunctionDefinitionCreator<MassUnits>, DelegatingNumericConverter> {

    /// Initialise using MassUnits and CPP conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: DelegatingFunctionCreator<MassUnits> = DelegatingFunctionCreator(),
        definitionCreator: CPPFunctionDefinitionCreator<MassUnits> = CPPFunctionDefinitionCreator(),
        numericConverter: DelegatingNumericConverter = DelegatingNumericConverter(),
        helpers: FunctionHelpers<Creator.Unit> = FunctionHelpers<Creator.Unit>()
    ) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: bodyCreator,
            definitionCreator: definitionCreator,
            numericConverter: numericConverter
        ))
    }

}

/// TimeUnits initialiser for cpp conversions using Delegating function creators.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<DelegatingFunctionCreator<TimeUnits>,
    CPPFunctionDefinitionCreator<TimeUnits>, DelegatingNumericConverter> {

    /// Initialise using TimeUnits and CPP conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: DelegatingFunctionCreator<TimeUnits> = DelegatingFunctionCreator(),
        definitionCreator: CPPFunctionDefinitionCreator<TimeUnits> = CPPFunctionDefinitionCreator(),
        numericConverter: DelegatingNumericConverter = DelegatingNumericConverter(),
        helpers: FunctionHelpers<Creator.Unit> = FunctionHelpers<Creator.Unit>()
    ) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: bodyCreator,
            definitionCreator: definitionCreator,
            numericConverter: numericConverter
        ))
    }

}

/// AngleUnits initialiser for cpp conversions using Delegating function creators.
extension UnitsGenerator where
    Creator == CompositeFunctionCreator<DelegatingFunctionCreator<AngleUnits>,
    CPPFunctionDefinitionCreator<AngleUnits>, DelegatingNumericConverter> {

    /// Initialise using AngleUnits and CPP conversions.
    /// - Parameters:
    ///   - bodyCreator: The creator which generates function bodies.
    ///   - definitionCreator: The definitionCreate which generates function definitions.
    ///   - numericConverter: The numericConverter which generates numeric type conversions.
    ///   - helpers: The helpers which generate function names and some definitions.
    public init(
        bodyCreator: DelegatingFunctionCreator<AngleUnits> = DelegatingFunctionCreator(),
        definitionCreator: CPPFunctionDefinitionCreator<AngleUnits> = CPPFunctionDefinitionCreator(),
        numericConverter: DelegatingNumericConverter = DelegatingNumericConverter(),
        helpers: FunctionHelpers<Creator.Unit> = FunctionHelpers<Creator.Unit>()
    ) {
        self.init(creator: CompositeFunctionCreator(
            bodyCreator: bodyCreator,
            definitionCreator: definitionCreator,
            numericConverter: numericConverter
        ))
    }

}
