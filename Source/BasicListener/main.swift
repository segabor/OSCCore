import Foundation
#if os(Linux)
import Glibc
#else
import Darwin
#endif

import OSCCore
import NIO

private final class OSCHandler: ChannelInboundHandler {
  typealias InboundIn = AddressedEnvelope<ByteBuffer>

  public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
    let addressedEnvelope = self.unwrapInboundIn(data)
    print("Recieved data from \(addressedEnvelope.remoteAddress)")

    if let rawBytes : [Byte] = addressedEnvelope.data.getBytes(at: 0, length: addressedEnvelope.data.capacity),
        let packet = decodeOSCPacket(from: rawBytes)
    {
        ctx.write(NIOAny(packet), promise: nil)
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

private final class OSCDebugHandler: ChannelInboundHandler {
    typealias InboundIn = OSCConvertible
    
    public func channelRead(ctx: ChannelHandlerContext, data: OSCConvertible) {
        if let msg = data as? OSCMessage {
            print("   \(msg.address): \(msg.args)")
        } else if let bndl = data as? OSCBundle {
            print("\(bndl.timetag.toDate())")
            for oscItem in bndl.content {
                if let msg = oscItem as? OSCMessage {
                    print("    \(msg.address): \(msg.args)")
                }
            }
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
        let oscSink = OSCDebugHandler()
        
        channel.pipeline.add(handler: packet2osc)
        return channel.pipeline.add(handler: oscSink, after: packet2osc)
}
defer {
    try! group.syncShutdownGracefully()
}

let arguments = CommandLine.arguments
let port = arguments.dropFirst().flatMap {Int($0)}.first ?? defaultPort

let channel = try! bootstrap.bind(host: "127.0.0.1", port: port).wait()

print("Channel accepting connections on \(channel.localAddress!)")

try channel.closeFuture.wait()
