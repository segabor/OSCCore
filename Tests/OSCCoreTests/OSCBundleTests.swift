@testable import OSCCore
import XCTest



class OSCBundleTests : XCTestCase {
    func testNoArgMessage() {
        let ttag = OSCTimeTag(0x123456789abcdef0)
        let bundle = OSCBundle(timetag: ttag, content: [])

        let expected_pkt : [Byte] = [
          0x23, 0x62, 0x75, 0x6e, 0x64, 0x6c, 0x65, 0x00,
          0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0  
        ]

        XCTAssertEqual(expected_pkt, bundle.oscValue)
    }
}

#if os(Linux)
extension OSCBundleTests {
    static var allTests: [(String, (OSCBundleTests) -> () throws -> Void)] {
        return [
            ("testNoArgMessage", testNoArgMessage)
        ]
    }
}
#endif
