//
//  alignment.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 12. 31..
//

import Foundation

@inline(__always) func align(size: Int) -> Int {
    return (size + 3) & ~0x03
}

extension String {
    // return size of UTF-8 string including terminator rounded up to 4
    public var alignedSize: Int {
        return align(size: self.utf8.count+1)
    }
}

extension Data {
    // return size payload rounded up to 4
    public var alignedSize: Int {
        return align(size: self.count)
    }
}
