# GUUnitsGeneratorConversions

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

