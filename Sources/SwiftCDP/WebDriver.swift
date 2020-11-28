//
// Created by 高林杰 on 2020/11/20.
//

import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient
import Combine
import Dispatch

public class WebDriver {
  private var process: Process?
  private var port = 9515
  private var client: HTTPClient
  public let queue: DispatchQueue
  private var jsonEncoder = JSONEncoder()
  private var jsonDecoder = JSONDecoder()

  public init(queue: DispatchQueue = DispatchQueue(label: "webdriver", attributes: [DispatchQueue.Attributes.concurrent])) {
    self.client = HTTPClient(eventLoopGroupProvider: .createNew)
    self.queue = queue
  }

  public func startChromeProcess() throws {
    self.process = try Process.run(URL(string: "file:///Users/jagger/CLionProjects/ChromeDevtoolProtocol/chromedriver")!, arguments: [])
  }

  public func wait() throws {
    self.process?.waitUntilExit()
  }

  @discardableResult
  internal func request<R: WebDriverRequest>(request: R, params: [String: String] = [:]) -> AnyPublisher<R.Response, Error> {
    let urlString = "http://127.0.0.1:9515\(R.url(params))"
    let url = request.extend(url: URL(string: urlString)!)
    if R.Request.self != NoBody.self {
      print("\(R.method) \(url) \(String(data: try! jsonEncoder.encode(request.body), encoding: .utf8)!)")
    } else {
      print("\(R.method) \(url)")
    }
    let httpRequest = R.Request.self != NoBody.self
                      ? try! HTTPClient.Request(url: url, method: R.method, body: HTTPClient.Body.data(jsonEncoder.encode(request.body)))
                      : try! HTTPClient.Request(url: url, method: R.method, body: R.method == .POST ? HTTPClient.Body.data("{}".data(using: .ascii)!) : nil)
    return client
        .execute(request: httpRequest)
        .flatMap { response in
          print(String(data: Data(buffer: response.body!), encoding: .utf8)!)
          if (response.status.code < 400) {
            return self.client.eventLoopGroup.next().makeSucceededFuture(try! self.jsonDecoder.decode(CommonResponse<R.Response>.self, from: response.body!).value)
          } else {
            let errorResponse = try! self.jsonDecoder.decode(CommonResponse<BadResponse>.self, from: response.body!).value
            return self.client.eventLoopGroup.next().makeFailedFuture(StringError(error: errorResponse.error, message: errorResponse.message, stackTrace: errorResponse.stacktrace).print())
          }
        }
        .wrapped
        .receive(on: self.queue)
        .eraseToAnyPublisher()
  }

  internal func debugRequest(url: String) -> AnyPublisher<String, Error> {
    let urlString = "http://127.0.0.1:9222\(url)"
    return self.client.get(url: urlString)
                      .map { response in
                        String(data: Data(buffer: response.body!), encoding: .utf8)!
                      }.wrapped.eraseToAnyPublisher()
  }

}

extension WebDriver {

  public func createSession<C: Encodable>(_ request: CreateSession<C>) -> AnyPublisher<Session, Error> {
    self.request(request: request).map { response in
      Session(info: response, driver: self)
    }.eraseToAnyPublisher()
  }

  public func status() -> AnyPublisher<StatusSession.Response, Error> {
    self.request(request: StatusSession()).eraseToAnyPublisher()
  }

}

public struct StringError: Error {
  let error: String
  let message: String
  let stackTrace: String?

  public func print() -> Self {
    if let s = stackTrace {
      Swift.print("Error: \(message)\n\(s.split(separator: "\n").map { "\t\($0)" }.joined(separator: "\n"))")
    } else {
      Swift.print("Error: \(message)")
    }
    return self
  }
}
