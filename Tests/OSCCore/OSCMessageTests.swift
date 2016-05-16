@testable import OSCCore
import XCTest

typealias Message = (address: String, args: [OSCValue])

class OSCMessageTests : XCTestCase {
    func testEmptyMessage() {
        let msg = OSCMessage(address: "hello")
        // packet := "hello".osc + "," + osc
        let packet : [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00]
        let value = msg.data

        XCTAssertNotNil(value)
        XCTAssertEqual(packet, value)
        
        guard
            let parsed : Message = msg.parse(),
            let parsed2 : Message = OSCMessage(data: packet).parse()
        else {
            XCTFail("Failed to restore message from packet")
            return
        }

        assertOSCMessagesEqual(parsed, parsed2)
    }

    // helper method to compare OSC messages
    private func assertOSCMessagesEqual(_ msg: Message, _ otherMsg: Message) {
        XCTAssertEqual(msg.address, otherMsg.address)
        assertOSCValuesEqual(msg.args, otherMsg.args)
    }
    
    // helper method to compare two OSCValue arrays
    private func assertOSCValuesEqual(_ obj: [OSCValue], _ other: [OSCValue]) {
        XCTAssertEqual(obj.count, other.count)
        
        for ix in (0..<obj.count) {
            let obj1 = obj[ix]
            let obj2 = other[ix]
            
            XCTAssertEqual(obj1.oscType, obj2.oscType)
            XCTAssertEqual(obj1.oscValue, obj2.oscValue)
        }
    }
}
