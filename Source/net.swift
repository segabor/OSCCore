//
//  net.swift
//  OSCCore
//
//  Created by Gábor Sebestyén on 19/06/16.
//
//

import UDP

extension OSCMessage {

    
    public func send(ip: IP) throws {
        let udpSocket = try? UDPSocket(ip: ip)
        try udpSocket?.send(Data(data), ip: ip)
    }
}
