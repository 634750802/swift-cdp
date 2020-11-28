import Foundation
import NIO
import WebSocketClient
import Combine


public class ChromeClient {
  private let client: WebSocketClient
  private var cancellable: AnyCancellable = AnyCancellable {}
  private var jsonEncoder = JSONEncoder()
  private var jsonDecoder = JSONDecoder()
  private var idSeq: Int = 0
  private var promises: [Int: EventLoopPromise<Data>] = [:]
  private var eventHandlers: [String: PassthroughSubject<Data, Error>] = [:]
  private var cancellableMap: [ObjectIdentifier: AnyCancellable] = [:]
  private var schedulerQueue = DispatchQueue(label: "WebSocketClient.Scheduler")

  public init(client: WebSocketClient) {
    self.client = client
    cancellable = self.client
        .subscribe()
        .sink(receiveCompletion: { completion in }, receiveValue: { data in
          do {
            print("read: \(String(data: data, encoding: .utf8) ?? data.description)")
            let commonPart = try self.jsonDecoder.decode(ChromeDevtoolsWebsocketResponseCommonPart.self, from: data)
            if let id = commonPart.id {
              self.triggerResponse(.method(id: id, body: data))
            } else if let method = commonPart.method {
              self.triggerResponse(.event(method: method, body: data))
            } else {
              self.triggerResponse(.unknown(body: data))
            }
          } catch {
            print(error)
          }
        })
  }

  deinit {
    cancellable.cancel()
    cancellableMap.values.forEach { $0.cancel() }
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
  public func on<M: ModelEvent>(_ handler: @escaping (M) -> Void) -> AnyCancellable {
    let id = schedulerQueue.sync { () -> EventSubscriberId in
      var s: AnyCancellable? = nil
      var subject: PassthroughSubject<Data, Error>!
      if let _subject = self.eventHandlers[M.name] {
        subject = _subject
      } else {
        subject = PassthroughSubject()
        var count = 0
        var anyCancellable: AnyCancellable? = nil
        anyCancellable = subject
            .handleEvents(
                receiveSubscription: { _ in count += 1 },
                receiveCancel: {
                  count -= 1
                  if count == 0 {
                    self.eventHandlers[M.name] = nil
                    subject = nil
                  }
                })
            .sink(
                receiveCompletion: { _ in
                  anyCancellable?.cancel()
                  anyCancellable = nil
                },
                receiveValue: { _ in })
        eventHandlers[M.name] = subject
      }
      s = subject.receive(on: self.schedulerQueue).sink(receiveCompletion: { _ in }, receiveValue: { [weak self] input in
        do {
          if let value = try self?.jsonDecoder.decode(ChromeDevtoolsWebsocketEventResponse<M>.self, from: input) {
            handler(value.params)
          } else {
            s?.cancel()
          }
        } catch {
          print("Error: failed to process event \(M.name) with data \(String(data: input, encoding: .utf8) ?? "<DATA:\(input.count)>")")
        }
      })
      if let s = s {
        let oi = ObjectIdentifier(s)
        cancellableMap[oi] = s
        return EventSubscriberId(objectId: oi)
      } else {
        return EventSubscriberId()
      }
    }

    return AnyCancellable {
      self.off(id)
    }
  }

  internal func off(_ esi: EventSubscriberId) {
    schedulerQueue.sync {
      if let oi = esi.objectId {
        cancellableMap[oi]?.cancel()
        cancellableMap[oi] = nil
      }
    }
  }

  fileprivate func triggerResponse(_ resp: ChromeDevtoolsWebsocketResponse) {
    schedulerQueue.sync {
      switch resp {
        case .method(let id, let body):
          promises[id]?.succeed(body)
          promises[id] = nil
        case .event(let method, let body):
          eventHandlers[method]?.send(body)
        case .unknown(let body):
          print("unknown \(String(data: body, encoding: .utf8) ?? "<Unknown data>")")
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
  fileprivate var objectId: ObjectIdentifier?

  fileprivate init(objectId: ObjectIdentifier? = nil) { self.objectId = objectId }
}
