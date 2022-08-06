import Foundation
@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for TemperatureTestGenerator Celsius to Numeric conversions.
final class TemperatureTestGeneratorNumTests: XCTestCase,
    TestParameterTestable,
    TestGeneratorNumericTestable {

    /// The generator to test.
    let generator = TemperatureTestGenerator()

    // swiftlint:disable missing_docs

    func testUnitFloatTypes() {
        TemperatureUnits.allCases.forEach { unit in
            [Signs.t, Signs.u, Signs.f, Signs.d].forEach { sign in
                unitTest(unit: unit, sign: sign)
            }
        }
    }

    func testUnitToNumericTypes() {
        TemperatureUnits.allCases.forEach { unit in
            [Signs.t, Signs.u, Signs.f, Signs.d].forEach { sign in
                self.numericTest(unit: unit, sign: sign)
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

    func testCelsiusDToCelsiusT() {
        let result = generator.testParameters(from: .celsius, with: .d, to: .celsius, with: .t)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "0"),
            TestParameters(input: "celsius_d(Double.greatestFiniteMagnitude)", output: "celsius_t(CInt.max)"),
            TestParameters(
                input: "celsius_d(-Double.greatestFiniteMagnitude)", output: "celsius_t(CInt.min)"
            ),
            TestParameters(input: "5.0", output: "5")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusDToCelsiusU() {
        let result = generator.testParameters(from: .celsius, with: .d, to: .celsius, with: .u)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "0"),
            TestParameters(
                input: "celsius_d(Double.greatestFiniteMagnitude)", output: "celsius_u(CUnsignedInt.max)"
            ),
            TestParameters(
                input: "celsius_d(-Double.greatestFiniteMagnitude)", output: "celsius_u(CUnsignedInt.min)"
            ),
            TestParameters(input: "5.0", output: "5")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    func testCelsiusDToCelsiusF() {
        let result = generator.testParameters(from: .celsius, with: .d, to: .celsius, with: .f)
        let expected: Set<TestParameters> = [
            TestParameters(input: "0.0", output: "0.0"),
            TestParameters(
                input: "celsius_d(Double.greatestFiniteMagnitude)",
                output: "celsius_f(Float.greatestFiniteMagnitude)"
            ),
            TestParameters(
                input: "celsius_d(-Double.greatestFiniteMagnitude)",
                output: "celsius_f(-Float.greatestFiniteMagnitude)"
            ),
            TestParameters(input: "5.0", output: "5.0")
        ]
        XCTAssertTrue(testSet(result: result, expected: expected))
    }

    // swiftlint:enable missing_docs

}
