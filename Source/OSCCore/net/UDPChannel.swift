//
//  UDPChannel.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//
import Socket

public class UDPChannel: OSCChannel {

    let socket: Socket

    public init(socket: Socket) {
        self.socket = socket

        try! socket.setReadTimeout(value: 100)
    }

    // returns OSC packet received over UDP socket
    public func receive() -> OSCConvertible? {
        var receiveBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
        defer {
            receiveBuffer.deallocate(capacity: 1024)
        }

        guard let readResult = try? socket.readDatagram(into: receiveBuffer, bufSize: 1024) else { return nil }

        return extract(contentOf: receiveBuffer, length: readResult.bytesRead)
    }

    public func send(packet: OSCConvertible) {
        // ABSTRACT FUNCTION - IMPLEMENT IN SUBCLASSES
    }

    func send(packet: OSCConvertible, to address: Socket.Address) {
        _ = packet.oscValue.withUnsafeBufferPointer {
            try! socket.write(from: $0.baseAddress!, bufSize: $0.count, to: address)
        }
    }
}
