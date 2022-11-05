@testable import GUUnitsGeneratorConversions
import XCTest

/// Helper protocol for testing units.
protocol UnitsTestable {

    /// Assert that the value matches the test data.
    /// - Parameters:
    ///   - value: The uut.
    ///   - rawValue: The expected rawValue.
    ///   - abbreviation: The expected abbreviation.
    ///   - description: The expected description.
    func assert<Unit>(
        value: Unit,
        rawValue: String,
        abbreviation: String,
        description: String
    ) where Unit: UnitProtocol, Unit: RawRepresentable, Unit.RawValue == String

}

/// Default implementation of UnitsTestable
extension UnitsTestable {

    /// Assert that the value matches the test data.
    /// - Parameters:
    ///   - value: The uut.
    ///   - rawValue: The expected rawValue.
    ///   - abbreviation: The expected abbreviation.
    ///   - description: The expected description.
    func assert<Unit>(
        value: Unit,
        rawValue: String,
        abbreviation: String,
        description: String
    ) where Unit: UnitProtocol, Unit: RawRepresentable, Unit.RawValue == String {
        XCTAssertEqual(value.rawValue, rawValue)
        XCTAssertEqual(value.abbreviation, abbreviation)
        XCTAssertEqual(value.description, description)
        XCTAssertEqual(value, Unit(description: value.description))
    }

}
