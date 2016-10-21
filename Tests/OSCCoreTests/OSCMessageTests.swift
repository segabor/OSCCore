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


class OSCMessageTests : XCTestCase {
    func testNoArgMessage() {
        // msg packet := "hello".osc + "," + osc
        let msg = OSCMessage(address: "hello")

        let expected_pkt : [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00]

        doTestOSCMessage(msg, expected_pkt)
    }

    func testSingleArgMessage() {
        let msg = OSCMessage(address: "/oscillator/4/frequency", args: Float32(440.0))

        let expected_pkt : [Byte] = [
            0x2f, 0x6f, 0x73, 0x63,
            0x69, 0x6c, 0x6c, 0x61,
            0x74, 0x6f, 0x72, 0x2f,
            0x34, 0x2f, 0x66, 0x72,
            0x65, 0x71, 0x75, 0x65,
            0x6e, 0x63, 0x79, 0x00,
            0x2c, 0x66, 0x00, 0x00,
            0x43, 0xdc, 0x00, 0x00
        ]

        doTestOSCMessage(msg, expected_pkt)
    }

    func testMultipleArgsMessage() {
        let msg = OSCMessage(address: "/foo", args: 1000, -1, "hello", Float32(1.234), Float32(5.678))

        let expected_pkt : [Byte] = [
            0x2f,  0x66,  0x6f,  0x6f,
            0x00,  0x00,  0x00,  0x00,
            0x2c,  0x69,  0x69,  0x73,
            0x66,  0x66,  0x00,  0x00,
            0x00,  0x00,  0x03,  0xe8,
            0xff,  0xff,  0xff,  0xff,
            0x68,  0x65,  0x6c,  0x6c,
            0x6f,  0x00,  0x00,  0x00,
            0x3f,  0x9d,  0xf3,  0xb6,
            0x40,  0xb5,  0xb2,  0x2d
        ]

        doTestOSCMessage(msg, expected_pkt)
    }
    

    private func doTestOSCMessage(_ msg : OSCMessage, _ expected_pkt : [Byte]) {
        let converted_pkt = msg.oscValue
        
        // check conversion is correct
        XCTAssertEqual(expected_pkt, converted_pkt)
        
        // check the opposite - restore messages from byte stream
        guard
            let parsed:  OSCMessage = OSCMessage(data: converted_pkt),
            let parsed2: OSCMessage = OSCMessage(data: expected_pkt)
        else {
            XCTFail("Failed to restore message from packet")
            return
        }
        
        XCTAssertTrue(parsed.address == parsed2.address)
        XCTAssertTrue(parsed.args == parsed2.args)
    }
}

#if os(Linux)
extension OSCMessageTests {
    static var allTests: [(String, (OSCMessageTests) -> () throws -> Void)] {
        return [
            ("testNoArgMessage", testNoArgMessage),
            ("testSingleArgMessage", testSingleArgMessage),
            ("testMultipleArgsMessage", testMultipleArgsMessage)

        ]
    }
}
#endif
