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

    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        let addressedEnvelope = self.unwrapInboundIn(data)

        if let rawBytes: [Byte] = addressedEnvelope.data.getBytes(at: 0, length: addressedEnvelope.data.readableBytes),
            let packet = decodeOSCPacket(from: rawBytes) {
            ctx.fireChannelRead(self.wrapInboundOut(packet))
        }
    }

    public func channelReadComplete(ctx: ChannelHandlerContext) {
        ctx.flush()
    }

    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        ctx.close(promise: nil)
    }
}
