//
//  util.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 22/04/16.
//  Copyright © 2016 Gábor Sebestyén. All rights reserved.
//




///
/// A simple hack to translate various Swift types to byte array
/// Source: http://stackoverflow.com/questions/26953591/how-to-convert-a-double-into-a-byte-array-in-swift
///


func binarytotype <T> (_ value: [Byte], _: T.Type) -> T
{
    /// input: array of bytes 
    /// -> get pointer to byte array (UnsafeBufferPointer<[Byte]>)
    /// -> access its base address
    /// -> rebind memory to target type T (UnsafeMutablePointer<T>)
    /// -> extract and return the value of target type
    return value.withUnsafeBufferPointer {
        $0.baseAddress!
          .withMemoryRebound(to: T.self, capacity: 1) {
            $0.pointee
        }
    }
}

func typetobinary <T> (_ value: T) -> [Byte]
{
    /// input type: value of type T
    /// -> get pointer to value of T
    /// -> rebind memory to the target type, which is a byte array
    /// -> create array with a buffer pointer initialized with the source pointer
    /// -> return the resulted array
    var mv : T = value
    let s : Int = MemoryLayout<T>.size
    return withUnsafePointer(to: &mv) {
        $0.withMemoryRebound(to: Byte.self, capacity: s) {
            Array(UnsafeBufferPointer(start: $0, count: s))
        }
    }
}



///
/// Round up number to the nearest multiple of 4
///
@inline(__always) func paddedSize(_ size: Int) -> Int {
    return (size + 3) & ~0x03
}



///
/// Mark integer types supporting bytes swapping with a designated interface
///

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


///
/// Workaround for lambda recursion
/// See: http://stackoverflow.com/questions/30523285/how-do-i-create-a-recursive-closure-in-swift 
///



func unimplemented<T>() -> T
{
      fatalError()
}



func recursive<T, U>(f: (@escaping (((T) -> U), T) -> U)) -> ((T) -> U)
{
    var g: ((T) -> U) = { _ in unimplemented() }

    g = { f(g, $0) }
              
    return g
}

