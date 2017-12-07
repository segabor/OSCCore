//
//  OSCMessage.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 18..
//

import Foundation

public struct OSCMessage {
    public let address: String
    public let args: [OSCType]

    public init(address: String, args: [OSCType]) {
        self.address = address
        self.args = args
    }

    public init(address: String, args: OSCType...) {
        self.init(address: address, args: args)
    }
}
