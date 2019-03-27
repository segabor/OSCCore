//
//  Data+OSCMessageArgument.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 30..
//

import Foundation

extension Data: OSCMessageArgument {

    public init?(data: ArraySlice<Byte>) {
        guard let size = UInt32(data: data[data.startIndex..<data.startIndex+4]) else {
            return nil
        }

        let rawPointer: UnsafeRawPointer? = data.suffix(from: data.startIndex+4).withUnsafeBytes {
            return $0.baseAddress
        }

        if let rawPointer = rawPointer {
            self.init(bytes: rawPointer, count: Int(size))
        } else {
            return nil
        }
    }

    public var oscType: TypeTagValues {
        return .BLOB_TYPE_TAG
    }

    public var packetSize: Int {
        return MemoryLayout<Int32>.size + align(size: self.count)
    }

    public var oscValue: [Byte]? {
        let dataSize = self.count
        var payload = [Byte]()

        payload += self.count.oscValue!
        payload += self.withUnsafeBytes { (pointer: UnsafeRawBufferPointer) -> [Byte] in
            return [Byte](pointer[0..<dataSize])
        }

        // append zeroes to the end
        let alignedSize = align(size: payload.count)
        let padding = alignedSize - payload.count
        if padding > 0 {
            payload += [Byte](repeating: 0, count: padding)
        }
        return payload
    }
}
