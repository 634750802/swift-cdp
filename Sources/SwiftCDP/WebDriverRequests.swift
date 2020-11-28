import Foundation
import NIOHTTP1

public protocol WebDriverRequest {
  associatedtype Request: Encodable = NoBody
  associatedtype Response: Decodable = NoBody
  static func url(_ params: [String: String]) -> String
  static var method: HTTPMethod { get }

  func extend(url: URL) -> URL
  var body: Request { get }
}

public struct NoBody: Codable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encodeNil()
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if !container.decodeNil() {
      throw DecodingError.typeMismatch(NoBody.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Value should be null."))
    }
  }

  public init() {}
}

public extension WebDriverRequest where Self.Request == NoBody {
  var body: Request {
    NoBody()
  }
}

public extension WebDriverRequest where Self.Request == Self {
  var body: Request {
    self
  }
}

public extension WebDriverRequest {
  func extend(url: URL) -> URL {
    url
  }
}

public struct CommonResponse<T: Decodable>: Decodable {
  var value: T
}

public struct BadResponse: Decodable {
  var error: String
  var message: String
  var stacktrace: String?
}

public struct CreateSession<Capabilities: Encodable>: WebDriverRequest, Encodable {
  public static var method: HTTPMethod {
    .POST
  }

  public static func url(_: [String: String]) -> String {
    "/session"
  }

  public typealias Request = Self

  public struct Response: Decodable {
    public var capabilities: ChromeCapabilities
    public var sessionId: String
  }

  public var user: String
  public var password: String?
  public var capabilities: Capabilities

}

public struct DeleteSession: WebDriverRequest {
  public static var method: HTTPMethod = .DELETE

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")"
  }

  public struct Response: Decodable {}
}

public struct StatusSession: WebDriverRequest {
  public static var method: HTTPMethod = .GET

  public static func url(_: [String: String]) -> String {
    "/status"
  }

  public struct Response: Decodable {
    public let ready: Bool
    public let message: String
  }

}

public struct ChromeSessionTimeout: Decodable {
  var implicit: Int
  var pageLoad: Int
  var script: Int
}


public struct ChromeCapabilities: Decodable {
  var acceptInsecureCerts: Bool
  var browserName: String
  var browserVersion: String
  var chrome: Info
  var chromeOptions: Options
  var networkConnectionEnabled: Bool
  var pageLoadStrategy: String
  var platformName: String
  var proxy: Proxy
  var setWindowRect: Bool
  var strictFileInteractability: Bool
  var timeouts: ChromeSessionTimeout
  var unhandledPromptBehavior: String
  var virtualAuthenticators: Bool

  public enum CodingKeys: String, CodingKey {
    case acceptInsecureCerts = "acceptInsecureCerts"
    case browserName = "browserName"
    case browserVersion = "browserVersion"
    case chrome = "chrome"
    case chromeOptions = "goog:chromeOptions"
    case networkConnectionEnabled = "networkConnectionEnabled"
    case pageLoadStrategy = "pageLoadStrategy"
    case platformName = "platformName"
    case proxy = "proxy"
    case setWindowRect = "setWindowRect"
    case strictFileInteractability = "strictFileInteractability"
    case timeouts = "timeouts"
    case unhandledPromptBehavior = "unhandledPromptBehavior"
    case virtualAuthenticators = "webauthn:virtualAuthenticators"
  }
}

extension ChromeCapabilities {
  public struct Info: Decodable {
    var chromedriverVersion: String
    var userDataDir: String
  }

  public struct Options: Decodable {
    var debuggerAddress: String
  }

  public struct Proxy: Decodable {
  }
}

public struct NavigationRequest: Encodable, WebDriverRequest {
  public static let method: HTTPMethod = .POST

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/url"
  }

  public typealias Request = Self

  public var url: String
}

public struct GetCurrentUrlRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/url"
  }

  public typealias Response = String
}

public struct GetWindowHandleRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/window"
  }

  public typealias Response = String
}

public struct GetWindowHandlesRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/window/handles"
  }

  public typealias Response = [String]
}

