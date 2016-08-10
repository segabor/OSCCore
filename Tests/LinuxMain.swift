import XCTest

@testable import OSCCoreTests

XCTMain([
    testCase(OSCMessageTests.allTests),
    testCase(ValueConversionTests.allTests)
])
