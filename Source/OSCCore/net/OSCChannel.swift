//
//  OSCChannel.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

public protocol OSCChannel {

    func send(packet: OSCConvertible)
    func receive() -> OSCConvertible?

}
