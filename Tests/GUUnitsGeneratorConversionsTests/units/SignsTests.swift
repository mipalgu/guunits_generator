@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for Signs.
final class SignsTests: XCTestCase {

    /// Test t
    func testT() {
        XCTAssertEqual(Signs.t.rawValue, "t")
        XCTAssertEqual(Signs.t.numericType, .int)
        XCTAssertEqual(Signs.t.type, NumericTypes.int.rawValue)
        XCTAssertFalse(Signs.t.isFloatingPoint)
    }

    /// Test U
    func testU() {
        XCTAssertEqual(Signs.u.rawValue, "u")
        XCTAssertEqual(Signs.u.numericType, .uint)
        XCTAssertEqual(Signs.u.type, NumericTypes.uint.rawValue)
        XCTAssertFalse(Signs.u.isFloatingPoint)
    }

    /// Test F
    func testf() {
        XCTAssertEqual(Signs.f.rawValue, "f")
        XCTAssertEqual(Signs.f.numericType, .float)
        XCTAssertEqual(Signs.f.type, NumericTypes.float.rawValue)
        XCTAssertTrue(Signs.f.isFloatingPoint)
    }

    /// Test D
    func testD() {
        XCTAssertEqual(Signs.d.rawValue, "d")
        XCTAssertEqual(Signs.d.numericType, .double)
        XCTAssertEqual(Signs.d.type, NumericTypes.double.rawValue)
        XCTAssertTrue(Signs.d.isFloatingPoint)
    }

}
