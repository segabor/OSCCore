//
//  OSCMessage+OSCChannel.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

public extension OSCMessage {
    public func send(over channel: OSCChannel) {
        channel.send(packet: self)
    }
}
