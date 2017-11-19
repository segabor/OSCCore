//
//  extract.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

public func extract(contentOf buffer: UnsafeMutablePointer<CChar>, length: Int) -> OSCConvertible? {
    let rawBytes: [Byte] = buffer.withMemoryRebound(to: Byte.self, capacity: length) { (bytesPointer: UnsafeMutablePointer<Byte>) -> [Byte] in
        return [Byte](UnsafeBufferPointer<Byte>.init(start: bytesPointer, count: length))
    }

    let decodedPacket: OSCConvertible? = { rawData in
        if let msg = OSCMessage(data: rawData ) {
            return msg
        } else if let bndl = OSCBundle(data: rawData) {
            return bndl
        }
        return nil
    }(rawBytes)

    return decodedPacket
}
