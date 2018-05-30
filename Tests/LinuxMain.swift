import XCTest

@testable import OSCCoreTests

XCTMain([
    testCase(OSCMessageTests.allTests),
    testCase(ValueConversionTests.allTests),
    testCase(AddressMatcherTests.allTests),
    testCase(DispatcherTests.allTests),
    testCase(OSCBundleTests.allTests)
])
