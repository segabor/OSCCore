//
//  OSCPacketReader.swift
//  OSCCore
//
//  Created by Sebestyén Gábor on 2018. 06. 06..
//

import NIO

public final class OSCPacketReader: ChannelInboundHandler {
    public typealias InboundIn = AddressedEnvelope<ByteBuffer>
    public typealias InboundOut = OSCConvertible

    public init() {}

    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let addressedEnvelope = self.unwrapInboundIn(data)

        if let rawBytes: [Byte] = addressedEnvelope.data.getBytes(at: 0, length: addressedEnvelope.data.readableBytes),
            let packet = decodeOSCPacket(from: rawBytes) {
            context.fireChannelRead(self.wrapInboundOut(packet))
        }
    }

    public func channelReadComplete(context: ChannelHandlerContext) {
        context.flush()
    }

    public func errorCaught(context: ChannelHandlerContext, error: Error) {
        context.close(promise: nil)
    }
}
