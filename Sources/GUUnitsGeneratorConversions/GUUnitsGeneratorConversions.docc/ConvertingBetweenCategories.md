# Coverting Between Categories
This guide provides instructions for creating relations between different unit categories. A user may use a relation to convert a unit
into another unit from a different category.

## Prerequisites
Please read the guides on [Getting Started](gettingstarted), [Creating New Units](creatingnewunits),
[Using Custom Code Generation](usingcustomcodegeneration) and [Composite Units](creatingcompositeunits).

## Defining Relationships
To convert between different categories, a unit may use a ``Relation``. A ``Relation`` is simply an
``Operation`` that converts a unit of one category into a unit of a different category. A unit may define
a relation by specifying a static property called `relationships` in it's category definition.

For example, consider the `Acceleration` unit below:

```swift
/// A unit that represents Acceleration in SI units.
public struct Acceleration: CompositeUnit {

    /// The base unit is SI metres per second squared (m/s^2).
    public static let baseUnit: Operation = .division(
        lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
        rhs: .exponentiate(
            base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
            power: .literal(declaration: .integer(value: 2))
        )
    )

    /// The unit instance of this category.
    public var unit: Operation

    /// Initialise the acceleration from an acceleration unit.
    /// - Parameter unit: The acceleration unit represented as distance divided by time squared.
    public init(unit: Operation) {
        self.unit = unit
    }

}
```

This unit is a ``CompositeUnit`` that represents `acceleration` using SI units. Now suppose we wish
to relate `acceleration` in SI units with another form of `acceleration`, say acceleration proportional
to Earths gravitational constant `g`. This relation should allow us to represent acceleration as `1g`,
`2g`, etc. To achieve this, we must create a new simple unit called ``ReferenceAcceleration`` that contains
the Earth `g`.

```swift
/// Provides non-SI acceleration units.
public enum ReferenceAcceleration: String {

    /// The acceleration from earth gravity.
    case earthG

}

/// ``UnitProtocol`` conformance.
extension ReferenceAcceleration: UnitProtocol {

    /// The abbreviation of the unit.
    public var abbreviation: String {
        switch self {
        case .earthG:
            return "gs"
        }
    }

    /// The description of the unit.
    public var description: String {
        self.rawValue
    }

}

/// ``UnitsConvertible`` conformance.
extension ReferenceAcceleration: UnitsConvertible {

    /// Convert this unit to another unit within the same category.
    /// - Parameter unit: The unit to convert to.
    /// - Returns: The operation converting `self` to `unit`.
    public func conversion(to unit: ReferenceAcceleration) -> Operation {
        .constant(declaration: AnyUnit(self))
    }

}
```

We can now *relate* ``Acceleration`` to ``ReferenceAcceleration`` using a ``Relation``. We can define
these relations inside the `relationships` static property in ``Acceleration``.

```swift
/// ``UnitRelatable`` conformance.
extension Acceleration {

    /// Add metresPerSecond static property for convenience.
    static var metresPerSecond2: AnyUnit {
        AnyUnit(
            Acceleration(
                unit: .division(
                    lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
                    rhs: .exponentiate(
                        base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                        power: .literal(declaration: .integer(value: 2))
                    )
                )
            )
        )
    }

    /// The related types that this category can convert into.
    public static var relationships: [Relation] {
        let mps2 = Operation.division(
            lhs: .constant(declaration: AnyUnit(DistanceUnits.metres)),
            rhs: .exponentiate(
                base: .constant(declaration: AnyUnit(TimeUnits.seconds)),
                power: .literal(declaration: .integer(value: 2))
            )
        )
        let operation = Operation.division(
            lhs: .constant(declaration: Acceleration.metresPerSecond2),
            rhs: .literal(declaration: .decimal(value: Double.earthAcceleration))
        )
        let target = AnyUnit(ReferenceAcceleration.earthG)
        return Self.allCases.map {
            let unit = AnyUnit($0)
            guard unit != Acceleration.metresPerSecond2 else {
                return Relation(
                    source: unit, target: target, operation: operation
                )
            }
            let newOperation = operation.replace(
                convertibles: [Acceleration.metresPerSecond2: $0.conversion(to: Acceleration(unit: mps2))]
            )
            return Relation(source: unit, target: target, operation: newOperation)
        }
    }

}

/// Add g-constant for earth acceleration.
extension Double {

    /// The acceleration of earths gravity in metres per second squared.
    static let earthAcceleration: Double = 9.80665

}
```

