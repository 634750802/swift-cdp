import Foundation
import NIO
import WebSocketClient
import Combine
import Logging


public class ChromeClient {
  private let client: WebSocketClient
  private var cancellable: AnyCancellable = AnyCancellable {}
  private var jsonEncoder = JSONEncoder()
  private var jsonDecoder = JSONDecoder()
  private var idSeq: Int = 0
  private var promises: [Int: EventLoopPromise<Data>] = [:]
  private var eventHandlers: [String: [ObjectIdentifier: (subject: PassthroughSubject<Data, Error>, cancellable: AnyCancellable)]] = [:]
  private var schedulerQueue = DispatchQueue(label: "WebSocketClient.Scheduler")
  private let logger = Logger(label: "ChromeClient")

  public init(client: WebSocketClient) {
    self.client = client
    client.closeFuture.whenComplete {_ in
      self.cancellable.cancel()
    }
    cancellable = self.client
        .subscribe()
        .sink(
            receiveCompletion: { [self] completion in
              for subs in self.eventHandlers.values {
                for sub in subs.values {
                  sub.cancellable.cancel()
                }
              }
              self.eventHandlers = [:]
            },
            receiveValue: { [self] data in
              do {
                logger.debug("read: \(String(data: data, encoding: .utf8) ?? data.description)")
                let commonPart = try self.jsonDecoder.decode(ChromeDevtoolsWebsocketResponseCommonPart.self, from: data)
                if let id = commonPart.id {
                  self.triggerResponse(.method(id: id, body: data))
                } else if let method = commonPart.method {
                  self.triggerResponse(.event(method: method, body: data))
                } else {
                  self.triggerResponse(.unknown(body: data))
                }
              } catch {
                logger.error("\(error)")
              }
            })
  }

  deinit {
    cancellable.cancel()
  }

  public var eventLoop: EventLoop {
    client.eventLoop
  }

  public var closeFuture: EventLoopFuture<Void> {
    client.closeFuture
  }

  public func async<M: ModelMethod>(_ method: M) -> EventLoopFuture<M.TransformedResult> {
    schedulerQueue.sync {
      idSeq += 1
      let id = idSeq
      let promise: EventLoopPromise<Data> = client.eventLoop.makePromise()
      promises[id] = promise
      do {
        let data = try jsonEncoder.encode(ChromeDevtoolsWebsocketRequest(requestId: id, method: method))
        logger.debug("write: \(String(data: data, encoding: .utf8) ?? data.description)")
        return self.client.write(data: data).flatMap {
          promise.futureResult.flatMapThrowing { data in
            let result = try self.jsonDecoder.decode(ChromeDevtoolsWebsocketMethodResponse<M>.self, from: data).result
            return M.transform(client: self, result: result)
          }
        }
      } catch {
        promise.fail(error)
        promises[id] = nil
        return client.eventLoop.makeFailedFuture(error)
      }
    }
  }

  public func sync<M: ModelMethod>(_ method: M) throws -> M.TransformedResult {
    try async(method).wait()
  }

  @discardableResult
  public func on<M: ModelEvent>(_ handler: @escaping (M) -> Void) -> some Cancellable {
    let esi = schedulerQueue.sync { () -> EventSubscriberId in
      var subject: PassthroughSubject<Data, Error>!
      subject = PassthroughSubject()
      if self.eventHandlers[M.name] == nil {
        self.eventHandlers[M.name] = [:]
      }
      let oi = ObjectIdentifier(subject)
      let cancellable = subject.sink(receiveCompletion: { _ in }, receiveValue: { [self] input in
        do {
          let value = try self.jsonDecoder.decode(ChromeDevtoolsWebsocketEventResponse<M>.self, from: input)
          handler(value.params)
        } catch {
          logger.error("\(error)")
        }
      })
      self.eventHandlers[M.name]![oi] = (subject, cancellable)
      return EventSubscriberId(subject: M.name, objectId: oi)
    }
    return CancelHandler(client: self, esi: esi)
  }

  internal func off(_ esi: EventSubscriberId) {
    schedulerQueue.sync {
      self.eventHandlers[esi.subject]?[esi.objectId]?.cancellable.cancel()
      self.eventHandlers[esi.subject]?[esi.objectId] = nil
    }
  }

  fileprivate func triggerResponse(_ resp: ChromeDevtoolsWebsocketResponse) {
    schedulerQueue.sync {
      switch resp {
        case .method(let id, let body):
          promises[id]?.succeed(body)
          promises[id] = nil
        case .event(let method, let body):
          if let tuples = eventHandlers[method]?.values {
            for tuple in tuples {
              tuple.subject.send(body)
            }
          }
        case .unknown(let body):
          logger.warning("Unknown remote message \(String(data: body, encoding: .utf8) ?? "\(body)")")
      }
    }
  }
}

private struct ChromeDevtoolsWebsocketRequest<Method: ModelMethod>: Encodable {
  let id: Int
  let method: String
  let params: Method

  init(requestId: Int, method: Method) {
    self.id = requestId
    self.method = Method.method
    self.params = method
  }
}

private struct ChromeDevtoolsWebsocketMethodResponse<Method: ModelMethod>: Decodable {
  var id: Int
  var result: Method.Result
}

private struct ChromeDevtoolsWebsocketEventResponse<Event: ModelEvent>: Decodable {
  var params: Event
}


private struct ChromeDevtoolsWebsocketResponseCommonPart: Decodable {
  var method: String?
  var id: Int?
}

private enum ChromeDevtoolsWebsocketResponse {
  case method(id: Int, body: Data)
  case event(method: String, body: Data)
  case unknown(body: Data)
}

public struct EventSubscriberId {
  fileprivate var subject: String
  fileprivate var objectId: ObjectIdentifier
}

public struct CancelHandler: Cancellable {
  var client: ChromeClient
  var esi: EventSubscriberId

  public func cancel() {
    client.off(esi)
  }
}
