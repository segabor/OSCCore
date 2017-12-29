//
//  Double+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 29..
//

#if os(Linux)
    import Glibc
#endif
import CoreFoundation

extension Double: OSCType {
    public var oscValue: [Byte]? {
        guard self.isFinite else {
            return nil
        }

        #if os(OSX) || os(iOS)
            let z = CFConvertDoubleHostToSwapped(self).v
        #elseif os(Linux)
            let z = htobe64(self.bitPattern)
        #endif
        return [Byte](typetobinary(z))
    }

    public var oscType: TypeTagValues {
        if self.isInfinite {
            return .INFINITUM_TYPE_TAG
        } else {
            return .DOUBLE_TYPE_TAG
        }
    }

    // custom init
    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Double>.size {
            return nil
        }
        #if os(OSX) || os(iOS)
            self = CFConvertDoubleSwappedToHost(binarytotype(binary, CFSwappedFloat64.self))
        #elseif os(Linux)
            self = Float(bitPattern: be64toh(binarytotype(binary, UInt64.self)))
        #endif
    }
}
