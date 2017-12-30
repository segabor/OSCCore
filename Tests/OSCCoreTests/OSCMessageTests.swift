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

    func testMessageHavingSymbolArgument() {
        let msg = OSCMessage(address: "/test", args: OSCSymbol(label: "symbol1"))

        let expectedPacket: [Byte] = [
            // "/test"
            0x2f, 0x74, 0x65, 0x73,
            0x74, 0x00, 0x00, 0x00,
            // ",S"
            0x2c, 0x53, 0x00, 0x00,
            // "symbol1"
            0x73, 0x79, 0x6d, 0x62,
            0x6f, 0x6c, 0x31, 0x00
        ]

        doTestOSCMessage(msg, expectedPacket)
    }

    func testMessageHavingDoubleArgument() {
        let msg = OSCMessage(address: "/test", args: 1234.5678)

        let expectedPacket: [Byte] = [
            // "/test"
            0x2f, 0x74, 0x65, 0x73,
            0x74, 0x00, 0x00, 0x00,
            // ",d"
            0x2c, 0x64, 0x00, 0x00,
            // double value
            0x40, 0x93, 0x4a, 0x45,
            0x6d, 0x5c, 0xfa, 0xad
        ]

        doTestOSCMessage(msg, expectedPacket)
    }

    func testMessageHavingInfinityArgument() {
        let msg = OSCMessage(address: "/test", args: Double.infinity)

        let expectedPacket: [Byte] = [
            // "/test"
            0x2f, 0x74, 0x65, 0x73,
            0x74, 0x00, 0x00, 0x00,
            // ",I"
            0x2c, 0x49, 0x00, 0x00
        ]

        doTestOSCMessage(msg, expectedPacket)
    }

    func testMessageHavingRGBAArgument() {
        let msg = OSCMessage(address: "/test", args: RGBA(red: 0x12, green: 0x34, blue: 0x56, alpha: 0x78))

        let expectedPacket: [Byte] = [
            // "/test"
            0x2f, 0x74, 0x65, 0x73,
            0x74, 0x00, 0x00, 0x00,
            // ",r"
            0x2c, 0x72, 0x00, 0x00,
            // value in bytes
            0x12, 0x34, 0x56, 0x78
        ]

        doTestOSCMessage(msg, expectedPacket)
    }

    func testMessageHavingMIDIArgument() {
        let msg = OSCMessage(address: "/test", args: MIDI(portId: 0x12, status: 0x34, data1: 0x56, data2: 0x78))

        let expectedPacket: [Byte] = [
            // "/test"
            0x2f, 0x74, 0x65, 0x73,
            0x74, 0x00, 0x00, 0x00,
            // ",m"
            0x2c, 0x6d, 0x00, 0x00,
            // value in bytes
            0x12, 0x34, 0x56, 0x78
        ]

        doTestOSCMessage(msg, expectedPacket)
    }

    private func doTestOSCMessage(_ msg: OSCMessage, _ expectedPacket: [Byte]) {
        XCTAssertNotNil(msg.oscValue)

        let convertedPacket = msg.oscValue!

        // check conversion is correct
        XCTAssertEqual(expectedPacket, convertedPacket)

        if let otherMsg = OSCMessage(data: convertedPacket) {
            XCTAssertEqual(msg.address, otherMsg.address, "Address field mismatch")
            XCTAssertEqual(msg.args.count, otherMsg.args.count, "Arguments size mismatch")

            for argPair in zip(msg.args, otherMsg.args) {
                if let msgVal = argPair.0, let msg2Val = argPair.1 {
                    XCTAssertEqual(msgVal.oscType, msg2Val.oscType)
                    // XCTAssertTrue(msgVal.isEqualTo(msg2Val))
                } else {
                    XCTAssertNil(argPair.0)
                    XCTAssertNil(argPair.1)
                }
            }
        } else {
            XCTFail("Failed to build message from bytes")
        }
    }
}

#if os(Linux)
extension OSCMessageTests {
    static var allTests: [(String, (OSCMessageTests) -> () throws -> Void)] {
        return [
            ("testNoArgMessage", testNoArgMessage),
            ("testSingleArgMessage", testSingleArgMessage),
            ("testMultipleArgsMessage", testMultipleArgsMessage),
            ("testMessageHavingSymbolArgument", testMessageHavingSymbolArgument),
            ("testMessageHavingDoubleArgument", testMessageHavingDoubleArgument),
            ("testMessageHavingInfinityArgument", testMessageHavingInfinityArgument),
            ("testMessageHavingRGBAArgument", testMessageHavingRGBAArgument),
            ("testMessageHavingMIDIArgument", testMessageHavingMIDIArgument)
        ]
    }
}
#endif
