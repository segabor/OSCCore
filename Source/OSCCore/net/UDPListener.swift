//
//  UDPListener.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2017. 11. 19..
//

import Socket

public final class UDPListener: UDPChannel {

    let listenerPort: Int

    public init(listenerPort: Int) {
        self.listenerPort = listenerPort

        let socket = try! Socket.create(family: .inet, type: .datagram, proto: .udp) //swiftlint:disable:this force_try

        super.init(socket: socket)
    }

    public func listen(responder: (OSCConvertible) -> OSCConvertible?) {
        var receiveBuffer = UnsafeMutablePointer<CChar>.allocate(capacity: 1024)
        defer {
            receiveBuffer.deallocate()
        }

        do {
            repeat {
                let result = try socket.listen(forMessage: receiveBuffer, bufSize: 1024, on: listenerPort)

                guard result.bytesRead > 0,
                    let oscValue = extract(contentOf: receiveBuffer, length: result.bytesRead)
                else {
                    continue
                }

                let response = responder(oscValue)

                // send response
                if let response = response {
                    send(packet: response, to: result.address!)
                }

            } while true
        } catch {
            // just let the listen loop exit
        }
    }
}
