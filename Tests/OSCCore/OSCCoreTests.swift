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
}

