@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for ImageUnits.
final class ImageUnitsTests: XCTestCase {

    /// Test Pixels.
    func testPixels() {
        XCTAssertEqual(ImageUnits.pixels.rawValue, "pixels")
        XCTAssertEqual(ImageUnits.pixels.abbreviation, "px")
        XCTAssertEqual(ImageUnits.pixels.description, "pixels")
    }

    /// Test static variables.
    func testStaticVars() {
        XCTAssertEqual(ImageUnits.category, "Pixels")
        XCTAssertEqual(ImageUnits.highestPrecision, .pixels)
        XCTAssertTrue(ImageUnits.sameZeroPoint)
    }

}
