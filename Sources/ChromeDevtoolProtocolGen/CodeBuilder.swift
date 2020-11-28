func escape(_ str: String, char: Character) -> String {
  str.split(separator: char).joined(separator: "\\\(char)")
}

public class CodeBuilder {
  public var lines: [String] = []

  public var currentIndent: Int = 0
  public var indentString = "  "

  public init() {
  }

  public func indent(_ block: () -> Void) {
    currentIndent += 1
    block()
    currentIndent -= 1
  }

  public func deprecated(_ reason: String? = nil) {
    if let reason = reason {
      self << "@available(*, deprecated, message: \"\(escape(reason, char: "\"")))\""
    } else {
      self << "@available(*, deprecated)"
    }
  }

  public func `import`(_ package: String) {
    self << "import \(package)"
  }

  public func comment(_ multiline: String, prefix: String = "") {
    var prefix = prefix
    for line in multiline.split(separator: "\n") {
      self << "/// \(prefix)\(line)"
      prefix = ""
    }
  }

  public func block(_ prefix: String, block: () -> Void) {
    self << (prefix + "{")
    self.indent(block)
    self << "}"
  }

  public static func <<(cb: CodeBuilder, string: String) {
    cb.lines.append(repeatElement(cb.indentString, count: cb.currentIndent).joined(separator: "") + string)
  }

  public func build() -> String {
    lines.joined(separator: "\n")
  }
}

extension CodeBuilder {
  public static let keywords: Set<String> = ["protocol", "class"]

  public static func escapeKeyword(name: String) -> String {
    if keywords.contains(name) {
      return "`\(name)`"
    } else {
      return name
    }
  }
}
