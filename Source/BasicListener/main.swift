import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

import OSCCore
import NIO


func debugOSCPacket(_ packet: OSCConvertible) {
    switch packet {
    case let msg as OSCMessage:
        let argsString: String = msg.args.map{
            if let arg = $0 {
                return String(describing: arg)
            } else {
                return "nil"
            }
            }.joined(separator: ", ")
        print("[message] Address: \(msg.address); Arguments: [\(argsString)]")
    case let bundle as OSCBundle:
        print("[bundle] Timestamp: \(bundle.timetag); elements:")
        bundle.content.forEach {
            debugOSCPacket($0)
        }
    default:
        ()
    }
}

private final class OSCHandler: ChannelInboundHandler {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    
    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let addressedEnvelope = self.unwrapInboundIn(data)
        print("Recieved data from \(addressedEnvelope.remoteAddress)")

        if let rawBytes : [Byte] = addressedEnvelope.data.getBytes(at: 0, length: addressedEnvelope.data.readableBytes),
            let packet = decodeOSCPacket(from: rawBytes)
        {
            print("Received OSC packet ... ")
            debugOSCPacket(packet)
            // ctx.channel.write(NIOAny(packet), promise: nil)
        }
    }

    public func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }
    
    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        print("error :", error)
        
        ctx.close(promise: nil)
    }
}

let defaultPort: Int = 57110

let group = MultiThreadedEventLoopGroup(numThreads: 1 /*System.coreCount*/)

// Using DatagramBootstrap turns out to be the only significant change between TCP and UDP in this case
let bootstrap = DatagramBootstrap(group: group)
    .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .channelInitializer { channel in
        let packet2osc = OSCHandler()

        return channel.pipeline.add(handler: packet2osc)
}
defer {
    try! group.syncShutdownGracefully()
}

let arguments = CommandLine.arguments
let port = arguments.dropFirst().flatMap {Int($0)}.first ?? defaultPort

let channel = try! bootstrap.bind(host: "127.0.0.1", port: port).wait()

print("Channel accepting connections on \(channel.localAddress!)")

try channel.closeFuture.wait()
