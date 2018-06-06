import Foundation
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

private final class OSCDebugHandler: ChannelInboundHandler {
    typealias InboundIn = OSCConvertible
    
    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let oscValue = unwrapInboundIn(data)
        
        print("Captured OSC packet ... ")
        debugOSCPacket(oscValue)
    }
}

// MAIN CODE STARTS HERE //

let threadGroup = MultiThreadedEventLoopGroup(numThreads: 1 /*System.coreCount*/)
defer {
    try! threadGroup.syncShutdownGracefully()
}

let bootstrap = DatagramBootstrap(group: threadGroup)
    .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .channelInitializer { channel in
        return channel.pipeline
            .add(handler: OSCPacketReader())
            .then({ _ in channel.pipeline.add(handler: OSCDebugHandler())})
    }

let arguments = CommandLine.arguments
let port = arguments
            .dropFirst()
            .compactMap {Int($0)}
            .first ?? 57110

let channel = try! bootstrap.bind(host: "127.0.0.1", port: port).wait()

print("Channel accepting connections on \(channel.localAddress!)")

try channel.closeFuture.wait()
