@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for SwiftNumericTypes.
final class SwiftNumericTypesTests: XCTestCase {

    /// Data container for storing test data for SwiftNumericTypes values.
    struct SwiftNumericTestContainer {

        /// The unit under test.
        var value: SwiftNumericTypes

        /// The values rawValue test data.
        var rawValue: String

        /// The values numericType test data.
        var numericType: NumericTypes

        /// The values sign test data.
        var sign: Signs

    }

    /// Test Int8
    func testInt8() {
        assert(value: .Int8, rawValue: "Int8", numericType: .int8, sign: .t)
    }

    /// Test Int16
    func testInt16() {
        assert(
            container: SwiftNumericTestContainer(
                value: .Int16,
                rawValue: "Int16",
                numericType: .int16,
                sign: .t
            )
        )
    }

    /// Test Int32
    func testInt32() {
        assert(
            container: SwiftNumericTestContainer(
                value: .Int32,
                rawValue: "Int32",
                numericType: .int32,
                sign: .t
            )
        )
    }

    /// Test Int64
    func testInt64() {
        assert(
            container: SwiftNumericTestContainer(
                value: .Int64,
                rawValue: "Int64",
                numericType: .int64,
                sign: .t
            )
        )
    }

    /// Test Int
    func testInt() {
        assert(
            container: SwiftNumericTestContainer(
                value: .Int,
                rawValue: "Int",
                numericType: .int64,
                sign: .t
            )
        )
    }

    /// Test CInt
    func testCInt() {
        assert(
            container: SwiftNumericTestContainer(
                value: .CInt,
                rawValue: "CInt",
                numericType: .int32,
                sign: .t
            )
        )
    }

    /// Test UInt8
    func testUInt8() {
        assert(
            container: SwiftNumericTestContainer(
                value: .UInt8,
                rawValue: "UInt8",
                numericType: .uint8,
                sign: .u
            )
        )
    }

    /// Test UInt16
    func testUInt16() {
        assert(
            container: SwiftNumericTestContainer(
                value: .UInt16,
                rawValue: "UInt16",
                numericType: .uint16,
                sign: .u
            )
        )
    }

    /// Test UInt32
    func testUInt32() {
        assert(
            container: SwiftNumericTestContainer(
                value: .UInt32,
                rawValue: "UInt32",
                numericType: .uint32,
                sign: .u
            )
        )
    }

    /// Test UInt64
    func testUInt64() {
        assert(
            container: SwiftNumericTestContainer(
                value: .UInt64,
                rawValue: "UInt64",
                numericType: .uint64,
                sign: .u
            )
        )
    }

    /// Test UInt
    func testUInt() {
        assert(
            container: SwiftNumericTestContainer(
                value: .UInt,
                rawValue: "UInt",
                numericType: .uint64,
                sign: .u
            )
        )
    }

    /// Test CUnsignedInt
    func testCUnsignedInt() {
        assert(
            container: SwiftNumericTestContainer(
                value: .CUnsignedInt,
                rawValue: "CUnsignedInt",
                numericType: .uint32,
                sign: .u
            )
        )
    }

    /// Test Float.
    func testFloat() {
        assert(
            container: SwiftNumericTestContainer(
                value: .Float,
                rawValue: "Float",
                numericType: .float,
                sign: .f
            )
        )
    }

    /// Test Double.
    func testDouble() {
        assert(
            container: SwiftNumericTestContainer(
                value: .Double,
                rawValue: "Double",
                numericType: .double,
                sign: .d
            )
        )
    }

    /// Test Unique Types static property.
    func testUniqueTypes() {
        let uniqueTypes = SwiftNumericTypes.uniqueTypes
        [
            .Int, .Int8, .Int16, .Int32, .Int64, .UInt, .UInt8, .UInt16, .UInt32, .UInt64, .Float, .Double
        ].forEach { XCTAssertTrue(uniqueTypes.contains($0)) }
        XCTAssertFalse(uniqueTypes.contains(.CInt))
        XCTAssertFalse(uniqueTypes.contains(.CUnsignedInt))
    }

    /// Assert that the containers value matches it's test data.
    /// - Parameter container: The container to test.
    private func assert(container: SwiftNumericTestContainer) {
        self.assert(
            value: container.value,
            rawValue: container.rawValue,
            numericType: container.numericType,
            sign: container.sign
        )
    }

    /// Asserts that a given value matches it's test data.
    /// - Parameters:
    ///   - value: The value to test.
    ///   - rawValue: The expected rawValue of the value.
    ///   - numericType: The expected numeric type of the value.
    ///   - sign: The expected sign of the value.
    private func assert(value: SwiftNumericTypes, rawValue: String, numericType: NumericTypes, sign: Signs) {
        XCTAssertEqual(value.rawValue, rawValue)
        XCTAssertEqual(value.numericType, numericType)
        XCTAssertEqual(value.sign, sign)
    }

}
