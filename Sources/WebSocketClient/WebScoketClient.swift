import NIO
import Combine
import Foundation
import NIOWebSocket
import NIOHTTP1

public final class WebSocketClient {

  private var channel: Channel
  private var subject: PassthroughSubject<Data, Error>

  fileprivate init(channel: Channel, subject: PassthroughSubject<Data, Error>) {
    self.channel = channel
    self.subject = subject
  }

  public var eventLoop: EventLoop {
    channel.eventLoop
  }

  public var closeFuture: EventLoopFuture<Void> {
    channel.closeFuture
  }

  public func write(data: Data) -> EventLoopFuture<Void> {
    print("write: \(String(data: data, encoding: .utf8) ?? data.description)")
    return channel.writeAndFlush(data)
  }

  public func subscribe() -> AnyPublisher<Data, Error> {
    subject.eraseToAnyPublisher()
  }

  public static func connect(url: String, group: EventLoopGroup) -> EventLoopFuture<WebSocketClient> {
    guard let url = URL(string: url) else {
      return group.next().makeFailedFuture(URLError(.badURL))
    }
    guard url.scheme == "ws" else {
      return group.next().makeFailedFuture(URLError(.badURL))
    }
    let host = url.host ?? "localhost"
    let port = url.port ?? 80

    print("connecting \(url)")

    let promise: EventLoopPromise<WebSocketClient> = group.next().makePromise()
    return ClientBootstrap(group: group)
        // Enable SO_REUSEADDR.
        .channelOption(ChannelOptions.socketOption(.so_reuseaddr), value: 1)
        .channelInitializer { channel in
          let httpHandler = HTTPInitialRequestHandler(url: "\(url.path)?\(url.query ?? "")#\(url.fragment ?? "")")
          let topHandler = TopHandler()
          let websocketUpgrader = NIOWebSocketClientUpgrader(requestKey: "ff=",
              upgradePipelineHandler: { (channel, response) in
                channel.pipeline.addHandler(WebSocketBinaryDataHandler())
                                .map {
                                  topHandler.process(channel: channel).whenComplete { client in promise.completeWith(client) }
                                }
              })

          let config: NIOHTTPClientUpgradeConfiguration = (
              upgraders: [websocketUpgrader],
              completionHandler: { res in
                channel.pipeline.removeHandler(httpHandler, promise: nil)
              })

          return channel.pipeline
              .addHTTPClientHandlers(withClientUpgrade: config)
              .flatMap {
                channel.pipeline.addHandler(httpHandler)
              }
        }
        .connect(host: host, port: port)
        .flatMap { channel in
          promise.futureResult
        }
  }
}

private final class TopHandler: ChannelInboundHandler {
  typealias InboundIn = Data
  typealias InboundOut = Never

  private var processed = false
  private weak var client: WebSocketClient?
  private let subject = PassthroughSubject<Data, Error>()


  init() {
  }

  func process(channel: Channel) -> EventLoopFuture<WebSocketClient> {
    if processed {
      fatalError("Process once.")
    }
    return channel.pipeline.addHandler(self).map {
      WebSocketClient(channel: channel, subject: self.subject)
    }
  }

  func channelRead(context: ChannelHandlerContext, data: NIOAny) {
    let data = self.unwrapInboundIn(data)
    self.subject.send(data)
  }

  func channelInactive(context: ChannelHandlerContext) {
    subject.send(completion: .finished)
  }

  func errorCaught(context: ChannelHandlerContext, error: Error) {

  }
}
