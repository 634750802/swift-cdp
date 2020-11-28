import NIO
import Combine
import NIOWebSocket



extension WebDriver {
  public class Session {
    public let id: String
    public let capabilities: ChromeCapabilities
    public let driver: WebDriver

    internal init<C: Encodable>(info: CreateSession<C>.Response, driver: WebDriver) {
      self.id = info.sessionId
      self.capabilities = info.capabilities
      self.driver = driver
    }

    deinit {
      self.closeWindow()
          .flatMap { () in
            self.request(request: DeleteSession())
          }
          .subscribe(Subscribers.Sink(receiveCompletion: { result in
            switch result {
              case .finished:
                break
              case .failure(let error):
                print(error)
            }
          }, receiveValue: { _ in }))
      print("session \(id) closed")
    }

    @discardableResult
    internal func request<R: WebDriverRequest>(request: R, params: [String: String] = [:]) -> AnyPublisher<R.Response, Error> {
      var params = params
      params["sessionId"] = self.id
      return driver.request(request: request, params: params)
    }
  }
}

extension WebDriver.Session {

  public func navigate(to url: String) -> AnyPublisher<Void, Error> {
    self.request(request: NavigationRequest(url: url)).map { _ in }.eraseToAnyPublisher()
  }

  public func getCurrentUrl() -> AnyPublisher<String, Error> {
    self.request(request: GetCurrentUrlRequest()).eraseToAnyPublisher()
  }

  public func getWindowHandle() -> AnyPublisher<WindowHandle, Error> {
    self.request(request: GetWindowHandleRequest())
        .map { handle in
          WindowHandle(session: self, id: handle)
        }
        .eraseToAnyPublisher()
  }

  public func getWindowHandles() -> AnyPublisher<[WindowHandle], Error> {
    self.request(request: GetWindowHandlesRequest())
        .map { handles in
          handles.map { handle in WindowHandle(session: self, id: handle) }
        }
        .eraseToAnyPublisher()
  }

  public func closeWindow() -> AnyPublisher<Void, Error> {
    self.request(request: CloseWindowRequest()).map { _ in }.eraseToAnyPublisher()
  }

  public func getRect() -> AnyPublisher<WindowHandle.Rect, Error> {
    self.request(request: GetWindowRectRequest()).eraseToAnyPublisher()
  }

  public func set(rect: WindowHandle.Rect) -> AnyPublisher<WindowHandle.Rect, Error> {
    self.request(request: SetWindowRectRequest(rect)).eraseToAnyPublisher()
  }

  public func set(state: WindowHandle.State) -> AnyPublisher<WindowHandle.Rect, Error> {
    self.request(request: SetWindowStateRequest(state: state)).eraseToAnyPublisher()
  }

  public func `switch`(to windowHandle: WindowHandle) -> AnyPublisher<Void, Error> {
    self.request(request: SwitchWindowRequest(handle: windowHandle.id)).map { _ in }.eraseToAnyPublisher()
  }

  public func findElement(by elementLocator: ElementLocator) -> AnyPublisher<Element, Error> {
    self.request(request: GetElementRequest(elementLocator: elementLocator))
        .map { dict in Element(session: self, id: dict.values.first!) }
        .eraseToAnyPublisher()
  }

}
