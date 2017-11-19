//
//  OSCType.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

///
/// Types adopting this protocol
/// can be converted to OSC value
///
public protocol OSCType: OSCConvertible {
    var oscType: TypeTagValues { get }
}

/// Helper function to compare two OSC value arrays
public func == (lhs: [OSCConvertible], rhs: [OSCConvertible]) -> Bool {
    if lhs.count == rhs.count {
        for pair in zip(lhs, rhs) {
            if pair.0.isEqualTo(pair.1) == false {
                return false
            }
        }
        return true
    }

    return false
}
