@testable import OSCCore
import XCTest

class OSCMessageTests: XCTestCase {
    func testNoArgMessage() {
        let msg = OSCMessage(address: "hello")

        let expectedPacket: [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00]

        doTestOSCMessage(msg, expectedPacket)
    }

    func testMessageHavingNilArgument() {
        let msg = OSCMessage(address: "/nil", args: nil)

        let expectedPacket: [Byte] = [0x2f, 0x6e, 0x69, 0x6c, 0x00, 0x00, 0x00, 0x00, 0x2c, 0x4e, 0x00, 0x00]

        doTestOSCMessage(msg, expectedPacket)
    }
    
    func testSingleArgMessage() {
        let msg = OSCMessage(address: "/oscillator/4/frequency", args: Float32(440.0))

        let expectedPacket: [Byte] = [
            0x2f, 0x6f, 0x73, 0x63,
            0x69, 0x6c, 0x6c, 0x61,
            0x74, 0x6f, 0x72, 0x2f,
            0x34, 0x2f, 0x66, 0x72,
            0x65, 0x71, 0x75, 0x65,
            0x6e, 0x63, 0x79, 0x00,
            0x2c, 0x66, 0x00, 0x00,
            0x43, 0xdc, 0x00, 0x00
        ]

        doTestOSCMessage(msg, expectedPacket)
    }

    func testMultipleArgsMessage() {
        let msg = OSCMessage(address: "/foo", args: Int32(1000), Int32(-1), "hello", Float32(1.234), Float32(5.678))

        let expectedPacket: [Byte] = [
            0x2f, 0x66, 0x6f, 0x6f,
            0x00, 0x00, 0x00, 0x00,
            0x2c, 0x69, 0x69, 0x73,
            0x66, 0x66, 0x00, 0x00,
            0x00, 0x00, 0x03, 0xe8,
            0xff, 0xff, 0xff, 0xff,
            0x68, 0x65, 0x6c, 0x6c,
            0x6f, 0x00, 0x00, 0x00,
            0x3f, 0x9d, 0xf3, 0xb6,
            0x40, 0xb5, 0xb2, 0x2d
        ]

        doTestOSCMessage(msg, expectedPacket)
    }

    private func doTestOSCMessage(_ msg: OSCMessage, _ expectedPacket: [Byte]) {
        XCTAssertNotNil(msg.oscValue)

        let convertedPacket = msg.oscValue!

        // check conversion is correct
        XCTAssertEqual(expectedPacket, convertedPacket)
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
