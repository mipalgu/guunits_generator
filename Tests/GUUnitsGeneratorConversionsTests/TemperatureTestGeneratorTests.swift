@testable import GUUnitsGeneratorConversions
import Foundation
import XCTest

final class TemperatureTestGeneratorTests: XCTestCase {

    let generator = TemperatureTestGenerator()

    func testCelsiusTToCelsiusFloatUnitTypes() {
        [Signs.f, Signs.d].forEach {
            let result = generator.testParameters(from: .celsius, with: .t, to: .celsius, with: $0)
            let expected: Set<TestParameters> = [
                TestParameters(input: "celsius_t(CInt.max)", output: "celsius_\($0.rawValue)(CInt.max)"),
                TestParameters(input: "celsius_t(CInt.min)", output: "celsius_\($0.rawValue)(CInt.min)"),
                TestParameters(input: "0", output: "0.0"),
                TestParameters(input: "5", output: "5.0")
            ]
            print("Start test")
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
            print("Start test.")
            let result = generator.testParameters(from: .celsius, with: .t, to: $0)
            guard testSet(result: result, expected: expected) else {
                XCTFail("Failing test for celsius_t to \($0.rawValue) conversion")
                return
            }
        }
    }

    private func testSet(result: [TestParameters], expected: Set<TestParameters>) -> Bool {
        var success = true
        result.forEach {
            guard expected.contains($0) else {
                XCTFail("Additional test \($0) found!")
                success = false
                return
            }
        }
        let resultSet = Set(result)
        let expectedArray = Array(expected)
        expectedArray.forEach {
            guard resultSet.contains($0) else {
                XCTFail("Missing test \($0)!")
                success = false
                return
            }
        }
        XCTAssertEqual(result.count, expected.count)
        XCTAssertEqual(result.count, resultSet.count)
        guard result.count == expected.count && result.count == resultSet.count else {
            return false
        }
        return success
    }

}
