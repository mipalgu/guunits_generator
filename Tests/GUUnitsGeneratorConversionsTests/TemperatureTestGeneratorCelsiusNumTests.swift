import Foundation
@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for TemperatureTestGenerator Celsius to Numeric conversions.
final class TemperatureTestGeneratorCelsiusNumTests: XCTestCase, TestParameterTestable {

    /// The generator to test.
    let generator = TemperatureTestGenerator()

    // swiftlint:disable missing_docs

    func testCelsiusTToCelsiusFloatUnitTypes() {
        [Signs.f, Signs.d].forEach {
            let result = generator.testParameters(from: .celsius, with: .t, to: .celsius, with: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "celsius_t(CInt.max)", output: "celsius_\($0.rawValue)(CInt.max)"),
                TestParameters(input: "celsius_t(CInt.min)", output: "celsius_\($0.rawValue)(CInt.min)"),
                TestParameters(input: "0", output: "0.0"),
                TestParameters(input: "5", output: "5.0")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for unit conversion from celsius_t to celsius_\($0.rawValue)")
                return
            }
        }
    }

    func testCelsiusTToFloatNumericTypes() {
        [NumericTypes.float, NumericTypes.double].forEach {
            let expected: Set<TestParameters> = [
                TestParameters(input: "celsius_t(CInt.max)", output: "\($0.swiftType)(CInt.max)"),
                TestParameters(input: "celsius_t(CInt.min)", output: "\($0.swiftType)(CInt.min)"),
                TestParameters(input: "0", output: "0.0"),
                TestParameters(input: "5", output: "5.0")
            ]
            let result = generator.testParameters(from: .celsius, with: .t, to: $0)
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for celsius_t to \($0.rawValue) conversion")
                return
            }
        }
    }

    func testCelsiusTToCelsiusSignedTypes() {
        [NumericTypes.int, NumericTypes.int32, NumericTypes.int64].forEach {
            let result = generator.testParameters(from: .celsius, with: .t, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(input: "celsius_t(CInt.max)", output: "\($0.swiftType.rawValue)(CInt.max)"),
                TestParameters(input: "celsius_t(CInt.min)", output: "\($0.swiftType.rawValue)(CInt.min)"),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_t to \($0.rawValue)")
                return
            }
        }
        [NumericTypes.int16, NumericTypes.int8].forEach {
            let result = generator.testParameters(from: .celsius, with: .t, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(input: "celsius_t(CInt.max)", output: "\($0.swiftType)(\($0.swiftType).max)"),
                TestParameters(input: "celsius_t(CInt.min)", output: "\($0.swiftType)(\($0.swiftType).min)"),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_t to \($0.rawValue)")
                return
            }
        }
    }

    func testCelsiusTToUnsignedTypes() {
        [NumericTypes.uint, NumericTypes.uint32, NumericTypes.uint64].forEach {
            let result = generator.testParameters(from: .celsius, with: .t, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(input: "celsius_t(CInt.max)", output: "\($0.swiftType.rawValue)(CInt.max)"),
                TestParameters(input: "celsius_t(CInt.min)", output: "\($0.swiftType)(\($0.swiftType).min)"),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_t to \($0.rawValue)")
                return
            }
        }
        [NumericTypes.uint16, NumericTypes.uint8].forEach {
            let result = generator.testParameters(from: .celsius, with: .t, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(input: "celsius_t(CInt.max)", output: "\($0.swiftType)(\($0.swiftType).max)"),
                TestParameters(input: "celsius_t(CInt.min)", output: "\($0.swiftType)(\($0.swiftType).min)"),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_t to \($0.rawValue)")
                return
            }
        }
    }

    func testCelsiusTToCelsiusU() {
        let result = generator.testParameters(from: .celsius, with: .t, to: .celsius, with: .u)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "0"),
            TestParameters(input: "celsius_t(CInt.max)", output: "celsius_u(CInt.max)"),
            TestParameters(input: "celsius_t(CInt.min)", output: "celsius_u(CUnsignedInt.min)"),
            TestParameters(input: "5", output: "5")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusUToCelsiusFloatUnitTypes() {
        [Signs.f, Signs.d].forEach {
            let result = generator.testParameters(from: .celsius, with: .u, to: .celsius, with: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0.0"),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.max)", output: "celsius_\($0.rawValue)(CUnsignedInt.max)"
                ),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.min)", output: "celsius_\($0.rawValue)(CUnsignedInt.min)"
                ),
                TestParameters(input: "5", output: "5.0")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for unit conversion from celsius_u to celsius_\($0.rawValue)")
                return
            }
        }
    }

    func testCelsiusUToFloatNumericTypes() {
        [NumericTypes.float, NumericTypes.double].forEach {
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0.0"),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.max)", output: "\($0.swiftType)(CUnsignedInt.max)"
                ),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.min)", output: "\($0.swiftType)(CUnsignedInt.min)"
                ),
                TestParameters(input: "5", output: "5.0")
            ]
            let result = generator.testParameters(from: .celsius, with: .u, to: $0)
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for celsius_u to \($0.rawValue) conversion")
                return
            }
        }
    }

    func testCelsiusUToCelsiusSignedTypes() {
        [NumericTypes.int, NumericTypes.int32, NumericTypes.int16, NumericTypes.int8].forEach {
            let result = generator.testParameters(from: .celsius, with: .u, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.max)",
                    output: "\($0.swiftType.rawValue)(\($0.swiftType.rawValue).max)"
                ),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.min)", output: "\($0.swiftType.rawValue)(CUnsignedInt.min)"
                ),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_u to \($0.rawValue)")
                return
            }
        }
        [NumericTypes.int64].forEach {
            let result = generator.testParameters(from: .celsius, with: .u, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.max)", output: "\($0.swiftType)(CUnsignedInt.max)"
                ),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.min)", output: "\($0.swiftType)(CUnsignedInt.min)"
                ),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_u to \($0.rawValue)")
                return
            }
        }
    }

    func testCelsiusUToUnsignedTypes() {
        [NumericTypes.uint, NumericTypes.uint32, NumericTypes.uint16, NumericTypes.uint8].forEach {
            let result = generator.testParameters(from: .celsius, with: .u, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.max)",
                    output: "\($0.swiftType.rawValue)(\($0.swiftType).max)"
                ),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.min)", output: "\($0.swiftType)(CUnsignedInt.min)"
                ),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_t to \($0.rawValue)")
                return
            }
        }
        [NumericTypes.uint64].forEach {
            let result = generator.testParameters(from: .celsius, with: .u, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0", output: "0"),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.max)", output: "\($0.swiftType)(CUnsignedInt.max)"
                ),
                TestParameters(
                    input: "celsius_u(CUnsignedInt.min)", output: "\($0.swiftType)(CUnsignedInt.min)"
                ),
                TestParameters(input: "5", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_t to \($0.rawValue)")
                return
            }
        }
    }

    func testCelsiusUToCelsiusT() {
        let result = generator.testParameters(from: .celsius, with: .u, to: .celsius, with: .t)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0", output: "0"),
            TestParameters(input: "celsius_u(CUnsignedInt.max)", output: "celsius_t(CInt.max)"),
            TestParameters(input: "celsius_u(CUnsignedInt.min)", output: "celsius_t(CUnsignedInt.min)"),
            TestParameters(input: "5", output: "5")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToCelsiusT() {
        let result = generator.testParameters(from: .celsius, with: .f, to: .celsius, with: .t)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "0"),
            TestParameters(input: "celsius_f(Float.greatestFiniteMagnitude)", output: "celsius_t(CInt.max)"),
            TestParameters(
                input: "celsius_f(-Float.greatestFiniteMagnitude)", output: "celsius_t(CInt.min)"
            ),
            TestParameters(input: "5.0", output: "5")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToCelsiusU() {
        let result = generator.testParameters(from: .celsius, with: .f, to: .celsius, with: .u)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "0"),
            TestParameters(
                input: "celsius_f(Float.greatestFiniteMagnitude)", output: "celsius_u(CUnsignedInt.max)"
            ),
            TestParameters(
                input: "celsius_f(-Float.greatestFiniteMagnitude)", output: "celsius_u(CUnsignedInt.min)"
            ),
            TestParameters(input: "5.0", output: "5")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToCelsiusD() {
        let result = generator.testParameters(from: .celsius, with: .f, to: .celsius, with: .d)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "0.0"),
            TestParameters(
                input: "celsius_f(Float.greatestFiniteMagnitude)",
                output: "celsius_d(Float.greatestFiniteMagnitude)"
            ),
            TestParameters(
                input: "celsius_f(-Float.greatestFiniteMagnitude)",
                output: "celsius_d(-Float.greatestFiniteMagnitude)"
            ),
            TestParameters(input: "5.0", output: "5.0")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusFToFloatNumericTypes() {
        [NumericTypes.float, NumericTypes.double].forEach {
            let expected: Set<TestParameters> = [
                TestParameters(input: "0.0", output: "0.0"),
                TestParameters(
                    input: "celsius_f(Float.greatestFiniteMagnitude)",
                    output: "\($0.swiftType)(Float.greatestFiniteMagnitude)"
                ),
                TestParameters(
                    input: "celsius_f(-Float.greatestFiniteMagnitude)",
                    output: "\($0.swiftType)(-Float.greatestFiniteMagnitude)"
                ),
                TestParameters(input: "5.0", output: "5.0")
            ]
            let result = generator.testParameters(from: .celsius, with: .f, to: $0)
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for celsius_f to \($0.rawValue) conversion")
                return
            }
        }
    }

    func testCelsiusFToCelsiusSignedTypes() {
        [NumericTypes.int, NumericTypes.int32, NumericTypes.int16, NumericTypes.int8, NumericTypes.int64]
        .forEach {
            let result = generator.testParameters(from: .celsius, with: .f, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0.0", output: "0"),
                TestParameters(
                    input: "celsius_f(Float.greatestFiniteMagnitude)",
                    output: "\($0.swiftType.rawValue)(\($0.swiftType.rawValue).max)"
                ),
                TestParameters(
                    input: "celsius_f(-Float.greatestFiniteMagnitude)",
                    output: "\($0.swiftType.rawValue)(\($0.swiftType.rawValue).min)"
                ),
                TestParameters(input: "5.0", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_f to \($0.rawValue)")
                return
            }
        }
    }

    func testCelsiusFToCelsiusUnSignedTypes() {
        [NumericTypes.uint, NumericTypes.uint32, NumericTypes.uint16, NumericTypes.uint8, NumericTypes.uint64]
        .forEach {
            let result = generator.testParameters(from: .celsius, with: .f, to: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "0.0", output: "0"),
                TestParameters(
                    input: "celsius_f(Float.greatestFiniteMagnitude)",
                    output: "\($0.swiftType.rawValue)(\($0.swiftType.rawValue).max)"
                ),
                TestParameters(
                    input: "celsius_f(-Float.greatestFiniteMagnitude)",
                    output: "\($0.swiftType.rawValue)(\($0.swiftType.rawValue).min)"
                ),
                TestParameters(input: "5.0", output: "5")
            ]
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failed to test conversion from celsius_f to \($0.rawValue)")
                return
            }
        }
    }

    // swiftlint:enable missing_docs

}
