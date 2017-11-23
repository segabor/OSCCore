//
//  Int+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

/// Create integers from bytes
extension FixedWidthInteger {
    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Self>.size {
            return nil
        }

        self = binarytotype(binary, Self.self).byteSwapped
    }
}

extension Int64: OSCType {
    public var oscValue: [Byte] {
        let z = self.bigEndian
        return [Byte](typetobinary(z))
    }

    public var oscType: TypeTagValues { return .INT64_TYPE_TAG }
}

extension Int32: OSCType {
    public var oscValue: [Byte] {
        let z = self.bigEndian
        return [Byte](typetobinary(z))
    }

    public var oscType: TypeTagValues { return .INT32_TYPE_TAG }
}

// default Integers is converted to 32-bin integer for the sake of convenience
extension Int: OSCType {
    public var oscValue: [Byte] {
        return Int32(self).oscValue
    }

    public var oscType: TypeTagValues { return .INT32_TYPE_TAG }

    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Int32>.size {
            return nil
        }

        self = Int( binarytotype(binary, Int32.self).byteSwapped )
    }
}
