import NIO
import Combine

extension WebDriver.Session {
  public struct WindowHandle {
    public let session: WebDriver.Session
    public let id: String

    internal init(session: WebDriver.Session, id: String) {
      self.session = session
      self.id = id
    }
  }
}

extension WebDriver.Session.WindowHandle {
  public func close() -> AnyPublisher<Void, Error> {
    session.switch(to: self)
           .flatMap { session.closeWindow() }
           .eraseToAnyPublisher()
  }

  public func getRect() -> AnyPublisher<Rect, Error> {
    session.switch(to: self)
           .flatMap { session.getRect() }
           .eraseToAnyPublisher()
  }

  public func set(rect: Rect) -> AnyPublisher<Rect, Error> {
    session.switch(to: self)
           .flatMap { session.set(rect: rect) }
           .eraseToAnyPublisher()
  }

  public func set(state: State) -> AnyPublisher<Rect, Error> {
    session.switch(to: self)
           .flatMap { session.set(state: state) }
           .eraseToAnyPublisher()
  }
}

extension WebDriver.Session.WindowHandle {
  public struct Rect: Codable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int
  }

  public enum State: String, Codable {
    case maximized = "maximize"
    case minimized = "minimize"
    case normal
    case fullscreen = "fullscreen"
  }
}
