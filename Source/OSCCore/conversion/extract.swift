//
//  extract.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

// FIXME: cover this with tests!
public func extract(contentOf buffer: UnsafeBufferPointer<Byte>, length: Int) -> OSCConvertible? {
    
    let rawBytes : [Byte] = [Byte](UnsafeBufferPointer<Byte>.init(start: buffer.baseAddress, count: length))
    
    let decodedPacket: OSCConvertible? = { rawData in
        if let bndl = OSCBundle(data: rawData ) {
            return bndl
        } else if let msg = OSCMessage(data: rawData) {
            return msg
        }
        return nil
    }(rawBytes)

    return decodedPacket
}

public func decodeOSCPacket(from bytes: [Byte]) -> OSCConvertible? {
    if let bndl = OSCBundle(data: bytes ) {
        return bndl
    } else if let msg = OSCMessage(data: bytes) {
        return msg
    }
    return nil
}
