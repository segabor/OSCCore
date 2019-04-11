//
//  Float+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

#if os(Linux)
	import Glibc
#endif
import CoreFoundation

extension Float32: OSCMessageArgument {
    public var oscValue: [Byte]? {
        #if os(OSX) || os(iOS)
            let rawValue = CFConvertFloat32HostToSwapped(self).v
        #elseif os(Linux)
            let rawValue = htonl(self.bitPattern)
        #endif
        return [Byte](typetobinary(rawValue))
    }

    public var oscType: TypeTagValues { return .FLOAT_TYPE_TAG }

    public var packetSize: Int {
        return MemoryLayout<Float32>.size
    }

    // custom init
    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Float32>.size {
            return nil
        }

        self = CFConvertFloatSwappedToHost(binary.withUnsafeBytes {
            $0.load(fromByteOffset: 0, as: CFSwappedFloat32.self)
        })
    }
}