public struct CloseWindowRequest: WebDriverRequest {
  public static let method: HTTPMethod = .DELETE

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/window"
  }

  public typealias Response = [String]
}

public struct SwitchWindowRequest: Encodable, WebDriverRequest {
  public static let method: HTTPMethod = .POST

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/window"
  }

  public typealias Request = Self

  public let handle: String
}

public struct GetWindowRectRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/window/rect"
  }

  public typealias Response = WebDriver.Session.WindowHandle.Rect
}

public struct SetWindowRectRequest: WebDriverRequest {

  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/window/rect"
  }

  public var body: WebDriver.Session.WindowHandle.Rect {
    rect
  }

  public typealias Response = WebDriver.Session.WindowHandle.Rect

  public let rect: WebDriver.Session.WindowHandle.Rect

  public init(_ rect: WebDriver.Session.WindowHandle.Rect) {
    self.rect = rect
  }
}

public struct SetWindowStateRequest: WebDriverRequest {
  public static let method: HTTPMethod = .POST

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/window"
  }

  public func extend(url: URL) -> URL {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      fatalError("bad url \(url)")
    }
    if components.path.last == "/" {
      components.path.removeLast()
    }
    components.path += "/\(self.state.rawValue)"
    return components.url!
  }

  public typealias Response = WebDriver.Session.WindowHandle.Rect

  public var state: WebDriver.Session.WindowHandle.State

  public init(state: WebDriver.Session.WindowHandle.State) {
    assert(state != .normal)
    self.state = state
  }
}

public struct GetElementRequest: WebDriverRequest, Encodable {
  public static let method: HTTPMethod = .POST

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element"
  }

  public typealias Request = Self
  public typealias Response = [String: String]

  public let elementLocator: ElementLocator

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: Key.self)
    switch elementLocator {
      case .css(let value):
        try container.encode("css selector", forKey: .using)
        try container.encode(value, forKey: .value)
      case .linkText(let value):
        try container.encode("link text", forKey: .using)
        try container.encode(value, forKey: .value)
      case .partialLinkText(let value):
        try container.encode("partial link text", forKey: .using)
        try container.encode(value, forKey: .value)
      case .tagName(let value):
        try container.encode("tag name", forKey: .using)
        try container.encode(value, forKey: .value)
      case .xPath(let value):
        try container.encode("xpath", forKey: .using)
        try container.encode(value, forKey: .value)
    }
  }

  public enum Key: CodingKey {
    case using
    case value
  }
}

public struct ElementClickRequest: WebDriverRequest {
  public static let method: HTTPMethod = .POST

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element/\(params["elementId"] ?? "???")/click"
  }
}


public struct ElementClearRequest: WebDriverRequest {
  public static let method: HTTPMethod = .POST

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element/\(params["elementId"] ?? "???")/clear"
  }
}

public struct ElementSendKeysRequest: WebDriverRequest, Codable {
  public static let method: HTTPMethod = .POST

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element/\(params["elementId"] ?? "???")/value"
  }

  public typealias Request = Self

  public let text: String
}

public struct ElementIsSelectedRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element/\(params["elementId"] ?? "???")/selected"
  }

  public typealias Response = Bool
}

public struct ElementIsEnabledRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element/\(params["elementId"] ?? "???")/enabled"
  }

  public typealias Response = Bool
}

public struct ElementGetDataRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element/\(params["elementId"] ?? "???")/"
  }

  public func extend(url: URL) -> URL {
    guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
      fatalError("bad url \(url)")
    }
    if components.path.last == "/" {
      components.path.removeLast()
    }
    components.path += "/\(self.elementData.rawValue)/\(self.name)"
    return components.url!
  }

  public typealias Response = String

  public let elementData: Element.Data
  public let name: String
}

public struct ElementRectRequest: WebDriverRequest {
  public static let method: HTTPMethod = .GET

  public static func url(_ params: [String: String]) -> String {
    "/session/\(params["sessionId"] ?? "???")/element/\(params["elementId"] ?? "???")/rect"
  }

  public typealias Response = Element.Rect
}
