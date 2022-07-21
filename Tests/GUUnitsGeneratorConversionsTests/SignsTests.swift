@testable import GUUnitsGeneratorConversions
import XCTest

final class SignsTests: XCTestCase {

    func testT() {
        XCTAssertEqual(Signs.t.rawValue, "t")
    }

    func testU() {
        XCTAssertEqual(Signs.u.rawValue, "u")
    }

    func testf() {
        XCTAssertEqual(Signs.f.rawValue, "f")
    }

    func testD() {
        XCTAssertEqual(Signs.d.rawValue, "d")
    }

}