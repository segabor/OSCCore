//
//  OSCBundle+OSCConvertible.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

extension OSCBundle: OSCConvertible {

    public static let prefix = "#bundle"

    public var oscValue: [Byte]? {
        var result = [Byte]()

        // write out head first
        result += OSCBundle.prefix.oscValue!
        result += timetag.oscValue!

        /// asemble osc elements: size then content
        content.forEach { msg in
            if let msgValue = msg.oscValue {
                result += Int32(msgValue.count).oscValue!
                result += msgValue
            }
        }
        return result
    }

    public var packetSize: Int {
        return content
            .map { $0.packetSize }
            .reduce(OSCBundle.prefix.alignedSize, { $0 + $1.packetSize })
    }

    public init?(data: ArraySlice<Byte>) {
        // Check the header
        // - packet length must be at least 16 bytes ('#bundle' + timetag)
        guard
            data.count >= 16,
            data[data.startIndex] == 0x23,
            let ts = OSCTimeTag(data: data[data.startIndex+8..<data.startIndex+16])
        else {
            return nil
        }

        var msgs = [OSCConvertible]()

        // Read up content
        var it = OSCBundleElementIterator(data[data.startIndex+16..<data.endIndex] )
        while let chunk = it.next() {
            if let bnd = OSCBundle(data: chunk) {
                msgs.append(bnd)
            } else if let msg = OSCMessage(data: chunk ) {
                msgs.append(msg)
            }
        }

        // init object state
        self.init(timetag: ts, content: msgs)
    }
}

/// Iterator that yields bundle elements as slices
private struct OSCBundleElementIterator: IteratorProtocol {
    let bytes: ArraySlice<Byte>
    var index: Int

    init(_ bytes: ArraySlice<Byte>) { self.bytes = bytes; index = bytes.startIndex }

    mutating func next() -> ArraySlice<Byte>? {
        guard
            index < bytes.endIndex,
            let len = Int(data: bytes[index..<(index+4)])
        else {
            return nil
        }

        let elemBytes = bytes[index+4..<index+4+len]
        index += 4+len
        return elemBytes

    }
}
