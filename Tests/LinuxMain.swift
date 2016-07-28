import XCTest

@testable import OSCCoreTestSuite 

XCTMain([
    testCase(OSCMessageTests.allTests),
    testCase(ValueConversionTests.allTests)
])
