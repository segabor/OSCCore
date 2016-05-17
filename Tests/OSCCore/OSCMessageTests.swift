@testable import OSCCore
import XCTest



// compare two OSC value arrays
func ==(lhs: [OSCValue], rhs: [OSCValue]) -> Bool {
    if lhs.count == rhs.count {
        
        for pair in zip(lhs,rhs) {
            if pair.0.isEqualTo(pair.1) == false {
                return false
            }
        }
        return true
    }

    return false
}

// compare two OSC messages parsed from byte stream
func ==(lhs: ParsedMessage, rhs: ParsedMessage) -> Bool {
    return lhs.address == rhs.address && lhs.args == rhs.args
}


class OSCMessageTests : XCTestCase {
    func testNoArgMessage() {
        // msg packet := "hello".osc + "," + osc
        let msg = OSCMessage(address: "hello")

        let expected_pkt : [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00]
        let converted_pkt = msg.data

        // check conversion is correct
        XCTAssertEqual(expected_pkt, converted_pkt)

        // check the opposite - restore messages from byte stream
        guard
            let parsed : ParsedMessage = msg.parse(),
            let parsed2 : ParsedMessage = OSCMessage(data: expected_pkt).parse()
        else {
            XCTFail("Failed to restore message from packet")
            return
        }

        XCTAssertTrue(parsed == parsed2)
    }
}