This code first converts the ``Acceleration`` into *metres per second squared*, and then divides this value
by Earths gravitation acceleration constant 9.80665 m/s^2. You will also notice that we need to specify the
source unit and the target unit along with this ``Operation`` when defining each ``Relation``.

## Specifying the Tests for the Relationships
The tests for the relationships are automatically generated and specified for each relation through default
implementations in protocol extensions. If you would like to however provide your own implementation, you
may specify a property called `relationTests` that is a `[UnitConversion: [TestParameters]]` type. Please
view the ``OperationalTestable``, ``UnitConversion``, and ``TestParameters`` types for the details of
implementing this.

## Generating The Source Code

There are no additional steps needed to generate the relations in the source code. The file creators for the
C and swift files automatically check the `relationships` property and generate the code appropriately.

## Generated Code
For brevity, we will only show the code for the `metres_per_seconds_sq` types.

### C Layer

#### Header

```h
/**
* Convert metres_per_seconds_sq_t to earthG_t.
*/
earthG_t m_per_s_sq_t_to_gs_t(metres_per_seconds_sq_t metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_t to earthG_u.
*/
earthG_u m_per_s_sq_t_to_gs_u(metres_per_seconds_sq_t metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_t to earthG_f.
*/
earthG_f m_per_s_sq_t_to_gs_f(metres_per_seconds_sq_t metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_t to earthG_d.
*/
earthG_d m_per_s_sq_t_to_gs_d(metres_per_seconds_sq_t metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_u to earthG_t.
*/
earthG_t m_per_s_sq_u_to_gs_t(metres_per_seconds_sq_u metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_u to earthG_u.
*/
earthG_u m_per_s_sq_u_to_gs_u(metres_per_seconds_sq_u metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_u to earthG_f.
*/
earthG_f m_per_s_sq_u_to_gs_f(metres_per_seconds_sq_u metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_u to earthG_d.
*/
earthG_d m_per_s_sq_u_to_gs_d(metres_per_seconds_sq_u metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_f to earthG_t.
*/
earthG_t m_per_s_sq_f_to_gs_t(metres_per_seconds_sq_f metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_f to earthG_u.
*/
earthG_u m_per_s_sq_f_to_gs_u(metres_per_seconds_sq_f metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_f to earthG_f.
*/
earthG_f m_per_s_sq_f_to_gs_f(metres_per_seconds_sq_f metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_f to earthG_d.
*/
earthG_d m_per_s_sq_f_to_gs_d(metres_per_seconds_sq_f metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_d to earthG_t.
*/
earthG_t m_per_s_sq_d_to_gs_t(metres_per_seconds_sq_d metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_d to earthG_u.
*/
earthG_u m_per_s_sq_d_to_gs_u(metres_per_seconds_sq_d metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_d to earthG_f.
*/
earthG_f m_per_s_sq_d_to_gs_f(metres_per_seconds_sq_d metres_per_seconds_sq);

/**
* Convert metres_per_seconds_sq_d to earthG_d.
*/
earthG_d m_per_s_sq_d_to_gs_d(metres_per_seconds_sq_d metres_per_seconds_sq);
```

#### Source File

