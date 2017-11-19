//
//  Float+OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

import CoreFoundation

extension Float32: OSCType {
    public var oscValue: [Byte] {
        #if os(OSX) || os(iOS)
            let z = CFConvertFloat32HostToSwapped(self).v
        #elseif os(Linux)
            let z = htonl(self.bitPattern)
        #endif
        return [Byte](typetobinary(z))
    }

    public var oscType: TypeTagValues { return .FLOAT_TYPE_TAG }
    
    // custom init
    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Float32>.size {
            return nil
        }
        #if os(OSX) || os(iOS)
            self = CFConvertFloatSwappedToHost(binarytotype(binary, CFSwappedFloat32.self))
        #elseif os(Linux)
            self = Float(bitPattern: ntohl(binarytotype(binary, UInt32.self)))
        #endif
    }
}
