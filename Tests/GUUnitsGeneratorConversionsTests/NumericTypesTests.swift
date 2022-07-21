@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for numeric types.
final class NumericTypesTests: XCTestCase {

    /// Test int
    func testInt() {
        assert(
            value: .int,
            rawValue: "int",
            abbreviation: "i",
            isSigned: true,
            isFloat: false,
            opposite: .uint,
            limits: ("INT_MIN", "INT_MAX"),
            swiftType: .CInt,
            smallerThan: [.int64, .double, .float],
            largerThan: [.int8, .int16]
        )
    }

    /// Test int8
    func testInt8() {
        assert(
            value: .int8,
            rawValue: "int8_t",
            abbreviation: "i8",
            isSigned: true,
            isFloat: false,
            opposite: .uint8,
            limits: ("-128", "127"),
            swiftType: .Int8,
            smallerThan: [.int16, .int32, .int64, .double, .float],
            largerThan: []
        )
    }

    /// Test int16
    func testInt16() {
        assert(
            value: .int16,
            rawValue: "int16_t",
            abbreviation: "i16",
            isSigned: true,
            isFloat: false,
            opposite: .uint16,
            limits: ("SHRT_MIN", "SHRT_MAX"),
            swiftType: .Int16,
            smallerThan: [.int32, .int64, .double, .float],
            largerThan: [.int8]
        )
    }

    /// Test int32
    func testInt32() {
        assert(
            value: .int32,
            rawValue: "int32_t",
            abbreviation: "i32",
            isSigned: true,
            isFloat: false,
            opposite: .uint32,
            limits: ("INT_MIN", "INT_MAX"),
            swiftType: .Int32,
            smallerThan: [.int64, .double, .float],
            largerThan: [.int8, .int16]
        )
    }

    /// Test int64
    func testInt64() {
        assert(
            value: .int64,
            rawValue: "int64_t",
            abbreviation: "i64",
            isSigned: true,
            isFloat: false,
            opposite: .uint64,
            limits: ("LONG_MIN", "LONG_MAX"),
            swiftType: .Int64,
            smallerThan: [],
            largerThan: [.int8, .int16, .int32, .int, .float]
        )
    }

    /// Test uint
    func testUInt() {
        assert(
            value: .uint,
            rawValue: "unsigned int",
            abbreviation: "u",
            isSigned: false,
            isFloat: false,
            opposite: .int,
            limits: ("0", "UINT_MAX"),
            swiftType: .CUnsignedInt,
            smallerThan: [.uint64],
            largerThan: [.uint8, .uint16]
        )
    }

    /// Test uint8
    func testUInt8() {
        assert(
            value: .uint8,
            rawValue: "uint8_t",
            abbreviation: "u8",
            isSigned: false,
            isFloat: false,
            opposite: .int8,
            limits: ("0", "255"),
            swiftType: .UInt8,
            smallerThan: [.uint16, .uint32, .uint64],
            largerThan: []
        )
    }

    /// Test uint16
    func testUInt16() {
        assert(
            value: .uint16,
            rawValue: "uint16_t",
            abbreviation: "u16",
            isSigned: false,
            isFloat: false,
            opposite: .int16,
            limits: ("0", "USHRT_MAX"),
            swiftType: .UInt16,
            smallerThan: [.uint32, .uint64],
            largerThan: [.uint8]
        )
    }

    /// Test uint32
    func testUInt32() {
        assert(
            value: .uint32,
            rawValue: "uint32_t",
            abbreviation: "u32",
            isSigned: false,
            isFloat: false,
            opposite: .int32,
            limits: ("0", "UINT_MAX"),
            swiftType: .UInt32,
            smallerThan: [.uint64],
            largerThan: [.uint8, .uint16]
        )
    }

    /// Test uint64
    func testUInt64() {
        assert(
            value: .uint64,
            rawValue: "uint64_t",
            abbreviation: "u64",
            isSigned: false,
            isFloat: false,
            opposite: .int64,
            limits: ("0", "ULONG_MAX"),
            swiftType: .UInt64,
            smallerThan: [],
            largerThan: [.uint8, .uint16, .uint32]
        )
    }

    /// Test float
    func testFloat() {
        assert(
            value: .float,
            rawValue: "float",
            abbreviation: "f",
            isSigned: true,
            isFloat: true,
            opposite: .float,
            limits: ("FLT_MIN", "FLT_MAX"),
            swiftType: .Float,
            smallerThan: [],
            largerThan: []
        )
    }

    /// Test double
    func testDouble() {
        assert(
            value: .double,
            rawValue: "double",
            abbreviation: "d",
            isSigned: true,
            isFloat: true,
            opposite: .double,
            limits: ("DBL_MIN", "DBL_MAX"),
            swiftType: .Double,
            smallerThan: [],
            largerThan: []
        )
    }

    /// Tests all properties of a NumericTypes case.
    /// - Parameters:
    ///   - value: The unit under test.
    ///   - rawValue: The underlying c declaration.
    ///   - abbreviation: The guunits abbreviation.
    ///   - isSigned: True when the value is signed.
    ///   - isFloat: True when the value is a floating point number.
    ///   - opposite: The opposite type.
    ///   - limits: The lowest value and highest values as a tuple.
    ///   - swiftType: The equivalent swift type.
    ///   - smallerThan: An array of types that are larger than value.
    ///   - largerThan: An array of types that are smaller than value.
    private func assert(
        value: NumericTypes,
        rawValue: String,
        abbreviation: String,
        isSigned: Bool,
        isFloat: Bool,
        opposite: NumericTypes,
        limits: (String, String),
        swiftType: SwiftNumericTypes,
        smallerThan: [NumericTypes],
        largerThan: [NumericTypes]
    ) {
        XCTAssertEqual(value.rawValue, rawValue)
        XCTAssertEqual(value.abbreviation, abbreviation)
        XCTAssertEqual(value.isSigned, isSigned)
        XCTAssertEqual(value.isFloat, isFloat)
        XCTAssertEqual(value.opposite, opposite)
        let valueLimits = value.limits
        XCTAssertEqual(valueLimits.0, limits.0)
        XCTAssertEqual(valueLimits.1, limits.1)
        XCTAssertEqual(value.swiftType, swiftType)
        assert(value: value, smallerThan: smallerThan)
        assert(value: value, largerThan: largerThan)
    }

    /// Assert that all types in largerThan or smaller than value.
    /// - Parameters:
    ///   - value: The uut.
    ///   - largerThan: Types smaller than value.
    private func assert(value: NumericTypes, largerThan: [NumericTypes]) {
        largerThan.forEach {
            XCTAssertTrue(value.largerThan($0))
        }
    }

    /// Assert that all types in smallerThan are larger than value.
    /// - Parameters:
    ///   - value: The uut.
    ///   - smallerThan: Types that are larger than value.
    private func assert(value: NumericTypes, smallerThan: [NumericTypes]) {
        smallerThan.forEach {
            XCTAssertTrue(value.smallerThan($0))
        }
    }

}
