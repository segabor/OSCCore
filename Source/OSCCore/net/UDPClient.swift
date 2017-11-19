//
//  UDPClient.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

import Socket

public class UDPClient: UDPChannel {

    let address: Socket.Address

    public init(host: String, port: Int32) {
        
        let socket = try! Socket.create(family: .inet, type: .datagram, proto: .udp)
        
        self.address = Socket.createAddress(for: host, on: port)!
        
        super.init(socket: socket)
    }

    public override func send(packet: OSCConvertible) {
        send(packet: packet, to: address)
    }
}
