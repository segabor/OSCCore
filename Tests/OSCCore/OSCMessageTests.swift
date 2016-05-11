@testable import OSCCore
import XCTest

class OSCMessageTests : XCTestCase {
    func testEmptyMessage() {
        let msg = OSCMessage(address: "hello")
        // packet := "hello".osc + "," + osc
        let packet : [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00]
        let value = msg.data

        XCTAssertNotNil(value)
        XCTAssertEqual(packet, value)
        
        guard
            let parsed = msg.parse(),    
            let parsed2 = OSCMessage(data: packet).parse()
        else {
            XCTFail("Failed to restore message from packet")
            return
        }

        XCTAssertEqual(parsed.address, parsed2.address)
        XCTAssertEqual(0, parsed.args.count)
        XCTAssertEqual(0, parsed2.args.count)
    }
}
