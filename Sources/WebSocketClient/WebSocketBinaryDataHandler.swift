import NIO
import Foundation
import NIOWebSocket

internal final class WebSocketBinaryDataHandler: ChannelInboundHandler, ChannelOutboundHandler {
  typealias InboundIn = WebSocketFrame
  typealias InboundOut = Data
  typealias OutboundOut = WebSocketFrame
  typealias OutboundIn = Data

  func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
    let data = self.unwrapOutboundIn(data)
    let buffer = data.withUnsafeBytes { bytes in context.channel.allocator.buffer(bytes: bytes) }
    let frame = WebSocketFrame(fin: true, opcode: .text, maskKey: [51, 44, 52, 3], data: buffer)
    context.write(self.wrapOutboundOut(frame), promise: promise)
  }

  func flush(context: ChannelHandlerContext) {
    context.flush()
  }

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let frame = self.unwrapInboundIn(data)

    switch frame.opcode {
      case .text, .binary:
        var data = frame.unmaskedData
        guard let textData = data.readString(length: data.readableBytes) else {
          context.fireErrorCaught(IOError(errnoCode: -1, reason: "Bad data"))
          return
        }
        context.fireChannelRead(self.wrapInboundOut(textData.data(using: .utf8)!))
      case .connectionClose:
        self.receivedClose(context: context, frame: frame)
      case .continuation, .ping, .pong:
        // We ignore these frames.
        break
      default:
        // Unknown frames are errors.
        self.closeOnError(context: context)
    }
  }

  private func receivedClose(context: ChannelHandlerContext, frame: WebSocketFrame) {
    // Handle a received close frame. We're just going to close.
    print("Received Close instruction from server")
    context.close(promise: nil)
  }

  private func closeOnError(context: ChannelHandlerContext) {
    // We have hit an error, we want to close. We do that by sending a close frame and then
    // shutting down the write side of the connection. The server will respond with a close of its own.
    var data = context.channel.allocator.buffer(capacity: 2)
    data.write(webSocketErrorCode: .protocolError)
    let frame = WebSocketFrame(fin: true, opcode: .connectionClose, data: data)
    context.write(self.wrapOutboundOut(frame)).whenComplete { (_: Result<Void, Error>) in
      context.close(mode: .output, promise: nil)
    }
  }
}