```c
/**
* Convert metres_per_seconds_sq_t to earthG_t.
*/
earthG_t m_per_s_sq_t_to_gs_t(metres_per_seconds_sq_t metres_per_seconds_sq)
{
    const int64_t unit0 = ((int64_t) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_t(unit0), 0)) {
        return 9223372036854775807;
    } else if (__builtin_expect((overflow_lower_t(unit0)), 0)) {
        return -9223372036854775807 - 1;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 9223372036854775807;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -9223372036854775807 - 1;
        } else {
            return ((earthG_t) (d_to_i64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_t to earthG_u.
*/
earthG_u m_per_s_sq_t_to_gs_u(metres_per_seconds_sq_t metres_per_seconds_sq)
{
    const int64_t unit0 = ((int64_t) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_t(unit0), 0)) {
        return 18446744073709551615U;
    } else if (__builtin_expect((overflow_lower_t(unit0)), 0)) {
        return 0;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 18446744073709551615U;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return 0;
        } else {
            return ((earthG_u) (d_to_u64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_t to earthG_f.
*/
earthG_f m_per_s_sq_t_to_gs_f(metres_per_seconds_sq_t metres_per_seconds_sq)
{
    const int64_t unit0 = ((int64_t) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_t(unit0), 0)) {
        return FLT_MAX;
    } else if (__builtin_expect((overflow_lower_t(unit0)), 0)) {
        return -FLT_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return FLT_MAX;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -FLT_MAX;
        } else {
            return ((earthG_f) (d_to_f(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_t to earthG_d.
*/
earthG_d m_per_s_sq_t_to_gs_d(metres_per_seconds_sq_t metres_per_seconds_sq)
{
    const int64_t unit0 = ((int64_t) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_t(unit0), 0)) {
        return DBL_MAX;
    } else if (__builtin_expect((overflow_lower_t(unit0)), 0)) {
        return -DBL_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return DBL_MAX;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -DBL_MAX;
        } else {
            return ((earthG_d) (result));
        }
    }
}

/**
* Convert metres_per_seconds_sq_u to earthG_t.
*/
earthG_t m_per_s_sq_u_to_gs_t(metres_per_seconds_sq_u metres_per_seconds_sq)
{
    const uint64_t unit0 = ((uint64_t) (metres_per_seconds_sq));
    if (__builtin_expect((overflow_upper_u(unit0)), 0)) {
        return 9223372036854775807;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 9223372036854775807;
        } else {
            return ((earthG_t) (d_to_i64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_u to earthG_u.
*/
earthG_u m_per_s_sq_u_to_gs_u(metres_per_seconds_sq_u metres_per_seconds_sq)
{
    const uint64_t unit0 = ((uint64_t) (metres_per_seconds_sq));
    if (__builtin_expect((overflow_upper_u(unit0)), 0)) {
        return 18446744073709551615U;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 18446744073709551615U;
        } else {
            return ((earthG_u) (d_to_u64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_u to earthG_f.
*/
earthG_f m_per_s_sq_u_to_gs_f(metres_per_seconds_sq_u metres_per_seconds_sq)
{
    const uint64_t unit0 = ((uint64_t) (metres_per_seconds_sq));
    if (__builtin_expect((overflow_upper_u(unit0)), 0)) {
        return FLT_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return FLT_MAX;
        } else {
            return ((earthG_f) (d_to_f(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_u to earthG_d.
*/
earthG_d m_per_s_sq_u_to_gs_d(metres_per_seconds_sq_u metres_per_seconds_sq)
{
    const uint64_t unit0 = ((uint64_t) (metres_per_seconds_sq));
    if (__builtin_expect((overflow_upper_u(unit0)), 0)) {
        return DBL_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return DBL_MAX;
        } else {
            return ((earthG_d) (result));
        }
    }
}

/**
* Convert metres_per_seconds_sq_f to earthG_t.
*/
earthG_t m_per_s_sq_f_to_gs_t(metres_per_seconds_sq_f metres_per_seconds_sq)
{
    const float unit0 = ((float) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_f(unit0), 0)) {
        return 9223372036854775807;
    } else if (__builtin_expect((overflow_lower_f(unit0)), 0)) {
        return -9223372036854775807 - 1;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 9223372036854775807;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -9223372036854775807 - 1;
        } else {
            return ((earthG_t) (d_to_i64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_f to earthG_u.
*/
earthG_u m_per_s_sq_f_to_gs_u(metres_per_seconds_sq_f metres_per_seconds_sq)
{
    const float unit0 = ((float) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_f(unit0), 0)) {
        return 18446744073709551615U;
    } else if (__builtin_expect((overflow_lower_f(unit0)), 0)) {
        return 0;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 18446744073709551615U;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return 0;
        } else {
            return ((earthG_u) (d_to_u64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_f to earthG_f.
*/
earthG_f m_per_s_sq_f_to_gs_f(metres_per_seconds_sq_f metres_per_seconds_sq)
{
    const float unit0 = ((float) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_f(unit0), 0)) {
        return FLT_MAX;
    } else if (__builtin_expect((overflow_lower_f(unit0)), 0)) {
        return -FLT_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return FLT_MAX;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -FLT_MAX;
        } else {
            return ((earthG_f) (d_to_f(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_f to earthG_d.
*/
earthG_d m_per_s_sq_f_to_gs_d(metres_per_seconds_sq_f metres_per_seconds_sq)
{
    const float unit0 = ((float) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_f(unit0), 0)) {
        return DBL_MAX;
    } else if (__builtin_expect((overflow_lower_f(unit0)), 0)) {
        return -DBL_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return DBL_MAX;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -DBL_MAX;
        } else {
            return ((earthG_d) (result));
        }
    }
}

/**
* Convert metres_per_seconds_sq_d to earthG_t.
*/
earthG_t m_per_s_sq_d_to_gs_t(metres_per_seconds_sq_d metres_per_seconds_sq)
{
    const double unit0 = ((double) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_d(unit0), 0)) {
        return 9223372036854775807;
    } else if (__builtin_expect((overflow_lower_d(unit0)), 0)) {
        return -9223372036854775807 - 1;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 9223372036854775807;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -9223372036854775807 - 1;
        } else {
            return ((earthG_t) (d_to_i64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_d to earthG_u.
*/
earthG_u m_per_s_sq_d_to_gs_u(metres_per_seconds_sq_d metres_per_seconds_sq)
{
    const double unit0 = ((double) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_d(unit0), 0)) {
        return 18446744073709551615U;
    } else if (__builtin_expect((overflow_lower_d(unit0)), 0)) {
        return 0;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return 18446744073709551615U;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return 0;
        } else {
            return ((earthG_u) (d_to_u64(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_d to earthG_f.
*/
earthG_f m_per_s_sq_d_to_gs_f(metres_per_seconds_sq_d metres_per_seconds_sq)
{
    const double unit0 = ((double) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_d(unit0), 0)) {
        return FLT_MAX;
    } else if (__builtin_expect((overflow_lower_d(unit0)), 0)) {
        return -FLT_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return FLT_MAX;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -FLT_MAX;
        } else {
            return ((earthG_f) (d_to_f(result)));
        }
    }
}

/**
* Convert metres_per_seconds_sq_d to earthG_d.
*/
earthG_d m_per_s_sq_d_to_gs_d(metres_per_seconds_sq_d metres_per_seconds_sq)
{
    const double unit0 = ((double) (metres_per_seconds_sq));
    if (__builtin_expect(overflow_upper_d(unit0), 0)) {
        return DBL_MAX;
    } else if (__builtin_expect((overflow_lower_d(unit0)), 0)) {
        return -DBL_MAX;
    } else {
        const double result = divide_d((((double) (metres_per_seconds_sq))), (((double) (9.80665))));
        if (__builtin_expect(overflow_upper_d(result), 0)) {
            return DBL_MAX;
        } else if (__builtin_expect(overflow_lower_d(result), 0)) {
            return -DBL_MAX;
        } else {
            return ((earthG_d) (result));
        }
    }
}
```

