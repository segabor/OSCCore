import OSCCore
import NIO

// ---- //

enum SuperColliderExampleError: Error {
    case decodeOSCPacketFailed
}

/// simple function that dumps contents of OSCMessage / OSCBundle
func debugOSCPacket(_ packet: OSCConvertible) {
    switch packet {
    case let msg as OSCMessage:
        let argsString: String = msg.args.map {
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

        debugOSCPacket(oscValue)
    }
}

extension Channel {
    public func writeAndFlush(_ packet: OSCConvertible, target remoteAddr: SocketAddress) throws {
        guard let bytes = packet.oscValue else {
            throw SuperColliderExampleError.decodeOSCPacketFailed
        }

        var buffer = self.allocator.buffer(capacity: bytes.count)
        buffer.writeBytes(bytes)

        // create envelope
        let envelope = AddressedEnvelope(remoteAddress: remoteAddr, data: buffer)

        return self.writeAndFlush(envelope, promise: nil)
    }
}

// MAIN CODE STARTS HERE //

let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
let bootstrap = DatagramBootstrap(group: group)
    .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
    .channelInitializer { channel in
        channel.pipeline.addHandlers([OSCPacketReader(), OSCDebugHandler()])
}
defer {
    try! group.syncShutdownGracefully()
}

let arguments = CommandLine.arguments

let channel = try bootstrap.bind(host: "127.0.0.1", port: 57150).wait()
let remoteAddr = try SocketAddress(ipAddress: "127.0.0.1", port: 57110)

/// assemble a synth

let synthID = Int32(4)

let bndl = OSCBundle(timetag: OSCTimeTag.immediate, content: [
    // "/s_new", name, node ID, pos, group ID
    OSCMessage(address: "/s_new", args: ["sine", synthID, Int32(1), Int32(1)]),
    // "/n_set", "amp", sine amplitude
    OSCMessage(address: "/n_set", args: [synthID, "amp", Float32(0.5)]),
    // "/n_set", "freq", sine frequency
    OSCMessage(address: "/n_set", args: [synthID, "freq", Float32(440.0)])
])

try channel.writeAndFlush(bndl, target: remoteAddr)

// get and print out frequency number from SuperCollider
let getFrqMessage = OSCMessage(address: "/s_get", args: [synthID, "freq"])
try channel.writeAndFlush(getFrqMessage, target: remoteAddr)

// let synth beeping for two secs
sleep(2)

// free synth node
let freeNodeMessage = OSCMessage(address: "/n_free", args: [synthID])
try channel.writeAndFlush(freeNodeMessage, target: remoteAddr)

try channel.closeFuture.wait()
