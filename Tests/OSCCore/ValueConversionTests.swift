@testable import OSCCore
import XCTest

class ValueConversionTests : XCTestCase {

    func testEmptyStringConversion() {
        // test value
        let str = ""
        // expected packet
        let packet : [Byte] = [0x00, 0x00, 0x00, 0x00]

        let value = str.oscValue

        XCTAssertNotNil(value, "Null value")
        XCTAssertEqual(value.count%4, 0, "Lenght must be divided by 4")
        XCTAssertEqual(value, packet, "Incorrect OSC Packet")
        XCTAssertEqual(str, String(data: packet), "Failed to convert OSC packet back to String value")
    }


    func testBasicStringConversion() {
        // test value
        let str = "hello"
        // expected packet
        let packet : [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00]   

        let value = str.oscValue

        XCTAssertNotNil(value, "Null value")
        XCTAssertEqual(value.count%4, 0, "Lenght must be divided by 4")
        XCTAssertEqual(value, packet, "Incorrect OSC Packet")
        XCTAssertEqual(str, String(data: packet), "Failed to convert OSC packet back to String value")
    }


    func testInt32Conversion() {
        let value : Int32 = 0x12345678
        let pkt = value.oscValue
        XCTAssertEqual(pkt, [0x12, 0x34, 0x56, 0x78])
        XCTAssertEqual(value, Int32(data: pkt), "Values mismatch") 
    }


    func testInt64Conversion() {
        let value : Int64 = 0x123456789abcdef0
        let pkt = value.oscValue
        XCTAssertEqual(pkt, [0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0])
        XCTAssertEqual(value, Int64(data: pkt), "Values mismatch")
    }


    func testIntConversion() {
        let value : Int = 0x12345678
        let pkt = value.oscValue
        XCTAssertEqual(pkt, [0x12, 0x34, 0x56, 0x78])
        XCTAssertEqual(value, Int(data: pkt), "Values mismatch")
    }


    func testFloat32Conversion() {
        let value : Float32 = Float32(1.234)
        let pkt = value.oscValue
        XCTAssertEqual(pkt, [0x3f, 0x9d, 0xf3, 0xb6])
        XCTAssertEqual(value, Float32(data: pkt), "Values mismatch")
    }
}

