import NIO
import Combine

public enum ElementLocator {
  case css(String)
  case linkText(String)
  case partialLinkText(String)
  case tagName(String)
  case xPath(String)
}

public struct Element {
  public let session: WebDriver.Session
  public let id: String

  @discardableResult
  internal func request<R: WebDriverRequest>(request: R, params: [String: String] = [:]) -> AnyPublisher<R.Response, Error> {
    var params = params
    params["elementId"] = self.id
    return self.session.request(request: request, params: params)
  }
}

extension Element {
  public enum State: String {
    case selected
    case enabled
  }

  public enum Data: String {
    case attribute
    case property
    case css
    case text
    case tagName
    case role
    case label
  }

  public struct Rect: Codable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int
  }
}

extension Element {
  public func click() -> AnyPublisher<Void, Error> {
    self.request(request: ElementClickRequest()).map { _ in }.eraseToAnyPublisher()
  }

  public func clear() -> AnyPublisher<Void, Error> {
    self.request(request: ElementClearRequest()).map { _ in }.eraseToAnyPublisher()
  }

  public func sendKeys(_ text: String) -> AnyPublisher<Void, Error> {
    self.request(request: ElementSendKeysRequest(text: text)).map { _ in }.eraseToAnyPublisher()
  }

  public func get(_ type: Data, name: String) -> AnyPublisher<String, Error> {
    self.request(request: ElementGetDataRequest(elementData: type, name: name)).eraseToAnyPublisher()
  }

  public func `is`(_ state: State) -> AnyPublisher<Bool, Error> {
    switch state {
      case .enabled:
        return self.request(request: ElementIsEnabledRequest()).eraseToAnyPublisher()
      case .selected:
        return self.request(request: ElementIsSelectedRequest()).eraseToAnyPublisher()
    }
  }
}
