import Combine
import NIO
import Dispatch

@inlinable internal func wrap<T>(_ eventLoopFuture: EventLoopFuture<T>) -> Future<T, Error> {
  Future { consume in
    eventLoopFuture.whenComplete(consume)
  }
}

extension EventLoopFuture {
  @inlinable var wrapped: Future<Value, Error> {
    wrap(self)
  }
}

public func block<P: Publisher>(_ publisher: P) throws -> P.Output {
  let s = DispatchSemaphore(value: 0)
  var result: Result<P.Output, P.Failure>? = nil
  publisher.subscribe(Subscribers.Sink(
      receiveCompletion: { completion in
        switch completion {
          case .finished:
            s.signal()
          case .failure(let error):
            result = .failure(error)
            s.signal()
        }
      },
      receiveValue: { value in
        result = .success(value)
      }))
  s.wait()
  switch result {
    case .none:
      fatalError("empty publisher")
    case .success(let output):
      return output
    case .failure(let error):
      throw error
  }
}
