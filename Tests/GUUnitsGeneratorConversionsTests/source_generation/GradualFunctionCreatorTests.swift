@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for GradualFunctionCreator
final class GradualFunctionCreatorTests: XCTestCase {

    /// The creator to use in the test functions.
    var creator: GradualFunctionCreator<DistanceUnits> {
        GradualFunctionCreator<DistanceUnits>(unitDifference: unitDifference)
    }

    /// The helper to use in the test functions.
    let helper = FunctionHelpers<DistanceUnits>()

    /// The sign converter to use in the test functions.
    let converter = SignConverter()

    /// The difference between metres -> centimetres -> millimetres
    let unitDifference: [DistanceUnits: Int] = [.millimetres: 10, .centimetres: 100]

    /// Test init correctly initialises stored properties.
    func testInit() {
        XCTAssertEqual(creator.unitDifference, unitDifference)
    }

    /// Test conversion using pre-defined delegate method.
    func testCastFunc() {
        let result = creator.castFunc(forUnit: .centimetres, sign: .t, otherSign: .u)
        let gen = converter.convert(
            DistanceUnits.centimetres.rawValue, otherUnit: DistanceUnits.centimetres, from: .t, to: .u
        )
        let expected = "    return \(gen);"
        XCTAssertEqual(expected, result)
    }

    /// Test the conversion is correct for the same units.
    func testCreateFuncWithSameUnit() {
        let result = creator.createFunction(unit: .centimetres, to: .centimetres, sign: .t, otherSign: .u)
        let implementation = converter.convert(
            DistanceUnits.centimetres.rawValue, otherUnit: DistanceUnits.centimetres, from: .t, to: .u
        )
        let expected = "    return \(implementation);"
        XCTAssertEqual(result, expected)
    }

    /// Test that the conversion to a lower unit type is correct.
    func testDownCast() {
        let result = creator.createFunction(unit: .metres, to: .millimetres, sign: .t, otherSign: .u)
        let expected = """
            if (metres < 0) {
                return 0;
            }
            const millimetres_u otherMetres = ((millimetres_u) (metres));
            if (otherMetres > UINT_MAX / 1000) {
                return UINT_MAX;
            }
            return otherMetres * 1000;
        """
        XCTAssertEqual(result, expected)
    }

    /// Test that the conversion to a greater unit type is correct.
    func testUpCast() {
        let result = creator.createFunction(unit: .millimetres, to: .metres, sign: .u, otherSign: .t)
        // swiftlint:disable line_length
        let expected = """
            const millimetres_u conversion = millimetres / 1000;
            return ((metres_t) ((conversion) > ((unsigned int) (INT_MAX)) ? ((unsigned int) (INT_MAX)) : conversion));
        """
        // swiftlint:enable line_length
        XCTAssertEqual(result, expected)
    }

}
