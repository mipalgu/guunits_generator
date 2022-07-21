@testable import guunits_generator
import XCTest

final class SignsTests: XCTestCase {

    func testT() {
        XCTAssertEqual(Signs.t, "t")
    }

    func testU() {
        XCTAssertEqual(Signs.u, "u")
    }

    func testf() {
        XCTAssertEqual(Signs.f, "f")
    }

    func testD() {
        XCTAssertEqual(Signs.d, "d")
    }

}