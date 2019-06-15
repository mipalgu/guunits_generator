import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(guunits_generatorTests.allTests),
    ]
}
#endif
