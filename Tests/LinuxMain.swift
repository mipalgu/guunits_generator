import XCTest

import guunits_generatorTests

var tests = [XCTestCaseEntry]()
tests += guunits_generatorTests.allTests()
XCTMain(tests)
