@testable import GUUnitsGeneratorConversions
import XCTest

/// Test class for DelegatingFunctionCreator
final class DelegatingFunctionCreatorTests: XCTestCase {

    /// The creator used in the test functions.
    let creator = DelegatingFunctionCreator<DistanceUnits>()

    /// The helper used in the test functions.
    let helper = FunctionHelpers<DistanceUnits>()

    /// Test createFunction.
    func testCreateFunction() {
        let gen = helper.functionName(forUnit: .centimetres, to: .metres, sign: .u, otherSign: .f)
        let result = creator.createFunction(unit: .centimetres, to: .metres, sign: .u, otherSign: .f)
        let expected = "    return ::\(gen)(\(DistanceUnits.centimetres));"
        XCTAssertEqual(result, expected)
    }

}
