@testable import OSCCore
import XCTest

class ValueConversionTests: XCTestCase {

    func testBooleanConversion() {
        assertValueConversion(expected: nil, typeTag: TypeTagValues.TRUE_TYPE_TAG, testValue: true)
        assertValueConversion(expected: nil, typeTag: TypeTagValues.FALSE_TYPE_TAG, testValue: false)
    }

    func testCharacterConversion() {
        let testValue = Character(" ")
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x20]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.CHAR_TYPE_TAG, testValue: testValue)
    }

    func testEmptyStringConversion() {
        // test value
        let str = ""
        // expected packet
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.STRING_TYPE_TAG, testValue: str)
    }

    func testBasicStringConversion() {
        // test value
        let str = "hello"
        // expected packet
        let packet: [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.STRING_TYPE_TAG, testValue: str)
    }

    func testSymbolConversion() {
        // test value
        let value = OSCSymbol(label: "hello")
        // expected packet
        let packet: [Byte] = [0x68, 0x65, 0x6c, 0x6c, 0x6f, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.SYMBOL_TYPE_TAG, testValue: value)
    }

    func testInt32Conversion() {
        let value: Int32 = 0x12345678
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.INT32_TYPE_TAG, testValue: value)
    }

    func testInt64Conversion() {
        let value: Int64 = 0x123456789abcdef0
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78, 0x9a, 0xbc, 0xde, 0xf0]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.INT64_TYPE_TAG, testValue: value)
    }

    func testIntConversion() {
        let value: Int = 0x12345678
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.INT32_TYPE_TAG, testValue: value)
    }

    func testFloat32Conversion() {
        let value: Float32 = Float32(1.234)
        let packet: [Byte] = [0x3f, 0x9d, 0xf3, 0xb6]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.FLOAT_TYPE_TAG, testValue: value)
    }

    func testDoubleConversion() {
        let value: Double = 1234.5678
        let packet: [Byte] = [0x40, 0x93, 0x4a, 0x45, 0x6d, 0x5c, 0xfa, 0xad]

        assertValueConversion(expected: packet, typeTag: .DOUBLE_TYPE_TAG, testValue: value)

        assertValueConversion(expected: nil, typeTag: .INFINITUM_TYPE_TAG, testValue: Double.infinity)
    }

    func testImmediateTimeTagConversion() {
        let value = OSCTimeTag.immediate
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.TIME_TAG_TYPE_TAG, testValue: value)
    }

    func testTimeTagConversion() {
        let interval = Double(0x12345678)
        let value: OSCTimeTag = OSCTimeTag.secondsSince1900(interval)
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78, 0x00, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.TIME_TAG_TYPE_TAG, testValue: value)
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

    func testRGBAConversion() {
        let value = RGBA(red: 0x12, green: 0x34, blue: 0x56, alpha: 0x78)
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.RGBA_COLOR_TYPE_TAG, testValue: value)
    }

    func testMIDIConversion() {
        let value = MIDI(portId: 0x12, status: 0x34, data1: 0x56, data2: 0x78)
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.MIDI_MESSAGE_TYPE_TAG, testValue: value)
    }

    func testEmptyBlobConversion() {
        let bytes: [Byte] = []

        let value: Data = bytes.withUnsafeBytes {
            return Data(bytes: $0.baseAddress!, count: bytes.count)
        }
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x00]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.BLOB_TYPE_TAG, testValue: value)
    }

    func testBlobConversion() {
        let bytes: [Byte] = [0xde, 0xad, 0xba, 0xbe]

        let value: Data = bytes.withUnsafeBytes {
            return Data(bytes: $0.baseAddress!, count: bytes.count)
        }
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x04, 0xde, 0xad, 0xba, 0xbe]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.BLOB_TYPE_TAG, testValue: value)
    }

    func testPaddedBlobConversion() {
        let bytes: [Byte] = [0xde, 0xad, 0xba, 0xbe, 0xca, 0xfe, 0xba]

        let value: Data = bytes.withUnsafeBytes {
            return Data(bytes: $0.baseAddress!, count: bytes.count)
        }
        let packet: [Byte] = [0x00, 0x00, 0x00, 0x07, 0xde, 0xad, 0xba, 0xbe, 0xca, 0xfe, 0xba, 0x00]

        assertValueConversion(expected: packet, typeTag: TypeTagValues.BLOB_TYPE_TAG, testValue: value)
    }

    func testArrayConversion() {
        let value0: [OSCMessageArgument?] = [OSCMessageArgument?]()
        let packet0: [Byte] = [Byte]()

        assertValueConversion(expected: packet0, typeTag: TypeTagValues.ARRAY_BEGIN_TYPE_TAG, testValue: value0)

        let valueNil: [OSCMessageArgument?] = [nil]
        let packetNil: [Byte] = [Byte]()

        assertValueConversion(expected: packetNil, typeTag: .ARRAY_BEGIN_TYPE_TAG, testValue: valueNil)

        let value: [OSCMessageArgument?] = [Int32(0x12345678)]
        let packet: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet, typeTag: .ARRAY_BEGIN_TYPE_TAG, testValue: value)

        let value2: [OSCMessageArgument?] = [Int32(0x12345678), Int32(0x12345678)]
        let packet2: [Byte] = [0x12, 0x34, 0x56, 0x78, 0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet2, typeTag: TypeTagValues.ARRAY_BEGIN_TYPE_TAG, testValue: value2)

        let value3: [OSCMessageArgument?] = [nil, Int32(0x12345678)]
        let packet3: [Byte] = [0x12, 0x34, 0x56, 0x78]

        assertValueConversion(expected: packet3, typeTag: TypeTagValues.ARRAY_BEGIN_TYPE_TAG, testValue: value3)
    }

    private func assertValueConversion(expected bytes: [Byte]?, typeTag: TypeTagValues, testValue: OSCMessageArgument) {
        XCTAssertEqual(typeTag, testValue.oscType, "Type tag mismatch")

        if let bytes = testValue.oscValue {
            XCTAssertEqual(bytes.count, testValue.packetSize, "OSC Packet size mismatch")
            XCTAssertEqual(bytes, bytes, "Incorrect OSC Packet")

            if TypeTagValues.STRING_TYPE_TAG == typeTag {
                XCTAssertEqual(bytes.count%4, 0, "Packet length misaligment, it must be multiple of 4")
            }
        } else {
            XCTAssertNil(bytes, "Test OSC value should not return serialized bytes")
        }
    }
}

