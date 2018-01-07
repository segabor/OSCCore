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
    public var alignedSize: Int {
        // include \0 terminator character
        let cStringSize = self.utf8.count+1
        return align(size: cStringSize)
    }
}

extension Data {
    public var alignedSize: Int {
        let length = self.count
        return (length + 3) & ~0x03
    }
}
