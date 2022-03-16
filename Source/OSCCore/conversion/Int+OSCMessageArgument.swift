//
//  Int+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

/// Create integers from bytes
extension FixedWidthInteger {
    public var packetSize: Int { MemoryLayout<Self>.size }

    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Self>.size {
            return nil
        }

        self = binary.withUnsafeBytes {
            $0.load(fromByteOffset: 0, as: Self.self)
        }.byteSwapped
    }
}

extension Int64: OSCMessageArgument {
    public var oscValue: [Byte]? {
        return withUnsafeBytes(of: self.bigEndian) {[Byte]($0)}
    }

    public var oscType: TypeTagValues { return .INT64_TYPE_TAG }
}

// for timestamps
extension UInt64: OSCConvertible {
    public var oscValue: [Byte]? {
        return withUnsafeBytes(of: self.bigEndian) {[Byte]($0)}
    }
}

extension Int32: OSCMessageArgument {
    public var oscValue: [Byte]? {
        return withUnsafeBytes(of: self.bigEndian) {[Byte]($0)}
    }

    public var oscType: TypeTagValues { .INT32_TYPE_TAG }
}

extension UInt32: OSCConvertible {
    public var oscValue: [Byte]? {
        return withUnsafeBytes(of: self.bigEndian) {[Byte]($0)}
    }
}

// default Integers is converted to 32-bin integer for the sake of convenience
extension Int: OSCMessageArgument {
    public var oscValue: [Byte]? {
        return Int32(self).oscValue
    }

    public var oscType: TypeTagValues { .INT32_TYPE_TAG }

    public var packetSize: Int { MemoryLayout<Int32>.size }

    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Int32>.size {
            return nil
        }

        self = Int(binary.withUnsafeBytes {
            $0.load(fromByteOffset: 0, as: Int32.self)
        }.byteSwapped)
    }
}
