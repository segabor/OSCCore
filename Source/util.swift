//
//  util.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 22/04/16.
//  Copyright © 2016 Gábor Sebestyén. All rights reserved.
//




/**
 * A simple hack to translate various Swift types to byte array
 * Source: http://stackoverflow.com/questions/26953591/how-to-convert-a-double-into-a-byte-array-in-swift
 */


func binarytotype <T> (_ value: [Byte], _: T.Type) -> T
{
    return value.withUnsafeBufferPointer { /* (UnsafeBufferPointer<Byte>) -> T in */
        $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
            $0.pointee
        }
    }
}

func typetobinary <T> (_ value: T) -> [Byte]
{
    var mv : T = value
    let s : Int = MemoryLayout<T>.size
    return withUnsafePointer(to: &mv) { /* (UnsafePointer<T>) -> Void in */
        $0.withMemoryRebound(to: Byte.self, capacity: s) { /* (UnsafeMutablePointer<Byte>) -> Void in */
            Array(UnsafeBufferPointer(start: $0, count: s))
        }
    }
}



/*
 * round up number to the nearest multiple of 4
 */
@inline(__always) func paddedSize(_ size: Int) -> Int {
    return (size + 3) & ~0x03
}



/*
 * Mark integer types supporting bytes swapping with a designated interface
 */

public protocol HasByteSwapping {
    /// byte order if necessary.
    var bigEndian: Self { get }
    
    /// Returns the current integer with the byte order swapped.
    var byteSwapped: Self { get }
}

// those types already support byte swapping
extension Int : HasByteSwapping {}
extension Int16 : HasByteSwapping {}
extension Int32 : HasByteSwapping {}
extension Int64 : HasByteSwapping {}
