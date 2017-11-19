//
//  HasByteSwapping.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

// FIXME: soon to be swapped with FixedWidthInteger protocol!
public protocol HasByteSwapping {
    /// byte order if necessary.
    var bigEndian: Self { get }

    /// Returns the current integer with the byte order swapped.
    var byteSwapped: Self { get }
}

// following Swift types has built-in byte swapping support
extension Int: HasByteSwapping {}
extension Int16: HasByteSwapping {}
extension Int32: HasByteSwapping {}
extension Int64: HasByteSwapping {}

extension HasByteSwapping {
    public init?(data: ArraySlice<Byte>) {
        let binary: [Byte] = [Byte](data)
        if binary.count != MemoryLayout<Self>.size {
            return nil
        }

        self = binarytotype(binary, Self.self).byteSwapped
    }
}