### Swift Layer

```swift
public extension Earthg_t {

    /// Create a `Earthg_t` from a `Metres_Per_Seconds_Sq_t`.
    init(_ value: Metres_Per_Seconds_Sq_t) {
        self.init(rawValue: m_per_s_sq_t_to_gs_t(value.rawValue))
    }

    /// Create a `Earthg_t` from a `Metres_Per_Seconds_Sq_u`.
    init(_ value: Metres_Per_Seconds_Sq_u) {
        self.init(rawValue: m_per_s_sq_u_to_gs_t(value.rawValue))
    }

    /// Create a `Earthg_t` from a `Metres_Per_Seconds_Sq_f`.
    init(_ value: Metres_Per_Seconds_Sq_f) {
        self.init(rawValue: m_per_s_sq_f_to_gs_t(value.rawValue))
    }

    /// Create a `Earthg_t` from a `Metres_Per_Seconds_Sq_d`.
    init(_ value: Metres_Per_Seconds_Sq_d) {
        self.init(rawValue: m_per_s_sq_d_to_gs_t(value.rawValue))
    }

}

public extension Earthg_u {

    /// Create a `Earthg_u` from a `Metres_Per_Seconds_Sq_t`.
    init(_ value: Metres_Per_Seconds_Sq_t) {
        self.init(rawValue: m_per_s_sq_t_to_gs_u(value.rawValue))
    }

    /// Create a `Earthg_u` from a `Metres_Per_Seconds_Sq_u`.
    init(_ value: Metres_Per_Seconds_Sq_u) {
        self.init(rawValue: m_per_s_sq_u_to_gs_u(value.rawValue))
    }

    /// Create a `Earthg_u` from a `Metres_Per_Seconds_Sq_f`.
    init(_ value: Metres_Per_Seconds_Sq_f) {
        self.init(rawValue: m_per_s_sq_f_to_gs_u(value.rawValue))
    }

    /// Create a `Earthg_u` from a `Metres_Per_Seconds_Sq_d`.
    init(_ value: Metres_Per_Seconds_Sq_d) {
        self.init(rawValue: m_per_s_sq_d_to_gs_u(value.rawValue))
    }

}

public extension Earthg_f {

    /// Create a `Earthg_f` from a `Metres_Per_Seconds_Sq_t`.
    init(_ value: Metres_Per_Seconds_Sq_t) {
        self.init(rawValue: m_per_s_sq_t_to_gs_f(value.rawValue))
    }

    /// Create a `Earthg_f` from a `Metres_Per_Seconds_Sq_u`.
    init(_ value: Metres_Per_Seconds_Sq_u) {
        self.init(rawValue: m_per_s_sq_u_to_gs_f(value.rawValue))
    }

    /// Create a `Earthg_f` from a `Metres_Per_Seconds_Sq_f`.
    init(_ value: Metres_Per_Seconds_Sq_f) {
        self.init(rawValue: m_per_s_sq_f_to_gs_f(value.rawValue))
    }

    /// Create a `Earthg_f` from a `Metres_Per_Seconds_Sq_d`.
    init(_ value: Metres_Per_Seconds_Sq_d) {
        self.init(rawValue: m_per_s_sq_d_to_gs_f(value.rawValue))
    }

}

public extension Earthg_d {

    /// Create a `Earthg_d` from a `Metres_Per_Seconds_Sq_t`.
    init(_ value: Metres_Per_Seconds_Sq_t) {
        self.init(rawValue: m_per_s_sq_t_to_gs_d(value.rawValue))
    }

    /// Create a `Earthg_d` from a `Metres_Per_Seconds_Sq_u`.
    init(_ value: Metres_Per_Seconds_Sq_u) {
        self.init(rawValue: m_per_s_sq_u_to_gs_d(value.rawValue))
    }

    /// Create a `Earthg_d` from a `Metres_Per_Seconds_Sq_f`.
    init(_ value: Metres_Per_Seconds_Sq_f) {
        self.init(rawValue: m_per_s_sq_f_to_gs_d(value.rawValue))
    }

    /// Create a `Earthg_d` from a `Metres_Per_Seconds_Sq_d`.
    init(_ value: Metres_Per_Seconds_Sq_d) {
        self.init(rawValue: m_per_s_sq_d_to_gs_d(value.rawValue))
    }

}
```
