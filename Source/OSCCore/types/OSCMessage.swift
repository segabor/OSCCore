//
//  OSCMessage.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

public struct OSCMessage: Equatable {
    public let address: String
    public let args: [OSCType]

    public init(address: String, args: [OSCType]) {
        self.address = address
        self.args = args
    }

    public init(address: String, args: OSCType...) {
        self.init(address: address, args: args)
    }

    /// Equatable
    public static func == (lhs: OSCMessage, rhs: OSCMessage) -> Bool {
        return lhs.address == rhs.address && lhs.args == rhs.args
    }
}
