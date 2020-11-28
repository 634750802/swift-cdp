import NIO
import NIOHTTP1

internal final class HTTPInitialRequestHandler: ChannelInboundHandler, RemovableChannelHandler {
  public typealias InboundIn = HTTPClientResponsePart
  public typealias OutboundOut = HTTPClientRequestPart

  private var url: String

  init(url: String) {
    self.url = url
  }

  public func channelActive(context: ChannelHandlerContext) {
    print("Client connected to \(context.remoteAddress!)")

    // We are connected. It's time to send the message to the server to initialize the upgrade dance.
    var headers = HTTPHeaders()
    headers.add(name: "Content-Type", value: "text/plain; charset=utf-8")
    headers.add(name: "Content-Length", value: "\(0)")

    let requestHead = HTTPRequestHead(version: HTTPVersion(major: 1, minor: 1),
        method: .GET,
        uri: url,
        headers: headers)

    context.write(self.wrapOutboundOut(.head(requestHead)), promise: nil)

    let body = HTTPClientRequestPart.body(.byteBuffer(ByteBuffer()))
    context.write(self.wrapOutboundOut(body), promise: nil)
    context.writeAndFlush(self.wrapOutboundOut(.end(nil)), promise: nil)
    print("Client send initial headers to server")
  }

  public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    print(data)
    let clientResponse = self.unwrapInboundIn(data)

    print("Upgrade failed")

    switch clientResponse {
      case .head(let responseHead):
        print("Received status: \(responseHead.status)")
      case .body(let byteBuffer):
        let string = String(buffer: byteBuffer)
        print("Received: '\(string)' back from the server.")
      case .end:
        print("Closing channel.")
        context.close(promise: nil)
    }
  }

  public func handlerRemoved(context: ChannelHandlerContext) {
    print("HTTP handler removed.")
  }

  public func errorCaught(context: ChannelHandlerContext, error: Error) {
    print("error: ", error)

    // As we are not really interested getting notified on success or failure
    // we just pass nil as promise to reduce allocations.
    context.close(promise: nil)
  }
}
