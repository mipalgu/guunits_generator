@testable import GUUnitsGeneratorConversions
import XCTest

final class SignsTests: XCTestCase {

    func testT() {
        XCTAssertEqual(Signs.t.rawValue, "t")
        XCTAssertEqual(Signs.t.numericType, .int)
        XCTAssertEqual(Signs.t.type, NumericTypes.int.rawValue)
    }

    func testU() {
        XCTAssertEqual(Signs.u.rawValue, "u")
        XCTAssertEqual(Signs.u.numericType, .uint)
        XCTAssertEqual(Signs.u.type, NumericTypes.uint.rawValue)
    }

    func testf() {
        XCTAssertEqual(Signs.f.rawValue, "f")
        XCTAssertEqual(Signs.f.numericType, .float)
        XCTAssertEqual(Signs.f.type, NumericTypes.float.rawValue)
    }

    func testD() {
        XCTAssertEqual(Signs.d.rawValue, "d")
        XCTAssertEqual(Signs.d.numericType, .double)
        XCTAssertEqual(Signs.d.type, NumericTypes.double.rawValue)
    }

}