//
//  extract.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

public func decodeOSCPacket(from bytes: [Byte]) -> OSCConvertible? {
    if let bndl = OSCBundle(data: bytes ) {
        return bndl
    } else if let msg = OSCMessage(data: bytes) {
        return msg
    }
    return nil
}