#if os(Linux)
extension ValueConversionTests {
    static var allTests: [(String, (ValueConversionTests) -> () throws -> Void)] {
        return [
            ("testBooleanConversion", testBooleanConversion),
            ("testCharacterConversion", testCharacterConversion),
            ("testEmptyStringConversion", testEmptyStringConversion),
            ("testBasicStringConversion", testBasicStringConversion),
            ("testSymbolConversion", testSymbolConversion),
            ("testInt32Conversion", testInt32Conversion),
            ("testInt64Conversion", testInt64Conversion),
            ("testIntConversion", testIntConversion),
            ("testFloat32Conversion", testFloat32Conversion),
            ("testDoubleConversion", testDoubleConversion),
            ("testImmediateTimeTagConversion", testImmediateTimeTagConversion),
            ("testTimeTagConversion", testTimeTagConversion),
            ("testFixedPrecisionToDoubleConversion", testFixedPrecisionToDoubleConversion),
            ("testMIDIConversion", testMIDIConversion),
            ("testRGBAConversion", testRGBAConversion),
            ("testEmptyBlobConversion", testEmptyBlobConversion),
            ("testBlobConversion", testBlobConversion),
            ("testPaddedBlobConversion", testPaddedBlobConversion),
            ("testArrayConversion", testArrayConversion)
        ]
    }
}
#endif
