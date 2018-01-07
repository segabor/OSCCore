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
    var oscValue: [Byte]? { get }

    /// returns size of OSC packet in bytes
    var packetSize: Int { get }

    /// construct OSC value from byte array
    init?(data: ArraySlice<Byte>)
}

extension OSCConvertible {
    // construct type from byte array
    init?(data: [Byte]) {
        self.init(data: data[0..<data.count])
    }
}
