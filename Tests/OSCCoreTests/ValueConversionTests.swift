@testable import OSCCore
import XCTest

class ValueConversionTests: XCTestCase {

    func testCharacterConversion() {
        let testValue = Character(" ")
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x20]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.CHAR_TYPE_TAG, testValue: testValue)
    }

    func testEmptyStringConversion() {
        // test value
        let str = ""
        // expected packet
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.STRING_TYPE_TAG, testValue: str)
    }

    func testBasicStringConversion() {
        // test value
        let str = "hello"
        // expected packet
        let packet: [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.STRING_TYPE_TAG, testValue: str)
    }

    func testInt32Conversion() {
        let value: Int32 = 0x12345678
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.INT32_TYPE_TAG, testValue: value)
    }

    func testInt64Conversion() {
        let value: Int64 = 0x123456789abcdef0
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.INT64_TYPE_TAG, testValue: value)
    }

    func testIntConversion() {
        let value: Int = 0x12345678
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.INT32_TYPE_TAG, testValue: value)
    }

    func testFloat32Conversion() {
        let value: Float32 = Float32(1.234)
        let packet: [Byte] = [0x3f, 0x9d, 0xf3, 0xb6]
        
        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.FLOAT_TYPE_TAG, testValue: value)
    }

    func testImmediateTimeTagConversion() {
        let value = OSCTimeTag.immediate
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.TIME_TAG_TYPE_TAG, testValue: value)
    }

    func testTimeTagConversion() {
        let interval = Double(0x12345678)
        let value: OSCTimeTag = OSCTimeTag.secondsSince1900(interval)
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78, 0x00, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, expectedTypeTag: TypeTagValues.TIME_TAG_TYPE_TAG, testValue: value)
    }

    func testFixedPrecisionToDoubleConversion() {
        let testZeroValue: Double = 0

        var fixedPointValue = testZeroValue.fixPointValue

        XCTAssertEqual(fixedPointValue.integer, UInt32(0))
        XCTAssertEqual(fixedPointValue.fraction, UInt32(0))

        var dblValue = Double(integer: fixedPointValue.integer, fraction: fixedPointValue.fraction)

        XCTAssertEqual(testZeroValue, dblValue)

        let testNonZeroValue: Double = 123.0+(456.0/4_294_967_296)

        fixedPointValue = testNonZeroValue.fixPointValue

        XCTAssertEqual(fixedPointValue.integer, UInt32(123))
        XCTAssertEqual(fixedPointValue.fraction, UInt32(456))

        dblValue = Double(integer: fixedPointValue.integer, fraction: fixedPointValue.fraction)

        XCTAssertEqual(testNonZeroValue, dblValue)
    }

    private func assertValueConversion(expected: [Byte], expectedTypeTag: TypeTagValues, testValue: OSCType) {
        XCTAssertEqual(expectedTypeTag, testValue.oscType, "Type tag mismatch")
        if let value = testValue.oscValue {
            XCTAssertEqual(expected, value, "Incorrect OSC Packet")
            
            if TypeTagValues.STRING_TYPE_TAG == expectedTypeTag {
                XCTAssertEqual(value.count%4, 0, "Packet length misaligment, it must be multiple of 4")
            }
        } else {
            XCTFail("Failed to convert value with type tag \(expectedTypeTag) to OSC bytes")
        }
    }
}

#if os(Linux)
extension ValueConversionTests {
    static var allTests: [(String, (ValueConversionTests) -> () throws -> Void)] {
        return [
            ("testCharacterConversion", testCharacterConversion),
            ("testEmptyStringConversion", testEmptyStringConversion),
            ("testBasicStringConversion", testBasicStringConversion),
            ("testInt32Conversion", testInt32Conversion),
            ("testInt64Conversion", testInt64Conversion),
            ("testIntConversion", testIntConversion),
            ("testFloat32Conversion", testFloat32Conversion),
            ("testImmediateTimeTagConversion", testImmediateTimeTagConversion),
            ("testTimeTagConversion", testTimeTagConversion),
            ("testFixedPrecisionToDoubleConversion", testFixedPrecisionToDoubleConversion)
        ]
    }
}
#endif
