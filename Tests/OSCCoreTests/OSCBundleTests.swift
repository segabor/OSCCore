@testable import OSCCore
import XCTest

class OSCBundleTests: XCTestCase {
    func testNoArgMessage() {
        let ttag = OSCTimeTag.immediate
        let bundle = OSCBundle(timetag: ttag, content: [])

        let expectedPacket: [Byte] = [
            0x23, 0x62, 0x75, 0x6e,
            0x64, 0x6c, 0x65, 0x00,
            0x00, 0x00, 0x00, 0x00,
            0x00, 0x00, 0x00, 0x01
        ]

        XCTAssertNotNil(bundle.oscValue)
        XCTAssertEqual(expectedPacket, bundle.oscValue!)
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
