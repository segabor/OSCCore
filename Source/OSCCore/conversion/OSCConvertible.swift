//
//  OSCConvertible.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

///
/// Objects implementing this protocol
/// can be converted to OSC packets
/// and back
///
/// Containers like OSC messages and
/// bundles implement this protocol
///
public protocol OSCConvertible {
    /// return as byte sequence
    var oscValue: [Byte] { get }

    /// construct OSC value from byte array
    init?(data: ArraySlice<Byte>)

    /// Custom function for Equatable
    func isEqualTo(_ other: OSCConvertible) -> Bool
}

extension OSCConvertible {
    // construct type from byte array
    init?(data: [Byte]) {
        self.init(data: data[0..<data.count])
    }
}

//
// Workaround for Equatable adoption
//
extension OSCConvertible where Self : Equatable {
    /// otherObject could also be 'Any'
    public func isEqualTo(_ other: OSCConvertible) -> Bool {
        if let otherAsSelf = other as? Self {
            return otherAsSelf == self
        }
        return false
    }
}
